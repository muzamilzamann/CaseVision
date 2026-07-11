from app.db.session import Base, engine
from app.models.user import User  # noqa: F401 - ensures model metadata is registered


def init_db() -> None:
    Base.metadata.create_all(bind=engine)
