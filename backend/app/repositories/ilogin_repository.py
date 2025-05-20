from abc import ABC, abstractmethod


class ILoginRepository(ABC):

    @abstractmethod
    async def create_account(self, email, password_hash, salt, phone_number):
        pass

    @abstractmethod
    async def get_password_info_by_email(self, email):
        pass

    @abstractmethod
    async def reset_password(self, email, new_password_hash, salt):
        pass

    @abstractmethod
    async def email_exists(self, email):
        pass
