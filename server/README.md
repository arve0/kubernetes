# server
En enkel server som videresender request til andre servere.

Eksempelvis:
```sh
$ node server.js &
starter server-a på port 8080
$ curl localhost:8080
server-a: mottok request fra ::ffff:127.0.0.1 til http://localhost:8080/
jeg er server-a
$ curl localhost:8080/arve.dev
server-a: mottok request fra ::ffff:127.0.0.1 til http://localhost:8080/arve.dev
<html>
<head><title>301 Moved Permanently</title></head>
<body bgcolor="white">
<center><h1>301 Moved Permanently</h1></center>
<hr><center>nginx</center>
</body>
</html>
$ pkill -f "node server.js"
fish: Job 1, 'node server.js &' terminated by signal SIGTERM (Polite quit request)
```

Mest sannsynlig ønsker en å kjøre flere varianter av samme server
med ulikt navn og kalle hverandre. Her på localhost:

```sh
$ node server.js &
starter server-a på port 8080
$ PORT=80 NAME=server-b node server.js &
starter server-b på port 80
$ curl localhost:8080
server-a: mottok request fra ::ffff:127.0.0.1 til http://localhost:8080/
jeg er server-a
$ curl localhost:8080/localhost
server-a: mottok request fra ::ffff:127.0.0.1 til http://localhost:8080/localhost
server-b: mottok request fra ::ffff:127.0.0.1 til http://localhost/
jeg er server-b
$ pkill -f "node server.js"
fish: Job 1, 'node server.js &' terminated by signal SIGTERM (Polite quit request)
fish: Job 2, 'PORT=80 NAME=server-b node serv…' terminated by signal SIGTERM (Polite quit request)
```