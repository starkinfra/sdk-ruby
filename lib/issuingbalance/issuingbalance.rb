# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # IssuingBalance object
  #
  # The IssuingBalance object displays the current issuing balance of the Workspace, which is the result of the sum of
  # all transactions within this Workspace. The balance is never generated by the user, but it can be retrieved to see
  # the available information.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingBalance is created. ex: '5656565656565656'
  # - amount [integer]: current issuing balance amount of the Workspace in cents. ex: 200 (= R$ 2.00)
  # - currency [string]: currency of the current Workspace. Expect others to be added eventually. ex: 'BRL'
  # - updated [DateTime]: latest update datetime for the IssuingBalance. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingBalance < StarkInfra::Utils::Resource
    attr_reader :amount, :currency, :updated, :id
    def initialize(amount: nil, currency: nil, updated: nil, id: nil)
      super(id)
      @amount = amount
      @currency = currency
      @updated = updated
    end

    # # Retrieve the IssuingBalance object
    #
    # Receive the IssuingBalance object linked to your Workspace in the Stark Infrq API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingBalance object with updated attributes
    def self.get(user: nil)
      StarkInfra::Utils::Rest.get_stream(user: user, **resource).next
    end

    def self.resource
      {
        resource_name: 'IssuingBalance',
        resource_maker: proc { |json|
          IssuingBalance.new(
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
