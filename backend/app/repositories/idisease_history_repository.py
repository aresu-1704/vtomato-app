from abc import ABC, abstractmethod
from typing import List, Optional
from app.models.disease_history import DiseaseHistoryModel

class IDiseaseHistoryRepository(ABC):
    @abstractmethod
    async def save_disease_history(self, user_id: int, image_path: str, class_indices: List[int]) -> None:
        pass

    @abstractmethod
    async def get_disease_history_by_id(self, history_id: int) -> Optional[DiseaseHistoryModel]:
        pass
