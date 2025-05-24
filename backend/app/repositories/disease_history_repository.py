import asyncio
from typing import List, Optional

from typing_extensions import override

from app.utils import DatabaseConnect
from app.models import DiseaseHistoryModel
from .idisease_history_repository import IDiseaseHistoryRepository

from config import settings


class DiseaseHistoryRepository(IDiseaseHistoryRepository):
    def __init__(self):
        self.db = DatabaseConnect(
            connect_string=settings.DATABASE_URL
        )

    @override
    async def save_disease_history(self, user_id: int, image_path: str, class_indices: List[int]) -> None:
        try:
            query = """
                SELECT sp_InsertPredictionHistory($1, $2);
            """
            params = (user_id, image_path)
            result = await self.db.data_query(query, params)

            Prediction_History_ID = result[0][0]

            tasks = []
            for idx in class_indices:
                query = "SELECT sp_InsertPredictionDetail($1, $2);"
                params = (Prediction_History_ID, idx)
                tasks.append(self.db.execute_non_query(query, params))

            await asyncio.gather(*tasks)

        except Exception as e:
            print(f"Error: {str(e)}")

    @override
    async def get_disease_history_by_id(self, history_id: int) -> Optional[DiseaseHistoryModel]:
        try:
            query = """
                SELECT * FROM sp_GetDiseaseHistoryByID($1);
            """
            params = (history_id,)
            return await self.db.data_query(query, params)
        except Exception as e:
            print(f"Error: {str(e)}")
            return None
