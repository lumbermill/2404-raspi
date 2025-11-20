# See tachibana repository for the original. (This is a copy for the reference)

import cv2, numpy, math, os, time

storage = os.path.expanduser('~/carpool/storage')
if not os.path.exists(storage):
    os.makedirs(storage)
    
with_window = False

cam = cv2.VideoCapture(0)

from ultralytics import YOLO
model = YOLO('yolo11n_ncnn_model')

n_cars_prev, n_cars_now, streak = 0, 0, 0
# 物体検出を行い、車の数をカウントする
while True:
    ret, image = cam.read()
    results = model(image, verbose=False)
    boxes = results[0].boxes
    font = cv2.FONT_HERSHEY_SIMPLEX
    n_cars = 0
    for b in boxes:
        pt1 = (int(b.xyxy[0][0]),int(b.xyxy[0][1]))
        pt2 = (int(b.xyxy[0][2]),int(b.xyxy[0][3]))
        # 車は青の矩形で囲む、それ以外の物体はグレーの矩形で囲む
        if b.cls == 2:
            n_cars += 1
            cv2.rectangle(image,pt1,pt2,(255,0,0),1)
        else:
            cv2.rectangle(image,pt1,pt2,(128,128,128),1)
    m = "%d cars" % (n_cars)
    cv2.putText(image,m,(10,460),font,1,(0,255,0),3,cv2.LINE_AA)

    if n_cars == n_cars_now:
        streak += 1
    else:
        streak = 0
    n_cars_now = n_cars
    
    on_time = int(time.time()) % 1200 == 0  # 1200 = 20min

    if (streak > 10 and n_cars_now != n_cars_prev) or on_time:
        f = "%s-%d.jpg" % (time.strftime('%y%m%d%H%M%S'), n_cars_now)
        filename = os.path.join(storage, f)
        cv2.imwrite(filename, image)
        print("%d -> %d: Saved image to %s" % (n_cars_prev, n_cars_now, filename))
        n_cars_prev = n_cars_now
    if with_window:
        cv2.imshow('yolo-carpool',image)
        if cv2.waitKey(1) != -1:
            break

cam.release()
if with_window:
    cv2.destroyAllWindows()
