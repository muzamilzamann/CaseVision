from datetime import datetime

from sqlalchemy import Column, Integer, String, Text, DateTime

from app.db.session import Base


class FIR(Base):
    __tablename__ = "firs"

    id = Column(Integer, primary_key=True, index=True)
    user_uid = Column(String(128), index=True, nullable=False)  # Firebase UID
    user_email = Column(String(255), nullable=False)

    file_name = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)

    # Dummy/placeholder analysis fields (to be replaced by real AI later)
    summary = Column(Text, nullable=True)
    predicted_laws = Column(Text, nullable=True)       # JSON string
    urdu_explanation = Column(Text, nullable=True)      # JSON string
    related_cases = Column(Text, nullable=True)         # JSON string

    status = Column(String(50), default="uploaded")     # uploaded / processing / completed

    created_at = Column(DateTime, default=datetime.utcnow)