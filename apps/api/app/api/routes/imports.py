from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel, HttpUrl

from ...dependencies import get_current_user
from ...models import User

router = APIRouter(prefix="/import/booking/portability", tags=["booking.com"])


class PortabilityRegistration(BaseModel):
    url: HttpUrl
    scope: str


class PortabilityResponse(BaseModel):
    message: str


@router.post("/register", response_model=PortabilityResponse)
def register_portability(
    payload: PortabilityRegistration,
    current_user: User = Depends(get_current_user),
) -> PortabilityResponse:
    # Placeholder implementation. In production this would trigger an async fetch of the export
    # referenced by the provided URL and parse candidate stays for the user to review.
    return PortabilityResponse(
        message=(
            "Booking.com portability import registered for "
            f"{current_user.email or current_user.firebase_uid}."
        )
    )


@router.get("/status", response_model=PortabilityResponse)
def portability_status(current_user: User = Depends(get_current_user)) -> PortabilityResponse:
    return PortabilityResponse(
        message=(
            "Portability import processing is not yet implemented. "
            "Check back once the feature flag is enabled."
        )
    )
