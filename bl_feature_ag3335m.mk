IC_CONFIG                             = ag3335
BOARD_CONFIG                          = ag3335m_evk
IC_CONFIG_AG3335_E1                   = y

MTK_BL_LOAD_ENABLE          = n

#can modify
MTK_BL_FOTA_CUST_ENABLE     = n
MTK_BL_DEBUG_ENABLE         = y
MTK_FOTA_ENABLE             = n
MTK_FOTA_FS_ENABLE          = n
MTK_FOTA_VIA_RACE_CMD       = n
MTK_MBEDTLS_CONFIG_FILE     = config-mtk-bootloader.h
MTK_FOTA_EXTERNEL_FLASH     = n
MTK_HAL_NO_LOG_ENABLE       = y
MTK_FQ_INCR_ENABLE          = y
#internal use
MTK_BL_FPGA_LOAD_ENABLE     = y

#factory
MTK_CAL_DCXO_CAPID          = n
# DCXO calibration value is in SW
MTK_BL_DCXO_KVALUE_SW       = n

MTK_HAL_EXT_32K_ENABLE      = y

MTK_NO_PSRAM_ENABLE         = y
