from __future__ import annotations

from sqlalchemy import Boolean, JSON, String
from sqlalchemy.orm import Mapped, mapped_column

from .base import Base, TimestampMixin
from .spatial import SpatialPointMixin


class PartnerProperty(Base, TimestampMixin, SpatialPointMixin):
    __tablename__ = "properties"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    address: Mapped[str | None] = mapped_column(String(512))
    phone: Mapped[str | None] = mapped_column(String(64))
    website: Mapped[str | None] = mapped_column(String(255))
    photos: Mapped[list[str]] = mapped_column(JSON, default=list)
    is_published: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
