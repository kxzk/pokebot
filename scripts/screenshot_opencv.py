import subprocess

import cv2
import numpy as np

# Capture the screenshot binary data
result = subprocess.run(["adb", "exec-out", "screencap", "-p"], stdout=subprocess.PIPE)
# Convert the binary data to a NumPy array and decode it as an image
image = cv2.imdecode(np.frombuffer(result.stdout, np.uint8), cv2.IMREAD_COLOR)
