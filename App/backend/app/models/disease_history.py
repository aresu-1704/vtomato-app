from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class DiseasePredictionDetail(BaseModel):
    class_index: int

class DiseaseHistoryModel(BaseModel):
    history_id: int
    user_id: int
    image_path: str
    predicted_at: datetime
    details: Optional[List[DiseasePredictionDetail]] = None
