import type { UserAgreement } from '@/infra/database/transformers'
import type { ExampleFindUserRepository } from '@/application/contracts/database'

export class ExampleUserRepository implements ExampleFindUserRepository {
  constructor(private readonly userTransformer: UserAgreement) {}

  async find(
    filters?: ExampleFindUserRepository.Filters
  ): Promise<ExampleFindUserRepository.Result> {
    const result = [
      {
        email: 'johndoe@johndoe.com',
        name: 'John Doe',
        username: 'johndoe',
        social_media_username: '@johndoe'
      }
    ]

    if (result.length <= 0) return false

    return this.userTransformer.transform(result[0])
  }
}
