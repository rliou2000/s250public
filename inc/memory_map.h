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

#ifndef __MEMORY_MAP_H__
#define __MEMORY_MAP_H__

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
} PartitionTableItem_T;

typedef struct {
    PartitionTableItem_T SEC_HEADER1;
    PartitionTableItem_T SEC_HEADER2;
    PartitionTableItem_T BL;
    PartitionTableItem_T CM4;
    PartitionTableItem_T FS;
    PartitionTableItem_T NVDM;
    PartitionTableItem_T GNSS_CONFIG;
    PartitionTableItem_T FOTA;
} PartitionTable_T;

#define ROM_BASE 0x08000000
#define PARTITION_TABLE  ((PartitionTable_T *)ROM_BASE)

#define SEC_HEADER1_BASE     PARTITION_TABLE->SEC_HEADER1.LoadAddressLow
#define SEC_HEADER1_LENGTH   PARTITION_TABLE->SEC_HEADER1.BinaryLengthLow

#define SEC_HEADER2_BASE     PARTITION_TABLE->SEC_HEADER2.LoadAddressLow
#define SEC_HEADER2_LENGTH   PARTITION_TABLE->SEC_HEADER2.BinaryLengthLow

#define BL_BASE     PARTITION_TABLE->BL.LoadAddressLow
#define BL_LENGTH   PARTITION_TABLE->BL.BinaryLengthLow

#define CM4_BASE    PARTITION_TABLE->CM4.LoadAddressLow
#define CM4_LENGTH  PARTITION_TABLE->CM4.BinaryLengthLow

#define FS_RESERVED_BASE    PARTITION_TABLE->FS.LoadAddressLow
#define FS_RESERVED_LENGTH  PARTITION_TABLE->FS.BinaryLengthLow

#define ROM_NVDM_BASE    PARTITION_TABLE->NVDM.LoadAddressLow
#define ROM_NVDM_LENGTH  PARTITION_TABLE->NVDM.BinaryLengthLow

#define GNSS_CONFIG_BASE    PARTITION_TABLE->GNSS_CONFIG.LoadAddressLow
#define GNSS_CONFIG_LENGTH  PARTITION_TABLE->GNSS_CONFIG.BinaryLengthLow

#define FOTA_RESERVED_BASE    PARTITION_TABLE->FOTA.LoadAddressLow
#define FOTA_RESERVED_LENGTH  PARTITION_TABLE->FOTA.BinaryLengthLow

#define RAM_BASE    0x00000000
#define RAM_LENGTH  0x00400000   /* 4096kB */

#define VRAM_BASE    0x10000000
#define VRAM_LENGTH  0x00400000   /* 4096kB */

#define TCM_BASE      0x04008000
#define TCM_LENGTH    0x00010000  /* 64kB */

#define VSYSRAM_BASE   0x14200000
#define VSYSRAM_LENGTH 0x00060000    /* 384kB */

#endif

