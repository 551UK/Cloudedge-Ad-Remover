ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CloudedgeAdRemover
CloudedgeAdRemover_FILES = Tweak.xm
CloudedgeAdRemover_CFLAGS = -fobjc-arc
CloudedgeAdRemover_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
