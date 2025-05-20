from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class LoginInfoModel(BaseModel):
    user_id: Optional[int] = None
    email: Optional[str] = None
    password_hash: Optional[str] = None
    salt: Optional[str] = None
    phone_number: Optional[str] = None
    created_at: Optional[datetime] = None
    is_active: Optional[bool] = None
