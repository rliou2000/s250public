# Copyright Statement:
#
# (C) 2019  Airoha Technology Corp. All rights reserved.
#
# This software/firmware and related documentation ("Airoha Software") are
# protected under relevant copyright laws. The information contained herein
# is confidential and proprietary to Airoha Technology Corp. ("Airoha") and/or its licensors.
# Without the prior written permission of Airoha and/or its licensors,
# any reproduction, modification, use or disclosure of Airoha Software,
# and information contained herein, in whole or in part, shall be strictly prohibited.
# You may only use, reproduce, modify, or distribute (as applicable) Airoha Software
# if you have agreed to and been bound by the applicable license agreement with
# Airoha ("License Agreement") and been granted explicit permission to do so within
# the License Agreement ("Permitted User").  If you are not a Permitted User,
# please cease any access or use of Airoha Software immediately.
# BY OPENING THIS FILE, RECEIVER HEREBY UNEQUIVOCALLY ACKNOWLEDGES AND AGREES
# THAT AIROHA SOFTWARE RECEIVED FROM AIROHA AND/OR ITS REPRESENTATIVES
# ARE PROVIDED TO RECEIVER ON AN "AS-IS" BASIS ONLY. AIROHA EXPRESSLY DISCLAIMS ANY AND ALL
# WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NONINFRINGEMENT.
# NEITHER DOES AIROHA PROVIDE ANY WARRANTY WHATSOEVER WITH RESPECT TO THE
# SOFTWARE OF ANY THIRD PARTY WHICH MAY BE USED BY, INCORPORATED IN, OR
# SUPPLIED WITH AIROHA SOFTWARE, AND RECEIVER AGREES TO LOOK ONLY TO SUCH
# THIRD PARTY FOR ANY WARRANTY CLAIM RELATING THERETO. RECEIVER EXPRESSLY ACKNOWLEDGES
# THAT IT IS RECEIVER'S SOLE RESPONSIBILITY TO OBTAIN FROM ANY THIRD PARTY ALL PROPER LICENSES
# CONTAINED IN AIROHA SOFTWARE. AIROHA SHALL ALSO NOT BE RESPONSIBLE FOR ANY AIROHA
# SOFTWARE RELEASES MADE TO RECEIVER'S SPECIFICATION OR TO CONFORM TO A PARTICULAR
# STANDARD OR OPEN FORUM. RECEIVER'S SOLE AND EXCLUSIVE REMEDY AND AIROHA'S ENTIRE AND
# CUMULATIVE LIABILITY WITH RESPECT TO AIROHA SOFTWARE RELEASED HEREUNDER WILL BE,
# AT AIROHA'S OPTION, TO REVISE OR REPLACE AIROHA SOFTWARE AT ISSUE,
# OR REFUND ANY SOFTWARE LICENSE FEES OR SERVICE CHARGE PAID BY RECEIVER TO
# AIROHA FOR SUCH AIROHA SOFTWARE AT ISSUE.
#
 
#######################################################
# Project vairables assignment

SOURCE_DIR = ../../../../..
BINPATH = $(SOURCE_DIR)/tools/gcc/gcc-arm-none-eabi/bin

PWD= $(shell pwd)
SDK_PATH    = $(abspath $(PWD)/$(SOURCE_DIR))

FEATURE ?= feature.mk
include $(FEATURE)
DEBUG = 0
FLOAT_TYPE = hard
BUILD_DIR = $(PWD)/Build

# Project name
PROJ_NAME = ag3335_bootloader
PROJ_PATH = $(PWD)
OUTPATH = $(PWD)/Build

#######################################################
# Gloabl Config
-include $(SOURCE_DIR)/.config
# IC Config
-include $(SOURCE_DIR)/config/chip/$(IC_CONFIG)/chip.mk
# Board Config
#-include $(SOURCE_DIR)/config/board/$(BOARD_CONFIG)/board.mk
# HAL driver files
include $(SOURCE_DIR)/driver/chip/$(IC_CONFIG)/module.mk
# EPT Config
#include $(SOURCE_DIR)/driver/board/$(BOARD_CONFIG)/ept/module.mk


#######################################################
# Main APP files
APP_PATH = $(patsubst $(SDK_PATH)/%,%,$(abspath $(dir $(PWD))))
APP_PATH_SRC = $(APP_PATH)/src


