from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status

from ...dependencies import get_current_user, get_poi_repository
from ...repositories.poi import PointOfInterestRepository
from ...schemas.poi import POICreate, POIRead, POIUpdate

router = APIRouter(prefix="/pois", tags=["points-of-interest"])


@router.get("/", response_model=list[POIRead])
def list_pois(
    bbox: str | None = Query(default=None, description="minLon,minLat,maxLon,maxLat"),
    repository: PointOfInterestRepository = Depends(get_poi_repository),
):
    parsed_bbox = None
    if bbox:
        try:
            min_lon, min_lat, max_lon, max_lat = map(float, bbox.split(","))
            parsed_bbox = (min_lon, min_lat, max_lon, max_lat)
        except ValueError as exc:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid bbox") from exc
    records = repository.list(parsed_bbox)
    return [POIRead.model_validate(poi) for poi in records]


@router.get("/{poi_id}", response_model=POIRead)
def get_poi(poi_id: int, repository: PointOfInterestRepository = Depends(get_poi_repository)):
    poi = repository.get(poi_id)
    if not poi:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="POI not found")
    return POIRead.model_validate(poi)


@router.post("/", response_model=POIRead, status_code=status.HTTP_201_CREATED)
def create_poi(
    payload: POICreate,
    repository: PointOfInterestRepository = Depends(get_poi_repository),
    _: object = Depends(get_current_user),
):
    poi = repository.create(payload)
    return POIRead.model_validate(poi)


@router.patch("/{poi_id}", response_model=POIRead)
def update_poi(
    poi_id: int,
    payload: POIUpdate,
    repository: PointOfInterestRepository = Depends(get_poi_repository),
    _: object = Depends(get_current_user),
):
    poi = repository.get(poi_id)
    if not poi:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="POI not found")
    updated = repository.update(poi, payload)
    return POIRead.model_validate(updated)


@router.delete("/{poi_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_poi(
    poi_id: int,
    repository: PointOfInterestRepository = Depends(get_poi_repository),
    _: object = Depends(get_current_user),
):
    poi = repository.get(poi_id)
    if not poi:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="POI not found")
    repository.delete(poi)
    return None
