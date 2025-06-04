import subprocess
import socket
import time
import os

def is_redis_running(host="localhost", port=6379):
    try:
        with socket.create_connection((host, port), timeout=2):
            return True
    except (socket.timeout, ConnectionRefusedError):
        return False

def start_redis(redis_path):
    redis_path = os.path.abspath(redis_path)
    if not is_redis_running():
        try:
            subprocess.Popen([redis_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print("Redis đã khởi động.")
            time.sleep(1)
        except Exception as e:
            print(f"Lỗi khi khởi động Redis: {e}")
    else:
        print("Redis đang chạy trước đó.")