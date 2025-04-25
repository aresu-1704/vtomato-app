import cv2
import os
import random
import yaml
import matplotlib.pyplot as plt
from matplotlib import rcParams

def load_config(yaml_file):
    with open(yaml_file, 'r') as file:
        config = yaml.safe_load(file)
    return config

def read_labels(label_file):
    with open(label_file, 'r') as f:
        labels = f.readlines()
    return [list(map(float, label.strip().split())) for label in labels]

def draw_bounding_boxes(img, labels, class_names, axs, idx):
    h, w, _ = img.shape
    for label in labels:
        class_id, x_center, y_center, width, height = label
        # Chuyển tọa độ chuẩn hóa về pixel
        x1 = int((x_center - width / 2) * w)
        y1 = int((y_center - height / 2) * h)
        x2 = int((x_center + width / 2) * w)
        y2 = int((y_center + height / 2) * h)

        cv2.rectangle(img, (x1, y1), (x2, y2), (0, 255, 255), 2)

        class_name = class_names[int(class_id)]

        axs[idx // 4, idx % 4].text(x1, y1 - 10, class_name, color='cyan', fontsize=12, fontweight='bold',
                                    verticalalignment='bottom', horizontalalignment='left')

rcParams['font.family'] = 'Tahoma'
rcParams['axes.unicode_minus'] = False

yaml_file = r"C:\Users\anly1\Downloads\Tomato\data.yaml"

config = load_config(yaml_file)

image_dir = config['train']
label_dir = os.path.join(os.path.dirname(image_dir), 'labels')

class_names = config['names']

print(f"Checking image directory: {image_dir}")
print(f"Checking label directory: {label_dir}")

if not os.path.exists(image_dir):
    print(f"Directory {image_dir} not found! Please check the path.")
else:
    image_files = [f for f in os.listdir(image_dir) if f.endswith('.jpg') or f.endswith('.png')]

    random_images = random.sample(image_files, 8)

    fig, axs = plt.subplots(2, 4, figsize=(15, 8))

    for idx, img_file in enumerate(random_images):
        img_path = os.path.join(image_dir, img_file)
        img = cv2.imread(img_path)
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        label_file = os.path.join(label_dir, os.path.splitext(img_file)[0] + '.txt')
        if os.path.exists(label_file):
            labels = read_labels(label_file)

            draw_bounding_boxes(img, labels, class_names, axs, idx)

            row = idx // 4
            col = idx % 4
            axs[row, col].imshow(img)
            axs[row, col].axis('off')
        else:
            print(f"Label file for {img_file} not found.")

    plt.tight_layout()
    plt.show()
