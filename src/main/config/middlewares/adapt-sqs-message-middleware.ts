import type { MiddlewareInterface } from '@/main/config/middlewares'
import { MessageHandlersChainFactory } from '@/main/factories/handlers'
import type { QueueMessage } from '@/domain/value-objects'

import type { SQSEvent } from 'aws-lambda'

export class AdaptSqsMessageMiddleware
  implements MiddlewareInterface<SQSEvent, undefined>
{
  next!: MiddlewareInterface<SQSEvent, undefined>
  async handle(request: SQSEvent): Promise<undefined> {
    const messageBody = request.Records.shift()?.body
    if (!messageBody) {
      throw new Error('Missing SQS message body')
    }

    let parsedBody: QueueMessage<any>
    try {
      parsedBody = JSON.parse(messageBody)
    } catch (e: unknown) {
      throw new Error('SQS message body parsing error')
    }

    if (!('type' in parsedBody) || !('payload' in parsedBody)) {
      throw new Error(
        'SQS message body must have the attributes :type and :payload'
      )
    }

    const handlersChainHead = MessageHandlersChainFactory.getInstance().make()

    await handlersChainHead.handle(parsedBody)

    return undefined
  }
}
