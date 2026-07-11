from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class FIRResponse(BaseModel):
    id: int
    file_name: str
    status: str
    summary: Optional[str] = None
    predicted_laws: Optional[List[str]] = None
    urdu_explanation: Optional[List[dict]] = None
    related_cases: Optional[List[dict]] = None
    created_at: datetime

    class Config:
        from_attributes = True