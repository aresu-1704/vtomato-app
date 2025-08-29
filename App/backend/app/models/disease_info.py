from pydantic import BaseModel


class DiseaseInfoModel(BaseModel):
    disease_name: str
    cause: str
    symptoms: str
    conditions: str
    treatment: str
