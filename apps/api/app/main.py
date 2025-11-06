from __future__ import annotations

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api.routes import auth, imports, pois, properties, trips
from .core.config import get_settings
from .core.database import engine
from .models import Base

settings = get_settings()

app = FastAPI(
    title="GuideLK API",
    version="0.1.0",
    root_path=settings.api_root_path,
    servers=[{"url": settings.api_root_path, "description": "cPanel deployment"}],
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def create_tables() -> None:
    if settings.environment == "test":
        return
    Base.metadata.create_all(bind=engine)


app.include_router(auth.router)
app.include_router(pois.router)
app.include_router(properties.router)
app.include_router(trips.router)
app.include_router(imports.router)


@app.get("/health", tags=["system"])
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}
