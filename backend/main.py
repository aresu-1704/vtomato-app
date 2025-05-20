from fastapi import FastAPI
from starlette.responses import JSONResponse

from slowapi.util import get_remote_address
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded

from app import login_router
from app import predict_router
from app import disease_history_router

from app.utils import start_redis


app = FastAPI(
    title="Tomato Disease Detection API",
    description="API phục vụ ứng dụng nhận diện bệnh cây cà chua từ hình ảnh lá cây và xác định lá bệnh.",
    version="1.0.0"
)

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter


@app.exception_handler(RateLimitExceeded)
async def ratelimit_error(request, exc):
    return JSONResponse(
        status_code=429,
        content={"detail": "Rate limit exceeded. Try again later."}
    )

app.include_router(login_router, prefix="/auth", tags=["Xác thực"])
app.include_router(predict_router, prefix="/predict", tags=["Chẩn đoán bệnh"])
app.include_router(disease_history_router, prefix="/disease-history", tags=["Lịch sử dự đoán"])

if __name__ == "__main__":
    import uvicorn
    start_redis('app/utils/otp_storage/redis-server.exe')
    uvicorn.run(app, host="0.0.0.0", port=8000)
