# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="user for newrelic daemon"
ACCT_USER_ID=4001
ACCT_USER_GROUPS=( newrelic )

acct-user_add_deps
