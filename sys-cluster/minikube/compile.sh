rm -f /var/tmp/portage/sys-cluster/minikube-1.5.2/.compiled
repoman manifest

ebuild ./minikube-1.5.2.ebuild compile
