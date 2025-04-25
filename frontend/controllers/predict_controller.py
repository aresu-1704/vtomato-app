from fastapi import APIRouter
import base64
from services.predict_service import PredictService
from pydantic import BaseModel
from fastapi.responses import JSONResponse

router = APIRouter()

class PredictRequest(BaseModel):
    Image: str

predict_service = PredictService(
    model_path="models/predicts/yolov12n/weights/best.pt",
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
            image_bytes = base64.b64decode(data)
            result = predict_service.predict(image_bytes)
            return JSONResponse(
                content=result,
                headers={"Content-Type": "application/json; charset=utf-8"}
            )
        except Exception as e:
            return {"status": "error", "message": "Invalid image data", "error": str(e)}
    except Exception as e:
        return {"status": "error", "message": "An unexpected error occurred", "error": str(e)}


