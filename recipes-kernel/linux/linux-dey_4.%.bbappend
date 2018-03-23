# Copyright (C) 2017 Digi International Inc.

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI_append_ccimx6ulstarter = " \
    ${@base_conditional('FB_PITFT_ENABLED', '1', 'file://0001-ARM-dts-ccimx6ulstarter-enable-TFT-PiHat-reset-line.patch', '', d)} \
    ${@base_conditional('FB_PITFT_ENABLED', '1', 'file://0002-ARM-kernel-ccimx6ulstarter-Add-support-for-PiHat-dis.patch', '', d)} \
    ${@base_conditional('FB_PITFT_CAP_TOUCH', '1', 'file://0003-ARM-dts-ccimx6ulstarter-enable-ft6236-touchscreen.patch', '', d)} \
"


#
# Enable kernel driver for FT6306 touchscreen
# 
pitft_kernel_captouch_preconfigure() {
        mkdir -p ${B}

        kernel_conf_variable TOUCHSCREEN_FUSION_7_10 n
        kernel_conf_variable TOUCHSCREEN_EDT_FT5X06 y
}

#
# Enable TFT driver support in kernel
#
pitft_kernel_preconfigure() {
        mkdir -p ${B}

        # Enable FBTFT support
        kernel_conf_variable FB_TFT m
        kernel_conf_variable FB_TFT_ILI9340 m
        kernel_conf_variable FB_TFT_ILI9341 m
        kernel_conf_variable FB_FLEX m
        kernel_conf_variable FB_TFT_FBTFT_DEVICE m

        kernel_conf_variable FB_SYS_FILLRECT m
        kernel_conf_variable FB_SYS_COPYAREA m
        kernel_conf_variable FB_SYS_IMAGEBLIT m
        kernel_conf_variable FB_SYS_FOPS m
        kernel_conf_variable FB_DEFERRED_IO y
        kernel_conf_variable FB_BACKLIGHT y
	
        sed -e "${CONF_SED_SCRIPT}" < '${WORKDIR}/defconfig' >> '${B}/.config'
}

#
# Enable kernel driver for FT6306 touchscreen
# 
pitft_kernel_captouch_preconfigure() {
        mkdir -p ${B}

        kernel_conf_variable TOUCHSCREEN_FUSION_7_10 n
        kernel_conf_variable TOUCHSCREEN_EDT_FT5X06 y
}

do_configure_prepend() {

        if [ "${FB_PITFT_ENABLED}" = "1" ]; then
                pitft_kernel_preconfigure
        fi

        if [ "${FB_PITFT_CAP_TOUCH}" = "1" ]; then
                pitft_kernel_captouch_preconfigure
        fi

        pitft_kernel_captouch_preconfigure
}

# set default FB device driver name, ili9340 and ili9341 tested
FB_DRIVER_NAME ?= "ili9341"

# set default display name, cc6ul_adafruit22_sb and cc6ul_adafruit28_Sb supported/tested
FB_DISPLAY_NAME ?= "cc6ul_adafruit28_sb"

#default rotation value
FB_ROTATION ?= "180"


# autoload the modules if installed
KERNEL_MODULE_AUTOLOAD += "syscopyarea sysfillrect sysimgblt fb_sys_fops fbtft_device fb_${FB_DRIVER_NAME}"
KERNEL_MODULE_PROBECONF += "fbtft_device"
module_conf_fbtft_device = "options fbtft_device name=${FB_DISPLAY_NAME} verbose=3 busnum=2 rotate=${FB_ROTATION}"

