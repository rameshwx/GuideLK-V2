from __future__ import annotations

from collections.abc import Sequence
from typing import Optional

from sqlalchemy import Select, func, select
from sqlalchemy.orm import Session

from ..models.poi import PointOfInterest
from ..models.spatial import SpatialPointMixin
from ..schemas.poi import POICreate, POIUpdate


class PointOfInterestRepository:
    def __init__(self, db: Session):
        self.db = db

    def query(self) -> Select[tuple[PointOfInterest]]:
        return select(PointOfInterest)

    def list(self, bbox: Optional[tuple[float, float, float, float]] = None) -> Sequence[PointOfInterest]:
        stmt = self.query()
        if bbox:
            min_lon, min_lat, max_lon, max_lat = bbox
            envelope = func.ST_MakeEnvelope(min_lon, min_lat, max_lon, max_lat, 4326)
            stmt = stmt.where(func.ST_Within(PointOfInterest.geom, envelope))
        stmt = stmt.order_by(PointOfInterest.name)
        return self.db.scalars(stmt).all()

    def get(self, poi_id: int) -> PointOfInterest | None:
        return self.db.get(PointOfInterest, poi_id)

    def create(self, payload: POICreate) -> PointOfInterest:
        poi = PointOfInterest(
            name=payload.name,
            category=payload.category,
            description=payload.description,
            photos=list(payload.photos),
            is_published=payload.is_published,
            latitude=payload.latitude,
            longitude=payload.longitude,
            geom=SpatialPointMixin.build_point(payload.longitude, payload.latitude),
        )
        self.db.add(poi)
        self.db.commit()
        self.db.refresh(poi)
        return poi

    def update(self, poi: PointOfInterest, payload: POIUpdate) -> PointOfInterest:
        if payload.name is not None:
            poi.name = payload.name
        if payload.category is not None:
            poi.category = payload.category
        if payload.description is not None:
            poi.description = payload.description
        if payload.photos is not None:
            poi.photos = list(payload.photos)
        if payload.is_published is not None:
            poi.is_published = payload.is_published
        if payload.latitude is not None and payload.longitude is not None:
            poi.latitude = payload.latitude
            poi.longitude = payload.longitude
            poi.geom = SpatialPointMixin.build_point(payload.longitude, payload.latitude)
        self.db.add(poi)
        self.db.commit()
        self.db.refresh(poi)
        return poi

    def delete(self, poi: PointOfInterest) -> None:
        self.db.delete(poi)
        self.db.commit()
