# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # PixUser object
  #
  # Pix Users are used to get fraud statistics of a user.
  #
  # ## Parameters (required):
  # - id [string]: user tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  #
  # ## Attributes (return-only):
  # - statistics [list of PixUser::Statistics, default []]: list of PixUser::Statistics objects. ex: [PixUser::Statistics.new(after: '2023-11-06T18:57:08.325090+00:00', source: 'pix-key')]
  class PixUser < StarkCore::Utils::Resource
    attr_reader :id, :statistics
    def initialize(id:, statistics: nil)
      super(id)
      @statistics = StarkInfra::PixUser::Statistics.parse_statistics(statistics)
    end

    # # Retrieve a PixUser object
    #
    # Receive a single PixUser object information by passing its taxId
    #
    # ## Parameters (required):
    # - id [string]: user tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
    #
    # ## Parameters (optional):
    # - key_id [string, default nil]: marked PixKey id. ex: '+5511989898989'
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixUser object that corresponds to the given id.
    def self.get(id, key_id: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, key_id: key_id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'PixUser',
        resource_maker: proc { |json|
          PixUser.new(
            id: json['id'],
            statistics: json['statistics']
          )
        }
      }
    end
  end
end
