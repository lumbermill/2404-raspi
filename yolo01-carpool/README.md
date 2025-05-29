# carpool app


## preparation

```
~/venv/bin/pip3 install ncnn
```

```
from ultralytics import YOLO

model = YOLO("yolo11n.pt")
model.export(format="ncnn")
```
