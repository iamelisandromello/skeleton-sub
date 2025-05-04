import './config/module-alias'
import { SqsMiddlewareManagerFactory } from '@/main/factories/middleware-managers'

import type { SQSEvent } from 'aws-lambda'

import type { APIGatewayProxyResult } from 'aws-lambda/trigger/api-gateway-proxy'

export const handler = async (
  event: SQSEvent
): Promise<APIGatewayProxyResult | undefined> => {
  console.log('EVENTO: ', event)
  if ('Records' in event) {
    const middlewareManager = SqsMiddlewareManagerFactory.getInstance().make()
    return await middlewareManager.execute(event)
  }
}
