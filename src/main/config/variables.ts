import env from 'env-var'

export const variables = {
  corsOriginPermission: env.get('CORS_ORIGIN_PERMISSION').required().asString(),
  timezone: env.get('TZ').required().asString(),
  queue: {
    url: env.get('EXAMPLE_QUEUE_URL').required().asString(),
    messageType: env.get('MESSAGE_TYPE_QUEUE').required().asString()
  }
}
