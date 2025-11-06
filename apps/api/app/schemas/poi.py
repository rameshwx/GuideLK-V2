from typing import Sequence

from pydantic import BaseModel, Field

from .base import TimestampedModel


class POIAttributes(BaseModel):
    name: str
    category: str
    description: str | None = None
    photos: Sequence[str] = ()
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    is_published: bool = False


class POICreate(POIAttributes):
    pass


class POIUpdate(BaseModel):
    name: str | None = None
    category: str | None = None
    description: str | None = None
    photos: Sequence[str] | None = None
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    is_published: bool | None = None


class POIRead(TimestampedModel, POIAttributes):
    id: int
