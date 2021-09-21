const AWS = require('aws-sdk')
const ecs = new AWS.ECS()
function log(message, context) {
  console.log(JSON.stringify({ message, ...context }))
}
// up handler
exports.handler = async () => {
  // get env vars
  const cluster = process.env.CLUSTER
  const service = process.env.SERVICE
  // stop
  await ecs.updateService({ cluster, service, desiredCount: 0 }).promise()
  log("stopping", { cluster, service })
  // wait until inactive
  await ecs.waitFor("servicesInactive", { cluster, services: [service] }).promise()
  log("service inactive", { cluster, service })
  // respond
  return { message: "stopped", bucket }
}
