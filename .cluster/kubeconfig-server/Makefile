build: Dockerfile
	docker build --tag kubeconfig-server .

publish: build
	docker tag kubeconfig-server registry.apps.workshop.arve.dev/kubeconfig-server
	docker push registry.apps.workshop.arve.dev/kubeconfig-server

deploy: publish deployment.yaml
	kubectl apply -f deployment.yaml
	kubectl delete pods -l app=kubeconfig-server