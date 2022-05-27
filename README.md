# Kubernetes workshop
Kubernetes har blitt en av de mest populære kjøreplattformene for container-applikasjoner.
I denne workshoppen lærer du deg hvordan kubernetes-plattformen brukes til å kontinuerlig
levere tjenester uten driftsstans.

## Innhold

1. [Introduksjon](intro.md)
2. [Kom i gang](start.md)
3. [Deployments](deployment.md)
4. [Intern trafikk](intern-trafikk.md)
5. [Ekstern trafikk](ekstern-trafikk.md)
6. [Rullerende deployment](rullerende-deployment.md)
7. [Hindre nedetid](hindre-nedetid.md)
8. [Ekstra (ikke del av kurs)](ekstra.md)

## Kursbeskrivelse
En intro om hva kubernetes tilbyr. Etter introduksjonen arbeides det individuelt med oppgaver.
Gjennom oppgavene vil du lære deg å levere en applikasjon i kubernetes og gjøre en rullende
oppdatering av applikasjonen uten brudd på tjenesten.

Workshoppen avsluttes med en kahoot.

### Oppnådd kompetanse
- Vet hensikten med abstraksjonene Deployment, ReplicaSet, Pod og container.
- Kan levere en applikasjon til et Kubernetes cluster med en Deployment.
- Kan rute trafikk til tjenesten innad i cluster med en Service.
- Kan rute trafikk til tjenesten utad clusteret med en Ingress.
- Kan gjøre en rullende oppdatering av applikasjonen uten brudd på tjenesten.
- Hindre nedetid ved å bruke `readinessProbe` og `livenessProbe`.

### Forhåndskunnskap
Deltaker burde ha kjennskap til hvordan en bygger og publiserer en applikasjon som et Docker image.

### Nødvendig programvare
Dette burde du ha installert på din PC for å utnytte tiden best under workshoppen:

- POSIX-terminal med `curl`, `git` og `tr`.

  **Bruker du Windows?** Bruk [WSL](https://docs.microsoft.com/en-us/windows/wsl/install).

  **Installasjon av WSL**: Åpne *PowerShell* og skriv:

  ```sh
  wsl --install -d ubuntu
  ```

  En ny terminal åpner som spør om brukernavn og passord. Passord brukes i `sudo`-kommandoer senere, husk det.

  Terminalen med Ubuntu brukes for alle kommandoer i kurset. Om du trenger flere terminaler, kan du åpne *PowerShell* og skrive `wsl`.

  Merk: [Debian 9 har en sertifikat-feil](https://serverfault.com/questions/1079199/client-on-debian-9-erroneously-reports-expired-certificate-for-letsencrypt-issue),
  derfor anbefales Ubuntu. Debian 10 er ikke tilgjengelig på WSL per mai 2022.

- [kubectl](https://kubectl.docs.kubernetes.io/installation/kubectl/):

  Linux og Windows WSL:

  ```sh
  sudo curl "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    --location \
    --output /usr/local/bin/kubectl
  sudo chmod +x /usr/local/bin/kubectl
  ```

  Mac, homebrew:

  ```sh
  brew install kubectl
  ```

  Annet? Se [installasjonsguide for kubectl](https://kubectl.docs.kubernetes.io/installation/kubectl/).

- teksteditor med YAML-støtte