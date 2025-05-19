from typing_extensions import override

from app.repositories.ilogin_repository import ILoginRepository
from app.utils.database import postgreSQL_connection as dtb

class LoginRepository(ILoginRepository):
    def __init__(self):
        self.db = dtb.DatabaseConnect(
            connect_string="postgresql://tomato_user:TomatoPassword123!@localhost:5432/tomato_disease_app"
        )

    @override
    async def create_account(self, email, password_hash, salt, phone_number):
        try:
            query = """
                SELECT sp_createaccount($1, $2, $3, $4);
            """
            params = (email, password_hash, salt, phone_number)
            result = await self.db.data_query(query, params)

            if result:
                return result[0][0]
            else:
                return "Unknown error occurred."
        except Exception as e:
            return f"Error: {str(e)}"

    @override
    async def get_password_info_by_email(self, email):
        try:
            query = """
                SELECT * FROM sp_GetPasswordInfoByEmail($1);
            """
            params = (email,)
            result = await self.db.data_query(query, params)

            if result:
                userID, password_hash, salt = result[0]
                return {
                    "UserID": userID,
                    "PasswordHash": password_hash,
                    "Salt": salt
                }
            else:
                return None
        except Exception as e:
            print(f"[ERROR] GetPasswordInfo failed: {e}")
            return None

    @override
    async def reset_password(self, user_id, new_password_hash, salt):
        try:
            query = """
               SELECT sp_resetpassword($1, $2, $3);
            """
            params = (user_id, new_password_hash, salt)
            result = await self.db.data_query(query, params)

            if result:
                return result[0][0]
            else:
                return "Unknown error occurred."
        except Exception as e:
            return f"Error: {str(e)}"

    @override
    async def email_exists(self, email):
        try:
            query = """
                SELECT * FROM sp_getuseridbyemail($1);
            """
            params = (email,)
            result = await self.db.data_query(query, params)

            if result:
                user_id = result[0][0]
                return user_id
            else:
                return None
        except Exception as e:
            return f"Error: {str(e)}"
