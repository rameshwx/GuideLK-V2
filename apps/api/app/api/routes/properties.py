from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status

from ...dependencies import get_current_user, get_property_repository
from ...repositories.property import PartnerPropertyRepository
from ...schemas.property import PropertyCreate, PropertyRead, PropertyUpdate

router = APIRouter(prefix="/properties", tags=["partner-properties"])


@router.get("/", response_model=list[PropertyRead])
def list_properties(
    bbox: str | None = Query(default=None, description="minLon,minLat,maxLon,maxLat"),
    repository: PartnerPropertyRepository = Depends(get_property_repository),
):
    parsed_bbox = None
    if bbox:
        try:
            min_lon, min_lat, max_lon, max_lat = map(float, bbox.split(","))
            parsed_bbox = (min_lon, min_lat, max_lon, max_lat)
        except ValueError as exc:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid bbox") from exc
    records = repository.list(parsed_bbox)
    return [PropertyRead.model_validate(prop) for prop in records]


@router.get("/{property_id}", response_model=PropertyRead)
def get_property(
    property_id: int,
    repository: PartnerPropertyRepository = Depends(get_property_repository),
):
    prop = repository.get(property_id)
    if not prop:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Property not found")
    return PropertyRead.model_validate(prop)


@router.post("/", response_model=PropertyRead, status_code=status.HTTP_201_CREATED)
def create_property(
    payload: PropertyCreate,
    repository: PartnerPropertyRepository = Depends(get_property_repository),
    _: object = Depends(get_current_user),
):
    prop = repository.create(payload)
    return PropertyRead.model_validate(prop)


@router.patch("/{property_id}", response_model=PropertyRead)
def update_property(
    property_id: int,
    payload: PropertyUpdate,
    repository: PartnerPropertyRepository = Depends(get_property_repository),
    _: object = Depends(get_current_user),
):
    prop = repository.get(property_id)
    if not prop:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Property not found")
    updated = repository.update(prop, payload)
    return PropertyRead.model_validate(updated)


@router.delete("/{property_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_property(
    property_id: int,
    repository: PartnerPropertyRepository = Depends(get_property_repository),
    _: object = Depends(get_current_user),
):
    prop = repository.get(property_id)
    if not prop:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Property not found")
    repository.delete(prop)
    return None
