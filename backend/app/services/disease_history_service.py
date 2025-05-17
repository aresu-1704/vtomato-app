from app.models.disease_history import DiseaseHistory
import os
from datetime import datetime
import base64

class DiseaseHistoryService:
    def __init__(self):
        self.disease_history_model = DiseaseHistory()

    async def SaveHistory(self, UserID=-1, ImageByte=None, ClassIdxList=[]):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"predict_{timestamp}_user{UserID}.jpg"

        img_dir = os.path.join(os.getcwd(), "media", "image_history")
        os.makedirs(img_dir, exist_ok=True)

        full_img_path = os.path.join(img_dir, filename)
        relative_img_path = f"media/image_history/{filename}"

        with open(full_img_path, "wb") as f:
            f.write(ImageByte)

        await self.disease_history_model.SaveDiseaseHistory(UserID, relative_img_path, ClassIdxList)

        return "Save successfully"

    async def GetPredictHictoryByID(self, ID=-1):
        table = await self.disease_history_model.GetDiseaseHistoryByID(ID)

        result = {
            "history": []
        }

        if table:
            for row in table:
                prediction_id = row[0]
                image_path = row[1]
                timestamp = row[2].strftime("%Y-%m-%d %H:%M:%S")
                disease_info = {
                    "DiseaseName": row[3],
                    "Cause": row[4],
                    "Symptoms": row[5],
                    "Conditions": row[6],
                    "Treatment": row[7]
                }

                existing_entry = next((entry for entry in result["history"] if entry["PredictionID"] == prediction_id),
                                      None)

                if not existing_entry:
                    try:
                        with open(image_path, "rb") as img_file:
                            img = img_file.read()
                        image_base64 = base64.b64encode(img).decode("utf-8")
                    except Exception as e:
                        print(f"Lỗi khi đọc ảnh từ {image_path}: {e}")
                        image_base64 = None

                    result["history"].append({
                        "PredictionID": prediction_id,
                        "Image": image_base64,
                        "Timestamp": timestamp,
                        "ListDisease": [disease_info]
                    })
                else:
                    existing_entry["history"].append(disease_info)

        return result
