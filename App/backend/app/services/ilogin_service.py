from abc import ABC, abstractmethod


class ILoginService(ABC):
    @abstractmethod
    async def verify_login(self, email: str, password: str) -> int | None:
        pass

    @abstractmethod
    async def register_account(self, email: str, phone_number: str, password: str) -> bool:
        pass

    @abstractmethod
    async def reset_password(self, user_id: int, new_password: str) -> bool:
        pass

    @abstractmethod
    async def send_otp_to_email(self, email: str) -> int:
        pass

    @abstractmethod
    async def verify_otp(self, user_id: int, otp: str) -> bool:
        pass
