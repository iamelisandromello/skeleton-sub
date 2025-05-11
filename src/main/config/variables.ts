import env from 'env-var'

export const variables = {
  corsOriginPermission: env.get('CORS_ORIGIN_PERMISSION').required().asString(),
  queue: {
    messageType: env.get('MESSAGE_TYPE_QUEUE').required().asString()
  }
}
