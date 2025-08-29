import asyncio
from typing import List, Dict
from typing_extensions import override

from app.repositories.disease_info_repository import DiseaseInfoRepository
from app.services.idisease_info_service import IDiseaseInfoService


class DiseaseInfoService(IDiseaseInfoService):
    def __init__(self):
        self._disease_info_repository = DiseaseInfoRepository()

    @override
    async def get_disease_info(self, DiseaseIDList) -> List[Dict[str, str]]:
        try:
            diseases = []
            tasks = [self._disease_info_repository.get_disease_info(cls_idx) for cls_idx in DiseaseIDList]

            results = await asyncio.gather(*tasks)

            for result in results:
                diseases.append({
                    "DiseaseName": result["disease_name"],
                    "Cause": result["cause"],
                    "Symptoms": result["symptoms"],
                    "Conditions": result["conditions"],
                    "Treatment": result["treatment"]
                })

            return diseases
        except Exception as e:
            return None
