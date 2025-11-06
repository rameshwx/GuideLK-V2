from __future__ import annotations

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from .core.database import get_db
from .models import User
from .models.enums import TripStopStatus
from .repositories.poi import PointOfInterestRepository
from .repositories.property import PartnerPropertyRepository
from .repositories.trip import TripRepository
from .services.firebase import firebase_verifier
from .services.users import UserService


def get_db_session() -> Session:
    yield from get_db()


def get_poi_repository(db: Session = Depends(get_db_session)) -> PointOfInterestRepository:
    return PointOfInterestRepository(db)


def get_property_repository(db: Session = Depends(get_db_session)) -> PartnerPropertyRepository:
    return PartnerPropertyRepository(db)


def get_trip_repository(db: Session = Depends(get_db_session)) -> TripRepository:
    return TripRepository(db)


def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db_session),
) -> User:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing token")
    raw_token = authorization.split(" ", maxsplit=1)[1]
    try:
        decoded = firebase_verifier.verify(raw_token)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)) from exc

    user = UserService(db).get_or_create(
        firebase_uid=decoded["uid"],
        email=decoded.get("email"),
        full_name=decoded.get("name"),
    )
    return user


def parse_stop_status(status_value: str) -> TripStopStatus:
    try:
        return TripStopStatus(status_value)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid status") from exc
