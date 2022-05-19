const http = require("http");

const name = process.env.NAME || "server-a";
const port = process.env.PORT || "8080";

const server = http.createServer((request, response) => {
  const forwarded = request.headers["x-forwarded-for"]
    ? ` forwarded for: ${request.headers["x-forwarded-for"]}`
    : "";
  const url = new URL(request.url, `http://${request.headers.host}`);
  console.log(
    `${name}: mottok request fra ${request.socket.remoteAddress}${forwarded} til ${url}`
  );

  if (url.pathname !== "/") {
    const host = url.pathname
      .slice(1)
      .toLowerCase()
      .replace(/[^a-z\.-]+/g, "");

    http
      .request({ host, path: "/" }, handleGet(response))
      .on("error", handleError(response))
      .end();
  } else {
    response.write(`jeg er service ${name}\n`);
    response.end();
  }
});

function handleGet(response) {
  return function (requestResponse) {
    response.statusCode = requestResponse.statusCode;

    for (var header in requestResponse.headers) {
      if (
        header === "access-control-allow-origin" ||
        !requestResponse.headers.hasOwnProperty(header)
      ) {
        continue;
      }
      response.setHeader(header, requestResponse.headers[header]);
    }

    requestResponse.on("data", response.write.bind(response));
    requestResponse.on("end", response.end.bind(response));
  };
}

function handleError(response) {
  return function (requestError) {
    console.error(requestError.stack);
    // send error
    response.statusCode = 500;
    response.write("Error.");
    response.end();
  };
}

console.log(`starter ${name} på port ${port}`);
server.listen(port);
