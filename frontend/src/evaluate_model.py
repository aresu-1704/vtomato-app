from ultralytics import YOLO

# Load model
model = YOLO("/models/predicts/yolov12/weights/best.pt")

data_yaml = r"C:\Users\anly1\Desktop\DoAnCoSo\data\Tomato\data.yaml"

metrics = model.val(data=data_yaml, split='test', save_json=True)

# In kết quả
print("\n===== Evaluation Metrics =====")
print(f"Precision (P):     {metrics.box.p.mean()*100:.4f}")
print(f"Recall (R):        {metrics.box.r.mean()*100:.4f}")
print(f"F1-score:          {metrics.box.f1.mean()*100:.4f}")
print(f"mAP@0.5:           {metrics.box.map50.mean()*100:.4f}")
print(f"mAP@0.5:0.95:      {metrics.box.map.mean()*100:.4f}")
print("==============================")
