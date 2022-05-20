# Ekstra oppgaver

## Deploy en egen tjeneste
Lag et docker image som du publiserer på [Docker hub](https://hub.docker.com).
For et utgangspunkt, se [den enkle nodejs serveren](server) som brukes i oppgavene.

## Enkel manifest templating
Bruk [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)
for enkel templating:

```sh
name=hallo envsubst < deployment.yaml | kubectl apply -f -
```

med deployment.yaml:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $name
  labels:
    app: $name
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $name
  template:
    metadata:
      labels:
        app: $name
    spec:
      containers:
      - name: $name
        image: busybox
        resources: {}
        command: ["/bin/sh"]
        args: ["-c", "while true; do echo $name; sleep 10; done"]
```

Prøv å utvide til å være en typisk deployment med navn og image som input
og `Deployment`, `Service` og `Ingress` som output.

## Templating med helm
Samme som over, men bruk [helm](https://helm.sh/docs/chart_template_guide/getting_started/) til templatingen.

```sh
helm template . | kubectl apply -f -
```

## Administrasjon av cluster
Installer ditt eget cluster. Hvis du ønsker tilsvarende oppsett som workshoppen,
se oppsettet i [.cluster] og spesielt målene `cluster/install` og `all` i [Makefile](.cluster/Makefile).