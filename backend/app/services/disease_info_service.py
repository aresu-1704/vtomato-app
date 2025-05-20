import asyncio
from typing import List, Dict
from app.repositories.disease_info_repository import DiseaseInfoRepository


class DiseaseInfoService:
    def __init__(self):
        self._disease_info_repository = DiseaseInfoRepository()

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
