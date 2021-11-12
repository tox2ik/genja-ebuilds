# Copyright 2021 jazzoslav@gmail.com
# Distributed under the terms of the GNU Affero General Public Licence v3
# $Header: $

EAPI="6"
USE_PHP="php7-3 php7-4 php8-0"

#MY_PN="${PHP_EXT_NAME}-php5"
PHP_EXT_NAME="newrelic"
PHP_EXT_S=/var/tmp/portage/dev-php/newrelic-php5-bin-$PV/work/newrelic-php5-$PV-linux
MY_P="newrelic-php5-${PV}-linux"
S="${WORKDIR}/${MY_P}"

inherit php-ext-source-r3 user

DESCRIPTION="New Relic PHP Agent"
HOMEPAGE="http://newrelic.com/"
SRC_URI="https://download.newrelic.com/php_agent/archive/${PV}/${MY_P}.tar.gz"
#        https://download.newrelic.com/php_agent/archive/9.18.1.303/newrelic-php5-9.18.1.303-linux.tar.gz
#        https://download.newrelic.com/php_agent/release/newrelic-php5-9.18.1.303-linux.tar.gz

LICENSE="newrelic Apache-2.0 BSD MIT openssl PCRE PHP-3.01 ZLIB"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="
	acct-user/newrelic
	dev-lang/php[cli]
	sys-apps/grep[pcre]"
RDEPEND="dev-lang/php"

php_get_information() {
	${PHPCLI} -i 2> /dev/null | grep -Po "(?<=^${1} => ).*$"
}


# skip exported php-ext-source-r2_src_prepare() function
# skip exported php-ext-source-r2_src_configure() function
# skip exported php-ext-source-r2_src_compile() function

#pkg_setup() { enewuser "newrelic"; }
src_prepare() {

	eapply_user;

	for slot in $(php_get_slots); do
		#echo "cp -vr $WORKDIR/newrelic-php5-$PV-linux/ $WORKDIR/${slot}"
		#cp -v $WORKDIR/newrelic-php5-$PV-linux/ $WORKDIR/${slot}
		#mkdir $WORKDIR/newrelic-php5-$PV-linux/ $WORKDIR/${slot}
		ln -snv $WORKDIR/newrelic-php5-$PV-linux/ $WORKDIR/${slot}
	done

}
src_configure() { true; }
src_compile() {
	true;
}

