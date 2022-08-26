const child = require("child_process");
const fs = require("fs");
const util = require("util");
const { play } = require('sound-play');
const http = require("http");

const exec = util.promisify(child.exec);

main()

let players = [];

async function main() {
  const namespaces = await getNamespaces();
  players = namespaces.map((ns) => ({ name: ns, level: 0 }));

  function levelup(player, msg) {
    console.log(player.name, msg);
    player.level += 1;
    play("levelup.wav")
  }

  // game loop
  while (true) {
    for (const player of players) {
      const pods = await getPods(player.name);
      if (player.level === 0 && hasCreatedPodHeiWithCli(pods)) {
        levelup(player, "hei done")
      }
      if (player.level < 2 && hasDeletedPods(pods)) {
        if (player.level === 0) {
          levelup(player, "hei done")
        }
        levelup(player, "deleted done")
        continue;
      }
      if (player.level === 2 && hasCreatedPodHeiWithYaml(pods)) {
        levelup(player, "created pod from yaml")
        continue;
      }

      const deployments = await getDeployments(player.name);
      if (player.level === 3 && hasCreatedDeployment(deployments)) {
        levelup(player, "created deployment")
        continue;
      }
      if (player.level === 4 && hasChangedDeployment(deployments)) {
        levelup(player, "changed deployment")
        continue;
      }
      if (player.level === 5 && hasCreatedInternalService(deployments)) {
        levelup(player, "created internal service")
        continue;
      }
      if (player.level === 6 && await hasMadeRequestToInternalService(player.name)) {
        levelup(player, "made request internal service")
        continue;
      }
      const ingress = await getIngresses(player.name);
      if (player.level === 6 && ingress) {
        levelup(player, "made ingress")
        continue;
      }
    }
    players.sort((a, b) => b.level - a.level)
  }
}

async function getNamespaces() {
  const result = await exec(`kubectl get secret -A -o json`);
  return JSON.parse(result.stdout)
    .items.filter((s) => s.metadata.name === "kubeconfig")
    .map((s) => s.metadata.namespace);
}

async function getPods(namespace) {
  const result = await exec(`kubectl get pods -n ${namespace} -o json`);
  return JSON.parse(result.stdout).items;
}

async function getDeployments(namespace) {
  const result = await exec(`kubectl get deployments -n ${namespace} -o json`);
  return JSON.parse(result.stdout).items;
}

function hasCreatedPodHeiWithCli(pods) {
  return pods.some(p => p.metadata.name === "hei" && p.spec.containers.length === 1);
}

function hasDeletedPods(pods) {
  return pods.every(p => p.metadata.name !== "sleeping-beauty");
}

function hasCreatedPodHeiWithYaml(pods) {
  return pods.some(p => p.metadata.name === "hei" && p.spec.containers.length === 2);
}

function hasCreatedDeployment(deployments) {
  return deployments.some(d => d.metadata.name === "hei");
}

function hasChangedDeployment(deployments) {
  return deployments.some(d => d.metadata.name === "hei" && !d.spec.template.spec.containers[0].args[1].includes("echo hei"));
}

function hasCreatedInternalService(deployments) {
  return deployments.some(d => d.metadata.name === "server-a");
}

async function hasMadeRequestToInternalService(namespace) {
  const logs = await exec(`kubectl logs deployment/server-a -n ${namespace}`);
  return logs.stdout.includes("til http://localhost:8080/");
}

async function getIngresses(namespace) {
  try {
    const ingress = await exec(`kubectl get ingress -n ${namespace} -o json`);
    const items = JSON.parse(ingress.stdout).items;
    if (items.length === 0) {
      return false
    }
    return items
  } catch (error) {
    return false;
  }
}

const port = process.env.PORT || "8080";
const index = fs.readFileSync("index.html", "utf-8");

const server = http.createServer(async (request, response) => {
  const url = new URL(request.url, `http://${request.headers.host}`);

  if (url.pathname === "/") {
    response.write(index);
    response.end();
  } else {
    response.write(JSON.stringify(players.filter(p => p.level !== 0)));
    response.end();
  }
});

server.on("error", (error) => console.error(error))

console.log(`starter server på port ${port}`);
server.listen(port);
