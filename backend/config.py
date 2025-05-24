from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DATABASE_URL: str
    EMAIL_SENDER: str
    EMAIL_HOST: str
    EMAIL_PORT: int
    EMAIL_USERNAME: str
    EMAIL_PASSWORD: str

    class Config:
        env_file = ".env"

settings = Settings()
