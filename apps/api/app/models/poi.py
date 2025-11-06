from __future__ import annotations

from sqlalchemy import Boolean, JSON, String
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base, TimestampMixin
from .spatial import SpatialPointMixin


class PointOfInterest(Base, TimestampMixin, SpatialPointMixin):
    __tablename__ = "pois"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    category: Mapped[str] = mapped_column(String(128), nullable=False)
    description: Mapped[str | None] = mapped_column(String(2048))
    photos: Mapped[list[str]] = mapped_column(JSON, default=list)
    is_published: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
