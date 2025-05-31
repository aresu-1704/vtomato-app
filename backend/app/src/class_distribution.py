import os
import matplotlib.pyplot as plt
from collections import Counter

class_names = [
    'Early Blight', 'Healthy', 'Late Blight', 'Leaf Miner', 'Leaf Mold',
    'Mosaic Virus', 'Septoria', 'Spider Mites', 'Yellow Leaf Curl Virus'
]

def count_yolo_class_distribution(annotation_folder):
    class_counts = Counter()

    for filename in os.listdir(annotation_folder):
        if filename.endswith(".txt"):
            with open(os.path.join(annotation_folder, filename), 'r') as f:
                for line in f:
                    class_id = int(line.split()[0])
                    class_counts[class_id] += 1

    return dict(class_counts)


def plot_class_distribution(class_counts):
    classes = list(class_counts.keys())
    counts = list(class_counts.values())

    class_labels = [class_names[class_id] for class_id in classes]

    plt.figure(figsize=(10, 6))
    plt.bar(class_labels, counts, color='green')
    plt.xlabel('Tên lớp')
    plt.ylabel('Số lượng')
    plt.title('Phân bố nhãn trong tập huấn luyện')
    plt.xticks(rotation=45, ha='right')
    plt.show()


# Ví dụ sử dụng
annotation_folder = r'C:\Users\anly1\Downloads\train\labels'
class_counts = count_yolo_class_distribution(annotation_folder)
plot_class_distribution(class_counts)
