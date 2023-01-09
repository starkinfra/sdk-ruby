# frozen_string_literal: true

require_relative('../utils/rest')
require('starkcore')

module StarkInfra
  # # IssuingWithdrawal object
  #
  # The IssuingWithdrawal objects created in your Workspace return cash from your Issuing balance to your Banking balance.
  #
  # When you initialize a IssuingWithdrawal, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - amount [integer]: IssuingWithdrawal value in cents. Minimum = 0 (any value will be accepted). ex: 1234 (= R$ 12.34)
  # - external_id [string] IssuingWithdrawal external ID. ex: '12345'
  # - description [string]: IssuingWithdrawal description. ex: 'sending money back'
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['tony', 'stark']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingWithdrawal is created. ex: '5656565656565656'
  # - transaction_id [string]: Stark Bank ledger transaction ids linked to this IssuingWithdrawal
  # - issuing_transaction_id [string]: issuing ledger transaction ids linked to this IssuingWithdrawal
  # - updated [DateTime]: latest update datetime for the IssuingWithdrawal. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingWithdrawal. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingWithdrawal < StarkCore::Utils::Resource
    attr_reader :amount, :external_id, :description, :tags, :id, :transaction_id, :issuing_transaction_id, :updated, :created
    def initialize(
      amount:, external_id:, description:, tags: nil, id: nil, transaction_id: nil, issuing_transaction_id: nil,
      updated: nil, created: nil
    )
      super(id)
      @amount = amount
      @external_id = external_id
      @description = description
      @tags = tags
      @transaction_id = transaction_id
      @issuing_transaction_id = issuing_transaction_id
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
      @created = StarkCore::Utils::Checks.check_datetime(created)
    end

    # # Create an IssuingWithdrawal
    #
    # Send a single IssuingWithdrawal object for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - withdrawal [IssuingWithdrawal object]: IssuingWithdrawal object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - IssuingWithdrawal object with updated attributes
    def self.create(withdrawal, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: withdrawal, user: user, **resource)
    end

    # # Retrieve a specific IssuingWithdrawal
    #
    # Receive a single IssuingWithdrawal object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - IssuingWithdrawal object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingWithdrawals
    #
    # Receive a generator of IssuingWithdrawal objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - external_ids [list of strings, default nil]: external IDs. ex: ['5656565656565656', '4545454545454545']
    # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingWithdrawal objects with updated attributes
    def self.query(limit: nil, external_ids: nil, after: nil, before: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        external_ids: external_ids,
        after: after,
        before: before,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingWithdrawals
    #
    # Receive a list of IssuingWithdrawals objects previously created in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - external_ids [list of strings, default nil]: external IDs. ex: ['5656565656565656', '4545454545454545']
    # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingWithdrawal objects with updated attributes
    # - cursor to retrieve the next page of IssuingWithdrawal objects
    def self.page(cursor: nil, limit: nil, external_ids: nil, after: nil, before: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        external_ids: external_ids,
        after: after,
        before: before,
        tags: tags,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingWithdrawal',
        resource_maker: proc { |json|
          IssuingWithdrawal.new(
            id: json['id'],
            amount: json['amount'],
            external_id: json['external_id'],
            description: json['description'],
            tags: json['tags'],
            transaction_id: json['transaction_id'],
            issuing_transaction_id: json['issuing_transaction_id'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
