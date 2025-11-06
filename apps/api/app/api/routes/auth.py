from __future__ import annotations

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel

from ...services.firebase import firebase_verifier

router = APIRouter(prefix="/auth", tags=["auth"])


class VerifyRequest(BaseModel):
    token: str


class VerifyResponse(BaseModel):
    uid: str
    email: str | None = None
    name: str | None = None


@router.post("/verify", response_model=VerifyResponse)
def verify_token(payload: VerifyRequest) -> VerifyResponse:
    try:
        decoded = firebase_verifier.verify(payload.token)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token") from exc
    return VerifyResponse(uid=decoded["uid"], email=decoded.get("email"), name=decoded.get("name"))
