# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')

module StarkInfra
  # # IssuingTransaction object
  #
  # The IssuingTransaction objects created in your Workspace to represent each balance shift.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingTransaction is created. ex: '5656565656565656'
  # - amount [integer]: IssuingTransaction value in cents. ex: 1234 (= R$ 12.34)
  # - balance [integer]: balance amount of the Workspace at the instant of the Transaction in cents. ex: 200 (= R$ 2.00)
  # - description [string]: IssuingTransaction description. ex: 'Buying food'
  # - source [string]: source of the transaction. ex: 'issuing-purchase/5656565656565656'
  # - tags [string]: list of strings inherited from the source resource. ex: ['tony', 'stark']
  # - created [DateTime]: creation datetime for the IssuingTransaction. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingTransaction < StarkInfra::Utils::Resource
    attr_reader :id, :amount, :balance, :description, :source, :tags, :created

    def initialize(
      id: nil, amount: nil, balance: nil, description: nil, source: nil, tags: nil, created: nil
    )
      super(id)
      @amount = amount
      @balance = balance
      @description = description
      @source = source
      @tags = tags
      @created = StarkInfra::Utils::Checks.check_datetime(created)
    end

    # # Retrieve a specific IssuingTransaction
    #
    # Receive a single IssuingTransaction object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingTransaction object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingTransactions
    #
    # Receive a generator of IssuingTransaction objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - external_ids [list of strings, default []]: external IDs. ex: ['5656565656565656', '4545454545454545']
    # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'approved', 'canceled', 'denied', 'confirmed' or 'voided'
    # - ids [list of strings, default [], default nil]: purchase IDs
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingTransaction objects with updated attributes
    def self.query(tags: nil, external_ids: nil, after: nil, before: nil, status: nil, ids: nil, limit: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        tags: tags,
        external_ids: external_ids,
        after: after,
        before: before,
        status: status,
        ids: ids,
        limit: limit,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingTransactions
    #
    # Receive a list of IssuingTransaction objects previously created in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - external_ids [list of strings, default nil: external IDs. ex: ['5656565656565656', '4545454545454545']
    # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'approved', 'canceled', 'denied', 'confirmed' or 'voided'
    # - ids [list of strings, default nil]: purchase IDs
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingTransactions objects with updated attributes
    # - cursor to retrieve the next page of IssuingTransactions objects
    def self.page(cursor: nil, tags: nil, external_ids: nil, after: nil, before: nil, status: nil, ids: nil, limit: nil,
                  user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        tags: tags,
        external_ids: external_ids,
        after: after,
        before: before,
        status: status,
        ids: ids,
        limit: limit,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingTransaction',
        resource_maker: proc { |json|
          IssuingTransaction.new(
            id: json['id'],
            amount: json['amount'],
            balance: json['balance'],
            description: json['description'],
            source: json['source'],
            tags: json['tags'],
            created: json['created']
          )
        }
      }
    end
  end
end
