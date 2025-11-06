from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    api_root_path: str = "/guidelkv2/api"
    api_debug: bool = False
    mysql_host: str = "localhost"
    mysql_port: int = 3306
    mysql_db: str = "guidelkv2"
    mysql_user: str = "guidelkv2_user"
    mysql_password: str = "change_me"
    firebase_project_id: str = "guidelk-d1393"
    environment: Literal["development", "production", "test"] = "development"
    sqlalchemy_database_uri: str | None = None

    @property
    def database_url(self) -> str:
        if self.sqlalchemy_database_uri:
            return self.sqlalchemy_database_uri
        return (
            f"mysql+mysqldb://{self.mysql_user}:{self.mysql_password}@{self.mysql_host}:"
            f"{self.mysql_port}/{self.mysql_db}?charset=utf8mb4"
        )


@lru_cache
def get_settings() -> Settings:
    return Settings()
