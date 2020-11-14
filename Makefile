######################################
# Project name
TARGET = g431-template

######################################
# building variables
# debug build?
DEBUG = 1
# optimization
OPT = -Og


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

######################################
# source
######################################
# C sources
C_SOURCES =  \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_adc.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_comp.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_cordic.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_crc.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_crs.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_dac.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_dma.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_exti.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_fmac.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_gpio.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_hrtim.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_i2c.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_lptim.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_lpuart.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_opamp.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_pwr.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_rcc.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_rng.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_rtc.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_spi.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_tim.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_ucpd.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_usart.c \
lib/STM32G4xx_HAL_Driver/Src/stm32g4xx_ll_utils.c \
src/main.c \
src/hardware/stm32g4xx_it.c \
src/hardware/system_stm32g4xx.c 

# ASM sources
ASM_SOURCES = chip/startup_stm32g431xx.s


#######################################
# binaries
#######################################
PREFIX = arm-none-eabi-
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

CUBEPROG = ~/.STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer.sh
 
#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4

# fpu
FPU = -mfpu=fpv4-sp-d16

# float-abi
FLOAT-ABI = -mfloat-abi=hard

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  \
-DSTM32G431xx \
-DUSE_FULL_LL_DRIVER


# AS includes
AS_INCLUDES = 

# C includes
C_INCLUDES =  \
-I. \
-Ilib/STM32G4xx_HAL_Driver/Inc \
-Ilib/CMSIS/Device/ST/STM32G4xx/Include \
-Ilib/CMSIS/Include \
-Isrc \
-Isrc/hardware

# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = chip/STM32G431KB.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))


#######################################

all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin


$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

flash: all
	@sleep 1
	$(CUBEPROG) -c port=SWD --write `pwd`/$(BUILD_DIR)/$(TARGET).bin 0x08000000
	#st-flash write `pwd`/$(BUILD_DIR)/$(TARGET).bin 0x08000000

clean:
	-rm -fR $(BUILD_DIR)
