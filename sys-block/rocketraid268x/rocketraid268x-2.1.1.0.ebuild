# Copyright 2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/lib/layman/genja/sys-block/rocketraid-268x/rocketraid-268x-2.1.1.0.ebuild Sun Nov 16 13:56:23 CET 2014 tox2ik Exp $

EAPI="5"
inherit eutils linux-info linux-mod unpacker

DESCRIPTION="HighPoint RocketRAID 268x SAS Controller Linux Open Source Driver"
HOMEPAGE="http://www.highpoint-tech.com/USA_new/rr2600_download.htm http://www.highpoint-tech.cn/usa/rr2680.htm"
BASE_URI="http://www.highpoint-tech.com/BIOS_Driver/rr268x/linux"
BASE_NAME="RR268x_Linux_Src_v${PV}"
HPT_VERSION=v2.1
HPT_DATE=_14_02_24
SRC_URI="${BASE_URI}/${BASE_NAME}${HPT_DATE}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="-* ~amd64 ~x86"

DEPEND="virtual/linux-sources"
RDEPEND=""

#S="${WORKDIR}"
#S="${WORKDIR}/usr/src/rr26x-${PV}"
S="${WORKDIR}/hptdrv/product/rr2680/linux"
HPT_ROOT="${WORKDIR}/hptdrv"

MODULE_NAMES="rr2680(drivers/scsi)"
#MODULESD_WL_ALIASES=("wlan0 wl")

#@@QA_PREBUILT@@

pkg_setup() {
	# # NOTE<lxnay>: module builds correctly anyway with b43 and SSB enabled
	# # make checks non-fatal. The correct fix is blackisting ssb and, perhaps
	# # b43 via udev rules. Moreover, previous fix broke binpkgs support.
	# CONFIG_CHECK="~!B43 ~!SSB"
	# CONFIG_CHECK2="LIB80211 ~!MAC80211 ~LIB80211_CRYPT_TKIP"
	# ERROR_B43="B43: If you insist on building this, you must blacklist it!"
	# ERROR_SSB="SSB: If you insist on building this, you must blacklist it!"
	# ERROR_LIB80211="LIB80211: Please enable it. If you can't find it: enabling the driver for \"Intel PRO/Wireless 2100\" or \"Intel PRO/Wireless 2200BG\" (IPW2100 or IPW2200) should suffice."
	# ERROR_MAC80211="MAC80211: If you insist on building this, you must blacklist it!"
	# ERROR_PREEMPT_RCU="PREEMPT_RCU: Please do not set the Preemption Model to \"Preemptible Kernel\"; choose something else."
	# ERROR_LIB80211_CRYPT_TKIP="LIB80211_CRYPT_TKIP: You will need this for WPA."
	# if kernel_is ge 3 8 8; then
	# 	CONFIG_CHECK="${CONFIG_CHECK} ${CONFIG_CHECK2} CFG80211 ~!PREEMPT_RCU"
	# elif kernel_is ge 2 6 32; then
	# 	CONFIG_CHECK="${CONFIG_CHECK} ${CONFIG_CHECK2} CFG80211"
	# elif kernel_is ge 2 6 31; then
	# 	CONFIG_CHECK="${CONFIG_CHECK} ${CONFIG_CHECK2} WIRELESS_EXT ~!MAC80211"
	# elif kernel_is ge 2 6 29; then
	# 	CONFIG_CHECK="${CONFIG_CHECK} ${CONFIG_CHECK2} WIRELESS_EXT COMPAT_NET_DEV_OPS"
	# else
	# 	CONFIG_CHECK="${CONFIG_CHECK} IEEE80211 IEEE80211_CRYPT_TKIP"
	# fi

	CONFIG_CHECK=""
	linux-mod_pkg_setup
	linux-info_pkg_setup

	BUILD_PARAMS="-C ${KV_DIR} M=${S} -I${HPT_ROOT}/osm/linux -I${KV_DIR}/include -I${KV_DIR}/drivers/scsi"
	#BUILD_TARGETS="rr2680.ko"
}

src_unpack() {
	#local arch_suffix
	#if use amd64; then
	#	arch_suffix="amd64"
	#else
	#	arch_suffix="i386"
	#fi
	#unpack_deb "${BASE_NAME}${arch_suffix}.deb"

	unpack ${A}
	./RR268x_Linux_Src_${HPT_VERSION}${HPT_DATE}.bin  --noexec --nox11 --target hptdrv >/dev/null 2>&1

}

src_compile() {

	cd "${S}"
	#tar -C / -xf  /tmp/mod.tar
	# --noexecstack no effect?

	#inherit flag-o-matic
	## This line goes before CFLAGS is used (either by the ebuild or by econf/emake)
	#append-flags -Wa,--noexecstack

	#inherit flag-o-matic
	## This line goes before LDFLAGS is used (either by the ebuild or by econf/emake)
	#append-ldflags -Wl,-z,noexecstack

	# no effect?
	QA_PRESTRIPPED="lib/modules/$KV_FULL/kernel/drivers/block/rr2680.ko"
	LDFLAGS="-Wl,-z,noexecstack" CFLAGS="-Wa,--noexecstack" KERNELDIR=$KV_DIR make

}

src_install() {
	local base=$D/lib/modules/$KV_FULL/kernel/drivers/block
	mkdir -p $base || die "Needs a folder"
	cp "${S}/rr2680.ko" "$base" || die "Can not copy mod file"
	#depmod  -b $base

}

pkg_postinst() {
	depmod
}

#src_prepare() {
##	Filter the outdated patches here
#	EPATCH_FORCE="yes" EPATCH_EXCLUDE="0002* 0004* 0005*" EPATCH_SOURCE="${S}/patches" EPATCH_SUFFIX=patch epatch
##	Makefile.patch: keep `emake install` working
##	linux-3.9.0.patch: add support for kernel 3.9.0
##	linux-3.10.0.patch: add support for kernel 3.10, bug #477372
#	epatch "${FILESDIR}/${P}-makefile.patch" \
#		"${FILESDIR}/${P}-linux-3.9.0.patch" \
#		"${FILESDIR}/${P}-linux-3.10.0.patch"
#	mv "${S}/lib/wlc_hybrid.o_shipped_"* "${S}/lib/wlc_hybrid.o_shipped" \
#		|| die "Where is the blob?"
#
#	epatch_user
#}
