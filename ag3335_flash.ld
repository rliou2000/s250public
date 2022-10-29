/********************************************************
memory map
    Start Address   Size    CM4 view Devices
    0x0000_0000     64MB    Reserved
    0x0400_0000     192KB   CM4 TCM / cache
    0x0403_0000     832KB   Reserved
    0x0410_0000     1MB     Boot ROM CM4
    0x0420_0000     664K    SYSRAM
    0x0430_0000     80K     Retention SRAM
    0x0440_0000     400K    GPS ROM
    0x0800_0000     128MB   SFC0
    0x1000_0000     128MB   SW virtual memory management
    0x1800_0000     128MB   SW virtual memory management
*********************************************************/

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)

/* Memory Spaces Definitions */
MEMORY
{
    ROM_PARTITION_TABLE(rx)        : ORIGIN = 0x08000000, LENGTH = 4K
    ROM_SECURITY_HEAD1(rx)         : ORIGIN = 0x08001000, LENGTH = 4K
    ROM_SECURITY_HEAD2(rx)         : ORIGIN = 0x08002000, LENGTH = 4K
    ROM_BL(rx)                     : ORIGIN = 0x08003000, LENGTH = 64K
    ROM_RTOS(rx)                   : ORIGIN = 0x08013000, LENGTH = 2420K
    ROM_FOTA_RESERVED(rx)          : ORIGIN = 0xFFFFFFFF, LENGTH = 0K
    ROM_FS_RESERVED(rx)            : ORIGIN = 0x08270000, LENGTH = 1532K
    ROM_NVDM_RESERVED(rx)          : ORIGIN = 0x083EF000, LENGTH = 64K
    ROM_GNSS_CONFIG(rx)            : ORIGIN = 0x083FF000, LENGTH = 4K
    RAM (rwx)                      : ORIGIN = 0x00000000, LENGTH = 4096K
    VRAM(rwx)                      : ORIGIN = 0x10000000, LENGTH = 4096K
    TCM (rwx)                      : ORIGIN = 0x04000000, LENGTH = 160K
    SYSRAM (rwx)                   : ORIGIN = 0x04200000, LENGTH = 648K
    SYSRAM_GPS_RESERVED (rwx)      : ORIGIN = 0x042A2000, LENGTH = 16K
    VSYSRAM (rwx)                  : ORIGIN = 0x14200000, LENGTH = 648K
    VSYSRAM_GPS_RESERVED (rwx)     : ORIGIN = 0x142A2000, LENGTH = 16K
    RETSRAM (rwx)                  : ORIGIN = 0x04300000, LENGTH = 80K
    ROM_LOG_STRING(rx)             : ORIGIN = 0x06000000, LENGTH = 32M
}

 /* Highest address of the stack */
_stack_end = ORIGIN(TCM) + LENGTH(TCM);    /* end of TCM */

/* Generate a link error if stack don't fit into TCM */
_stack_size = 0x1000; /* required amount of stack 4KB*/

/* stack start */
_stack_start = _stack_end - _stack_size;

/* Linker symbol provided for C/Assembly Code */
_sysram_start   = ORIGIN(SYSRAM);
_sysram_length  = LENGTH(SYSRAM);
_vsysram_start  = ORIGIN(VSYSRAM);
_vsysram_length = LENGTH(VSYSRAM);
_tcm_start      = ORIGIN(TCM);
_tcm_length     = LENGTH(TCM);
_retsram_start  = ORIGIN(RETSRAM);
_retsram_length = LENGTH(RETSRAM);


/* swla start and size */
_swla_size = 0;       /* default swla will use free ram as the working memory, and also can reserve a region for swla by modify the value of _swla_size */
_swla_start = ORIGIN(VSYSRAM) + LENGTH(VSYSRAM) - _swla_size; /* at the tail of VSYSRAM */

/* Entry Point */
ENTRY(Reset_Handler)

