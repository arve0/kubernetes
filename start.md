# Kom i gang
Når du er ferdig med oppgavene på denne siden skal du kunne bruke
[`kubectl`](https://kubectl.docs.kubernetes.io) til å administrere
ressurser på kurs-clusteret.

0. Les [seksjonen Nødvendig programvare i README](README.md).
1. Klon dette repoet.

    ```sh
    git clone https://github.com/arve0/kubernetes
    cd kubernetes
    ```

2. [Hent](https://kubeconfig.apps.workshop.arve.dev) og lagre kubeconfig:

    ```sh
    curl https://kubeconfig.apps.workshop.arve.dev/<brukernavn-fra-epost> > kubeconfig
    ```

    Ikke fått brukernavn på epost? Ta kontakt med en av kursholderne.

    Feilet med "SSL certificate problem: certificate has expired" på Windows WSL / Debian 9? Les [løsning på Server Fault](https://serverfault.com/a/1079226/317247).

3. Aktiver kubeconfig.

    Hvis du har en *~/.kube/config* som du allerede bruker, ta backup av den:

    ```sh
    if [[ -f ~/.kube/config ]]; then cp ~/.kube/config ~/.kube/config.backup; fi
    ```

    Aktiver kubeconfig ved å flytte den til standardlokasjon:

    ```sh
    mkdir -p ~/.kube
    cp kubeconfig ~/.kube/config
    ```

    Alternativt er det mulig å bruke environment-variabelen
    [`KUBECONFIG`](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/):

    ```sh
    export KUBECONFIG=$(pwd)/kubeconfig
    ```

4. Hent pods med `kubectl`:

    ```sh
    kubectl get pods
    ```

    Du skal se en pod med navn *sleeping-beauty*.

## Se spesifikasjon til pod
Du kan hente spesifikasjonen til pod med `--output yaml`:

```sh
kubectl get pod sleeping-beauty -o yaml
```

Tips: Med [yq](https://github.com/mikefarah/yq) kan du velge hvilken del av
spesifikasjonen du vil se på. Eksempelvis `kubectl get pod sleeping-beauty -o yaml | yq .spec.containers`.
JSON er også mulig med `-o json` og [jq](https://github.com/stedolan/jq).

## Hjelp
Alle kommandoer har `--help`:

```sh
kubectl get --help
```

`kubectl explain` forklarer ressurser:

```sh
kubectl explain pod
```

En kan også be om hjelp for et spesifikt felt:

```sh
kubectl explain pod.spec.containers
```

## Status til pod
`kubectl describe` gir en tekst-formatert variant av ressursen, med samme informasjon som i `yaml`-serialiseringen:

```sh
kubectl describe pod sleeping-beauty
```

`describe` gir også *Events*, som er nyttig dersom noe har feilet. For eksempel om den ikke
klarte laste ned image, eller om en container er restartet pga minnebruk (OutOfMemory).
Merk at standard levetid (retention) for Events er en time. Normalt sendes Events til
et eksternt loggsystem for å ta vare på de.

## Starte egen pod
`kubectl run` lar deg enkelt starte en pod. Det er nyttig for rask debugging.

Start en pod som skriver ut *hei verden*:

```sh
kubectl run hei --image=busybox --restart=Never --command -- echo hei verden
```

## Se logg til pod
`kubectl logs` viser deg logg til en pod:

```sh
kubectl logs hei
```

## Se ressursbruk til pod
`kubectl top` viser deg forbruk av CPU og minne til pod:

```sh
kubectl top pods
```

En ønsker at faktisk ressursbruk og forespurte ressurser er lik,
slik at Kubernetes klarerå fordele lasten utover nodene riktig.
Mer om ressursbruk i [Deployment](deployment.md).

Ressursbruk til noder vises med:

```sh
kubectl top nodes
```


## Slett pod
`kubectl delete` kan brukes for å slette ressurser:

```sh
kubectl delete pod/hei pod/sleeping-beauty
```

Merk: Det kan ta litt tid før *sleeping-beauty* slettes. Les mer om terminering i guiden [terminating with grace](https://cloud.google.com/blog/products/containers-kubernetes/kubernetes-best-practices-terminating-with-grace).

## Opprette pod med yaml-manifest
Vanligvis ønsker en å ta vare på kjørekonfigurasjonen. YAML gir en
lesbar serialisering av ressursene i clusteret som en kan versjonskontrollere
med git.

Opprett en pod fra pod.yaml:

```sh
kubectl create -f pod.yaml
```

Merk: Fikk du feilmeldingen *AlreadyExists*? Da må du slette poden først. [Neste steg](deployment.md) bruker `Deployment` som er mulig å endre.

- Hva ble navn på pod?
- Hva er status til pod?
- Hvor mange containere kjører den?
- Hva deler containerne? Hint: Les [pod.yaml](pod.yaml).
- Logger den noe? Hint: Bruk `--container` eller `-c` i `kubectl logs` for å velge container.

[Neste oppgave er Deployments.](deployment.md)
