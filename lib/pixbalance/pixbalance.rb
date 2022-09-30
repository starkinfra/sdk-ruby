# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # PixBalance object
  #
  # The PixBalance object displays the current balance of the workspace,
  # which is the result of the sum of all transactions within this
  # workspace. The balance is never generated by the user, but it
  # can be retrieved to see the available information.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when Balance is created. ex: '5656565656565656'
  # - amount [integer]: current balance amount of the workspace in cents. ex: 200 (= R$ 2.00)
  # - currency [string]: currency of the current workspace. Expect others to be added eventually. ex: 'BRL'
  # - updated [DateTime]: latest update datetime for the balance. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixBalance < StarkInfra::Utils::Resource
    attr_reader :id, :amount, :currency, :updated
    def initialize(id: nil, amount: nil, currency: nil, updated: nil)
      super(id)
      @amount = amount
      @currency = currency
      @updated = updated
    end

    # # Retrieve PixBalance
    #
    # Receive the PixBalance object linked to your workspace in the Stark Infra API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixBalance object with updated attributes
    def self.get(user: nil)
      StarkInfra::Utils::Rest.get_stream(user: user, **resource).next
    end

    def self.resource
      {
        resource_name: 'PixBalance',
        resource_maker: proc { |json|
          PixBalance.new(
            id: json['id'],
            amount: json['amount'],
            currency: json['currency'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
