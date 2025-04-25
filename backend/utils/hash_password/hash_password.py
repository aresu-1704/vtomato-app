import hashlib
import secrets

def hash_password(password: str, salt: str) -> str:
    """
    Trả về chuỗi hash của mật khẩu sau khi kết hợp với muối (salt).
    """
    # Ghép salt + password (hoặc password + salt đều được, miễn nhất quán)
    salted = salt + password
    hashed = hashlib.sha256(salted.encode('utf-8')).hexdigest()
    return hashed

def generate_salt(length: int = 16) -> str:
    return secrets.token_hex(length)