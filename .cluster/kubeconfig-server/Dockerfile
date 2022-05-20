FROM bitnami/kubectl
USER root
RUN apt update && apt install -y nodejs && apt clean
USER 1001
COPY index.html server.js .
ENTRYPOINT ["/usr/bin/node"]
CMD ["server.js"]