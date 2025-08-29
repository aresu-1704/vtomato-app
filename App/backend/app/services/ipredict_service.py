from abc import ABC, abstractmethod

class IPredictService(ABC):
    @abstractmethod
    def predict(self, image_bytes: bytes) -> dict:
        pass
