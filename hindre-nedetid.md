# Hindre nedetid
Når du er ferdig med oppgavene på denne siden skal du kunne bruke
[`readinessProbe` og `livenessProbe`](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
til å holde en ustabil tjeneste oppe.

I [Rullerende deployment](rullerende-deployment.md) endret vi tjenesten,
uten at det medførte driftsstans. Hvis en ikke definerer noe annet,
vil Kubernetes sende trafikk til tjenesten så snart prosessen i container
kjører. For veldig enkle tjenester er dette nok, men for tjenester som
krasjer vil en snart oppleve nedetid.

Kubernetes har to teknikker for å hindre nedetid:

1. `replicas` kjører flere like pods som alle mottar trafikk.
2. Helseprobene `startup`, `readiness` og `liveness` sjekker at tjenesten er OK.

`replicas` har vi allerede brukt, i [deployment.yaml](deployment.yaml) satt vi
`replicas: 2`.

Helseprober har vi ikke tatt i bruk. Her skal vi bruke `readinessProbe` og `livenessProbe`,
`startupProbe` trenger vi ikke siden tjenesten er rask å starte opp.

## Start en ustabil tjeneste
Først trenger vi å kjøre en ustabil tjeneste. For kurset er det opprettet
[en server som tilfeldig feiler](ustabil-server/server.js) fire forespørsler
etter hverandre, samt dør helt etter 60 eller 80 sekunder.

Målet er å oppnå en så stabil tjeneste som mulig, uten å endre
[ustabil-server/server.js](ustabil-server/server.js).

Start med å definere hostname for tjenesten:

```sh
export HOST=ustabil-<brukernavn>
```

`$HOST` brukes i [ustabil-server.yaml](ustabil-server.yaml),
og byttes ut ved å bruke `envsubst`.

Opprett tjenesten:

```sh
envsubst < ustabil-server.yaml | kubectl apply -f -
```

Sjekk hva som skjer:

```sh
while true; do
  date | tr '\n' ' '
  curl $HOST.apps.workshop.arve.dev
  sleep 1
done
```

La testen kjøre i et vindu for alle oppgavene på denne siden.

Etter en stund burde du se at flere forespørsler feiler. Venter du lenge nok,
vil du se at begge tjenesten går ned.

## Stopp trafikk når HTTP feiler
Første løsning er å ikke sende trafikk til `Pod` når flere forespørsler
etter hverandre feiler med en `readinessProbe`. Når proben feiler,
vil ikke `Pod` motta trafikk fra `Service`.

Åpne [ustabil-server.yaml](ustabil-server.yaml) og legg på en `readinessProbe` under
container-spesifikasjonen (`statefulset.spec.template.spec.containers)`:

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 8080
  periodSeconds: 1 # sjekk hvert sekund
  failureThreshold: 1 # en feil -> ikke send trafikk
```

`httpGet` sier at helsesjekken skal bruke en HTTP-forespørsel mot port 8080.
`periodSeconds` sier hvor ofte sjekken skal skje. `failureThreshold` sier
hvor mange ganger den kan feile før `Service` stopper å sende trafikk.

Aktiver endringen:

```sh
envsubst < ustabil-server.yaml | kubectl apply -f -
```

Nå burde vi se at tjenesten feiler kun en gang før den andre tar over trafikken.

```
Thu Jun 23 10:44:10 CEST 2022 jeg er ustabil-server-1 en ustabil server som dør etter 80 sekunder Internal server error: Feil nr 3/4.
Thu Jun 23 10:44:11 CEST 2022 jeg er ustabil-server-0 en ustabil server som dør etter 60 sekunder
Thu Jun 23 10:44:12 CEST 2022 jeg er ustabil-server-0 en ustabil server som dør etter 60 sekunder
Thu Jun 23 10:44:13 CEST 2022 jeg er ustabil-server-0 en ustabil server som dør etter 60 sekunder
Thu Jun 23 10:44:14 CEST 2022 jeg er ustabil-server-0 en ustabil server som dør etter 60 sekunder
```

Merk at _ustabil-server-1_ ikke svarer, men ustabil-server-0. Pod er ikke _ready_ på
grunn av proben vi la til.

Også, når ustabil-server-0 krasjer helt etter 60 sekund, skal vi se kun
svar fra ustabil-server-1 en stund før alle request feiler med
*503 Service Temporarily Unavailable*.

```
Thu Jun 23 10:44:32 CEST 2022 jeg er ustabil-server-0 en ustabil server som dør etter 60 sekunder
... 20 requests til - ingen svar fra ustabil-server-0 her
Thu Jun 23 10:45:48 CEST 2022 jeg er ustabil-server-1 en ustabil server som dør etter 80 sekunder
Thu Jun 23 10:45:49 CEST 2022 jeg er ustabil-server-1 en ustabil server som dør etter 80 sekunder
Thu Jun 23 10:45:50 CEST 2022 jeg er ustabil-server-1 en ustabil server som dør etter 80 sekunder
Thu Jun 23 10:45:51 CEST 2022 jeg er ustabil-server-1 en ustabil server som dør etter 80 sekunder
Thu Jun 23 10:45:52 CEST 2022 <html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx</center>
</body>
</html>
Thu Jun 23 10:45:53 CEST 2022 <html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

`kubectl describe` viser at proben har feilet for begge pods:

```sh
kubectl describe pods -l app=ustabil-server
```

For å bedre oppetiden må vi også restarte pod.

## Restart Pod når HTTP feiler lenge
Siden begge podene dør til slutt, etter 60 eller 80 sekunder, trenger
vi å omstarte poden når det skjer.

Legg til en `livenessProbe` i [ustabil-server.yaml](ustabil-server.yaml):

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 8080
  periodSeconds: 1 # sjekk hvert sekund
  failureThreshold: 5 # fem feil -> omstart pod
```

Liveness-proben skal på samme sted som readiness-proben, under
`statefulset.spec.template.spec.containers`.

Aktiver endringen:

```sh
envsubst < ustabil-server.yaml | kubectl apply -f -
kubectl delete pod -l app=ustabil-server
```

Av en eller annen grunn detekterer ikke Kubernetes endringen i pod-template,
så vi må slette pods for å få den oppdaterte spesifikasjonen.

Nå skal tjenesten klare å holde seg oppe, med noen feilende
forespørsler.

En skal se at podene restartes når de krasjer for godt:

```sh
kubectl get pods -l app=ustabil-server
```

Merk at vi gjorde `readiness` mer aggressiv enn `liveness`.
Det er en god strategi for å så raskt som mulig skifte trafikk
over til friske pods, la syke pods få tid til å bli friske igjen,
og hvis ikke omstarte de.

Om du kjører tjenesten lenge, vil den likevel være ustabil,
ettersom *ustabil-server* er ekstremt ustabil. Når en pod
omstarter svært ofte vil Kubernetes sette pod i tilstanden
*CrashLoopBackOff* og vente med å starte den.

Du er nå ferdig. Sjekk om du har kontroll på
[Oppnådd kompetanse i README](README.md). Hvis ikke, spør
en av kursholderne.

[Lyst å lære mer? Les ekstra-oppgavene.](ekstra.md)