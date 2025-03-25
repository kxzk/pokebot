.PHONY: cap pixel

cap:
	@echo "[screenshot] taking..."
	@adb shell screencap /sdcard/img.png
	@echo "[screenshot] pulling..."
	@adb pull /sdcard/img.png img.png
	@echo "[screenshot] deleting..."
	@adb shell rm /sdcard/img.png

pixel:
	@echo "[img-pixel-extract] running..."
	cd img-pixel-extract && python3 -m http.server 2323
