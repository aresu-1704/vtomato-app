import hashlib
import secrets

async def hash_password(password: str, salt: str) -> str:
    salted = salt + password
    hashed = hashlib.sha256(salted.encode('utf-8')).hexdigest()
    return hashed

async def generate_salt(length: int = 16) -> str:
    return secrets.token_hex(length)