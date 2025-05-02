from PIL import ImageFont, ImageDraw, Image
import torch
from ultralytics import YOLO
import io
import base64

from services.disease_info_service import DiseaseService


class PredictService:
    def __init__(self, model_path: str, class_names: list[str], descriptions: dict[str, str] = None, input_size: int = 640):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"[🔧 PredictService] Using device: {self.device}")

        # Load YOLO model
        self.model = YOLO(model_path)
        self.model.to(self.device)
        self.model.eval()

        self.class_names = class_names
        self.descriptions = descriptions or {}
        self.input_size = input_size

        self.font = ImageFont.truetype("utils/fonts/roboto.ttf", 20)

        fixed_colors = [
            (255, 255, 0),
            (255, 0, 255),
            (0, 0, 0),
            (255, 255, 255),
            (128, 0, 255),
            (255, 165, 0),
            (0, 0, 139),
            (255, 105, 180)
        ]

        self.class_colors = {
            name: fixed_colors[i % len(fixed_colors)]
            for i, name in enumerate(class_names)
        }

    def predict(self, image_bytes: bytes) -> dict:
        nonerotate_original_image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        original_image = nonerotate_original_image.rotate(-90, expand=True)
        original_width, original_height = original_image.size
        resized_image = original_image.resize((self.input_size, self.input_size))

        results = self.model(resized_image)
        predictions = results[0].boxes
        predictions_count = 0

        draw = ImageDraw.Draw(original_image)

        detected_class_indices = []

        for idx, cls in enumerate(predictions.cls):
            class_name = self.class_names[int(cls)]
            new_class_name = self.descriptions.get(class_name, class_name)

            if class_name == 'Healthy':
                continue

            confidence = float(predictions.conf[idx])
            box = predictions.xyxy[idx].tolist()

            x1, y1, x2, y2 = box
            scale_x = original_width / self.input_size
            scale_y = original_height / self.input_size
            x1 *= scale_x
            x2 *= scale_x
            y1 *= scale_y
            y2 *= scale_y

            color = self.class_colors[class_name]
            draw.rectangle([x1, y1, x2, y2], outline=color, width=3)
            label = f"{new_class_name} ({confidence:.2f})"
            draw.text((x1, y1 - 25), label, fill=color, font=self.font)

            predictions_count += 1
            if int(cls) not in detected_class_indices:
                detected_class_indices.append(int(cls))

        if predictions_count == 0:
            return {
                "status": "no_disease",
                "message": "No disease detected in the image",
                "class_count": 0,
                "class_indices": [],
            }

        buffered = io.BytesIO()
        original_image.save(buffered, format="JPEG")
        img_str = base64.b64encode(buffered.getvalue()).decode("utf-8")

        return {
            "status": "success",
            "image": img_str,
            "class_count": predictions_count,
            "class_indices": detected_class_indices,
        }
