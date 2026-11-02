#---------------------------------------------------------------------------------
# Target configuration
#---------------------------------------------------------------------------------
TARGET		:= EpicDuck
BUILD		:= build
SOURCES		:= source
DATA		:= data
INCLUDES	:= include

# App metadata for SMDH / CIA generation
APP_TITLE	:= Epic Duck 3DS
APP_AUTHOR	:= catbloxity
APP_DESC	:= A 3DS port of Epic Duck
APP_ICON	:= icon.png

#---------------------------------------------------------------------------------
# Tools & Flags
#---------------------------------------------------------------------------------
PREFIX		:= arm-none-eabi-
CC		:= $(PREFIX)gcc
CXX		:= $(PREFIX)g++
LD		:= $(PREFIX)c++
STRIP		:= $(PREFIX)strip
ELF2SMDH	:= smdhtool
3DSXTOOL	:= 3dsxtool
MAKEROM		:= makerom

ARCH		:= -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=cp15

CFLAGS		:= -g -Wall -O2 -ffunction-sections \
		   $(ARCH) -D__3DS__ $(INCLUDE)

CXXFLAGS	:= $(CFLAGS) -fno-rtti -fno-exceptions

LDFLAGS		:= -specs=3dsx.specs $(ARCH) -Wl,--gc-sections

LIBS		:= -lcitro2d -lcitro3d -lctru -lm

#---------------------------------------------------------------------------------
# Directory setup & Source discovery
#---------------------------------------------------------------------------------
export TOPDIR	:= $(CURDIR)
export BUILDDIR	:= $(CURDIR)/$(BUILD)

CFILES		:= $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.c))
CPPFILES	:= $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.cpp))
SFILES		:= $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.s))

OFILES		:= $(addprefix $(BUILD)/,$(notdir $(CFILES:.c=.o))) \
		   $(addprefix $(BUILD)/,$(notdir $(CPPFILES:.cpp=.o))) \
		   $(addprefix $(BUILD)/,$(notdir $(SFILES:.s=.o)))

export VPATH	:= $(foreach dir,$(SOURCES),$(CURDIR)/$(dir))

INCLUDE		:= $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) \
		   -I$(CURDIR)/$(BUILD) \
		   -I$(DEVKITPRO)/libctru/include \
		   -I$(DEVKITPRO)/portlibs/3ds/include

LIBPATHS	:= -L$(DEVKITPRO)/libctru/lib -L$(DEVKITPRO)/portlibs/3ds/lib

#---------------------------------------------------------------------------------
# Build Rules
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. (e.g. export DEVKITPRO=/opt/devkitpro)")
endif

export DEVKITARM	:= $(DEVKITPRO)/devkitARM
export PATH		:= $(DEVKITARM)/bin:$(PATH)

.PHONY: all clean $(BUILD)

all: $(BUILD) $(TARGET).3dsx $(TARGET).cia

$(BUILD):
	@mkdir -p $@

$(TARGET).cia: $(TARGET).elf
	@echo "building .cia..."
	@$(MAKEROM) -f cia -o $@ -elf $(TARGET).elf -rsf $(CURDIR)/build.rsf -icon $(TARGET).smdh 2>/dev/null || \
	 $(MAKEROM) -f cia -o $@ -elf $(TARGET).elf -rsf $(CURDIR)/build.rsf || echo "CIA build failed (makerom or rsf issue)"

$(TARGET).3dsx: $(TARGET).elf $(TARGET).smdh
	@echo "building .3dsx..."
	@$(3DSXTOOL) $(TARGET).elf $@ --smdh=$(TARGET).smdh

$(TARGET).smdh: $(APP_ICON)
	@echo "building smdh..."
	@smdhtool --create "$(APP_TITLE)" "$(APP_DESC)" "$(APP_AUTHOR)" $(APP_ICON) $@ 2>/dev/null || \
	 echo "smdh creation skipped (no icon or tool missing)"

$(TARGET).elf: $(OFILES)
	@echo "linking..."
	@$(LD) $(LDFLAGS) $(OFILES) $(LIBPATHS) $(LIBS) -o $@
	@$(STRIP) -s $@

$(BUILD)/%.o: %.c
	@echo "compiling $<..."
	@$(CC) $(CFLAGS) -c $< -o $@

$(BUILD)/%.o: %.cpp
	@echo "compiling $<..."
	@$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD)/%.o: %.s
	@echo "assembling $<..."
	@$(CC) -c $(ARCH) $< -o $@

clean:
	@echo "cleaning..."
	@rm -fr $(BUILD) $(TARGET).elf $(TARGET).3dsx $(TARGET).smdh $(TARGET).cia
