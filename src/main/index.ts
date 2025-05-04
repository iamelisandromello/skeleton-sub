import { handler } from './app'
import * as fromMocks from '@/domain/mocks'

const event = fromMocks.messageMock
const result = handler(event)

if (result instanceof Promise) {
  result.then(console.log)
}
