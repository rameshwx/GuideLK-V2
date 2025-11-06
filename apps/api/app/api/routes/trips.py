from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel

from ...dependencies import get_current_user, get_trip_repository
from ...models import Trip, TripStop, User
from ...models.enums import TripStopStatus
from ...repositories.trip import TripRepository
from ...schemas.trip import (
    BookingCreate,
    BookingRead,
    TripCreate,
    TripRead,
    TripStopCreate,
    TripStopRead,
    TripStopUpdate,
    TripUpdate,
)

router = APIRouter(prefix="/trips", tags=["trips"])


class ReorderPayload(BaseModel):
    stop_ids: list[int]


class MarkStopPayload(BaseModel):
    status: TripStopStatus


@router.get("/", response_model=list[TripRead])
def list_trips(
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trips = repository.for_user(current_user.id)
    return [TripRead.model_validate(trip) for trip in trips]


@router.post("/", response_model=TripRead, status_code=status.HTTP_201_CREATED)
def create_trip(
    payload: TripCreate,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.create(current_user.id, payload)
    return TripRead.model_validate(trip)


@router.get("/{trip_id}", response_model=TripRead)
def get_trip(
    trip_id: int,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.get(trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    return TripRead.model_validate(trip)


@router.patch("/{trip_id}", response_model=TripRead)
def update_trip(
    trip_id: int,
    payload: TripUpdate,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.get(trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    updated = repository.update(trip, payload)
    return TripRead.model_validate(updated)


@router.delete("/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_trip(
    trip_id: int,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.get(trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    repository.delete(trip)
    return None


@router.post("/{trip_id}/stops", response_model=TripStopRead, status_code=status.HTTP_201_CREATED)
def create_stop(
    trip_id: int,
    payload: TripStopCreate,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.get(trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    stop = repository.add_stop(trip, payload)
    return TripStopRead.model_validate(stop)


@router.patch("/{trip_id}/stops/{stop_id}", response_model=TripStopRead)
def update_stop(
    trip_id: int,
    stop_id: int,
    payload: TripStopUpdate,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.get(trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    stop = next((s for s in trip.stops if s.id == stop_id), None)
    if not stop:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Stop not found")
    updated = repository.update_stop(stop, payload)
    return TripStopRead.model_validate(updated)


@router.delete("/{trip_id}/stops/{stop_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_stop(
    trip_id: int,
    stop_id: int,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.get(trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    stop = next((s for s in trip.stops if s.id == stop_id), None)
    if not stop:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Stop not found")
    trip.stops.remove(stop)
    repository.remove_stop(stop)
    return None


@router.post("/{trip_id}/stops/reorder", response_model=TripRead)
def reorder_stops(
    trip_id: int,
    payload: ReorderPayload,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.get(trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    updated = repository.reorder_stops(trip, payload.stop_ids)
    return TripRead.model_validate(updated)


@router.post("/stops/{stop_id}/mark", response_model=TripStopRead)
def mark_stop(
    stop_id: int,
    payload: MarkStopPayload,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    # We expect to locate the stop across trips owned by the user
    for trip in repository.for_user(current_user.id):
        stop = next((s for s in trip.stops if s.id == stop_id), None)
        if stop:
            updated = repository.mark_stop_status(stop, payload.status)
            return TripStopRead.model_validate(updated)
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Stop not found")


@router.post("/{trip_id}/bookings", response_model=BookingRead, status_code=status.HTTP_201_CREATED)
def create_booking(
    trip_id: int,
    payload: BookingCreate,
    current_user: User = Depends(get_current_user),
    repository: TripRepository = Depends(get_trip_repository),
):
    trip = repository.get(trip_id)
    if not trip or trip.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")
    booking = repository.add_booking(payload.model_copy(update={"trip_id": trip_id}))
    return BookingRead.model_validate(booking)
