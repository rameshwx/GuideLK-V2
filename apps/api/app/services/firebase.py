from __future__ import annotations

from google.auth.transport import requests
from google.oauth2 import id_token

from ..core.config import get_settings


class FirebaseVerifier:
    def __init__(self) -> None:
        self._request = requests.Request()
        self._project_id = get_settings().firebase_project_id

    def verify(self, token: str) -> dict:
        try:
            return id_token.verify_firebase_token(token, self._request, audience=self._project_id)
        except ValueError as exc:  # includes Expired or invalid token
            raise ValueError("Invalid Firebase token") from exc


firebase_verifier = FirebaseVerifier()
