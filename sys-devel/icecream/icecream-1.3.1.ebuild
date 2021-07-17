# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_P="${P/icecream/icecc}"

inherit systemd

DESCRIPTION="Distributed compiling of C(++) code across several machines; based on distcc"
HOMEPAGE="https://github.com/icecc/icecream"
SRC_URI="https://api.github.com/repos/icecc/icecream/tarball/${PV} -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ppc ~sparc ~x86"
IUSE="systemd"

DEPEND="
	sys-libs/libcap-ng
	acct-group/icecream
	acct-user/icecream
"
RDEPEND="
	${DEPEND}
	dev-util/shadowman
	app-arch/libarchive
	app-arch/xz-utils
	sys-libs/zlib
	dev-libs/libxml2
	dev-libs/icu
"

DOCS=( NEWS BENCH README.md )

S="${WORKDIR}/icecc-${PN}-6eec038"

src_prepare() {
	default
	./autogen.sh || die
}

src_configure() {
	econf \
		--enable-shared --disable-static \
		--enable-clang-wrappers \
		--enable-clang-rewrite-includes
#		--prefix=/opt/icecream
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die


	echo '
	ICECREAM_VERBOSITY="-vv"' >> suse/sysconfig.icecream
	newconfd suse/sysconfig.icecream icecream
	newinitd "${FILESDIR}"/icecream-r2 icecream

	insinto /etc/logrotate.d
	newins suse/logrotate icecream

	insinto /usr/share/shadowman/tools
	newins - icecc <<<'/usr/libexec/icecc/bin'

	systemd_dounit "${FILESDIR}"/${PN}-scheduler.service
	systemd_dounit "${FILESDIR}"/${PN}-daemon.service



}

pkg_prerm() {
	if [[ -z ${REPLACED_BY_VERSION} && ${ROOT} == / ]]; then
		eselect compiler-shadow remove icecc
	fi
}

pkg_postinst() {
	if [[ ${ROOT} == / ]]; then
		eselect compiler-shadow update icecc
	fi
	source /etc/conf.d/icecream
	#touch ${ICECREAM_SCHEDULER_LOG_FILE:-"/var/log/icecc_scheduler"}
	#chown icecream:icecream ${ICECREAM_SCHEDULER_LOG_FILE:-"/var/log/icecc_scheduler"}
}
