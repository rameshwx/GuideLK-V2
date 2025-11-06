from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from ..models import User


class UserService:
    def __init__(self, db: Session):
        self.db = db

    def get_or_create(self, firebase_uid: str, email: str | None = None, full_name: str | None = None) -> User:
        stmt = select(User).where(User.firebase_uid == firebase_uid)
        user = self.db.scalars(stmt).first()
        if user:
            return user
        user = User(firebase_uid=firebase_uid, email=email, full_name=full_name)
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
