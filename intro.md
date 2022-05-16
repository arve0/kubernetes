# Introduksjon
Kubernetes er en kjøreplattform for containere på [OCI-standarden](https://opencontainers.org).

Kort sagt har Kubernetes ansvaret for

- å holde tjenesten i live
- horisontalt skalere containere
- rute trafikk internt mellom tjenester
- rute ekstern trafikk til tjenesten
- rullende oppgraderinger
- mellomlagre logg fra stdout og stderr
- håndtere konfigurasjon til tjenesten
- adminstrere lagring til tjenesten
- med mer

Adminsitrasjon skjer via ressurser som beskriver tjenestene og deres tilhørende konfigurasjon. Typisk er ressursene serialisert som YAML.

Eksempelvis kan en beskrive en kjørende container som en [`Pod`](https://kubernetes.io/docs/concepts/workloads/pods/):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tjeneste-a
  namespace: namespace-b
spec:
  containers:
  - name: nginx
    image: nginx:1.14.2
    ports:
    - containerPort: 80
```

Her er kombinasjonen `apiVersion`, `kind`, `name` og `namespace` unik, slik at den
brukes som oppslagsnøkkel i databasen. `spec` beskriver hva/hvordan containeren skal kjøre.

## fysiske maskiner
Vanligvis er det tre maskiner som kjører databasen etcd og
n-antall worker-noder som kjører arbeidslasten.

```
   ┌─master-node-1────┐               ┌─master-node-2────┐     ┌─master-node-3────┐
   │                  │               │                  │     │                  │
   │                  │               │                  │     │                  │
   │ ┌─etcd-db─────┐  │               │ ┌─etcd-db─────┐  │     │  ┌─etcd-db─────┐ │
   │ │             │  │               │ │             │  │     │  │             │ │
   │ │             │  │               │ │             │  │     │  │             │ │
   │ │             │  ├───┬─nettverk──┤ │             │  ├──┬──┤  │             │ │
   │ │             │  │   │           │ │             │  │  │  │  │             │ │
   │ │             │  │   │           │ │             │  │  │  │  │             │ │
   │ └─────────────┘  │   │           │ └─────────────┘  │  │  │  └─────────────┘ │
   │                  │   │           │                  │  │  │                  │
   │                  │   │           │                  │  │  │                  │
   └──────────────────┘   │           └──────────────────┘  │  └──────────────────┘
                          │                                 │
                          │                                 │
                          ├─────────────────────────────────┘
                          │
                          │
   ┌─worker-node-1────┐   │   ┌─worker-node-2────┐
   │                  │   │   │                  │
   │                  │   │   │                  │
   │ ┌─pod-a───────┐  │   │   │ ┌─pod-c───────┐  │
   │ │             │  │   │   │ │             │  │
   │ │ container-1 │  │   │   │ │ container-1 │  │
   │ │             │  │   │   │ │             │  │
   │ │ container-2 │  │   │   │ │ container-2 │  │
   │ │             │  │   │   │ │             │  │
   │ └─────────────┘  │   │   │ └─────────────┘  │
   │                  │   │   │                  │
   │                  │   │   │                  │       .... worker n
   │ ┌─pod-b───────┐  ├───┴───┤ ┌─pod-d───────┐  │
   │ │             │  │       │ │             │  │
   │ │ container   │  │       │ │ container   │  │
   │ │             │  │       │ │             │  │
   │ │             │  │       │ │             │  │
   │ │             │  │       │ │             │  │
   │ └─────────────┘  │       │ └─────────────┘  │
   │                  │       │                  │
   │                  │       │                  │
   │  ...             │       │  ...             │
   │                  │       │                  │
   │                  │       │                  │
   │                  │       │                  │
   └──────────────────┘       └──────────────────┘
```

## abstraksjoner for arbeidslast
[`Deployment`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
er normalt det en bruker for å kjøre en tjeneste.
Ansvaret til en `Deployment` er i hovedsak å rullere til neste
versjon av tjenesten, uten å forstyrre arbeidslasten. Ved endringer i `image` vil
Deployment-controlleren kjøre opp den nye varianten av tjenesten og vente
med å slå av forrige versjon til ny variant er oppe og kjører.

For å kjøre tjenesten, delegerer `Deployment` ansvaret videre til
[`ReplicaSet`](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/).
Hovedansvar til `ReplicaSet` er å kjøre et spesifisert antall `Pods`, altså
horisontal skallering. Dersom en `Pod` forsvinner, vil replica-controlleren
opprette en ny.

Til slutt har `Pod` ansvaret for å holde container i tjenesten i live. Typisk via
å starte prosess i container på nytt hvis den dør eller restarte containere dersom
en [`livenessProbe`](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#types-of-probe)
feiler.

For å selv utforske ressurs-hierarkiet, kan en se på `metadata.ownerReferences`. Her er en `Pod`
med navn `tjeneste-a-6dfbb6d557-md5dr` barn av `ReplicaSet` med navn `tjeneste-a-6dfbb6d557`:

```yaml
kind: Pod
apiVersion: v1
metadata:
  name: tjeneste-a-6dfbb6d557-md5dr
  namespace: namespace-b
  ownerReferences:
    - apiVersion: apps/v1
      kind: ReplicaSet
      name: tjeneste-a-6dfbb6d557
      uid: 7ba79c63-df7a-49d1-b38d-a7d8155aea68
      controller: true
      blockOwnerDeletion: true
```

## Kontrollspørsmål
Hvilken controller/abstraksjon har ansvaret for å holde container i live?

- Deployment
- ReplicaSet
- Pod

Hvilken ressurs brukes vanligvis når en ønsker en kjørende tjeneste?

- Deployment
- ReplicaSet
- Pod

Hvilken ressurs kan kjøre opp en ny variant av tjenesten før forrige variant fjernes?

- Deployment
- ReplicaSet
- Pod