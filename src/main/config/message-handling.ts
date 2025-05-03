import type { AbstractHandler } from '@/presentation/handlers'
import { ExampleHandlerFactory } from '@/main/factories/handlers'

// biome-ignore lint/suspicious/noExplicitAny: <explanation>
export const MessageHandlerFactories: Array<{
  make: () => AbstractHandler<any>
}> = [ExampleHandlerFactory.getInstance()]
