import models.entities.login_info as LoginInfo
from models.entities.login_info import LoginInfo
from utils.hash_password import hash_password
from utils.send_otp.send_OTP_to_email import send_otp, verify_otp


class LoginServices:
    def __init__(self):
        self._loginInfo = LoginInfo()

    async def VerifyLogin(self, Email, Password):
        account_pass = await self._loginInfo.FindAccount(Email)

        if account_pass == None:
            return None
        else:
            store_password = account_pass["PasswordHash"]
            salt = account_pass["Salt"]

            input_password = hash_password.hash_password(Password, salt)

            if store_password == input_password:
                return account_pass['UserID']
            else:
                return None

    async def RegisterNewAccount(self, Email, PhoneNumber, Input_Password):
        try:
            salt = await hash_password.generate_salt(16)
            password = await hash_password.hash_password(Input_Password, salt)

            result = await self._loginInfo.CreateNewAccount(Email=Email, PasswordHash=password, Salt=salt, PhoneNumber=PhoneNumber)

            if result == "Email already exists.":
                return False
            else:
                return True
        except Exception as e:
            return f"Error: {str(e)}"

    async def ResetPassword(self, Email, New_Password):
        try:
            salt = await hash_password.generate_salt(16)
            new_hashPassword = await hash_password.hash_password(New_Password, salt)

            result = self._loginInfo.ResetPassword(Email=Email, New_Password=new_hashPassword, Salt=salt)

            if result == "Email not found or account is not active.":
                return False
            else:
                return True
        except Exception as e:
            return f"Error: {str(e)}"

    async def SendOTPToEmail(self, Email):
        result = await self._loginInfo.FindAccountByEmail(Email)

        if result == False:
            return 0
        else:
            status = await send_otp(Email)
            if status is not None:
                return status

    async def VerifyOTP(self, PhoneNumber, OTP):
        return await verify_otp(PhoneNumber, OTP)

