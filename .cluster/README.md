Installasjon av cluster for workshoppen.

Installasjon er cirka:

```sh
rm cluster/ca
rm cluster/server
rm cluster/version
rm cluster/kubeconfig
rm cluster/install
make cluster/install cluster/metrics
make all # feiler
# sett opp wildcard DNS
make registry
make docker-pull-secret
make list-repos
# tjeneste for å hente kubeconfig
cd kubeconfig-server/
make
curl https://kubeconfig.apps.workshop.arve.dev
cd ..
# docker images til oppgaver
make server ustabil-server
# brukere
make usernames NUMBER_OF_USERS=30
make users
make user-setup
```