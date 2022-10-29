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

.file "startup_ag3335.s"
.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.equ    WDT_Base,           0xA2080000
.equ    WDT_Disable,        0x10
.equ    Remap_Base,         0xE0181000
.equ    Remap_Entry_HI0,    0x14200017
.equ    Remap_Entry_LO0,    0x04200000
.equ    Remap_Entry_HI1,    0x10000023
.equ    Remap_Entry_LO1,    0x0
.equ    Boot_From_Slv,      0xA2160008
.equ    Boot_Slv_Disable,   0x0

.global  g_pfnVectors
.global  Default_Handler

/**
 * @brief  reset_handler is the entry point that processor starts to boot
 * @param  None
 * @retval : None
*/

  .section  .reset_handler
  .weak  Reset_Handler
  .type  Reset_Handler, %function
Reset_Handler:

/* set stack pointer */
  ldr  sp, =_stack_end

/* interrupt disable */
  cpsid i

/* preinit cache to accelerate region init progress */
  ldr r0, =CachePreInit
  blx r0

/* watch dog disable */
  ldr  r0, =WDT_Base
  ldr  r1, =WDT_Disable
  str  r1, [r0, #0]

/* boot slave disable */
  ldr  r0, =Boot_From_Slv
  ldr  r1, =Boot_Slv_Disable
  str  r1, [r0, #0]

/* make virtual space available */
  ldr  r0, =Remap_Entry_HI0
  ldr  r1, =Remap_Entry_LO0
  ldr  r3, =Remap_Entry_HI1
  ldr  r4, =Remap_Entry_LO1
  ldr  r2, =Remap_Base
  str  r0, [r2], #4
  str  r1, [r2], #4
  str  r3, [r2], #4
  str  r4, [r2, #0]

/* stack space zero init */
  movs  r0, #0
  ldr  r1, =_stack_start
  ldr  r2, =_stack_end
FillZero:
  str  r0, [r1], #4
  cmp  r1, r2
  blo  FillZero

/* tcm section init */
  ldr  r1, =_tcm_text_load
  ldr  r2, =_tcm_text_start
  ldr  r3, =_tcm_text_end
  bl  Data_Init

  ldr  r2, =_tcm_zi_start
  ldr  r3, =_tcm_zi_end
  bl  Bss_Init

#if (defined(AG3335A) || defined(AG3335B))
/* ram_text section init */
  ldr  r1, =_ram_code_load
  ldr  r2, =_ram_code_start
  ldr  r3, =_ram_code_end
  bl  Data_Init

/* cached_data section */
  ldr  r1, =_data_load
  ldr  r2, =_data_start
  ldr  r3, =_data_end
  bl  Data_Init

/* noncached_data section init */
  ldr  r1, =_ram_noncached_rw_load
  ldr  r2, =_ram_noncached_rw_start
  ldr  r3, =_ram_noncached_rw_end
  bl  Data_Init
#endif

/* sysram_text section init */
  ldr  r1, =_sysram_code_load
  ldr  r2, =_sysram_code_start
  ldr  r3, =_sysram_code_end
  bl  Data_Init

/* cached_sysram_data section init */
  ldr  r1, =_cached_sysram_data_load
  ldr  r2, =_cached_sysram_data_start
  ldr  r3, =_cached_sysram_data_end
  bl  Data_Init

/* noncached_sysram_data section init */
  ldr  r1, =_noncached_sysram_rw_load
  ldr  r2, =_noncached_sysram_rw_start
  ldr  r3, =_noncached_sysram_rw_end
  bl  Data_Init

#if (defined(AG3335A) || defined(AG3335B))
  ldr  r2, =_bss_start
  ldr  r3, =_bss_end
  bl  Bss_Init

  ldr  r2, =_ram_noncached_zi_start
  ldr  r3, =_ram_noncached_zi_end
  bl  Bss_Init
#endif

  ldr  r2, =_cached_sysram_bss_start
  ldr  r3, =_cached_sysram_bss_end
  bl  Bss_Init

  ldr  r2, =_noncached_sysram_zi_start
  ldr  r3, =_noncached_sysram_zi_end
  bl  Bss_Init

/* Check whether is wake up from RTC or not */
  ldr  r1, = hal_rtc_is_back_from_rtcmode
  blx  r1
  cmp  r0, #1
  beq  SYSTEM_INIT

/* retention section init */
  ldr  r1, =_retsram_data_load
  ldr  r2, =_retsram_data_start
  ldr  r3, =_retsram_data_end
  bl  Data_Init

  ldr  r2, =_retsram_bss_start
  ldr  r3, =_retsram_bss_end
  bl   Bss_Init

SYSTEM_INIT:
/* Call the clock system intitialization function.*/
  ldr r0, =SystemInit
  blx r0

/* Call the application's entry point.*/
  ldr r0, =main
  bx r0
  bx  lr
.size  Reset_Handler, .-Reset_Handler

/**
 * @brief  This is data init sub-function
 * @param  None
 * @retval None
*/
  .section  .region_loader,"ax",%progbits
Data_Init:
CopyDataLoop:
  cmp     r2, r3
  ittt    lo
  ldrlo   r0, [r1], #4
  strlo   r0, [r2], #4
  blo     CopyDataLoop
  bx  lr
  .size  Data_Init, .-Data_Init

/**
 * @brief  This is bss init sub-function
 * @param  None
 * @retval None
*/
  .section  .region_loader,"ax",%progbits
Bss_Init:
ZeroBssLoop:
  cmp     r2, r3
  ittt    lo
  movlo   r0, #0
  strlo   r0, [r2], #4
  blo     ZeroBssLoop
  bx  lr
  .size  Bss_Init, .-Bss_Init

/**
 * @brief  This is the code that gets called when the processor receives an
 *         unexpected interrupt.  This simply enters an infinite loop, preserving
 *         the system state for examination by a debugger.
 * @param  None
 * @retval None
*/
  .section  .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
  b  Infinite_Loop
  .size  Default_Handler, .-Default_Handler


/******************************************************************************
*
* The minimal vector table for a Cortex M4. Note that the proper constructs
* must be placed on this to ensure that it ends up at physical address
* 0x0000.0000.
*
*******************************************************************************/
  .section  .isr_vector,"a",%progbits
  .type  g_pfnVectors, %object
  .size  g_pfnVectors, .-g_pfnVectors


g_pfnVectors:
  .word  _stack_end
  .word  Reset_Handler
  .word  NMI_Handler
  .word  HardFault_Handler
  .word  MemManage_Handler
  .word  BusFault_Handler
  .word  UsageFault_Handler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  SVC_Handler
  .word  DebugMon_Handler
  .word  0
  .word  PendSV_Handler
  .word  SysTick_Handler

/* External Interrupts */
  .word     isrC_main     /*16:  OS GPT         */
  .word     isrC_main     /*17:  MCU DMA        */
  .word     isrC_main     /*18:  I2C DMA        */
  .word     isrC_main     /*19:  SPI master 0   */
  .word     isrC_main     /*20:  SPI master 1   */
  .word     isrC_main     /*21:  SPI slave      */
  .word     isrC_main     /*22:  SDIO master    */
  .word     isrC_main     /*23:  SDIO master 0 wakeup  */
  .word     isrC_main     /*24:  UART0          */
  .word     isrC_main     /*25:  UART1          */
  .word     isrC_main     /*26:  UART2          */
  .word     isrC_main     /*27:  CRYPTO_ENGINE  */
  .word     isrC_main     /*28:  trng           */
  .word     isrC_main     /*29:  I2C0           */
  .word     isrC_main     /*30:  I2C1           */
  .word     isrC_main     /*31:  I2C_SLV        */
  .word     isrC_main     /*32:  RTC            */
  .word     isrC_main     /*33:  GPTIMER_CM4_HIGH */
  .word     isrC_main     /*34:  GPTIMER_CM4_LOW  */
  .word     isrC_main     /*35:  GPTIMER_GPSL1    */
  .word     isrC_main     /*36:  GPTIMER_GPSL5    */
  .word     isrC_main     /*37:  SPM            */
  .word     isrC_main     /*38:  RGU            */
  .word     isrC_main     /*39:  EINT           */
  .word     isrC_main     /*40:  SFC            */
  .word     isrC_main     /*41:  ESC            */
  .word     isrC_main     /*42:  USB            */
  .word     isrC_main     /*43:  PMU_DIG        */
  .word     isrC_main     /*44:  gpssys_l1_0    */
  .word     isrC_main     /*45:  gpssys_l1_1    */
  .word     isrC_main     /*46:  gpssys_l1_2    */
  .word     isrC_main     /*47:  gpssys_l5_0    */
  .word     isrC_main     /*48:  gpssys_l5_1    */
  .word     isrC_main     /*49:  gpssys_l5_2    */
  .word     isrC_main     /*50:  Security       */
  .word     isrC_main     /*51:  CM4 reserved   */


/*******************************************************************************
*
* Provide weak aliases for each Exception handler to the Default_Handler.
* As they are weak aliases, any function with the same name will override
* this definition.
*
*******************************************************************************/

  .weak      NMI_Handler
  .thumb_set NMI_Handler,Default_Handler

  .weak      HardFault_Handler
  .thumb_set HardFault_Handler,Default_Handler

  .weak      MemManage_Handler
  .thumb_set MemManage_Handler,Default_Handler

  .weak      BusFault_Handler
  .thumb_set BusFault_Handler,Default_Handler

  .weak      UsageFault_Handler
  .thumb_set UsageFault_Handler,Default_Handler

  .weak      SVC_Handler
  .thumb_set SVC_Handler,Default_Handler

  .weak      DebugMon_Handler
  .thumb_set DebugMon_Handler,Default_Handler

  .weak      PendSV_Handler
  .thumb_set PendSV_Handler,Default_Handler

  .weak      SysTick_Handler
  .thumb_set SysTick_Handler,Default_Handler




