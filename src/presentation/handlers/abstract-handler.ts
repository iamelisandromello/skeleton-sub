import type { QueueMessage } from '@/domain/value-objects'

export abstract class AbstractHandler<T> {
  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  private nextHandler?: AbstractHandler<any>

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  setNextHandler (handler: AbstractHandler<any>): AbstractHandler<any> {
    this.nextHandler = handler
    return this.nextHandler
  }

  async handle (message: QueueMessage<T>): Promise<void> {
    if (this.canHandle(message)) {
      await this.process(message)
    } else if (this.nextHandler) {
      await this.nextHandler.handle(message)
    } else {
      throw new Error(`No handler found for message type: ${message.type}`)
    }
  }

  protected abstract canHandle (message: QueueMessage<T>): boolean

  protected abstract process (message: QueueMessage<T>): Promise<void>
}