##############################################################################
#
# SDK source files
#
##############################################################################
S_FILES += $(APP_PATH)/GCC/startup_bootloader.s
C_FILES += $(APP_PATH)/GCC/syscalls.c
C_FILES += $(APP_PATH)/src/bl_dbgprint.c
C_FILES += $(APP_PATH)/src/custom_blconfig.c
C_FILES += $(APP_PATH)/src/bl_rom_parameter.c
C_FILES += $(APP_PATH)/src/main.c

ifeq ($(IC_CONFIG_AG3335_E1), y)
CFLAGS += -DIC_CONFIG_AG3335_E1
endif

# lzma files
include $(SOURCE_DIR)/middleware/third_party/lzma_decoder/module.mk

ifeq ($(MTK_FOTA_ENABLE),y)
ifeq ($(MTK_BL_FOTA_CUST_ENABLE),y)
C_FILES += $(APP_PATH)/src/custom_fota.c
else
ifeq ($(MTK_FOTA_VIA_RACE_CMD),y)
# NEW_FOTA
include $(SOURCE_DIR)/driver/board/component/bsp_flash/module.mk
ifeq ($(BSP_EXTERNAL_SERIAL_FLASH_ENABLE), y)
#include $(SOURCE_DIR)/driver/board/component/bsp_external_flash/module.mk
endif
include $(SOURCE_DIR)/middleware/MTK/fota/module.mk
C_FILES += $(APP_PATH)/src/bl_fota_util.c
C_FILES += $(APP_PATH)/src/bl_fota_flash_ctrl.c
C_FILES += $(APP_PATH)/src/bl_fota_upgrade.c
CFLAGS  += -DMOD_CFG_FOTA_DISABLE_OS
CFLAGS  += -DBL_FOTA_ENABLE
CFLAGS  += -DBL_FOTA_DEBUG
CFLAGS += -I$(SOURCE_DIR)/middleware/MTK/fota/inc/race
CFLAGS += -I$(SOURCE_DIR)/middleware/MTK/fota/inc/internal
else
C_FILES += $(APP_PATH)/src/bl_fota.c
C_FILES += middleware/third_party/mbedtls/library/sha1.c
CFLAGS += -DMBEDTLS_CONFIG_FILE='<config-mtk-sha1.h>'
endif
endif
endif

ifeq ($(MTK_BOOTLOADER_USE_MBEDTLS),y)
# mbedtls
CFLAGS +=-DMTK_BOOTLOADER_USE_MBEDTLS
include $(SOURCE_DIR)/middleware/third_party/mbedtls/module.mk
CFLAGS  += -DMTK_BOOTLOADER_USE_MBEDTLS
ifeq ($(MTK_SECURE_BOOT_ENABLE),y)
CFLAGS += -DMBEDTLS_CONFIG_FILE='<config-mtk-secure_boot.h>'
endif
endif


# fatfs files
ifeq ($(MTK_FOTA_FS_ENABLE),y)
include $(SOURCE_DIR)/middleware/third_party/fatfs/module.mk
endif

ifeq ($(MTK_HAL_NO_LOG_ENABLE),y)
CFLAGS += -DMTK_HAL_NO_LOG_ENABLE
endif

ifeq ($(MTK_BL_DCXO_KVALUE_SW),y)
CFLAGS += -DBL_DCXO_KVALUE_SW
endif

ifeq ($(MTK_CAL_DCXO_CAPID),0)
CFLAGS += -DBL_RUN_DCXO_CAL
  ifneq ($(MTK_BL_DCXO_KVALUE_SW),y)
  CFLAGS += -DBL_CAL_DCXO_CAPID0
  endif
endif

ifeq ($(MTK_CAL_DCXO_CAPID),1)
CFLAGS += -DBL_RUN_DCXO_CAL
  ifneq ($(MTK_BL_DCXO_KVALUE_SW),y)
  CFLAGS += -DBL_CAL_DCXO_CAPID1
  endif
endif

ifeq ($(MTK_CAL_DCXO_CAPID),2)
CFLAGS += -DBL_RUN_DCXO_CAL
  ifneq ($(MTK_BL_DCXO_KVALUE_SW),y)
  CFLAGS += -DBL_CAL_DCXO_CAPID2
  endif
endif

