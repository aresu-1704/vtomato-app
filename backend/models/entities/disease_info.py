from utils.database import postgreSQL_connection as dtb

class DiseaseInfo:
    def __init__(self):
        self.db = dtb.DatabaseConnect(
            connect_string="postgresql://tomato_user:TomatoPassword123!@localhost:5432/tomato_disease_app"
        )

    def GetDiseaseInfo(self, DiseaseID = -1):
        try:
            query = """
            SELECT * FROM sp_GetDiseaseInfo(%s);
            """
            result = self.db.data_query(query, (DiseaseID,))

            if result:
                diseaseName, cause, symptoms, conditions, treatment = result[0]
                return {
                    "DiseaseName": diseaseName,
                    "Cause": cause,
                    "Symptoms": symptoms,
                    "Conditions": conditions,
                    "Treatment": treatment
                }
            else:
                return None
        except Exception as e:
            print(f"Error: {str(e)}")
            return None;
