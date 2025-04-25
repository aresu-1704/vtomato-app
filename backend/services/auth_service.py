import models.entitys.login_info as LoginInfo
from models.entitys.login_info import LoginInfo
from utils.hash_password import hash_password
from utils.send_otp.send_OTP_to_email import send_otp, verify_otp


class LoginServices:
    def __init__(self):
        self._loginInfo = LoginInfo()

    def VerifyLogin(self, Email, Password):
        account_pass = self._loginInfo.FindAccount(Email)

        if account_pass == None:
            return None
        else:
            store_password = account_pass["PasswordHash"]
            salt = account_pass["Salt"]

            input_password = Hash_Password.hash_password(Password, salt)

            if store_password == input_password:
                return account_pass['UserID']
            else:
                return None

    def RegisterNewAccount(self, Email, PhoneNumber, Input_Password):
        try:
            salt = Hash_Password.generate_salt(16)
            hash_password = Hash_Password.hash_password(Input_Password, salt)

            result = self._loginInfo.CreateNewAccount(Email=Email, PasswordHash=hash_password, Salt=salt, PhoneNumber=PhoneNumber)

            if result == "Email already exists.":
                return False
            else:
                return True
        except Exception as e:
            return f"Error: {str(e)}"

    def ResetPassword(self, Email, New_Password):
        try:
            salt = Hash_Password.generate_salt(16)
            new_hashPassword = Hash_Password.hash_password(New_Password, salt)

            result = self._loginInfo.ResetPassword(Email=Email, New_Password=new_hashPassword, Salt=salt)

            if result == "Email not found or account is not active.":
                return False
            else:
                return True
        except Exception as e:
            return f"Error: {str(e)}"

    def SendOTPToEmail(self, Email):
        result = self._loginInfo.FindAccountByEmai(Email)

        if result == False:
            return 0
        else:
            status = send_otp(Email)
            if status is not None:
                return status

    def VerifyOTP(self, PhoneNumber, OTP):
        return verify_otp(PhoneNumber, OTP)

