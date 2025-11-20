import os
import time
from pathlib import Path

# carpool.pyが生成した画像のうち、1日以上経った古いものを削除する

def clean_old_images(image_dir="images", days_old=1):
    """Delete image files older than specified days"""
    if not os.path.exists(image_dir):
        return
    
    current_time = time.time()
    cutoff_time = current_time - (days_old * 24 * 60 * 60)
    
    for file_path in Path(image_dir).glob("*.png"):
        if file_path.stat().st_mtime < cutoff_time:
            try:
                file_path.unlink()
                print(f"Deleted: {file_path}")
            except OSError as e:
                print(f"Error deleting {file_path}: {e}")

if __name__ == "__main__":
    clean_old_images()