ifeq ($(MTK_SECURE_BOOT_ENABLE),y)
SBOOT_LIB_PATH = $(SOURCE_DIR)/prebuilt/middleware/MTK/secure_boot
LIBS += $(SOURCE_DIR)/prebuilt/middleware/MTK/secure_boot/libsboot_3335_CM4_GCC.a
CFLAGS += -DMTK_SECURE_BOOT_ENABLE
CFLAGS += -I$(SOURCE_DIR)/prebuilt/middleware/MTK/secure_boot/inc
endif

##############################################################################
#
# SDK object files
#
##############################################################################


C_OBJS = $(C_FILES:%.c=$(BUILD_DIR)/%.o)
S_OBJS = $(S_FILES:%.s=$(BUILD_DIR)/%.o)

#######################################################
# Include path

CFLAGS += -I$(SOURCE_DIR)/$(RTOS_SRC)/portable/GCC/ARM_CM4F
CFLAGS += -I$(SOURCE_DIR)/driver/CMSIS/Include
CFLAGS += -I$(SOURCE_DIR)/$(APP_PATH)/inc
CFLAGS += -I$(SOURCE_DIR)/middleware/third_party/mbedtls/include
CFLAGS += -I$(SOURCE_DIR)/middleware/third_party/lzma_decoder/inc
#######################################################

###################################################

# Check for valid float argument
# NOTE that you have to run make clan after
# changing these as hardfloat and softfloat are not
# binary compatible
ifneq ($(FLOAT_TYPE), hard)
ifneq ($(FLOAT_TYPE), soft)
override FLOAT_TYPE = hard
#override FLOAT_TYPE = soft
endif
endif

###################################################
# CC Flags
ALLFLAGS = -g -Os
ALLFLAGS += -Wall -mlittle-endian -mthumb -mcpu=cortex-m4
CFLAGS += $(ALLFLAGS) -flto -ffunction-sections -fdata-sections -fno-builtin

ifeq ($(FLOAT_TYPE), hard)
FPUFLAGS = -fsingle-precision-constant -Wdouble-promotion
FPUFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
#CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=softfp
else
FPUFLAGS = -msoft-float
endif

# Definitions
CFLAGS += $(FPUFLAGS)

ifeq ($(MTK_BL_FPGA_LOAD_ENABLE),y)
CFLAGS += -D__FPGA_TARGET__
endif


ifeq ($(MTK_BL_DEBUG_ENABLE),y)
CFLAGS += -DBL_DEBUG
endif

ifeq ($(MTK_FOTA_ENABLE),y)
CFLAGS += -DBL_FOTA_ENABLE
CFLAGS += -DMOD_CFG_FOTA_BL_RESERVED
endif

ifeq ($(MTK_NO_PSRAM_ENABLE),y)
CFLAGS += -DMTK_NO_PSRAM_ENABLE
endif

ifeq ($(MTK_FOTA_EXTERNEL_FLASH),y)
CFLAGS += -DFOTA_EXTERNAL_FLASH_SUPPORT
endif

ifeq ($(MTK_FQ_INCR_ENABLE),y)
CFLAGS += -DMTK_FQ_INCR_ENABLE
endif

ifeq ($(MTK_BL_LOAD_ENABLE),y)
CFLAGS += -DBL_LOAD_ENABLE
endif

CFLAGS += -D__UBL__ -D__EXT_BOOTLOADER__

CFLAGS += -DOTA_ENC_KEY="{ 0xf, 0xe, 0xd, 0xc, 0xb, 0xa, 9,8,7,6,5,4,3,2,1,0}" 
CFLAGS += -DOTA_ENC_IV="{'c','7','8','2','d','c','4','c','0','9','8','c','6','6','c','b'}"


# LD Flags
LDFLAGS = $(ALLFLAGS) $(FPUFLAGS) --specs=nano.specs -lnosys -nostartfiles
LDFLAGS += -Wl,-Tag3335_tcm.ld -Wl,--gc-sections




#-----LX 240

# LD Flags
#LDFLAGS = $(ALLFLAGS) $(FPUFLAGS) --specs=nano.specs -lnosys -nostartfiles
#ifeq ($(MTK_CUSTOMIZED_BL_REGION_ENABLE),y)
#LSCRIPT = ag3335_tcm_with_2nd_bl.ld
#else
#LSCRIPT = ag3335_tcm.ld
#endif


