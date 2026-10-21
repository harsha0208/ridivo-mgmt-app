# Ridivo Event Management — Flutter
# No flavors; env files under env/ drive API_BASE_URL via --dart-define-from-file.

ENV ?= dev
MODE ?= debug
DEVICE ?=

# Prefer FVM when installed (matches ridivo-app SDK pinning once .fvmrc is present).
FLUTTER := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm flutter" || echo flutter)

ifeq ($(ENV),dev)
  ENV_FILE := env/dev.env
else ifeq ($(ENV),network)
  ENV_FILE := env/network.env
else ifeq ($(ENV),android)
  ENV_FILE := env/android.env
else
  $(error Unknown ENV=$(ENV). Use dev, network, or android)
endif

ifeq ($(MODE),release)
  RUN_FLAG := --release
else ifeq ($(MODE),profile)
  RUN_FLAG := --profile
else ifeq ($(MODE),debug)
  RUN_FLAG :=
else
  $(error Unknown MODE=$(MODE). Use debug, profile, or release)
endif

DART_DEFINES := --dart-define-from-file=$(ENV_FILE)

# Pick a device without an interactive prompt.
# Prefer physical iPhone over USB (wireless CoreDevice often yields empty xcodebuild settings).
# mobile_scanner/MLKit is unreliable on Apple Silicon sims — phone first, then Android, then sim.
define PICK_DEVICE
python3 -c "import json,sys; ds=json.load(sys.stdin);\
ios_p=[d for d in ds if d.get('targetPlatform')=='ios' and not d.get('emulator')];\
wired=[d for d in ios_p if str(d.get('connectionInterface','')).lower()=='usb'];\
ios_s=[d for d in ds if d.get('targetPlatform')=='ios' and d.get('emulator')];\
and_=[d for d in ds if str(d.get('targetPlatform','')).startswith('android')];\
pick=(wired or ios_p or and_ or ios_s); print(pick[0]['id'] if pick else '')"
endef

.PHONY: help get analyze test devices run run-android run-ios build-apk build-ios clean

help:
	@echo "Usage:"
	@echo "  make get"
	@echo "  make run ENV=dev|network|android MODE=debug|profile|release [DEVICE=id]"
	@echo "      (auto-picks physical iPhone when DEVICE is unset — no prompt)"
	@echo "  make run-android ENV=android MODE=debug"
	@echo "  make run-ios ENV=dev MODE=debug"
	@echo "  make analyze / make test / make devices"
	@echo "  make build-apk / make build-ios"
	@echo "  make clean"
	@echo ""
	@echo "ENV files:"
	@echo "  dev     → env/dev.env       (localhost:8080)"
	@echo "  network → env/network.env   (remote api-dev)"
	@echo "  android → env/android.env   (10.0.2.2:8080 for emulator)"
	@echo ""
	@echo "Tip: use a physical iPhone (USB preferred) for QR scan. Apple Silicon sims lack MLKit arm64."
	@echo "iOS device: Xcode must have an Apple ID (Settings > Accounts) and Team 6RTB379774."

get:
	$(FLUTTER) pub get
	@# CocoaPods required — SPM is disabled (secure_storage / mobile_scanner).
	cd ios && pod install

analyze:
	$(FLUTTER) analyze

test:
	$(FLUTTER) test

devices:
	$(FLUTTER) devices

run:
ifneq ($(DEVICE),)
	$(FLUTTER) run $(RUN_FLAG) $(DART_DEFINES) -d "$(DEVICE)"
else
	@dev=$$($(FLUTTER) devices --machine | $(PICK_DEVICE)); \
	if [ -z "$$dev" ]; then echo "No iOS/Android device found. Run: make devices"; exit 1; fi; \
	echo "Using device: $$dev"; \
	$(FLUTTER) run $(RUN_FLAG) $(DART_DEFINES) -d "$$dev"
endif

# Prefer an Android device when several are attached.
run-android:
	@dev=$$($(FLUTTER) devices --machine | python3 -c "import sys,json; ds=json.load(sys.stdin); \
a=[d for d in ds if d.get('targetPlatform','').startswith('android')]; \
print(a[0]['id'] if a else '')"); \
	if [ -z "$$dev" ]; then echo "No Android device found"; exit 1; fi; \
	echo "Using Android device: $$dev"; \
	$(FLUTTER) run $(RUN_FLAG) $(DART_DEFINES) -d "$$dev"

# Prefer a physical iPhone over simulator when several are attached.
run-ios:
	@dev=$$($(FLUTTER) devices --machine | python3 -c "import sys,json; ds=json.load(sys.stdin); \
phones=[d for d in ds if d.get('targetPlatform')=='ios' and not d.get('emulator')]; \
wired=[d for d in phones if str(d.get('connectionInterface','')).lower()=='usb']; \
sims=[d for d in ds if d.get('targetPlatform')=='ios' and d.get('emulator')]; \
pick=(wired or phones or sims); print(pick[0]['id'] if pick else '')"); \
	if [ -z "$$dev" ]; then echo "No iOS device found"; exit 1; fi; \
	echo "Using iOS device: $$dev"; \
	$(FLUTTER) run $(RUN_FLAG) $(DART_DEFINES) -d "$$dev"

build-apk:
	$(FLUTTER) build apk --release $(DART_DEFINES)

build-ios:
	$(FLUTTER) build ipa --release $(DART_DEFINES)

clean:
	$(FLUTTER) clean
