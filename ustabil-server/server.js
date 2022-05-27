const http = require("http");

// For illustration purposes, do not die
// at the same time when running two pods.
// Use StatefulSet to guarantee that name
// are either -1 or -2.
const podName = process.env.POD_NAME || "";
const dieIn = podName === "ustabil-server-0"
  ? 60
  : 80;
const name = process.env.NAME || `${podName} en ustabil server som dør etter ${dieIn} sekunder`;
const port = process.env.PORT || "8080";
const start = Date.now();

let unstable = false;
let unstableCounter = 0;
const unstableCounterLimit = 4;

const server = http.createServer((request, response) => {
  const forwarded = request.headers["x-forwarded-for"]
    ? ` forwarded for: ${request.headers["x-forwarded-for"]}`
    : "";
  const url = new URL(request.url, `http://${request.headers.host}`);
  console.log(
    `${new Date()} ${name}: mottok request fra ${request.socket.remoteAddress}${forwarded} til ${url}`
  );

  if (failWhenAwakeAWhile()) {
    console.log("Død tjeneste, sender 500-svar");
    response.statusCode = 500;
    response.write(`jeg er ${name} Internal server error: Våken mer enn ${dieIn} sekunder, jeg trenger en omstart.\n`);
    response.end();
    return;
  }

  if (failFourTimesIfUnstable()) {
    console.log("Ustabil tjeneste, sender 500-svar");
    response.statusCode = 500;
    response.write(`jeg er ${name} Internal server error: Feil nr ${unstableCounter}/${unstableCounterLimit}.\n`);
    response.end();
    return;
  }

  response.write(`jeg er ${name}\n`);
  response.end();
});

function failFourTimesIfUnstable() {
  if (unstableCounter >= unstableCounterLimit) {
    unstable = false;
    unstableCounter = 0;
    return false;
  }

  if (unstable) {
    unstableCounter += 1;
    return true;
  }

  // one in every 20 request should enable "unstable"
  unstable = Math.random() < 0.05;
}

function failWhenAwakeAWhile() {
  return Date.now() - start > dieIn * 1000;
}

console.log(
  `starter ${name} på port ${port}`
);
server.listen(port);
