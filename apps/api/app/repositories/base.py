from __future__ import annotations

from typing import Protocol

from sqlalchemy.orm import Session


class SessionRepository:
    def __init__(self, db: Session):
        self.db = db


class SupportsSession(Protocol):
    db: Session
