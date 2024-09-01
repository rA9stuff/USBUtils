IGCC            = xcrun -sdk iphoneos gcc -miphoneos-version-min=12.0
MGCC_FLAGS      = -framework IOKit -framework Foundation -Os -Wall $(CFLAGS) -DDEBUG
IGCC_FLAGS      = $(MGCC_FLAGS) -arch arm64 -DIPHONEOS_ARM -I/Users/runner/work/USBUtils/USBUtils

SOURCE          = \
                main.m \
                CalleeObject.m \
                USBUtils.m

OUTPUT          = usbutils_iphoneos_arm64

.PHONY: all static clean

all: $(OUTPUT)

$(OUTPUT): $(SOURCE)
	$(IGCC) $(IGCC_FLAGS) -o $(OUTPUT) $(SOURCE)

static:
	$(MGCC) $(IGCC_FLAGS) $(SOURCE) $(STATIC32) -o $(OUTPUT)

clean:
	-$(RM) $(OUTPUT)
