EAPI=5
PYTHON_COMPAT=( python{2_6,2_7} )

if [[ ${PV} = *9999* ]]; then
inherit git-2
EGIT_REPO_URI="git://github.com/dsoprea/GDriveFS.git
               https://github.com/dsoprea/GDriveFS.git"
else
SRC_URI="https://github.com/dsoprea/GDriveFS/archive/${PV}.tar.gz"
fi

inherit distutils-r1 eutils

DESCRIPTION="An innovative FUSE wrapper for Google Drive."
HOMEPAGE="https://github.com/dsoprea/GDriveFS"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

## look into: https://github.com/ZyX-I/powerline/commit/2fea731c3a26f11139d0583720408d7b5dc18528
#python_test() {
#	PYTHON="${PYTHON}" tests/test.sh || die "Tests fail with ${EPYTHON}"
#}

RDEPEND="
	>=dev-python/fusepy-2.0.2
	>=dev-python/gevent-1.0
	>=dev-python/gipc-0.4.0
	dev-python/oauth2client
	>=dev-python/greenlet-0.4.2
	>=dev-python/httplib2-0.8
	>=dev-python/python-dateutil-2.2
	>=dev-python/six-1.7.3"
DEPEND="${RDEPEND}"

S="${WORKDIR}/GDriveFS-$PV"
src_unpack() {
	unpack $A

	echo FOLDER $PWD
	echo PN $PN
	echo P $P
	echo S $S
	ls
	#echo ------------------------------
	#env | grep dist| sed 's/^/ENV /'
	echo ------------------------------
	echo ------------------------------

}


src_prepare() {
	#epatch "${FILESDIR}"/exclude_all_tests.patch
	epatch "${FILESDIR}"/exclude_tests.patch
}

python_install() {
	distutils-r1_python_install
	dosym /usr/bin/gdfs /sbin/mount.gdfs
}
