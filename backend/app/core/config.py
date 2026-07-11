from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    project_name: str = "CaseVision API"
    database_url: str = "mysql://user:3121@localhost/casevision"
    secret_key: str = "change-me-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24
    firebase_credentials_path: str = "app/core/firebase-service-account.json"
    gemini_api_key: str = ""
    tesseract_path: str = ""
    poppler_path: str = ""

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


settings = Settings()