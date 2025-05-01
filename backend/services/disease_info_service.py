import models.entities.disease_info as DiseaseInfo
from models.entities.disease_info import DiseaseInfo
from typing import List, Dict

class DiseaseService:
    def __init__(self):
        self._diseaseInfo = DiseaseInfo()

    def GetDiseaseInfo(self, DiseaseIDList) -> List[Dict[str, str]]:
        try:
            diseases = []
            for cls_idx in DiseaseIDList:
                result = self._diseaseInfo.GetDiseaseInfo(cls_idx)
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
