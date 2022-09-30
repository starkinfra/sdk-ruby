# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/sub_resource')

module StarkInfra
  # # MerchantCategory object
  #
  # MerchantCategory's codes and types are used to define categories filters in IssuingRules.
  #
  # A MerchantCategory filter must define exactly one parameter between code and type.
  # A type, such as 'food', 'services', etc., defines an entire group of merchant codes,
  # whereas a code only specifies a specific MCC.
  #
  # ## Parameters (conditionally required):
  # - code [string, default nil]: category's code. ex: 'veterinaryServices', 'fastFoodRestaurants'
  # - type [string, default nil]: category's type. ex: 'pets', 'food'
  #
  # Attributes (return-only):
  # - name [string]: category's name. ex: 'Veterinary services', 'Fast food restaurants'
  # - number [string]: category's number. ex: '742', '5814'
  class MerchantCategory < StarkInfra::Utils::SubResource
    attr_reader :code, :type, :name, :number
    def initialize(code:, type:, name: nil, number: nil)
      @code = code
      @type = type
      @name = name
      @number = number
    end

    # # Retrieve MerchantCategories
    #
    # Receive a generator of MerchantCategory objects available in the Stark Infra API
    #
    # ## Parameters (optional):
    # - search [string, default nil]: keyword to search for code, name, number or short_code
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of MerchantCategory objects with updated attributes
    def self.query(search: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(
        search: search,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'MerchantCategory',
        resource_maker: proc { |json|
          MerchantCategory.new(
            code: json['code'],
            type: json['type'],
            name: json['name'],
            number: json['number']
          )
        }
      }
    end
  end
end
