import os
import base64
from datetime import datetime
from typing import List, Dict, Any

from app.repositories import DiseaseHistoryRepository


class DiseaseHistoryService:
    def __init__(self):
        self._disease_history_repository = DiseaseHistoryRepository()

    async def save_history(self, user_id: int, image_bytes: bytes, class_idx_list: List[int]) -> str:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"predict_{timestamp}_user{user_id}.jpg"

        img_dir = os.path.join(os.getcwd(), "media", "image_history")
        os.makedirs(img_dir, exist_ok=True)

        full_path = os.path.join(img_dir, filename)
        relative_path = os.path.join("media", "image_history", filename)

        try:
            with open(full_path, "wb") as f:
                f.write(image_bytes)
        except Exception as e:
            return f"Failed to save image: {str(e)}"

        await self._disease_history_repository.save_disease_history(user_id, relative_path, class_idx_list)

        return "Save successfully"

    async def get_predict_history_by_id(self, history_id: int) -> Dict[str, Any]:
        raw_data = await self._disease_history_repository.get_disease_history_by_id(history_id)

        result = {"history": []}

        if not raw_data:
            return result

        for row in raw_data:
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

            existing_entry = next(
                (entry for entry in result["history"] if entry["PredictionID"] == prediction_id),
                None
            )

            if not existing_entry:
                try:
                    with open(image_path, "rb") as img_file:
                        image_base64 = base64.b64encode(img_file.read()).decode("utf-8")
                except Exception as e:
                    print(f"[ERROR] Could not read image {image_path}: {e}")
                    image_base64 = None

                result["history"].append({
                    "PredictionID": prediction_id,
                    "Image": image_base64,
                    "Timestamp": timestamp,
                    "ListDisease": [disease_info]
                })
            else:
                existing_entry["ListDisease"].append(disease_info)

        return result
