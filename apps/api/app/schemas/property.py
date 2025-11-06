from typing import Sequence

from pydantic import BaseModel, Field

from .base import TimestampedModel


class PropertyAttributes(BaseModel):
    name: str
    address: str | None = None
    phone: str | None = None
    website: str | None = None
    photos: Sequence[str] = ()
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    is_published: bool = False


class PropertyCreate(PropertyAttributes):
    pass


class PropertyUpdate(BaseModel):
    name: str | None = None
    address: str | None = None
    phone: str | None = None
    website: str | None = None
    photos: Sequence[str] | None = None
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    is_published: bool | None = None


class PropertyRead(TimestampedModel, PropertyAttributes):
    id: int
