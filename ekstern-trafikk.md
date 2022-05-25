# Ekstern trafikk
Når du er ferdig med oppgavene på denne siden skal du kunne bruke
[`Ingress`](https://kubernetes.io/docs/concepts/services-networking/ingress/)
til å rute HTTP-trafikk fra internett til tjenesten i clusteret. Du skal
kunne sette eget hostname og rute ulike paths til ulike tjenester.

## Om Ingress
Ressursen `Ingress` er en ressurs for å rute HTTP-trafikk. Spesifikasjonen
har en rekke regler, som hver har `host`, `path` og en tilhørende `service`.

- `host` er hostname, altså DNS-navnet til tjenesten.
- `path` er path til HTTP-forespørsel.
- `service` er en Kubernetes service, slik som ble opprettet i [intern trafikk](intern-trafikk.md).

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: server-a
spec:
  rules:
  - host: server-a-elegant-denzil.apps.workshop.arve.dev
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: server-a
            port:
              number: 80
```

En enklere måte å definere det samme på er med `kubectl create ingress`:

```sh
kubectl create ingress server-a --rule="a-elegant-denzil.apps.workshop.arve.dev/*=server-a:80"
```

Her er `server-a-elegant-denzil.apps.workshop.arve.dev/*` både `host`, `path` og `pathType`, hvor
`*` indikerer `pathType=Prefix`. Bak `=` er service som skal motta trafikken. `:80` er porten som
service lytter på.

## Send trafikk direkte til service
Lag en `Ingress` som:

- Ruter trafikk til `a-<brukernavn>.apps.workshop.arve.dev/*` mot service `server-a`
  fra [oppgavene om intern trafikk](intern-trafikk.md), der du bytter ut `<brukernavn>`
  med ditt brukernavn.
- Ruter trafikk til `b-<brukernavn>.apps.workshop.arve.dev/*` mot service `server-b`.

**Merk:** `host` må være `<navn>.apps.workshop.arve.dev` der `<navn>` ikke inneholder punktum,
ettersom DNS for *.apps.workshop.arve.dev peker til clusteret. Dersom du velger et `<navn>`
som allerede er i bruk, vil du få en feilmelding tilsvarende denne:

> error: failed to create ingress: admission webhook "validate.nginx.ingress.kubernetes.io" denied the request

Sjekk at `Ingress` fungerer:

```sh
❯ curl a-<brukernavn>.apps.workshop.arve.dev/
jeg er server-a

❯ curl b-<brukernavn>.apps.workshop.arve.dev/
jeg er server-b

❯ curl a-<brukernavn>.apps.workshop.arve.dev/server-b
jeg er server-b

❯ curl b-<brukernavn>.apps.workshop.arve.dev/server-a
jeg er server-a
```

## Send trafikk fra en host til ulike services
Vi ønsker at trafikk til `<brukernavn>.apps.workshop.arve.dev/a/*` skal gå til *server-a*,
og `<brukernavn>.apps.workshop.arve.dev/b/*` til *server-b*.

En slik kombinasjon av ulike tjenester under samme hostname er nyttig for versjonering av API,
der du kan la gammel tjeneste kjøre upåvirket av at `/v2/` er under utvikling.

Ruting på path er også nyttig når en monolitt brytes opp i mindre deler, eksempelvis dersom du
har behov for å optimalisere eller skalere en bestemt del av API-et.

Naivt kan en prøve å opprette ingress:

```sh
kubectl create ingress kombinert \
  --rule='elegant-denzil.apps.workshop.arve.dev/a/*=server-a:80' \
  --rule='elegant-denzil.apps.workshop.arve.dev/b/*=server-b:80'
```

Men forespørsler til tjenesten feiler:

```sh
❯ curl elegant-denzil.apps.workshop.arve.dev/a/
Error.
```

I loggen til poden ser vi hvorfor:

```sh
❯ kubectl logs server-a-c944bbd4b-r49gm | tail -n 3
server-a: mottok request fra ::ffff:10.244.0.29 forwarded for: 212.251.175.15 til http://elegant-denzil.apps.workshop.arve.dev/a/
Error: getaddrinfo ENOTFOUND a
    at GetAddrInfoReqWrap.onlookup [as oncomplete] (node:dns:83:26)
```

Path er ikke omskrevet fra `/a` på utsiden til `/` som tjenesten forventer.
Istedenfor å "fikse" tjenesten, kan vi lage en
[omskrivning av path i `Ingress`](https://kubernetes.github.io/ingress-nginx/examples/rewrite/).

```sh
kubectl delete ingress kombinert
kubectl create ingress kombinert \
  --rule='elegant-denzil.apps.workshop.arve.dev/a(/|$)(.*)=server-a:80' \
  --rule='elegant-denzil.apps.workshop.arve.dev/b(/|$)(.*)=server-b:80'
kubectl annotate ingress kombinert nginx.ingress.kubernetes.io/rewrite-target='/$2'
```

Over lager vi en [regex med to grupper, `(/|$)` og `(.*)`](https://regex101.com/r/RMmBjH/1):

- `(/|$)`: enden / eller slutt på path.
- `(.*)`: hva som helst.

I annotasjonen `nginx.ingress.kubernetes.io/rewrite-target` skrives path om til `/$2`, der
`$2` er andre gruppe `(.*)`.

Merk: Her må en bruke enkel tekstfnutt `'/$2'` for å unnga at `$` ekspanderer i shellet,
vs `"/$2"` som ikke vil fungere.

Oppgave: Lag en `Ingress` med navn *kombinert* som sender alt under `/a` til *server-a*
og alt under `/b` til *server-b*.

Sjekk at den fungerer:

```sh
❯ curl <brukernavn>.apps.workshop.arve.dev/a
jeg er server-a

❯ curl <brukernavn>.apps.workshop.arve.dev/a/server-b
jeg er server-b

❯ curl <brukernavn>.apps.workshop.arve.dev/b
jeg er server-b

❯ curl <brukernavn>.apps.workshop.arve.dev/b/server-a
jeg er server-a
```

## TLS
[cert-manager](https://cert-manager.io) er installert og satt opp med
[lets-encrypt](https://letsencrypt.org) på clusteret.

For å kryptere et endepunkt, trenger en å spesifisere hvilken *Issuer*
som skal gi oss sertifikatene:

```sh
kubectl delete ingress server-a
kubectl create ingress server-a --rule="a-elegant-denzil.apps.workshop.arve.dev/*=server-a:80,tls=server-a-cert"
kubectl annotate ingress server-a cert-manager.io/cluster-issuer=letsencrypt
```

Når `Ingress` har annotasjonen, vil cert-manager opprette `Secret` med navn `server-a-cert`.
Nginx ingress-controlleren finner så `Secret` og bruker sertifikatet der til å kryptere forbindelsen.

[Neste oppgave er å endre tjenesten mens den er live.](rullerende-deployment.md)