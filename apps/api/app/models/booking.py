from __future__ import annotations

from datetime import date

from sqlalchemy import Enum, ForeignKey, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin
from .enums import BookingSource


class Booking(Base, TimestampMixin):
    __tablename__ = "bookings"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    trip_id: Mapped[int] = mapped_column(ForeignKey("trips.id", ondelete="CASCADE"), nullable=False)
    stay_id: Mapped[int | None] = mapped_column(ForeignKey("properties.id"))
    check_in: Mapped[date | None]
    check_out: Mapped[date | None]
    source: Mapped[BookingSource] = mapped_column(Enum(BookingSource), default=BookingSource.MANUAL)
    raw_json: Mapped[dict | None] = mapped_column(JSON)

    trip: Mapped["Trip"] = relationship()
    stay: Mapped["PartnerProperty" | None] = relationship()
