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

def start_redis():
    redis_path = os.path.abspath('redis-server.exe')
    if not is_redis_running():
        try:
            subprocess.Popen([redis_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print("Redis started.")
            time.sleep(1)
        except Exception as e:
            print(f"Failed to start Redis: {e}")
    else:
        print("Redis is already running.")