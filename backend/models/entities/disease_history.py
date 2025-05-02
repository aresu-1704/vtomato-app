import asyncio
from utils.database import postgreSQL_connection as dtb

class DiseaseHistory:
    def __init__(self):
        self.db = dtb.DatabaseConnect(
            connect_string="postgresql://tomato_user:TomatoPassword123!@localhost:5432/tomato_disease_app"
        )

    async def SaveDiseaseHistory(self, UserID=-1, ImagePath=None, ListClassIdx=[]):
        try:
            query = """
            SELECT sp_InsertPredictionHistory(%s, %s);
            """
            params = (UserID, ImagePath)
            result = await self.db.data_query(query, params)

            Prediction_History_ID = result[0][0]

            tasks = []
            for idx in ListClassIdx:
                query = "SELECT sp_InsertPredictionDetail(%s, %s);"
                params = (Prediction_History_ID, idx)
                tasks.append(self.db.execute_non_query(query, params))

            await asyncio.gather(*tasks)

        except Exception as e:
            print(f"Error: {str(e)}")

    async def GetDiseaseHistoryByID(self, ID=-1):
        try:
            query = """
            SELECT * FROM sp_GetDiseaseHistoryByID(%s);
            """
            params = (ID,)
            return await self.db.data_query(query, params)
        except Exception as e:
            print(f"Error: {str(e)}")
            return None
