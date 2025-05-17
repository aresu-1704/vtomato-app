import base64
import asyncio

from fastapi import APIRouter
from app.services.disease_info_service import DiseaseService

from app.services.predict_service import PredictService
from pydantic import BaseModel
from fastapi.responses import JSONResponse

from app.executor_pool import executor


router = APIRouter()

class PredictRequest(BaseModel):
    Image: str

_predict_service = PredictService(
    model_path="ai_models/yolov12n/weights/best.pt",
    class_names=[
        "Early Blight",
        "Healthy",
        "Late Blight",
        "Leaf Miner",
        "Leaf Mold",
        "Mosaic Virus",
        "Septoria",
        "Spider Mites",
        "Yellow Leaf Curl Virus"
    ],
    descriptions={
        "Yellow Leaf Curl Virus": "Xoăn vàng lá",
        "Septoria": "Đốm lá Septoria",
        "Healthy": "Lá khỏe mạnh",
        "Early Blight": "Đốm nâu",
        "Spider Mites": "Nhện đỏ ăn lá",
        "Late Blight": "Sương mai",
        "Leaf Miner": "Sâu đục lá",
        "Leaf Mold": "Mốc lá",
        "Mosaic Virus": "Virus khảm lá"
    }
)

@router.post("/predict-image")
async def predict_image(request: PredictRequest):
    try:
        data = request.Image
        try:
            _disease_info_service = DiseaseService()
            image_bytes = base64.b64decode(data)
            loop = asyncio.get_running_loop()
            result = await loop.run_in_executor(executor, _predict_service.predict, image_bytes)
            disease_info_list = await _disease_info_service.get_disease_info(result["class_indices"])

            result_with_disease_info = {
                "status": result["status"],
                "image": result["image"],
                "class_count": result["class_count"],
                "class_indices": result["class_indices"],
                "data": disease_info_list
            }

            return JSONResponse(
                content=result_with_disease_info,
                headers={"Content-Type": "application/json; charset=utf-8"}
            )
        except Exception as e:
            return {"status": "error", "message": "Invalid image data", "error": str(e)}
    except Exception as e:
        return {"status": "error", "message": "An unexpected error occurred", "error": str(e)}


