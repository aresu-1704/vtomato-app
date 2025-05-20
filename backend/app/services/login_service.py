from app.repositories import LoginRepository
from app.utils import hash_password
from app.utils import send_otp, verify_otp


class LoginServices:
    def __init__(self):
        self._login_repository = LoginRepository();

    async def verify_login(self, email: str, password: str):
        try:
            account = await self._login_repository.get_password_info_by_email(email)

            if not account:
                return None

            stored_hash = account["PasswordHash"]
            salt = account["Salt"]
            input_hash = await hash_password.hash_password(password, salt)

            if stored_hash == input_hash:
                return account["UserID"]
            return None
        except Exception as e:
            raise Exception(f"Login verification failed: {e}")

    async def register_account(self, email: str, phone_number: str, password: str):
        try:
            salt = await hash_password.generate_salt(16)
            hashed_password = await hash_password.hash_password(password, salt)

            result = await self._login_repository.create_account(
                email=email,
                password_hash=hashed_password,
                salt=salt,
                phone_number=phone_number
            )

            return result != "Email already exists."
        except Exception as e:
            raise Exception(f"Account registration failed: {e}")

    async def reset_password(self, user_id: int, new_password: str):
        try:
            salt = await hash_password.generate_salt(16)
            new_hash = await hash_password.hash_password(new_password, salt)

            result = await self._login_repository.reset_password(
                user_id=user_id,
                new_password_hash=new_hash,
                salt=salt
            )

            return result != "Email not found or account is not active."
        except Exception as e:
            raise Exception(f"Password reset failed: {e}")

    async def send_otp_to_email(self, email: str):
        try:
            user_id = await self._login_repository.email_exists(email)
            if not user_id:
                return 0
            return await send_otp(email, user_id)
        except Exception as e:
            raise Exception(f"Sending OTP failed: {e}")

    async def verify_otp(self, user_id: int, otp: str):
        try:
            return await verify_otp(user_id, otp)
        except Exception as e:
            raise Exception(f"OTP verification failed: {e}")
