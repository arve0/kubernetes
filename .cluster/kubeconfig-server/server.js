const fs = require("fs");
const child = require("child_process");
const http = require("http");
const util = require("util");

const exec = util.promisify(child.exec);

const port = process.env.PORT || "8080";
const index = fs.readFileSync("index.html", "utf-8");

const server = http.createServer(async (request, response) => {
  const forwarded = request.headers["x-forwarded-for"]
    ? ` forwarded for: ${request.headers["x-forwarded-for"]}`
    : "";
  const url = new URL(request.url, `http://${request.headers.host}`);
  console.log(
    `mottok request fra ${request.socket.remoteAddress}${forwarded} til ${url}`
  );

  if (url.pathname === "/") {
    response.write(index);
    response.end();
  } else {
    const username = url.pathname
      .slice(1)
      .toLowerCase()
      .replace(/[^a-z-]+/g, "");

    try {
      const result = await exec(`kubectl get secret kubeconfig -n ${username} -o json`)
      const kubeconfigSecret = JSON.parse(result.stdout);
      const kubeconfig = Buffer.from(kubeconfigSecret.data.kubeconfig, 'base64').toString('utf-8');

      response.write(kubeconfig);
      response.end();
    } catch (error) {
      console.error(error);
      response.statusCode = 500;
      response.write(error.message);
      response.end();
    }
  }
});

server.on("error", console.error.bind(console))

console.log(`starter server på port ${port}`);
server.listen(port);
