# frozen_string_literal: true

require('json')

module StarkInfra
  module Error
    StarkInfraError = StarkCore::Error::StarkCoreError

    Error = StarkCore::Error::Error

    InputErrors = StarkCore::Error::InputErrors

    InternalServerError = StarkCore::Error::InternalServerError

    UnknownError = StarkCore::Error::UnknownError

    InvalidSignatureError = StarkCore::Error::InvalidSignatureError
  end
end
