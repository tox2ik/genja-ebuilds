# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..10} pypy3 )
#PYTHON_REQ_USE="xml(+),threads(+)"

# https://devmanual.gentoo.org/eclass-reference/python-utils-r1.eclass/index.html
# https://dev.gentoo.org/~mgorny/python-guide/eclass.html
inherit python-r1 distutils-r1

DESCRIPTION="A highly efficient backup system based on the git packfile format"
HOMEPAGE="https://bup.github.io/ https://github.com/bup/bup"
SRC_URI="https://github.com/bup/bup/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+doc test web readline"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
dev-vcs/git
sys-libs/readline
"
DEPEND="${RDEPEND}
	web? ( www-servers/tornado[${PYTHON_USEDEP}] )
	doc? ( app-text/pandoc )
	test? (
		dev-lang/perl
		net-misc/rsync
	)
	dev-python/pyxattr
	dev-python/pylibacl
"
# apt-get install python3-pyxattr python3-pytest
# apt-get install python3-distutils
# apt-get install pkg-config linux-libc-dev libacl1-dev
# apt-get install gcc make acl attr rsync
# apt-get isntall python3-pytest-xdist # optional (parallel tests)
# apt-get install par2 # optional (error correction)
# apt-get install libreadline-dev # optional (bup ftp)
# apt-get install python3-tornado # optional (bup web)

#RDEPEND="${PYTHON_DEPS}
#	app-arch/par2cmdline
#	dev-python/fuse-python[${PYTHON_USEDEP}]
#	dev-python/pyxattr[${PYTHON_USEDEP}]
#	dev-python/pylibacl[${PYTHON_USEDEP}]

# unresolved sandbox issues
RESTRICT="test"

PATCHES=(
	"${FILESDIR}"/${P}-sitedir.patch
	"${FILESDIR}"/${P}-config.patch
)

src_configure() {
	# only build/install docs if enabled
	export PANDOC=$(usex doc pandoc "")
	cd config
	./configure || die
	echo EPY "${EPYTHON}"
	echo site $(python_get_sitedir)
}

python_prepare_all() {
	distutils-r1_python_prepare_all
	python_setup
}

src_compile() {
	#python_copy_sources
	#python_foreach_impl run_in_build_dir emake
	emake
}

src_test() {
	emake test
}

# todo:
# should be in site-packages? /usr/lib/bup/bup/__pycache__/source_info.cpython-39.opt-2.pyc
# should be in site-packages? /usr/lib/bup/bup/__pycache__/source_info.cpython-39.opt-1.pyc
# should be in site-packages? /usr/lib/bup/bup/__pycache__/source_info.cpython-39.pyc
# should be in site-packages? /usr/lib/bup/bup/source_info.py

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr DOCDIR="/usr/share/${PF}" \
		SITEDIR="$(python_get_sitedir)" install
	#local SI=$(python_get_sitedir)
	#echo ED "$ED"
	#echo SI $(python_get_sitedir)
	#python_fix_shebang "${ED}"
	python_optimize "${ED}"
	python_optimize "${ED}/bup"
	python_optimize "${ED}/bup/__pycache__/"
}
