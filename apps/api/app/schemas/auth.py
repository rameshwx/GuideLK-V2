from pydantic import BaseModel, EmailStr


class TokenPayload(BaseModel):
    uid: str
    email: EmailStr | None = None
    name: str | None = None
    picture: str | None = None
