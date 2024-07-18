# frozen_string_literal: true
require('starkcore')
require_relative('../../utils/rest')

module StarkInfra

  # CreditNote::Invoice::Description object
  #
  # Invoice description information.
  #
  # ## Parameters (required):
  # - key [string]: Description for the value. ex: 'Taxes'
  #
  # ## Parameters (optional):
  # - value [string, default nil]: amount related to the described key. ex: 'R$100,00'
  class Description < StarkCore::Utils::SubResource
    attr_reader :percentage, :due
    def initialize(key:, value: nil)
      @key = key
      @value = value
    end

    def self.parse_descriptions(descriptions)
      resource_maker = StarkInfra::Description.resource[:resource_maker]
      return descriptions if descriptions.nil?

      parsed_descriptions = []
      descriptions.each do |description|
        unless description.is_a? Description
          description = StarkCore::Utils::API.from_api_json(resource_maker, description)
        end
        parsed_descriptions << description
      end
      parsed_descriptions
    end

    def self.resource
      {
        resource_name: 'Description',
        resource_maker: proc { |json|
          Description.new(
            key: json['key'],
            value: json['value']
          )
        }
      }
    end
  end
end
