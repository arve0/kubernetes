DOMAIN ?= workshop.arve.dev
NODE_COUNT = 1
EMAIL ?= arve+workshop@seljebu.no
USERNAME ?= arve
NUMBER_OF_USERS ?= 10
USERS := $(shell cat usernames 2>/dev/null | sed 's|^|users/|')

all: ingress cert-manager letsencrypt registry

cluster/region:
	doctl kubernetes options regions \
		| grep Amsterdam \
		| head -n 1 \
		| cut -f1 -d' ' \
		| tr -d '\n' \
		| tee cluster/region

cluster/size:
	doctl kubernetes options sizes \
		| grep 8gb \
		| head -n 1 \
		| cut -f1 -d' ' \
		| tr -d '\n' \
		| tee cluster/size

cluster/version:
	doctl kubernetes options versions \
		| grep 1.22 \
		| head -n 1 \
		| cut -f1 -d' ' \
		| tr -d '\n' \
		| tee cluster/version

cluster/install: cluster/region cluster/size cluster/version
	doctl kubernetes cluster create $(subst .,-,${DOMAIN}) \
		--wait \
		--region $$(cat cluster/region) \
		--version $$(cat cluster/version) \
		--node-pool "name=nodes;size=$$(cat cluster/size);auto-scale=true;min-nodes=1;max-nodes=5" \
		--output json \
		| tee cluster/install

cluster/kubeconfig: cluster/install
	doctl kubernetes cluster kubeconfig show $(subst .,-,${DOMAIN}) \
		| tee cluster/kubeconfig
	chmod go-rwx cluster/kubeconfig

home-kubeconfig: cluster/kubeconfig
	if [[ $$(sha1sum cluster/kubeconfig) != "$$(sha1sum $$HOME/.kube/config)" ]]; then \
		mv $$HOME/.kube/config $$HOME/.kube/config.backup; \
		cp cluster/kubeconfig $$HOME/.kube/config; \
		chmod go-rwx $$HOME/.kube/config; \
	fi

ingress/ingress.yaml:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm template ingress-nginx ingress-nginx/ingress-nginx \
		--namespace ingress-nginx \
		> ingress/ingress.yaml

ingress: ingress/ingress.yaml FORCE
	kubectl kustomize ingress \
		| DOMAIN=${DOMAIN} envsubst \
		| kubectl apply -f -

cert-manager/cert-manager.yaml:
	helm repo add jetstack https://charts.jetstack.io
	helm template cert-manager jetstack/cert-manager \
		--namespace cert-manager \
		--set installCRDs=true \
		> cert-manager/cert-manager.yaml

cert-manager: cert-manager/cert-manager.yaml FORCE
	kubectl kustomize cert-manager \
		| kubectl apply -f -

letsencrypt: FORCE
	kubectl wait pod --for=condition=Ready -l app=webhook -n cert-manager --timeout=120s
	EMAIL=${EMAIL} envsubst < cert-manager/letsencrypt.yaml \
		| kubectl apply -f -

uninstall-cert-manager:
	kubectl kustomize cert-manager \
		| kubectl delete -f -
	kubectl delete -n kube-system configmap cert-manager-cainjector-leader-election
	kubectl delete -n kube-system configmap cert-manager-controller
	kubectl delete -A service -l acme.cert-manager.io/http01-solver=true
	kubectl delete -A ingress -l acme.cert-manager.io/http01-solver=true

registry/password:
	if kubectl get secret registry-auth -n internal &>/dev/null; then \
		kubectl get secret registry-auth -n internal -o json \
			| jq --raw-output .data.password \
			| base64 -d > registry/password ; \
	else \
		dd if=/dev/urandom bs=30 count=1 2>/dev/null | base64 > registry/password; \
	fi

