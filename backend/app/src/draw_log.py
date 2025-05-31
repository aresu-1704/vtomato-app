import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("models/ai_models/yolov12n/results.csv")

df['epoch'] = pd.to_numeric(df['epoch'], errors='coerce')

plot_columns = [
    "train/box_loss", "train/cls_loss", "train/dfl_loss",
    "val/box_loss", "val/cls_loss", "val/dfl_loss",
    "metrics/precision(B)", "metrics/recall(B)", "metrics/mAP50(B)", "metrics/mAP50-95(B)",
    "lr/pg0", "lr/pg1", "lr/pg2"
]

available_columns = [col for col in plot_columns if col in df.columns]

for col in available_columns:
    plt.figure(figsize=(10, 6))
    plt.plot(df["epoch"], df[col], label=col, color="tab:blue")
    plt.title(col)
    plt.xlabel("Epoch")
    plt.ylabel(col)
    plt.grid(True)
    plt.legend()
    plt.tight_layout()
    plt.show()