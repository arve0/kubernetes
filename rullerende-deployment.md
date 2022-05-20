# Rullerende deployment
Når du er ferdig med oppgavene på denne siden skal kjenne til
[`Deployment.spec.strategy`](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy).

## Gjør en rullende oppdatering
Nå som du har oppe et HTTP-endepunkt som er lett å kalle,
kan vi gjøre en endring i tjenesten og observere hva som skjer.

- Start en overvåkning:

  ```sh
  while true; do
    date | tr '\n' ' '
    curl <brukernavn>.apps.workshop.arve.dev/a
    sleep 1
  done
  ```

- Endre navn på den ene deploymenten i [service.yaml](service.yaml) ved å sette environment-variabelen `NAME` til noe annet enn `server-a`.

- Deploy endringen:

  ```sh
  kubectl apply -f service.yaml
  ```

I overvåkningen skal du nå se at nytt navn kommer opp, og at gammelt navn forsvinner:

```
Fri May 20 23:08:05 CEST 2022 jeg er server-a
Fri May 20 23:08:06 CEST 2022 jeg er server-a
Fri May 20 23:08:07 CEST 2022 jeg er server-a
Fri May 20 23:08:08 CEST 2022 jeg er HAHA
Fri May 20 23:08:09 CEST 2022 jeg er server-a
Fri May 20 23:08:11 CEST 2022 jeg er server-a
Fri May 20 23:08:12 CEST 2022 jeg er HAHA
Fri May 20 23:08:13 CEST 2022 jeg er HAHA
Fri May 20 23:08:14 CEST 2022 jeg er HAHA
```

På ett tidspunkt er begge tjenestene oppe, som kalles *RollingUpdate* som er standardinnstillingen:

```sh
❯ kubectl get deployment server-a -o yaml | yq .spec.strategy
rollingUpdate:
  maxSurge: 25%
  maxUnavailable: 25%
type: RollingUpdate
```

I tillegg har den innstilling for hvor mange pods den kan ha ekstra, `maxSurge`.
Og hvor mange pods som kan slettes uten å forrige tjenesten, `maxUnavailable`.

Alternativet til *RollingUpdate* er *Recreate* som vil slette alle pods, før den
oppretter nye.
