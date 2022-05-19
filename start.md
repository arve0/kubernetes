# kom i gang
Når du er ferdig med oppgavene denne siden skal du kunne bruke
[`kubectl`](https://kubectl.docs.kubernetes.io) til å administrere
ressurser på kurs-clusteret.

0. Klon dette repoet.
1. Send en melding på slack til Arve og be om kubeconfig.
2. Lagre output fra Arve til ~/.kube/config.
3. Hent pods med `kubectl`:

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

## Status til pod
`kubectl describe` gir en formatert variant av `yaml` eller `json` serialiseringen:

```sh
kubectl describe pod hei
```

## Starte egen pod
`kubectl run` lar deg enkelt starte en pod. Det er nyttig for rask debugging.

Start en pod skriver ut *hei verden*:

```sh
kubectl run hei --image=busybox --restart=Never --command -- echo hei verden
```

## Se logg til pod
`kubectl logs` viser deg logg til en pod:

```sh
kubectl logs hei
```

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

Merk: Fikk du feilmeldingen *AlreadyExists*? Da må du slette pod først. Neste steg bruker `Deployment` som er mulig å endre.

- Hva ble navn på pod?
- Hva er status til pod?
- Hvor mange containere kjører den?
- Hva deler containerne? Hint: Les [pod.yaml](pod.yaml).
- Logger den noe? Hint: bruk `--container` eller `-c`.
