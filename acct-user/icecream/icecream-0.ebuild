# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="user for icecream daemons"
ACCT_USER_ID=145
ACCT_USER_GROUPS=( icecream )

acct-user_add_deps
