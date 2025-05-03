import { variables } from '@/main/config/variables'
import { ExampleServiceFactory } from '@/main/factories/services'
import { ExampleValidationFactory } from '@/main/factories/validations'
import { type AbstractHandler, ExampleHandler } from '@/presentation/handlers'

export class ExampleHandlerFactory {
  private static instance: ExampleHandlerFactory

  public static getInstance(): ExampleHandlerFactory {
    if (!ExampleHandlerFactory.instance) {
      ExampleHandlerFactory.instance = new ExampleHandlerFactory()
    }

    return ExampleHandlerFactory.instance
  }

  // biome-ignore lint/suspicious/noExplicitAny: <explanation>
  public make(): AbstractHandler<any> {
    return new ExampleHandler(
      ExampleValidationFactory.getInstance().make(),
      ExampleServiceFactory.getInstance().make(),
      variables.queue.messageType
    )
  }
}
