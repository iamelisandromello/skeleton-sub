import type { SQSEvent } from 'aws-lambda'

const SQSEventMock: SQSEvent = {
  Records: [
    {
      messageId: 'ab153eef-59a2-4346-9861-dab6d136cea5',
      receiptHandle:
        'AQEB8OU9PJJa8DkqUTbbzKIMC5p/Gl3ORW/l37QDebOMoBGEe0bHqeAsUyn9DI1iT+TF21bVFdRoywMBgtFaVGadBC4m+7rLJOdCQp5br4BfFPl72Sq+5SUFLGW3mumGPrBmZ+Q9wBvcjga6K3bIHZdqTcZC6ZKBc4VuSCJRaZHonr/bxslfy8qSH05xAxSQPmmeVZr81kGJ0MB/FJlgtXlSEKzLEsRqbSpOMCIf4hhDTgM6LSp7p2RdQePBVS7kU4g/1Yq44Vn7GkwyZmkgVcZ1xMdNaeV6FD2pZao7KaEucuJHxBglNHDqnAp3nnsCWGEszfyTRff18GsXxwbhsGaI7iB74QMMIPizAXDQ6lAcqxcAEpEheCzhM8jSQWd3iShiXoNf9ZIicd+XhJGddr+oiQ==',
      body: JSON.stringify({
        type: 'process-publi-message',
        payload: {
          email: 'johndoe@breathing.com',
          username: 'johndoe',
          name: 'John Doe'
        }
      }),
      attributes: {
        ApproximateReceiveCount: '1',
        SentTimestamp: '1683907943259',
        SenderId: 'AIDAQN4K2DWC7CQO6FI6I',
        ApproximateFirstReceiveTimestamp: '1683907943264'
      },
      messageAttributes: {},
      md5OfBody: 'd968a43b8fedc62a10e4a04841df26af',
      eventSource: 'aws:sqs',
      eventSourceARN: 'arn:aws:sqs:us-east-2:029819018629:sqs-default',
      awsRegion: 'us-east-2'
    }
  ]
}

export const messageMock = SQSEventMock