SECTIONS
{
    /* partition table */
    .partition_table :
    {
        /* Security_Header1 */
        LONG(0x00000000);/* BinaryId */
        LONG(0x00000000);/* PartitionId */
        LONG(0x00000000);/* LoadAddressHigh */
        LONG(ORIGIN(ROM_SECURITY_HEAD1));/* LoadAddressLow */
        LONG(0x00000000);/* BinaryMaxLengthHigh */
        LONG(LENGTH(ROM_SECURITY_HEAD1));/* BinaryMaxLengthLow */
        LONG(0x00000000);/* ExecutionAddress */
        LONG(0x00000000);/* ReservedItem0 */
        LONG(0x00000000);/* ReservedItem1 */
        LONG(0x00000000);/* ReservedItem2 */
        LONG(0x00000000);/* ReservedItem3 */
        LONG(0x00000000);/* ReservedItem4 */

        /* Security_Header2 */
        LONG(0x00000008);/* BinaryId */
        LONG(0x00000000);/* PartitionId */
        LONG(0x00000000);/* LoadAddressHigh */
        LONG(ORIGIN(ROM_SECURITY_HEAD2));/* LoadAddressLow */
        LONG(0x00000000);/* BinaryMaxLengthHigh */
        LONG(LENGTH(ROM_SECURITY_HEAD2));/* BinaryMaxLengthLow */
        LONG(0x00000000);/* ExecutionAddress */
        LONG(0x00000000);/* ReservedItem0 */
        LONG(0x00000000);/* ReservedItem1 */
        LONG(0x00000000);/* ReservedItem2 */
        LONG(0x00000000);/* ReservedItem3 */
        LONG(0x00000000);/* ReservedItem4 */

        /* Bootloader */
        LONG(0x00000001);/* BinaryId */
        LONG(0x00000000);/* PartitionId */
        LONG(0x00000000);/* LoadAddressHigh */
        LONG(ORIGIN(ROM_BL));/* LoadAddressLow */
        LONG(0x00000000);/* BinaryMaxLengthHigh */
        LONG(LENGTH(ROM_BL));/* BinaryMaxLengthLow */
        LONG(0x00000000);/* ExecutionAddress */
        LONG(0x00000000);/* ReservedItem0 */
        LONG(0x00000000);/* ReservedItem1 */
        LONG(0x00000000);/* ReservedItem2 */
        LONG(0x00000000);/* ReservedItem3 */
        LONG(0x00000000);/* ReservedItem4 */

        /* CM4 */
        LONG(0x00000003);/* BinaryId */
        LONG(0x00000000);/* PartitionId */
        LONG(0x00000000);/* LoadAddressHigh */
        LONG(ORIGIN(ROM_RTOS));/* LoadAddressLow */
        LONG(0x00000000);/* BinaryMaxLengthHigh */
        LONG(LENGTH(ROM_RTOS));/* BinaryMaxLengthLow */
        LONG(0x00000000);/* ExecutionAddress */
        LONG(0x00000000);/* ReservedItem0 */
        LONG(0x00000000);/* ReservedItem1 */
        LONG(0x00000000);/* ReservedItem2 */
        LONG(0x00000000);/* ReservedItem3 */
        LONG(0x00000000);/* ReservedItem4 */

        /* FS */
        LONG(0x00000006);/* BinaryId */
        LONG(0x00000000);/* PartitionId */
        LONG(0x00000000);/* LoadAddressHigh */
        LONG(ORIGIN(ROM_FS_RESERVED));/* LoadAddressLow */
        LONG(0x00000000);/* BinaryMaxLengthHigh */
        LONG(LENGTH(ROM_FS_RESERVED));/* BinaryMaxLengthLow */
        LONG(0x00000000);/* ExecutionAddress */
        LONG(0x00000000);/* ReservedItem0 */
        LONG(0x00000000);/* ReservedItem1 */
        LONG(0x00000000);/* ReservedItem2 */
        LONG(0x00000000);/* ReservedItem3 */
        LONG(0x00000000);/* ReservedItem4 */

        /* NVDM */
        LONG(0x00000007);/* BinaryId */
        LONG(0x00000000);/* PartitionId */
        LONG(0x00000000);/* LoadAddressHigh */
        LONG(ORIGIN(ROM_NVDM_RESERVED));/* LoadAddressLow */
        LONG(0x00000000);/* BinaryMaxLengthHigh */
        LONG(LENGTH(ROM_NVDM_RESERVED));/* BinaryMaxLengthLow */
        LONG(0x00000000);/* ExecutionAddress */
        LONG(0x00000000);/* ReservedItem0 */
        LONG(0x00000000);/* ReservedItem1 */
        LONG(0x00000000);/* ReservedItem2 */
        LONG(0x00000000);/* ReservedItem3 */
        LONG(0x00000000);/* ReservedItem4 */

        /* GNSS CONFIG */
        LONG(0x00000009);/* BinaryId */
        LONG(0x00000000);/* PartitionId */
        LONG(0x00000000);/* LoadAddressHigh */
        LONG(ORIGIN(ROM_GNSS_CONFIG));/* LoadAddressLow */
        LONG(0x00000000);/* BinaryMaxLengthHigh */
        LONG(LENGTH(ROM_GNSS_CONFIG));/* BinaryMaxLengthLow */
        LONG(0x00000000);/* ExecutionAddress */
        LONG(0x00000000);/* ReservedItem0 */
        LONG(0x00000000);/* ReservedItem1 */
        LONG(0x00000000);/* ReservedItem2 */
        LONG(0x00000000);/* ReservedItem3 */
        LONG(0x00000000);/* ReservedItem4 */

        /* FOTA CONFIG */
        LONG(0x00000009);/* BinaryId */
        LONG(0x00000000);/* PartitionId */
        LONG(0x00000000);/* LoadAddressHigh */
        LONG(ORIGIN(ROM_FOTA_RESERVED));/* LoadAddressLow */
        LONG(0x00000000);/* BinaryMaxLengthHigh */
        LONG(LENGTH(ROM_FOTA_RESERVED));/* BinaryMaxLengthLow */
        LONG(0x00000000);/* ExecutionAddress */
        LONG(0x00000000);/* ReservedItem0 */
        LONG(0x00000000);/* ReservedItem1 */
        LONG(0x00000000);/* ReservedItem2 */
        LONG(0x00000000);/* ReservedItem3 */
        LONG(0x00000000);/* ReservedItem4 */
    } > ROM_PARTITION_TABLE

    /* log string */
    .log_str :
    {
        KEEP(*(.log_version))
        KEEP(*(.log_timestamp))
        KEEP(*(SORT_BY_NAME(.log_filter_mirror*)))
        *(.log_string)
    } > ROM_LOG_STRING

    . = ORIGIN(ROM_RTOS);
    . = ALIGN(4);
    .text :ALIGN(4)
    {
        _text_start = .;
        Image$$TEXT$$Base = .;

        KEEP(*(.reset_handler))
        KEEP(*(.region_loader))
        KEEP(*(.init))
        KEEP(*(.fini))
        *(.text)
        *(.text*)
        *(EXCLUDE_FILE (*libmnl_kf_dual.a) .rodata*)

        . = ALIGN(4);
        _log_filter_start = .;
        KEEP(*(SORT_BY_NAME(.log_filter*)))
        _log_filter_end = .;

        . = ALIGN(4);
        Image$$TEXT$$Limit = .;
        _text_end = .;
    } > ROM_RTOS  AT> ROM_RTOS

    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    }  > ROM_RTOS  AT> ROM_RTOS

    .ARM.exidx :
    {
        __exidx_start = .;
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        __exidx_end = .;
    } > ROM_RTOS  AT> ROM_RTOS

    . = ALIGN(32);
    _sysram_code_load = LOADADDR(.sysram_text);
    .sysram_text :
    {
        Image$$CACHED_SYSRAM_TEXT$$Base = .;
        _sysram_code_start = .;

        *(.sysram_code*)
        *(.ram_code*)
        *(.sysram_rodata*)
        *(.ram_rodata*)

        Image$$CACHED_SYSRAM_TEXT$$Limit = .;
        _sysram_code_end = .;
    } > VSYSRAM   AT> ROM_RTOS

    . = ALIGN(4);
    _cached_sysram_data_load = LOADADDR(.data);
    .data :
    {
        _cached_sysram_data_start = .;
        Image$$CACHED_SYSRAM_DATA$$RW$$Base = .;

        *(EXCLUDE_FILE (*libmnl_kf_dual.a) .data*)

        *(.cached_sysram_rwdata*)

        . = ALIGN(4);
        /* preinit data */
        PROVIDE (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE (__preinit_array_end = .);

        . = ALIGN(4);
        /* init data */
        PROVIDE (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE (__init_array_end = .);

        . = ALIGN(4);
        /* finit data */
        PROVIDE (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE (__fini_array_end = .);

        _cached_sysram_data_end = .;
        Image$$CACHED_SYSRAM_DATA$$RW$$Limit = .;
    } > VSYSRAM  AT> ROM_RTOS

    . = ALIGN(4);
    .bss (NOLOAD) :
    {
        _cached_sysram_bss_start = .;
        Image$$CACHED_SYSRAM_DATA$$ZI$$Base = .;

        *(EXCLUDE_FILE (*libmnl_kf_dual.a) .bss*)
        *(COMMON)
        *(.cached_sysram_zidata*)

        . = ALIGN(4);
        _cached_sysram_bss_end = .;
        Image$$CACHED_SYSRAM_DATA$$ZI$$Limit = .;
    } > VSYSRAM  AT> ROM_RTOS

    . = ALIGN(32);
    _noncached_sysram_rw_load = LOADADDR(.noncached_sysram_data);
    . = . - ORIGIN(VSYSRAM) + ORIGIN(SYSRAM);

    .noncached_sysram_data . :
    {
        Image$$NONCACHED_SYSRAM_DATA$$Base = .;

        _noncached_sysram_rw_start = .;

        *(.noncached_sysram_rwdata*)
        *(.noncached_ram_rwdata*)

        Image$$NONCACHED_SYSRAM_DATA$$Limit = .;
        _noncached_sysram_rw_end = .;
    } > SYSRAM  AT> ROM_RTOS

    . = ALIGN(4);
    .noncached_sysram_bss . (NOLOAD) :
    {
        Image$$NONCACHED_SYSRAM_ZI$$Base = .;
        _noncached_sysram_zi_start = .;

        *(.noncached_sysram_zidata*)
        *(.noncached_ram_zidata*)

        Image$$NONCACHED_SYSRAM_ZI$$Limit = .;
        _noncached_sysram_zi_end = .;
    } > SYSRAM  AT> ROM_RTOS

    ASSERT(_noncached_sysram_zi_end <= (ORIGIN(SYSRAM) + LENGTH(SYSRAM)),"SYSRAM expired")

    . = _swla_start;
    . = ALIGN(32);
    .swla . (NOLOAD) :
    {
        Image$$SWLA$$Base = .;
        . = ALIGN(4);

        . = . + (_swla_size) ;

        . = ALIGN(4);
        Image$$SWLA$$Limit = .;
    } > VSYSRAM

    . = ALIGN(4);
    _retsram_data_load = LOADADDR(.retsram_data);
    .retsram_data :
    {
        Image$$RETSRAM_DATA$$Base = .;
        _retsram_data_start = .;

        *(.retsram_rwdata*)

        Image$$RETSRAM_DATA$$Limit = .;
        _retsram_data_end = .;
    } > RETSRAM  AT> ROM_RTOS

    . = ALIGN(4);
    .retsram_bss (NOLOAD) :
    {
        Image$$RETSRAM_ZI$$Base = .;
        _retsram_bss_start = .;

        *(.retsram_zidata*)

        Image$$RETSRAM_ZI$$Limit = .;
        _retsram_bss_end = .;
    } >RETSRAM  AT> ROM_RTOS

    ASSERT(_retsram_bss_end <= (ORIGIN(RETSRAM) + LENGTH(RETSRAM)),"RETSRAM expired")

    . = ALIGN(4);
    _tcm_text_load = LOADADDR(.tcm);

    .tcm :
    {
        _tcm_text_start = .;
        Image$$TCM$$RO$$Base = .;
        Image$$VECTOR$$TABLE$$Base = .;

        KEEP(*(.isr_vector))
        *(.exception_code)
        *(.exception_code*)
        *(.exception_rodata)
        *(.exception_rodata*)
        *(.tcm_code*)
        *(.tcm_rodata*)
        KEEP(*libmnl_kf_dual.a:*(.rodata*))

        Image$$TCM$$RO$$Limit = .;
        Image$$TCM$$RW$$Base = .;

        *(.tcm_rwdata*)
        KEEP(*libmnl_kf_dual.a:*(.data*))

        . = ALIGN(4);
        Image$$TCM$$RW$$Limit = .;
        _tcm_text_end = .;
    }> TCM  AT> ROM_RTOS

    . = ALIGN(4);
    .tcm_bss (NOLOAD) :
    {
        _tcm_zi_start = .;
        Image$$TCM$$ZI$$Base = .;

        *(.tcm_zidata*)
        KEEP(*libmnl_kf_dual.a:*(.bss*))

        _tcm_zi_end = .;
        Image$$TCM$$ZI$$Limit = .;
    }> TCM

    /* use to check if the stack exceeds the total TCM size*/
    .stack :
    {
        . = ALIGN(4);
        PROVIDE ( end = . );
        PROVIDE ( _end = . );
        . = . + _stack_size;
        . = ALIGN(4);
    } > TCM

    Image$$STACK$$ZI$$Base = _stack_end - _stack_size;
    Image$$STACK$$ZI$$Limit = _stack_end;
}
