from typing import List, Dict, Any
from abc import ABC, abstractmethod


class IDiseaseHistoryService(ABC):
    @abstractmethod
    async def save_history(self, user_id: int, image_bytes: bytes, class_idx_list: List[int]) -> str:
        pass

    @abstractmethod
    async def get_predict_history_by_id(self, history_id: int) -> Dict[str, Any]:
        pass
