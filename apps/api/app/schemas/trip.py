from __future__ import annotations

from datetime import date
from typing import Sequence

from pydantic import BaseModel, Field

from ..models.enums import BookingSource, TripStatus, TripStopKind, TripStopStatus
from .base import TimestampedModel
from .poi import POIRead
from .property import PropertyRead


class TripStopBase(BaseModel):
    kind: TripStopKind
    poi_id: int | None = None
    stay_id: int | None = None
    day_index: int = Field(ge=0, default=0)
    sort: int = Field(ge=0, default=0)
    status: TripStopStatus = TripStopStatus.PLANNED


class TripStopCreate(TripStopBase):
    pass


class TripStopUpdate(BaseModel):
    kind: TripStopKind | None = None
    poi_id: int | None = None
    stay_id: int | None = None
    day_index: int | None = Field(default=None, ge=0)
    sort: int | None = Field(default=None, ge=0)
    status: TripStopStatus | None = None


class TripStopRead(TimestampedModel, TripStopBase):
    id: int
    poi: POIRead | None = None
    stay: PropertyRead | None = None


class TripBase(BaseModel):
    name: str
    start_date: date | None = None
    end_date: date | None = None
    status: TripStatus = TripStatus.DRAFT


class TripCreate(TripBase):
    stops: Sequence[TripStopCreate] = ()


class TripUpdate(BaseModel):
    name: str | None = None
    start_date: date | None = None
    end_date: date | None = None
    status: TripStatus | None = None
    stops: Sequence[TripStopCreate] | None = None


class TripRead(TimestampedModel, TripBase):
    id: int
    user_id: int
    stops: list[TripStopRead] = []


class BookingBase(BaseModel):
    stay_id: int | None = None
    check_in: date | None = None
    check_out: date | None = None
    source: BookingSource = BookingSource.MANUAL
    raw_json: dict | None = None


class BookingCreate(BookingBase):
    trip_id: int


class BookingRead(TimestampedModel, BookingBase):
    id: int
    trip_id: int
