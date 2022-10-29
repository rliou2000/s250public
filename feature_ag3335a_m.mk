# 20210922 : to build 35a based on 35m LX  + with hw RTC off
#                
############################################# 
IC_CONFIG                             = ag3335
BOARD_CONFIG                          = ag3335m_evk
IC_CONFIG_AG3335_E1                   = y
BL_FEATURE                            = bl_feature_ag3335m.mk

LX_3335A_M_BUILD                  = y

##############################################
#IC_CONFIG                             = ag3335
#BOARD_CONFIG                          = ag3335a_evk
#IC_CONFIG_AG3335_E1                   = y
#BL_FEATURE                            = bl_feature_ag3335a.mk
##############################################




# debug level: none, error, warning, info and debug
#MTK_DEBUG_LEVEL                       = info
#MTK_DEBUG_LEVEL                       = info  LX->none  22KB+
MTK_DEBUG_LEVEL                       = none



MTK_NVDM_ENABLE                       = y
#MTK_USB_DEMO_ENABLED                  = y
#MTK_USB_DEMO_ENABLED                  = y #LX+10KB   not within region `SYSRAM
MTK_USB_DEMO_ENABLED                  = n



# SWLA
MTK_SWLA_ENABLE                       = y

MTK_HAL_EXT_32K_ENABLE                = y
MTK_NO_PSRAM_ENABLE                   = y

# heap dump
#MTK_SUPPORT_HEAP_DEBUG                = y--> n LX no good
MTK_SUPPORT_HEAP_DEBUG                = y


MTK_SUPPORT_HEAP_DEBUG_ADVANCED       = n
# heap peak profiling
MTK_HEAP_SIZE_GUARD_ENABLE            = n

# system hang debug: none, y, o1 and o2
#MTK_SYSTEM_HANG_TRACER_ENABLE         = y
#MTK_SYSTEM_HANG_TRACER_ENABLE         = n  LX-->n  SDK_1_5 enable this (to debug reboot in 22sec after power on) 20210628
MTK_SYSTEM_HANG_TRACER_ENABLE         = n
#MTK_SYSTEM_HANG_TRACER_ENABLE         = y   reboot S150 no good 


MTK_MEMORY_MONITOR_ENABLE             = n

# port service
MTK_PORT_SERVICE_ENABLE               = y

# ATCI
#ATCI_ENABLE                           = y
#MTK_AT_CMD_DISABLE                    = n
#ATCI_ENABLE                           = y   LX
#MTK_AT_CMD_DISABLE                    = n LX
ATCI_ENABLE                           = n
MTK_AT_CMD_DISABLE                    = y

# Race
MTK_RACE_CMD_ENABLE                   = n

# GNSS Basic Config
MTK_GNSS_SERVICE_ENABLE               = y
MTK_GNSS_L5_ENABLE                    = y
MTK_GNSS_RTK_ENABLE                   = n
MTK_GNSS_ANT_DETECTION_ENABLE         = n
MTK_GNSS_NAVIC_ENABLE                 = n

# GNSS Demo Config
#MTK_GNSS_SUPPORT_LOCUS                = y
#MTK_GNSS_SUPPORT_LOCUS                = y  LX   3KB RAM
MTK_GNSS_SUPPORT_LOCUS                = n

# Dump
#MTK_MINIDUMP_ENABLE                   = n
#MTK_FULLDUMP_ENABLE                   = y
#MTK_MINIDUMP_ENABLE                   = n  LX-->y  do not change No good 
#MTK_FULLDUMP_ENABLE                   = y  LX-->n 
MTK_MINIDUMP_ENABLE                   = y
MTK_FULLDUMP_ENABLE                   = n


# boot reason check
MTK_BOOTREASON_CHECK_ENABLE           = y

#VRTC SRAM power source control
#y : RTC SRAM power provided by VRTC, n: RTC SRAM power controlled by HW
#y for HW RTC mode(35m) , n for SW RTC mode (for 35a)
#LX AG3335A/AG3335S don't support HW RTC mode, should never set to y. (RTC_N=SW_RTC)
MTK_SW_CTL_VRTC_VSRAM_POWER           = n



# VCCK External Buck Config
# This configuration describe which level your external buck is
# Three levels: low, normal, high (3)
# If none (0) use Vcck external buck, please set to none   LX 
#for LX MC1612, MC1010
MTK_VCCK_EXTERNAL_BUCK = none
# LX: default 384Mhz 
# to 530Mhz , send BUCK to high
# after power on and GNSS ready , send cmd PAIR106,1 to switch to 530MHz  LX
#MTK_VCCK_EXTERNAL_BUCK = high
