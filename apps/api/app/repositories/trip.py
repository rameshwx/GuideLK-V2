from __future__ import annotations

from collections.abc import Iterable

from sqlalchemy import Select, select
from sqlalchemy.orm import Session

from ..models import Booking, Trip, TripStop
from ..models.enums import TripStopStatus
from ..schemas.trip import (
    BookingCreate,
    TripCreate,
    TripStopCreate,
    TripStopUpdate,
    TripUpdate,
)


class TripRepository:
    def __init__(self, db: Session):
        self.db = db

    def query(self) -> Select[tuple[Trip]]:
        return select(Trip).order_by(Trip.created_at.desc())

    def for_user(self, user_id: int) -> list[Trip]:
        return self.db.scalars(self.query().where(Trip.user_id == user_id)).all()

    def get(self, trip_id: int) -> Trip | None:
        return self.db.get(Trip, trip_id)

    def create(self, user_id: int, payload: TripCreate) -> Trip:
        trip = Trip(
            user_id=user_id,
            name=payload.name,
            start_date=payload.start_date,
            end_date=payload.end_date,
            status=payload.status,
        )
        self.db.add(trip)
        self.db.flush()
        for index, stop in enumerate(payload.stops):
            trip.stops.append(self._build_stop(stop, index))
        self.db.commit()
        self.db.refresh(trip)
        return trip

    def update(self, trip: Trip, payload: TripUpdate) -> Trip:
        if payload.name is not None:
            trip.name = payload.name
        if payload.start_date is not None:
            trip.start_date = payload.start_date
        if payload.end_date is not None:
            trip.end_date = payload.end_date
        if payload.status is not None:
            trip.status = payload.status
        if payload.stops is not None:
            trip.stops.clear()
            for index, stop in enumerate(payload.stops):
                trip.stops.append(self._build_stop(stop, index))
        self.db.add(trip)
        self.db.commit()
        self.db.refresh(trip)
        return trip

    def delete(self, trip: Trip) -> None:
        self.db.delete(trip)
        self.db.commit()

    def add_stop(self, trip: Trip, payload: TripStopCreate) -> TripStop:
        stop = self._build_stop(payload, len(trip.stops))
        trip.stops.append(stop)
        self.db.add(trip)
        self.db.commit()
        self.db.refresh(stop)
        return stop

    def update_stop(self, stop: TripStop, payload: TripStopUpdate) -> TripStop:
        if payload.kind is not None:
            stop.kind = payload.kind
        if payload.poi_id is not None:
            stop.poi_id = payload.poi_id
        if payload.stay_id is not None:
            stop.stay_id = payload.stay_id
        if payload.day_index is not None:
            stop.day_index = payload.day_index
        if payload.sort is not None:
            stop.sort = payload.sort
        if payload.status is not None:
            stop.status = payload.status
        self.db.add(stop)
        self.db.commit()
        self.db.refresh(stop)
        return stop

    def mark_stop_status(self, stop: TripStop, status: TripStopStatus) -> TripStop:
        stop.status = status
        self.db.add(stop)
        self.db.commit()
        self.db.refresh(stop)
        return stop


    def remove_stop(self, stop: TripStop) -> None:
        self.db.delete(stop)
        self.db.commit()

    def reorder_stops(self, trip: Trip, stop_ids: Iterable[int]) -> Trip:
        order_map = {stop_id: index for index, stop_id in enumerate(stop_ids)}
        for stop in trip.stops:
            if stop.id in order_map:
                stop.sort = order_map[stop.id]
        trip.stops.sort(key=lambda stop: stop.sort)
        self.db.add(trip)
        self.db.commit()
        self.db.refresh(trip)
        return trip

    def _build_stop(self, payload: TripStopCreate, index: int) -> TripStop:
        return TripStop(
            kind=payload.kind,
            poi_id=payload.poi_id,
            stay_id=payload.stay_id,
            day_index=payload.day_index,
            sort=payload.sort if payload.sort else index,
            status=payload.status,
        )

    # Booking helpers -----------------------------------------------------

    def add_booking(self, payload: BookingCreate) -> Booking:
        booking = Booking(
            trip_id=payload.trip_id,
            stay_id=payload.stay_id,
            check_in=payload.check_in,
            check_out=payload.check_out,
            source=payload.source,
            raw_json=payload.raw_json,
        )
        self.db.add(booking)
        self.db.commit()
        self.db.refresh(booking)
        return booking

    def list_bookings(self, trip_id: int) -> list[Booking]:
        stmt = select(Booking).where(Booking.trip_id == trip_id).order_by(Booking.check_in)
        return self.db.scalars(stmt).all()

    def delete_booking(self, booking: Booking) -> None:
        self.db.delete(booking)
        self.db.commit()
