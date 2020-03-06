# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Yet Another Dotfiles Manager"
HOMEPAGE="https://yadm.io"
SRC_URI="https://github.com/TheLocehiliosan/yadm/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	app-shells/bash:*
"
RDEPEND="${DEPEND}"

src_compile() {
	true;
}

src_install(){
	mv bootstrap yadm-bootstrap
	dobin yadm-bootstrap
	dobin yadm
	doman yadm.1
}
