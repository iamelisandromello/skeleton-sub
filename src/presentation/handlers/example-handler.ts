import { AbstractHandler } from './abstract-handler'
import type { Validation } from '@/presentation/interfaces'
import type { QueueMessage } from '@/domain/value-objects'
import type { ExampleUsecase } from '@/domain/usecases/'

type Payload = { email: string; name: string; username: string }

export class ExampleHandler extends AbstractHandler<Payload> {
  constructor(
    private readonly validation: Validation<Payload>,
    private readonly exampleService: ExampleUsecase,
    private readonly messageType: string
  ) {
    super()
  }

  protected override canHandle(message: QueueMessage<Payload>): boolean {
    console.log('canHandle', message.type)
    return message.type === this.messageType
  }

  protected override async process({
    payload
  }: QueueMessage<Payload>): Promise<void> {
    console.log('Entrou no Handler')
    const error = await this.validation.validate(payload)
    console.log('error HANDLER:: ', error)
    if (error) throw error

    const { email, name, username } = payload
    const isResult = await this.exampleService.perform({
      email,
      name,
      username
    })

    if (!isResult) throw isResult
    console.log('[PROCESS PAYMENT CREATOR RESULT:]', isResult)
  }
}