src_install() {
	dodoc README.txt
	dodoc scripts/newrelic.ini.template
	dodoc scripts/newrelic.cfg.template
	dodoc scripts/newrelic.ini.template


	local slot
	for slot in $(php_get_slots); do
		php_init_slot_env ${slot}
		test -f ${PHPCLI} || die "Missing PHP binary: '${PHPCLI}'"

		local abi="$( php_get_information "PHP Extension" )"
		local zts="$( php_get_information "Thread Safety" )"

		[[ ${zts} == enabled ]] && zts=-zts || zts=''
		local extension_file="${PHP_EXT_NAME}-${abi}${zts}.so"

		if use amd64; then local arch="x64";
		elif use x86; then local arch="x86";
		else die "Unsupported architecture";
		fi

		insinto "${EXT_DIR}"
		newins agent/${arch}/${extension_file} "${PHP_EXT_NAME}.so"
	done

	exeinto /usr/bin
	newexe daemon/newrelic-daemon.${arch} newrelic-daemon
	newexe scripts/newrelic-iutil.${arch} newrelic-iutil


	local daemon_pid="/run/newrelic/daemon.pid"
	local daemon_socket="/run/newrelic/newrelic.sock"

	php-ext-source-r3_createinifiles

	# Addding required ini options which do not have a (sane) default value.
	php-ext-source-r3_addtoinifiles "[newrelic]"
	php-ext-source-r3_addtoinifiles "newrelic.license" "REPLACE_WITH_REAL_KEY"
	#php-ext-source-r3_addtoinifiles "newrelic.appname" "PHP Application"
	#php-ext-source-r3_addtoinifiles "newrelic.logfile" "/var/log/newrelic/php_agent.log"
	#php-ext-source-r3_addtoinifiles "newrelic.loglevel" "info"
	# php-ext-source-r3_addtoinifiles "; newrelic.loglevel = info (error / warning / info / verbose / debug / verbosedebug) (SYSTEM)"
	# php-ext-source-r3_addtoinifiles "; newrelic.capture_params = false (PERDIR)"
	# php-ext-source-r3_addtoinifiles "; newrelic.framework = no_framework / symfony4 / cakephp etc (PERDIR)"
	# php-ext-source-r3_addtoinifiles "; newrelic.ignored_params = DEPRECATED (PERDIR)"
	# php-ext-source-r3_addtoinifiles "; newrelic.transaction_tracer.detail = 1 (1; all, 0; internal + newrelic.transaction_tracer.custom."
	# php-ext-source-r3_addtoinifiles "; newrelic.high_security = false"
	# php-ext-source-r3_addtoinifiles '; newrelic.labels = "Server:One;Data Center:Primary"'
	# php-ext-source-r3_addtoinifiles "; newrelic.process_host.display_name = myserver"

	# php-ext-source-r3_addtoinifiles "newrelic.daemon.logfile" "/var/log/newrelic/daemon.log"
	# php-ext-source-r3_addtoinifiles "newrelic.daemon.address" "${daemon_socket}"
	# php-ext-source-r3_addtoinifiles "newrelic.daemon.pidfile" "${daemon_pid}"
	# php-ext-source-r3_addtoinifiles "newrelic.daemon.location" "/usr/bin/newrelic-daemon"

	# dont_launch: 0: No restrictions are placed on daemon startup and the agent can start the daemon any time.
	# dont_launch: 1: Non-command line (such as Apache or php-fpm) agents can start the daemon.
	# dont_launch: 2: Only command line agents can start the daemon.
	# dont_launch: 3: The agent will never start the daemon. Use this setting if you are configuring
	# mv /etc/newrelic/newrelic.cfg /etc/newrelic/newrelic.cfg.external
	# newrelic.daemon.dont_launch = 0



	insinto /etc/newrelic
	newins ${FILESDIR}/newrelic.cfg newrelic.cfg
	# Gentoo places PIDs and sockets under /run
	sed -i \
		-e "s|^#\?\(pidfile\)=.*|\1=${daemon_pid}|" \
		-e "s|^#\?\(address\)=.*|\1=${daemon_socket}|" \
		"${D}"/etc/newrelic/newrelic.cfg || die "Sed failed"

	insinto /etc/logrotate.d
	newinitd ${FILESDIR}/newrelic.logrotate newrelic
	#newins scripts/newrelic-daemon.logrotate newrelic-daemon
	#newins scripts/newrelic-php5.logrotate newrelic-php_agent


	insinto /lib/systemd/system
	#newins scripts/newrelic-daemon.service  newrelic.service
	newins ${FILESDIR}/newrelic.service newrelic.service


	diropts -o newrelic -g newrelic
	keepdir /var/log/newrelic


	## tox2ik: "checkpath" for openrc to create directories
	#newinitd "${FILESDIR}"/newrelic-daemon.initd newrelic-daemon
	#newconfd "${FILESDIR}"/newrelic-daemon.confd newrelic-daemon
}

pkg_postinst() {
	einfo ""
	einfo "Make sure to replace the newrelic.license value with your real key"
	einfo "and also set the newrelic.appname to match your application's name"
	einfo ""
	einfo "When you have obtained a licence (access key) from Newrelic, add it to the newrelic.ini"
	einfo ""
	einfo "    sed -i /etc/php/*/ext/newrelic.ini -e s/REPLACE_WITH_REAL_KEY/eu01xx...............................RAL/"


	# einfo "The newrelic daemon can be started with the provided init-script"
	# einfo "/etc/init.d/newrelic-daemon start"
}
