import psycopg2
from utils.database import postgreSQL_connection as dtb

class DiseaseHistory:
    def __init__(self):
        self.db = dtb.DatabaseConnect(
            connect_string="postgresql://tomato_user:TomatoPassword123!@localhost:5432/tomato_disease_app"
        )

    def SaveDiseaseHistory(self, UserID = -1, ImagePath = None, ListClassIdx = []):
        try:
            query = """
            SELECT sp_InsertPredictionHistory(%s, %s);
            """
            params = (UserID, ImagePath)
            result = self.db.data_query(query, params)

            Prediction_History_ID = result[0][0]

            for idx in ListClassIdx:
                query = """
                SELECT sp_InsertPredictionDetail(%s, %s);
                """
                params = (Prediction_History_ID, idx)
                self.db.execute_non_query(query, params)

        except Exception as e:
            print(f"Error: {str(e)}")

    def GetDiseaseHistoryByID(self, ID=-1):
        try:
            query = """
            SELECT * FROM sp_GetDiseaseHistoryByID(%s);
            """
            params = (ID,)
            return self.db.data_query(query, params)
        except Exception as e:
            print(f"Error: {str(e)}")
            return None
