from abc import ABC, abstractmethod


class IDiseaseInfoRepository(ABC):
    @abstractmethod
    async def get_disease_info(self, disease_id: int = -1):
        pass