registry: registry/password FORCE
	kubectl kustomize registry \
		| DOMAIN=${DOMAIN} envsubst \
		| kubectl apply -f -

	htpasswd -ic auth ${USERNAME} < registry/password

	if ! kubectl get secret registry-auth -n internal &>/dev/null; then \
		kubectl create secret generic registry-auth -n internal --from-file=auth --from-file=registry/password; \
	fi
	rm auth

registry-login: registry/password
	docker login registry.apps.${DOMAIN} --username ${USERNAME} --password-stdin < registry/password

list-repos: registry/password
	curl -u arve:$$(cat registry/password) https://registry.apps.arve.dev/v2/_catalog

docker-pull-secret: registry/password
	kubectl delete secret registry-credentials -n default || true
	kubectl create secret docker-registry registry-credentials \
		--namespace=default \
		--docker-server=registry.apps.${DOMAIN} \
		--docker-username=${USERNAME} \
		--docker-password=$$(cat registry/password)
	kubectl patch serviceaccount default -n default -p '{"imagePullSecrets": [{"name": "registry-credentials"}]}'

adjectives.txt:
	curl -L https://gist.githubusercontent.com/hugsy/8910dc78d208e40de42deb29e62df913/raw/eec99c5597a73f6a9240cab26965a8609fa0f6ea/english-adjectives.txt \
		> adjectives.txt

names.txt:
	curl -L https://github.com/hadley/data-baby-names/raw/master/baby-names.csv \
		| grep 20 \
		> baby-names.csv
	grep boy baby-names.csv > boys.txt
	grep girl baby-names.csv > girls.txt
	paste -d '\n' boys.txt girls.txt \
		| cut -f2 -d, \
		| tr -d '"' \
		| tr '[:upper:]' '[:lower:]' \
		| sort | uniq \
		> names.txt
	rm boys.txt girls.txt baby-names.csv

usernames: adjectives.txt names.txt random-usernames.sh
	./random-usernames.sh ${NUMBER_OF_USERS} > usernames

cluster/ca: cluster/kubeconfig
	yq .clusters[0].cluster.certificate-authority-data cluster/kubeconfig > cluster/ca

cluster/server: cluster/kubeconfig
	yq .clusters[0].cluster.server cluster/kubeconfig > cluster/server

cluster/workshop-role:
	kubectl create clusterrole workshop --verb="*" --resource=pods
	touch cluster/workshop-role

users: ${USERS}
${USERS}: home-kubeconfig rbac cluster/ca cluster/server cluster/workshop-role
	mkdir -p $@
	# create private key

	openssl genrsa -out $@/key 2048
	# create CertificateSigningRequest
	user=$(subst users/,,$@) envsubst < user.csr.cnf > $@/csr.cnf
	openssl req -new -config $@/csr.cnf -key $@/key -out $@/csr
	# create CertificateSigningRequest in cluster
	kubectl delete csr $(subst users/,,$@)-authentication || true
	user=$(subst users/,,$@) \
		csr=$$(cat $@/csr | base64 | tr -d '\n') \
		envsubst < user-authentication.yaml \
		| kubectl apply -f-
	# approve CertificateSigningRequest in cluster
	kubectl certificate approve $(subst users/,,$@)-authentication
	# copy certificate to user folder
	kubectl get csr $(subst users/,,$@)-authentication -o jsonpath='{.status.certificate}' | base64 --decode > $@/crt
	# create kubeconfig
	user=$(subst users/,,$@) \
		ca=$$(cat cluster/ca) \
		server=$$(cat cluster/server) \
		crt=$$(cat $@/crt | base64 | tr -d '\n') \
		key=$$(cat $@/key | base64 | tr -d '\n') \
		envsubst < user.kubeconfig > $@/kubeconfig
	kubectl create namespace $(subst users/,,$@) || true
	user=$(subst users/,,$@) \
		envsubst < rbac-user.yaml \
		| kubectl apply -f-
	KUBECONFIG=$@/kubeconfig kubectl get pods

rbac:
	kubectl apply -f rbac-common.yaml

FORCE: