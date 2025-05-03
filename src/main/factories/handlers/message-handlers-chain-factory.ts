import { MessageHandlerFactories } from '@/main/config/message-handling'
import type { AbstractHandler } from '@/presentation/handlers'

export class MessageHandlersChainFactory {
  private static instance: MessageHandlersChainFactory

  public static getInstance(): MessageHandlersChainFactory {
    if (!MessageHandlersChainFactory.instance) {
      MessageHandlersChainFactory.instance = new MessageHandlersChainFactory()
    }

    return MessageHandlersChainFactory.instance
  }

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  public make(): AbstractHandler<any> {
    // biome-ignore lint/suspicious/noExplicitAny: <explanation>
    const handlers: Array<AbstractHandler<any>> = MessageHandlerFactories.map(
      (factory: { make: () => any }) => factory.make()
    )
    const chainHead = handlers.shift()
    if (!chainHead) {
      throw new Error('There is no message handlers')
    }
    handlers.reduce((actualHandler, nextHandler) => {
      return actualHandler.setNextHandler(nextHandler)
    }, chainHead)

    return chainHead
  }
}
