from __future__ import annotations

from collections.abc import Sequence
from typing import Optional

from sqlalchemy import Select, func, select
from sqlalchemy.orm import Session

from ..models.property import PartnerProperty
from ..models.spatial import SpatialPointMixin
from ..schemas.property import PropertyCreate, PropertyUpdate


class PartnerPropertyRepository:
    def __init__(self, db: Session):
        self.db = db

    def query(self) -> Select[tuple[PartnerProperty]]:
        return select(PartnerProperty)

    def list(self, bbox: Optional[tuple[float, float, float, float]] = None) -> Sequence[PartnerProperty]:
        stmt = self.query()
        if bbox:
            min_lon, min_lat, max_lon, max_lat = bbox
            envelope = func.ST_MakeEnvelope(min_lon, min_lat, max_lon, max_lat, 4326)
            stmt = stmt.where(func.ST_Within(PartnerProperty.geom, envelope))
        stmt = stmt.order_by(PartnerProperty.name)
        return self.db.scalars(stmt).all()

    def get(self, property_id: int) -> PartnerProperty | None:
        return self.db.get(PartnerProperty, property_id)

    def create(self, payload: PropertyCreate) -> PartnerProperty:
        dialect = self.db.bind.dialect.name if self.db.bind else None
        prop = PartnerProperty(
            name=payload.name,
            address=payload.address,
            phone=payload.phone,
            website=payload.website,
            photos=list(payload.photos),
            is_published=payload.is_published,
            latitude=payload.latitude,
            longitude=payload.longitude,
            geom=SpatialPointMixin.build_point(payload.longitude, payload.latitude, dialect),
        )
        self.db.add(prop)
        self.db.commit()
        self.db.refresh(prop)
        return prop

    def update(self, prop: PartnerProperty, payload: PropertyUpdate) -> PartnerProperty:
        if payload.name is not None:
            prop.name = payload.name
        if payload.address is not None:
            prop.address = payload.address
        if payload.phone is not None:
            prop.phone = payload.phone
        if payload.website is not None:
            prop.website = payload.website
        if payload.photos is not None:
            prop.photos = list(payload.photos)
        if payload.is_published is not None:
            prop.is_published = payload.is_published
        if payload.latitude is not None and payload.longitude is not None:
            prop.latitude = payload.latitude
            prop.longitude = payload.longitude
            dialect = self.db.bind.dialect.name if self.db.bind else None
            prop.geom = SpatialPointMixin.build_point(
                payload.longitude, payload.latitude, dialect
            )
        self.db.add(prop)
        self.db.commit()
        self.db.refresh(prop)
        return prop

    def delete(self, prop: PartnerProperty) -> None:
        self.db.delete(prop)
        self.db.commit()
