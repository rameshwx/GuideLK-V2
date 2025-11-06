from __future__ import annotations

from typing import Any

from sqlalchemy import func
from sqlalchemy.dialects.mysql import DOUBLE
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.types import String, TypeDecorator, UserDefinedType


class MySQLGeometry(UserDefinedType):
    def get_col_spec(self, **kw):  # type: ignore[override]
        return "GEOMETRY SRID 4326"


class GeometryPoint(TypeDecorator[Any]):
    """Geometry column that downgrades to text when the dialect lacks spatial types."""

    impl = String(255)
    cache_ok = True

    def load_dialect_impl(self, dialect):  # type: ignore[override]
        if dialect.name == "mysql":
            return MySQLGeometry()
        return dialect.type_descriptor(String(255))


class SpatialPointMixin:
    geom: Mapped[Any] = mapped_column(
        GeometryPoint(), nullable=False, comment="WGS84 point stored as GEOMETRY or text"
    )
    latitude: Mapped[float] = mapped_column(DOUBLE(asdecimal=False), nullable=False)
    longitude: Mapped[float] = mapped_column(DOUBLE(asdecimal=False), nullable=False)

    @staticmethod
    def build_point(longitude: float, latitude: float, dialect: str | None = None) -> Any:
        if dialect == "mysql":
            return func.ST_SRID(func.ST_Point(longitude, latitude), 4326)
        # Persist a simple "lon,lat" text representation for lightweight stores (e.g. tests)
        return f"{longitude},{latitude}"

    @staticmethod
    def parse_point(value: Any) -> tuple[float, float] | None:
        if value is None:
            return None
        if isinstance(value, str) and "," in value:
            lon, lat = value.split(",", maxsplit=1)
            return float(lon), float(lat)
        return None
