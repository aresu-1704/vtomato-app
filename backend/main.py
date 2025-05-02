from fastapi import FastAPI
from starlette.responses import JSONResponse

from slowapi.util import get_remote_address
from slowapi import Limiter
from slowapi.errors import RateLimitExceeded

from controllers.auth_controller import router as login_router
from controllers.predict_controller import router as predict_router
from controllers.disease_history_controller import router as disease_history_router

from utils.otp_storage.start_redis import start_redis

app = FastAPI()

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.exception_handler(RateLimitExceeded)
async def ratelimit_error(request, exc):
    return JSONResponse(
        status_code=429,
        content={"detail": "Rate limit exceeded. Try again later."}
    )

app.include_router(login_router, prefix="/auth", tags=["Authentication"])
app.include_router(predict_router, prefix="/predict", tags=["Predict Disease"])
app.include_router(disease_history_router, prefix="/disease-history", tags=["Disease History"])

if __name__ == "__main__":
    import uvicorn
    start_redis('utils/otp_storage/redis-server.exe')
    uvicorn.run(app, host="0.0.0.0", port=8000)
