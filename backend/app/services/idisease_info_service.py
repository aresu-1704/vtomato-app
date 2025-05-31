from typing import List, Dict
from abc import ABC, abstractmethod


class IDiseaseInfoService(ABC):
    @abstractmethod
    async def get_disease_info(self, DiseaseIDList: List[int]) -> List[Dict[str, str]]:
        pass
