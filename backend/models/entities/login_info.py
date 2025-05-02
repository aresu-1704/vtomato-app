from utils.database import postgreSQL_connection as dtb

class LoginInfo:
    def __init__(self, UserID=None, Email=None, PasswordHash=None, Salt=None, PhoneNumber=None,
                 CreatedAt=None, IsActive=None):
        self.UserID = UserID
        self.Email = Email
        self.PasswordHash = PasswordHash
        self.Salt = Salt
        self.PhoneNumber = PhoneNumber
        self.CreatedAt = CreatedAt
        self.IsActive = IsActive
        self.db = dtb.DatabaseConnect(
            connect_string="postgresql://tomato_user:TomatoPassword123!@localhost:5432/tomato_disease_app"
        )

    async def CreateNewAccount(self, Email, PasswordHash, Salt, PhoneNumber):
        try:
            query = """
            SELECT sp_createaccount($1, $2, $3, $4);
            """
            params = (Email, PasswordHash, Salt, PhoneNumber)
            result = await self.db.data_query(query, params)

            if result:
                return result[0][0]
            else:
                return "Unknown error occurred."
        except Exception as e:
            return f"Error: {str(e)}"

    async def FindAccount(self, Email):
        try:
            query = """
                SELECT * FROM sp_GetPasswordInfoByEmail($1);
                """
            params = (Email,)
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

    async def ResetPassword(self, Email, NewPasswordHash, Salt):
        try:
            query = """
            SELECT sp_resetpassword($1, $2, $3);
            """
            params = (Email, NewPasswordHash, Salt)
            result = await self.db.data_query(query, params)

            if result:
                return result[0][0]  # Kết quả trả về từ stored procedure
            else:
                return "Unknown error occurred."
        except Exception as e:
            return f"Error: {str(e)}"

    async def FindAccountByEmail(self, Email):
        try:
            query = """
                SELECT COUNT(*) FROM sp_FindPhoneNumberByEmail($1);
            """
            params = (Email,)
            result = await self.db.data_query(query, params)

            if result and result[0][0] > 0:
                return True
            else:
                return False
        except Exception as e:
            return f"Error: {str(e)}"
