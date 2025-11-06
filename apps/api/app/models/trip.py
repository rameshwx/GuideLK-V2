from __future__ import annotations

from datetime import date
from typing import TYPE_CHECKING, Optional

from sqlalchemy import CheckConstraint, Enum, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base, TimestampMixin
from .enums import TripStatus, TripStopKind, TripStopStatus


if TYPE_CHECKING:  # pragma: no cover - typing helpers
    from .poi import PointOfInterest
    from .property import PartnerProperty
    from .user import User


class Trip(Base, TimestampMixin):
    __tablename__ = "trips"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    start_date: Mapped[date | None]
    end_date: Mapped[date | None]
    status: Mapped[TripStatus] = mapped_column(
        Enum(TripStatus, values_callable=lambda enum_cls: [item.value for item in enum_cls]),
        default=TripStatus.DRAFT,
        nullable=False,
    )

    user: Mapped["User"] = relationship(back_populates="trips")
    stops: Mapped[list["TripStop"]] = relationship(
        back_populates="trip", cascade="all, delete-orphan", order_by="TripStop.sort"
    )


class TripStop(Base, TimestampMixin):
    __tablename__ = "trip_stops"
    __table_args__ = (
        CheckConstraint("kind in ('poi','stay')", name="trip_stop_kind_valid"),
        CheckConstraint(
            "status in ('planned','visited','skipped')",
            name="trip_stop_status_valid",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    trip_id: Mapped[int] = mapped_column(ForeignKey("trips.id", ondelete="CASCADE"), nullable=False)
    kind: Mapped[TripStopKind] = mapped_column(
        Enum(TripStopKind, values_callable=lambda enum_cls: [item.value for item in enum_cls]),
        nullable=False,
    )
    poi_id: Mapped[int | None] = mapped_column(ForeignKey("pois.id"))
    stay_id: Mapped[int | None] = mapped_column(ForeignKey("properties.id"))
    day_index: Mapped[int] = mapped_column(Integer, default=0)
    sort: Mapped[int] = mapped_column(Integer, default=0)
    status: Mapped[TripStopStatus] = mapped_column(
        Enum(TripStopStatus, values_callable=lambda enum_cls: [item.value for item in enum_cls]),
        default=TripStopStatus.PLANNED,
        nullable=False,
    )

    trip: Mapped["Trip"] = relationship(back_populates="stops")
    poi: Mapped[Optional["PointOfInterest"]] = relationship()
    stay: Mapped[Optional["PartnerProperty"]] = relationship()
