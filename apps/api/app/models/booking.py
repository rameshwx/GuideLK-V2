from __future__ import annotations

from datetime import date

from typing import TYPE_CHECKING, Optional

from sqlalchemy import Enum, ForeignKey, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin
from .enums import BookingSource


if TYPE_CHECKING:  # pragma: no cover - imported for typing only
    from .property import PartnerProperty
    from .trip import Trip


class Booking(Base, TimestampMixin):
    __tablename__ = "bookings"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    trip_id: Mapped[int] = mapped_column(ForeignKey("trips.id", ondelete="CASCADE"), nullable=False)
    stay_id: Mapped[int | None] = mapped_column(ForeignKey("properties.id"))
    check_in: Mapped[date | None]
    check_out: Mapped[date | None]
    source: Mapped[BookingSource] = mapped_column(
        Enum(BookingSource, values_callable=lambda enum_cls: [item.value for item in enum_cls]),
        default=BookingSource.MANUAL,
    )
    raw_json: Mapped[dict | None] = mapped_column(JSON)

    trip: Mapped["Trip"] = relationship()
    stay: Mapped[Optional["PartnerProperty"]] = relationship()
