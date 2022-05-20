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
7. [Ekstra](ekstra.md)

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

### Forhåndskunnskap
Deltaker burde ha kjennskap til hvordan en bygger og publiserer en applikasjon som et Docker image.

### Nødvendig programvare
Dette burde du ha installert på din PC for å utnytte tiden best under workshoppen:

- [kubectl](https://kubectl.docs.kubernetes.io/installation/kubectl/)
- teksteditor med YAML-støtte