import { TreatmentErrorAdapterFactory } from '@/main/factories/adapters'
import {
  MiddlewareManager,
  type MiddlewareManagerInterface
} from '@/main/config/middlewares'
import { AdaptSqsMessageMiddleware } from '@/main/config/middlewares/'
import { SqsMiddlewareErrorHandler } from '@/main/config/middlewares/errors-handlers'

import type { SQSEvent } from 'aws-lambda'

export class SqsMiddlewareManagerFactory {
  private static instance: SqsMiddlewareManagerFactory

  public static getInstance(): SqsMiddlewareManagerFactory {
    if (!SqsMiddlewareManagerFactory.instance) {
      SqsMiddlewareManagerFactory.instance = new SqsMiddlewareManagerFactory()
    }

    return SqsMiddlewareManagerFactory.instance
  }

  public make(): MiddlewareManagerInterface<SQSEvent, undefined> {
    const middlewareManager = new MiddlewareManager<SQSEvent, undefined>(
      new SqsMiddlewareErrorHandler()
    )
    middlewareManager.use([new AdaptSqsMessageMiddleware()])

    return middlewareManager
  }
}
