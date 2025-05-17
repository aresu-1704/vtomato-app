from typing_extensions import override

from app.utils.database import postgreSQL_connection as dtb
from app.repositories.idisease_info_repository import IDiseaseInfoRepository


class DiseaseInfoRepository(IDiseaseInfoRepository):
    def __init__(self):
        self.db = dtb.DatabaseConnect(
            connect_string="postgresql://tomato_user:TomatoPassword123!@localhost:5432/tomato_disease_app"
        )

    @override
    async def get_disease_info(self, disease_id: int = -1):
        try:
            query = """
                SELECT * FROM sp_GetDiseaseInfo($1);
            """
            result = await self.db.data_query(query, (disease_id,))

            if result:
                disease_name, cause, symptoms, conditions, treatment = result[0]
                return {
                    "disease_name": disease_name,
                    "cause": cause,
                    "symptoms": symptoms,
                    "conditions": conditions,
                    "treatment": treatment
                }
            else:
                return None
        except Exception as e:
            print(f"Error: {str(e)}")
            return None
