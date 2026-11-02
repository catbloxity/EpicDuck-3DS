#---------------------------------------------------------------------------------
# Epic Duck 3DS Makefile
#---------------------------------------------------------------------------------
TARGET		:= EpicDuck
BUILD		:= build
SOURCES		:= source
DATA		:= data
INCLUDES	:= include

APP_TITLE	:= Epic Duck 3DS
APP_AUTHOR	:= catbloxity
APP_DESC	:= A 3DS port of Epic Duck
APP_ICON	:= icon.png

#---------------------------------------------------------------------------------
# Force correct paths (works in Docker + local)
#---------------------------------------------------------------------------------
DEVKITPRO	?= /opt/devkitpro
DEVKITARM	:= $(DEVKITPRO)/devkitARM

PREFIX		:= arm-none-eabi-
CC		:= $(PREFIX)gcc
CXX		:= $(PREFIX)g++
LD		:= $(PREFIX)g++
STRIP		:= $(PREFIX)strip
3DSXTOOL	:= 3dsxtool
MAKEROM		:= makerom

ARCH		:= -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=cp15

INCLUDE		:= -I$(CURDIR)/include \
		   -I$(CURDIR)/$(BUILD) \
		   -I$(DEVKITPRO)/libctru/include \
		   -I$(DEVKITPRO)/portlibs/3ds/include

CFLAGS		:= -g -Wall -O2 -ffunction-sections \
		   $(ARCH) -D__3DS__ $(INCLUDE)

CXXFLAGS	:= $(CFLAGS) -fno-rtti -fno-exceptions

LDFLAGS		:= -specs=3dsx.specs $(ARCH) -Wl,--gc-sections

LIBS		:= -lctru -lm
LIBPATHS	:= -L$(DEVKITPRO)/libctru/lib -L$(DEVKITPRO)/portlibs/3ds/lib

#---------------------------------------------------------------------------------
CFILES		:= $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.c))
CPPFILES	:= $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.cpp))
SFILES		:= $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.s))

OFILES		:= $(addprefix $(BUILD)/,$(notdir $(CFILES:.c=.o))) \
		   $(addprefix $(BUILD)/,$(notdir $(CPPFILES:.cpp=.o))) \
		   $(addprefix $(BUILD)/,$(notdir $(SFILES:.s=.o)))

VPATH		:= $(foreach dir,$(SOURCES),$(CURDIR)/$(dir))

export PATH	:= $(DEVKITARM)/bin:$(PATH)

.PHONY: all clean

all: $(BUILD) $(TARGET).elf $(TARGET).3dsx
	@$(MAKE) $(TARGET).cia || true

$(BUILD):
	@mkdir -p $@

$(TARGET).cia: $(TARGET).elf
	@echo "building .cia..."
	@$(MAKEROM) -f cia -o $@ -elf $(TARGET).elf -rsf $(CURDIR)/build.rsf $(if $(wildcard $(TARGET).smdh),-icon $(TARGET).smdh,) 2>/dev/null || \
	 echo "Note: CIA skipped (makerom missing or failed)"

$(TARGET).3dsx: $(TARGET).elf
	@echo "building .3dsx..."
	@if [ -f $(TARGET).smdh ]; then \
		$(3DSXTOOL) $(TARGET).elf $@ --smdh=$(TARGET).smdh; \
	else \
		$(3DSXTOOL) $(TARGET).elf $@; \
	fi

$(TARGET).smdh:
	@if [ -f $(APP_ICON) ] && command -v smdhtool >/dev/null 2>&1; then \
		echo "building smdh..."; \
		smdhtool --create "$(APP_TITLE)" "$(APP_DESC)" "$(APP_AUTHOR)" $(APP_ICON) $@; \
	else \
		echo "No icon or smdhtool - skipping smdh"; \
	fi

$(TARGET).elf: $(OFILES)
	@echo "linking $(TARGET).elf..."
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