LINKER_SCRIPT_PATH = $(SOURCE_DIR)/$(APP_PATH)/GCC/$(LSCRIPT)
# Auto generate flash_download.cfg file
FLASH_DOWNLOAD_CFG_GENERATOR := $(SOURCE_DIR)/tools/scripts/build/auto_download_cfg.sh
#-------

ifeq ($(DEBUG), 1)
LDFLAGS += --specs=rdimon.specs -lrdimon
endif
#LDFLAGS = $(CFLAGS)

# OKPASS 	@if [ -f $(SOURCE_DIR)/tools/scripts/build/auto_download_cfg.shx ]; then echo "autodownload file found LX S240" ; else echo "autodownload Not found LX S160 20221003" ;fi

# Rules

.PHONY: proj clean $(MODULE_PATH)

all: cleanlog proj
	@mkdir -p $(BUILD_DIR)
	@$(SIZE) $(OUTPATH)/$(PROJ_NAME).elf
	#@if [ -f $(SOURCE_DIR)/tools/scripts/build/auto_download_cfg.sh ]; then echo "autodownload file found LX"  @$(FLASH_DOWNLOAD_CFG_GENERATOR) $(LINKER_SCRIPT_PATH) $(OUTPATH) $(IC_CONFIG) BL; else echo "autodownload Not found LX"  ;fi	
	#@$(FLASH_DOWNLOAD_CFG_GENERATOR) $(LINKER_SCRIPT_PATH) $(OUTPATH) $(IC_CONFIG) BL  ++S240 we disable this but patch S240 copyfirmware.sh  !!! 20221003 
	@$(SOURCE_DIR)/tools/scripts/build/copy_firmware.sh $(SOURCE_DIR) $(OUTPATH) $(IC_CONFIG) $(BOARD_CONFIG) $(PROJ_NAME).bin $(PWD) $(MTK_SECURE_BOOT_ENABLE)

MOD_EXTRA = BUILD_DIR=$(BUILD_DIR) OUTPATH=$(OUTPATH) PROJ_PATH=$(PROJ_PATH)

$(LIBS): $(MODULE_PATH)

$(MODULE_PATH):
	@+make -C $@ $(MOD_EXTRA) $($@_EXTRA)

proj: $(OUTPATH)/$(PROJ_NAME).elf

$(OUTPATH)/$(PROJ_NAME).elf: $(C_OBJS) $(CXX_OBJS) $(S_OBJS) $(LIBS)
	@echo Linking...
	@if [ -e "$@" ]; then rm -f "$@"; fi
	@if [ -e "$(OUTPATH)/$(PROJ_NAME).map" ]; then rm -f "$(OUTPATH)/$(PROJ_NAME).map"; fi
	@if [ -e "$(OUTPATH)/$(PROJ_NAME).dis" ]; then rm -f "$(OUTPATH)/$(PROJ_NAME).dis"; fi
	@if [ -e "$(OUTPATH)/$(PROJ_NAME).hex" ]; then rm -f "$(OUTPATH)/$(PROJ_NAME).hex"; fi
	@if [ -e "$(OUTPATH)/$(PROJ_NAME).bin" ]; then rm -f "$(OUTPATH)/$(PROJ_NAME).bin"; fi
	@$(CC) $(LDFLAGS) -Wl,--start-group $^ -Wl,--end-group -Wl,-Map=$(OUTPATH)/$(PROJ_NAME).map -lm -o $@ 2>>$(ERR_LOG)
	#@$(OBJDUMP) -D $(OUTPATH)/$(PROJ_NAME).elf > $(OUTPATH)/$(PROJ_NAME).dis
	@$(OBJCOPY) -O ihex $(OUTPATH)/$(PROJ_NAME).elf $(OUTPATH)/$(PROJ_NAME).hex
	@$(OBJCOPY) -O binary $(OUTPATH)/$(PROJ_NAME).elf $(OUTPATH)/$(PROJ_NAME).bin
	@$(NM) --size-sort --reverse-sort $(OUTPATH)/$(PROJ_NAME).elf > $(OUTPATH)/$(PROJ_NAME).size
	@echo Done

ifeq ($(MTK_SECURE_BOOT_ENABLE), y)
	@$(SOURCE_DIR)/tools/security/secure_boot/scripts/build/build_sboot_header.sh $(SOURCE_DIR) $(OUTPATH) $(BOARD_CONFIG) $(PROJ_NAME).bin
endif

include $(SOURCE_DIR)/.rule.mk

clean:
	rm -rf $(OUTPATH)


