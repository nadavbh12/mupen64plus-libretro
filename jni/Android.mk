LOCAL_PATH := $(call my-dir)
PERFTEST = 0
HAVE_HWFBE = 0
HAVE_SHARED_CONTEXT=0
SINGLE_THREAD=0
HAVE_OPENGL=1
GLES = 1

include $(CLEAR_VARS)

LOCAL_MODULE := retro

ROOT_DIR := ..
LIBRETRO_DIR = ../libretro

ifeq ($(TARGET_ARCH),arm)
LOCAL_ARM_MODE := arm
LOCAL_CFLAGS := -marm
WITH_DYNAREC := arm

COMMON_FLAGS := -DANDROID_ARM -DDYNAREC -DNEW_DYNAREC=3 -DNO_ASM
WITH_DYNAREC := arm

ifeq ($(TARGET_ARCH_ABI), armeabi-v7a)
#HAVE_VULKAN :=1
LOCAL_ARM_NEON := true
HAVE_NEON := 1
endif

endif

ifeq ($(TARGET_ARCH),x86)
COMMON_FLAGS := -DANDROID_X86 -DDYNAREC -D__SSE2__ -D__SSE__ -D__SOFTFP__
WITH_DYNAREC := x86
#HAVE_VULKAN :=1
endif

ifeq ($(TARGET_ARCH),mips)
COMMON_FLAGS := -DANDROID_MIPS
#HAVE_VULKAN :=1
endif

ifeq ($(NDK_TOOLCHAIN_VERSION), 4.6)
COMMON_FLAGS += -DANDROID_OLD_GCC
endif

SOURCES_C   :=
SOURCES_CXX :=
SOURCES_ASM :=
INCFLAGS    :=

HAVE_OPENGL = 1

include $(ROOT_DIR)/Makefile.common

LOCAL_SRC_FILES := $(SOURCES_CXX) $(SOURCES_C) $(SOURCES_ASM)

# Video Plugins

ifeq ($(HAVE_HWFBE), 1)
COMMON_FLAGS += -DHAVE_HWFBE
endif

ifeq ($(HAVE_SHARED_CONTEXT), 1)
COMMON_FLAGS += -DHAVE_SHARED_CONTEXT
endif

ifeq ($(SINGLE_THREAD), 1)
COMMON_FLAGS += -DSINGLE_THREAD
endif

PLATFORM_EXT := unix

ifeq ($(GLIDE64MK2),1)
COMMON_FLAGS += -DGLIDE64_MK2
endif

COMMON_FLAGS += -DM64P_CORE_PROTOTYPES -D_ENDUSER_RELEASE -DM64P_PLUGIN_API -D__LIBRETRO__ -DINLINE="inline" -DANDROID -DSINC_LOWER_QUALITY -DHAVE_LOGGER -fexceptions $(GLFLAGS) -DHAVE_OPENGLES -DHAVE_OPENGLES2
COMMON_OPTFLAGS = -O3 -ffast-math

LOCAL_CFLAGS += $(COMMON_OPTFLAGS) $(COMMON_FLAGS) $(INCFLAGS)
LOCAL_CXXFLAGS += $(COMMON_OPTFLAGS) $(COMMON_FLAGS) $(INCFLAGS)

ifeq ($(HAVE_VULKAN),1)
LOCAL_CXXFLAGS += -std=c++11
endif

LOCAL_LDLIBS += -lGLESv2
LOCAL_C_INCLUDES = $(CORE_DIR)/src $(CORE_DIR)/src/api $(VIDEODIR_GLIDE)/Glitch64/inc $(LIBRETRO_DIR)/libco $(LIBRETRO_DIR)

ifeq ($(PERFTEST), 1)
LOCAL_CFLAGS += -DPERF_TEST
LOCAL_CXXFLAGS += -DPERF_TEST
endif

include $(BUILD_SHARED_LIBRARY)

