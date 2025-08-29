import random
import redis
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from config import settings

REDIS_HOST = 'localhost'
REDIS_PORT = 6379
REDIS_DB = 0

redis_client = redis.StrictRedis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB)


async def generate_otp():
    return random.randint(10000, 99999)

async def send_otp(email_address, user_id):
    if redis_client.exists(user_id):
        return user_id

    otp = await generate_otp()
    redis_client.setex(user_id, 300, otp)

    subject = "Mã OTP khôi phục tài khoản:"
    body = f"Mã xác minh của bạn là: {otp}"

    msg = MIMEMultipart()
    msg["From"] = settings.EMAIL_SENDER
    msg["To"] = email_address
    msg["Subject"] = subject

    msg.attach(MIMEText(body, "plain"))

    try:
        server = smtplib.SMTP(settings.EMAIL_HOST, settings.EMAIL_PORT)
        server.starttls()
        server.login(settings.EMAIL_USERNAME, settings.EMAIL_PASSWORD)
        server.sendmail(settings.EMAIL_SENDER, email_address, msg.as_string())
        server.quit()
        return user_id
    except Exception as e:
        return 0

async def verify_otp(user_id, otp):
    stored_otp = redis_client.get(user_id)
    if stored_otp is None:
        return "OTP has expired or does not exist."
    if int(stored_otp) == otp:
        redis_client.delete(user_id)
        return "OTP verified successfully!"
    else:
        return "Invalid OTP."
