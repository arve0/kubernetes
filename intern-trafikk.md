# Intern trafikk
Når du er ferdig med oppgavene på denne siden skal du kunne bruke
[`Service`](https://kubernetes.io/docs/concepts/services-networking/service/)
til å rute trafikk internt i cluster til podene som kjører tjenesten.

## Om Service
Siden pods kan oppstå og forsvinne brukes abstraksjonen `Service`
for å finne tjenester. En `Service` peker til en eller flere `Pod`
med labels og spesifiserer hvilken port trafikken går på.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hei
spec:
  selector:
    app: hei
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 8080
```

Spesifikasjonen over gir endepunktet http://hei/ som vil sende trafikken
til pods med label `app=hei` på port 8080.

## En enkel proxy tjeneste
Mappen [server](server) inneholder en implementasjon av en enkel proxy-server.
Serveren vil gjøre en HTTP-forespørsel mot host fra path. For eksempel vil
`curl server` svare med navnet på server og `curl server/arve.dev` vil
videresende svaret fra `curl arve.dev`.

Denne serveren er tilgjengelig som docker image `registry.apps.workshop.arve.dev/server`
innad i clusteret.

[service.yaml](service.yaml) inneholder ressurser for å kjøre serveren på clusteret med
to `Service` og to `Deployment`. Navn på tjenesten er *server-a* og *server-b*.

Deploy tjenestene til clusteret:

```sh
kubectl apply -f service.yaml
```

Åpne en port-forward til *server-a*:

```sh
kubectl port-forward service/server-a 8080:80
```

Port 8080 er lokal, 80 er på clusteret. `kubectl port-forward` må kjøre så lenge du holder på med oppgavene på denne siden.

Prøv å kalle tjenesten:

```sh
curl localhost:8080
curl localhost:8080/server-b
curl localhost:8080/server-a # rekursivt en gang
```

Se loggen til servere:

```sh
kubectl logs deployment/server-a
kubectl logs deployment/server-b
```

## Om navn som går igjen og igjen og igjen
Hvis du leste [service.yaml](service.yaml) lurer du kanskje på hvorfor navnet _server-a_
går igjen over alt? Det er navn på ressursene, det brukes i label `app` og i navn til container.

Grunnen er at Kubernetes er designet for å være en generisk løsning, der byggeklossene skal
kunne dekke alle behov. For enkle tjenester blir navnet repetivt, som trigger trangen til å
lage ulike (lure) navn.

Hold tilbake trangen, for det er mye enklere å få oversikt dersom navnet er likt.
Hvilken `Deployment` er det som `Service` peker til? Lese spesifikasjonen og `labels`
eller lete etter noe med samme navn? Å bruke samme navn reduserer kompleksiteten.

Løsningen for å slippe det gjentagende er å bruke templating, som du kan se noe av i
[hindre nedetid](hindre-nedetid.md) og [ekstraoppgavene](ekstra.md).

## Kalle andre tjenester i clusteret
DNS-oppslag uten . vil prøve å finne en tjeneste i samme
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/).
I dette kurset har hver deltaker et eget namespace.

Tjenester i andre namespace kan nås via *service.namespace*, eksempelvis *server-a.elegant-denzil*.

Spør sidemannen om brukernavnet sitt og se om du når tjenestene dems:

```sh
curl localhost:8080/server-a.<brukernavn>
curl localhost:8080/server-b.<brukernavn>
```

Tips: Hvis sidemann ikke er ferdig med forrige oppgave, kan du prøve mot namespacet *elegant-denzil*.

[Neste oppgave lager et eksternt endepunkt for tjenstene.](ekstern-trafikk.md)