from __future__ import annotations

from typing import Any

from sqlalchemy import func
from sqlalchemy.dialects.mysql import DOUBLE, GEOMETRY
from sqlalchemy.orm import Mapped, mapped_column


class SpatialPointMixin:
    geom: Mapped[Any] = mapped_column(
        GEOMETRY(geometry_type="POINT", srid=4326), nullable=False, comment="WGS84 point"
    )
    latitude: Mapped[float] = mapped_column(DOUBLE(asdecimal=False), nullable=False)
    longitude: Mapped[float] = mapped_column(DOUBLE(asdecimal=False), nullable=False)

    @staticmethod
    def build_point(longitude: float, latitude: float) -> Any:
        return func.ST_SRID(func.ST_Point(longitude, latitude), 4326)
