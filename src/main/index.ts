import { lambdaHandler } from './app'
import * as fromMocks from '@/domain/mocks'

const event = fromMocks.messageMock
const result = lambdaHandler(event)

if (result instanceof Promise) {
  result.then(console.log)
}
