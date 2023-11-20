cmake_minimum_required(VERSION 3.10)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Prevent error from CLion
SET(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Set compiler for ARM
set(CMAKE_C_COMPILER "arm-none-eabi-gcc")
set(CMAKE_CXX_COMPILER "arm-none-eabi-g++")
set(CMAKE_OBJCOPY "arm-none-eabi-objcopy")

project(template C ASM)

include_directories(
        lib/CMSIS/Core/Include
        lib/CMSIS/Device/ST/STM32G4xx/Include
        lib/HAL/Inc
)

SET(USER_SOURCES
        lib/CMSIS/Device/ST/STM32G4xx/Source/Templates/gcc/startup_stm32g431xx.s
        lib/CMSIS/Device/ST/STM32G4xx/Source/Templates/system_stm32g4xx.c
        lib/HAL/Src/stm32g4xx_ll_rcc.c
        lib/HAL/Src/stm32g4xx_ll_gpio.c
        lib/HAL/Src/stm32g4xx_ll_utils.c
        src/main.c
        )

SET(CMAKE_EXE_LINKER_FLAGS "-Wl,--no-wchar-size-warning,--gc-sections,-M=binary.map,-T./../chip/STM32G431KB.ld")

set(CMAKE_C_FLAGS "-g -O0 -DSTM32G431xx -mthumb -mthumb-interwork -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 --specs=nosys.specs -ffreestanding -flto")

add_executable(template ${USER_SOURCES})
