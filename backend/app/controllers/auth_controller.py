from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel
from app.services.auth_service import LoginServices
from slowapi import Limiter
from slowapi.util import get_remote_address


router = APIRouter()
login_services = LoginServices()
limiter = Limiter(key_func=get_remote_address)

class LoginRequest(BaseModel):
    Email: str
    Password: str

class RegisterRequest(BaseModel):
    Email: str
    PhoneNumber: str
    Password: str

class ResetPasswordRequest(BaseModel):
    Email: str
    NewPassword: str

class FindAccount(BaseModel):
    Email: str

class VerifyOTP(BaseModel):
    Email: str
    OTP: int

@router.post("/login")
@limiter.limit("5/minute")
async def login(request: Request, body: LoginRequest):
    userID = await login_services.verify_login(body.Email, body.Password)

    if userID is not None:
        return {
            "message": "Login successful",
            "UserID": userID
        }
    else:
        raise HTTPException(status_code=401, detail="Invalid email or password")

@router.post("/register")
async def register(request: RegisterRequest):
    is_registered = await login_services.register_account(request.Email, request.PhoneNumber, request.Password)

    if is_registered:
        return {"message": "Account registered successfully"}
    else:
        raise HTTPException(status_code=400, detail="Email already exists or error during registration")


@router.post("/reset-password")
async def reset_password(request: ResetPasswordRequest):
    is_reset = await login_services.reset_password(request.Email, request.NewPassword)

    if is_reset:
        return {"message": "Password reset successful"}
    else:
        raise HTTPException(status_code=400, detail="Email not found or account is not active")

@router.post("/send-otp")
@limiter.limit("5/minutes")
async def send_otp(request: Request, body: FindAccount):
    result = await login_services.send_otp_to_email(body.Email)
    return {
        "Message": result,
    }

@router.post("/verify-otp")
async def verify_otp(request: VerifyOTP):
    result = await login_services.verify_login(request.Email, request.OTP)
    return {
        "Message": result,
    }