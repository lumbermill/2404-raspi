import cv2, numpy, math

cv2.namedWindow('yolo-carpool')
cam = cv2.VideoCapture(0)

from ultralytics import YOLO
model = YOLO('yolo11n_ncnn_model')
while True:
    ret, image = cam.read()
    results = model(image)
    boxes = results[0].boxes
    n_cars = 0
    for b in boxes:
        pt1 = (int(b.xyxy[0][0]),int(b.xyxy[0][1]))
        pt2 = (int(b.xyxy[0][2]),int(b.xyxy[0][3]))
        if b.cls == 2: # car
            cv2.rectangle(image,pt1,pt2,(255,0,0),1)
            n_cars += 1
        else:
            cv2.rectangle(image,pt1,pt2,(128,128,128),1)
    m = "%d cars" % (n_cars)
    font = cv2.FONT_HERSHEY_SIMPLEX
    cv2.putText(image,m,(10,460),font,1,(0,255,0),3,cv2.LINE_AA)

    cv2.imshow('yolo-carpool',image)
    k = cv2.waitKey(1)
    if k != -1:
        break

cam.release()
cv2.destroyAllWindows()
