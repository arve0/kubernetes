# Kom i gang
Når du er ferdig med oppgavene på denne siden skal du kunne bruke
[`kubectl`](https://kubectl.docs.kubernetes.io) til å administrere
ressurser på kurs-clusteret.

0. Installer [kubectl](https://kubectl.docs.kubernetes.io/installation/kubectl/).
1. Klon dette repoet.
2. [Hent kubeconfig](https://kubeconfig.apps.workshop.arve.dev) med brukernavn fra epost.
3. Lagre kubeconfig til ~/.kube/config.
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

`kubectl explain` gir en forklarer ressurser:

```sh
kubectl explain pod
```

En kan også be om hjelp for et spesifikt felt:

```sh
kubectl explain pod.spec.containers
```

## Status til pod
`kubectl describe` gir en formatert variant av `yaml` eller `json` serialiseringen:

```sh
kubectl describe pod hei
```

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

En ønsker at `resources.request` under `spec.containers[]` til en `Pod` skal samsvare med hva den bruker.
Da klarer Kubernetes å fordele lasten utover nodene riktig.

Merk: `kubectl top node` viser ressursbruk på noder.

## Slett pod
`kubectl delete` kan brukes for å slette ressurser:

```sh
kubectl delete pod/hei pod/sleeping-beauty
```

Merk: Det kan ta litt tid før *sleeping-beauty* slettes. Les mer om terminering i guiden [terminating with grace](https://cloud.google.com/blog/products/containers-kubernetes/kubernetes-best-practices-terminating-with-grace).

## Opprette pod med yaml-manifest
Valigvis ønsker en å ta vare på kjørekonfigurasjonen. YAML gir en
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
- Logger den noe? Hint: bruk `--container` eller `-c`.

[Neste oppgave er Deployments.](deployment.md)
