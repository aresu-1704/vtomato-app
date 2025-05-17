from abc import ABC, abstractmethod
from app.models.disease_info import DiseaseInfoModel

class IDiseaseInfoRepository(ABC):
    @abstractmethod
    async def get_disease_info(self, disease_id: int = -1):
        pass
