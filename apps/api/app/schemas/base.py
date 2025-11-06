from datetime import datetime

from pydantic import BaseModel


class ORMModel(BaseModel):
    class Config:
        from_attributes = True
        populate_by_name = True


class TimestampedModel(ORMModel):
    created_at: datetime
    updated_at: datetime
