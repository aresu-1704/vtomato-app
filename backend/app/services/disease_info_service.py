from app import models as DiseaseInfo
import asyncio
from app.models.disease_info import DiseaseInfo
from typing import List, Dict

class DiseaseService:
    def __init__(self):
        self._diseaseInfo = DiseaseInfo()

    async def GetDiseaseInfo(self, DiseaseIDList) -> List[Dict[str, str]]:
        try:
            diseases = []
            tasks = [self._diseaseInfo.GetDiseaseInfo(cls_idx) for cls_idx in DiseaseIDList]

            results = await asyncio.gather(*tasks)

            for result in results:
                diseases.append({
                    "DiseaseName": result["DiseaseName"],
                    "Cause": result["Cause"],
                    "Symptoms": result["Symptoms"],
                    "Conditions": result["Conditions"],
                    "Treatment": result["Treatment"]
                })

            return diseases
        except Exception as e:
            return None
