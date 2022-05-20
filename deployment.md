# Deployment
Når du er ferdig med oppgavene på denne siden skal du kunne bruke
[`Deployment`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
for å kjøre en tjeneste, samt endre tjenesten i dens livsløp.

## Om Deployment
Pod har svært begrenset ansvar. Du merket kanskje at poden ikke kunne endres etter den var opprettet?
[`Deployment`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) fyller behovet for å endre en tjeneste.

Lik pod, har også `Deployment` en `spec`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hei
  labels:
    app: hei
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hei
  template:
    metadata:
      labels:
        app: hei
    spec:
      containers:
      - name: hei
        image: busybox
        resources: {}
        command: ["/bin/sh"]
        args: ["-c", "while true; do echo hei; sleep 10; done"]
```

Under `spec.template.spec` finner vi `spec` til `Pod` som vi så i [pod.yaml](pod.yaml).

I tillegg har vi `repliacas`, `selector` og `template.metadata`.

`replicas` bestemmer hvor mange pods som skal kjøre.

`selector` sier hvordan deployment-controlleren skal finne pods som er sine. Her er det vanlig
å bruke samme navn som tjenesten. `tempalte.metadata` setter den aktuelle labelen på `Pod`.

Resulterende `Pod` blir noe slikt som under *(har fjernet detaljer som er uviktige)*:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hei-7b77d9dc96-jwm8q
  labels:
    app: hei
spec:
  containers:
  - name: hei
    image: busybox
    resources: {}
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo hei; sleep 10; done"]
```

Ved endring av `Deployment` vil ny `Pod` opprettes og feltet `metadata.labels.app` brukes
for å rydde opp i gamle pods som ikke trenger å kjøre mer.

## Opprette en deployment
`kubectl apply` brukes som samlekommando for å opprette eller endre. Opprett `Deployment`
spesifisert i `deployment.yaml`:

```sh
kubectl apply -f deployment.yaml
```

- Hva skjer om du kjører kommandoen flere ganger?
- Se om du finner tilhørende pods med `kubectl get pods --selector app=hei`.
- Hva skjer om du sletter pods med `kubectl delete pods --selector app=hei --wait=false`?

## Endre en deployment
Åpne [deployment.yaml] og endre spesifikasjonen til å skrive ut dato istedenfor *"hei"*.

Oppdater clusteret med den nye spesifikasjonen:

```sh
kubectl apply -f deployment.yaml
```

Ser du pods med ulike statuser slik som *ContainerCreating*, *Terminating* og *Running*?

## ReplicaSet
`replicas` som settes i `Deployment` kontrolleres av `ReplicaSet`. Oppgaven til
`ReplicaSet` er å holde n antall pods i live. Som du tidligere så, ville en ny
pod oppstå dersom en eksisterende ble slettet.

Du kan se tilhørende `ReplicaSet` med samme label som på pod:

```sh
kubectl describe replicaset --selector app=hei
```

Normalt er det lite nyttig informasjon på `ReplicaSet`, men det er lurt å vite om
eierskapet `Deployment` -> `ReplicaSet` -> `Pod` når en skal debugge en tjeneste
som ikke kommer opp.

[Neste oppgave er intern trafikk i cluster.](intern-trafikk.md)