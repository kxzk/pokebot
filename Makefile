.PHONY: cap app

cap:
## make cap: take a screenshot on device
	@echo "[screenshot] taking..."
	@adb shell screencap /sdcard/img.png
	@echo "[screenshot] pulling..."
	@adb pull /sdcard/img.png img.png
	@echo "[screenshot] deleting..."
	@adb shell rm /sdcard/img.png

app:
## make app: run img-pixel-extract app
	@echo "[img-pixel-extract] running..."
	cd img-pixel-extract && python3 -m http.server 2323

help:
	@echo "Usage: \n"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/-/'
