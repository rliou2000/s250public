/* Copyright Statement:
 *
 * (C) 2019  Airoha Technology Corp. All rights reserved.
 *
 * This software/firmware and related documentation ("Airoha Software") are
 * protected under relevant copyright laws. The information contained herein
 * is confidential and proprietary to Airoha Technology Corp. ("Airoha") and/or its licensors.
 * Without the prior written permission of Airoha and/or its licensors,
 * any reproduction, modification, use or disclosure of Airoha Software,
 * and information contained herein, in whole or in part, shall be strictly prohibited.
 * You may only use, reproduce, modify, or distribute (as applicable) Airoha Software
 * if you have agreed to and been bound by the applicable license agreement with
 * Airoha ("License Agreement") and been granted explicit permission to do so within
 * the License Agreement ("Permitted User").  If you are not a Permitted User,
 * please cease any access or use of Airoha Software immediately.
 * BY OPENING THIS FILE, RECEIVER HEREBY UNEQUIVOCALLY ACKNOWLEDGES AND AGREES
 * THAT AIROHA SOFTWARE RECEIVED FROM AIROHA AND/OR ITS REPRESENTATIVES
 * ARE PROVIDED TO RECEIVER ON AN "AS-IS" BASIS ONLY. AIROHA EXPRESSLY DISCLAIMS ANY AND ALL
 * WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NONINFRINGEMENT.
 * NEITHER DOES AIROHA PROVIDE ANY WARRANTY WHATSOEVER WITH RESPECT TO THE
 * SOFTWARE OF ANY THIRD PARTY WHICH MAY BE USED BY, INCORPORATED IN, OR
 * SUPPLIED WITH AIROHA SOFTWARE, AND RECEIVER AGREES TO LOOK ONLY TO SUCH
 * THIRD PARTY FOR ANY WARRANTY CLAIM RELATING THERETO. RECEIVER EXPRESSLY ACKNOWLEDGES
 * THAT IT IS RECEIVER'S SOLE RESPONSIBILITY TO OBTAIN FROM ANY THIRD PARTY ALL PROPER LICENSES
 * CONTAINED IN AIROHA SOFTWARE. AIROHA SHALL ALSO NOT BE RESPONSIBLE FOR ANY AIROHA
 * SOFTWARE RELEASES MADE TO RECEIVER'S SPECIFICATION OR TO CONFORM TO A PARTICULAR
 * STANDARD OR OPEN FORUM. RECEIVER'S SOLE AND EXCLUSIVE REMEDY AND AIROHA'S ENTIRE AND
 * CUMULATIVE LIABILITY WITH RESPECT TO AIROHA SOFTWARE RELEASED HEREUNDER WILL BE,
 * AT AIROHA'S OPTION, TO REVISE OR REPLACE AIROHA SOFTWARE AT ISSUE,
 * OR REFUND ANY SOFTWARE LICENSE FEES OR SERVICE CHARGE PAID BY RECEIVER TO
 * AIROHA FOR SUCH AIROHA SOFTWARE AT ISSUE.
 */

#include "bl_common.h"
#include "bl_fota.h"
#include "hal_uart.h"
#include "hal_flash.h"
#include "core_cm4.h"
#include "hal_clock_internal.h"
#include "hal_rtc.h"
#include "hal_emi_internal.h"
#define BL_EXECUTION_VIEW_ADDRESS SYSRAM_BASE
#define BL_ENABLE_JTAG
#define PARSE_PARTITION_TABLE
#ifdef MTK_SECURE_BOOT_ENABLE
#include "secure_boot.h"
#endif

extern void  bl_rtc_func_init(void);
//extern void hal_dcxo_init(void);
/* Placement at SYSRAM for SFC/EMI initialization.
   In XIP case, bl_print should NOT be called between
   hal_clock_set_pll_dcm_init and hal_emi_configure_advanced/custom_setSFIExt*/
void bl_hardware_init(){
    /* To set DCXO frequency for hal_clock_fxo_is_26m */
    hal_clock_init();
    hal_uart_config_t uart_config;

    /* UART init */
    uart_config.baudrate = HAL_UART_BAUDRATE_921600;
    uart_config.parity = HAL_UART_PARITY_NONE;
    uart_config.stop_bit = HAL_UART_STOP_BIT_1;
    uart_config.word_length = HAL_UART_WORD_LENGTH_8;
    if(hal_uart_init(HAL_UART_0, &uart_config)!= HAL_UART_STATUS_OK){
        while(1);
    }
    /* Enable FPU. Set CP10 and CP11 Full Access.  bl_print_internal in keil uses FPU.*/
    SCB->CPACR |= ((3UL << 10 * 2) | (3UL << 11 * 2));
    bl_print(LOG_DEBUG,"set CP10 and CP11 Full Access \r\n");
    /* SW workaround for EOSC accuracy issue, need measure EOSC frequency before die temperature up.*/

    /* print log */
    bl_set_debug_level(LOG_DEBUG);
    //bl_print(LOG_DEBUG, "bl_uart_init\r\n";

    /* PLL init */
    bl_print(LOG_DEBUG, "hal_clock_set_pll_dcm_init\r\n");
    hal_clock_set_pll_dcm_init();
#ifdef MTK_FQ_INCR_ENABLE
#ifndef MTK_NO_PSRAM_ENABLE
    bl_print(LOG_DEBUG, "hal_emi_configure\r\n");
    hal_emi_configure(EMI_CLK_192M);
#endif
    if(HAL_CLOCK_STATUS_OK == hal_clock_set_volt_lv(VOLT_0P7_LV,OSC_ENV))
    {
        bl_print(LOG_DEBUG,"rising freq to 384m level pass!\r\n");
    } else
    {
        bl_print(LOG_DEBUG,"rising freq to 384m level Failed!\r\n");
    }
#ifndef MTK_NO_PSRAM_ENABLE
    hal_emi_configure_advanced(EMI_CLK_192M);
#endif
#endif
    custom_setSFIExt();
    bl_print(LOG_DEBUG, "hal_flash_init\r\n");
    hal_flash_init();
    bl_print(LOG_DEBUG, "hf_fsys_ck freq=%d\r\n", hal_clock_freq_meter(_hf_fsys_ck));
    bl_print(LOG_DEBUG, "hf_fsfc_ck freq=%d\r\n", hal_clock_freq_meter(_hf_fsfc_ck));
    bl_rtc_func_init();//define in hal_rtc.c
    /* SF STT and Disturbance Test*/

    // Clear crypto irq raised in BROM
    NVIC_ClearPendingIRQ(CRYPTO_IRQn);

}

#ifdef PARSE_PARTITION_TABLE

typedef struct {
  uint32_t BinaryId;
  uint32_t PartitionId;
  uint32_t LoadAddressHigh;
  uint32_t LoadAddressLow;
  uint32_t BinaryLengthHigh;
  uint32_t BinaryLengthLow;
  uint32_t ExecutionAddress;
  uint32_t ReservedItem0;
  uint32_t ReservedItem1;
  uint32_t ReservedItem2;
  uint32_t ReservedItem3;
  uint32_t ReservedItem4;
} PartitionTableItem;

typedef struct {
    PartitionTableItem_T SEC_HEADER1;
    PartitionTableItem_T SEC_HEADER2;
    PartitionTableItem_T BL;
    PartitionTableItem_T CM4;
} PartitionTable;

#endif

void bl_start_user_code()
{
#if defined(MTK_SECURE_BOOT_ENABLE)
    sboot_status_t ret = SBOOT_STATUS_OK;
    uint32_t hdrAddr = bl_custom_header_start_address();
#endif
#ifdef PARSE_PARTITION_TABLE
    uint32_t targetAddr;
    PartitionTable pt;
    hal_flash_status_t flash_status = HAL_FLASH_STATUS_OK;
    int32_t fallback = 0;

    targetAddr = bl_custom_cm4_start_address();

    /* partition table is at the start of flash */
    flash_status = hal_flash_read(0, (uint8_t *)&pt, sizeof(PartitionTable));
    if (flash_status != HAL_FLASH_STATUS_OK) {
        fallback = -1;
    }
    if (pt.CM4.BinaryId != 0x3) {
        fallback = -2;
    }

    if (fallback == 0) {
        targetAddr = pt.CM4.LoadAddressLow;
    }
#if defined(MTK_SECURE_BOOT_ENABLE)
    if (pt.SEC_HEADER2.BinaryId != 0x8)
    {
        fallback = -3;
    }
    else
    {
        hdrAddr = pt.SEC_HEADER2.LoadAddressLow;
    }
#endif
    //bl_print(LOG_DEBUG, "Partition(%d) %x\r\n", fallback, targetAddr);
#else
    uint32_t targetAddr = bl_custom_cm4_start_address();
#endif
#if defined(MTK_SECURE_BOOT_ENABLE)
    bl_print(LOG_DEBUG, "bl_custom_header_start_address = %x\r\n", hdrAddr);

    ret = sboot_secure_boot_check((uint8_t *)hdrAddr, NULL, SBOOT_IOTHDR_V2, 0);

    if (ret == SBOOT_STATUS_FAIL) {
        bl_print(LOG_DEBUG, "secure boot check failed. system halt (%x)\r\n", ret);
        while(1);
    } else if (ret == SBOOT_STATUS_NOT_ENABLE) {
        bl_print(LOG_DEBUG, "secure boot disabled\r\n");
    } else if(ret == SBOOT_STATUS_OK) {
        bl_print(LOG_DEBUG, "secure boot check pass\r\n");
    }
    else
    {
        bl_print(LOG_DEBUG, "secure boot check failed. system halt (%x)\r\n", ret);
        while(1);
    }
#endif
    bl_print(LOG_DEBUG, "Jump to addr %x\r\n\r\n", targetAddr);
    JumpCmd(targetAddr);
}

int main()
{
    bl_hardware_init();
#ifdef BL_FOTA_ENABLE
    bl_fota_process();
#endif

    bl_start_user_code();

    return 0;
}

