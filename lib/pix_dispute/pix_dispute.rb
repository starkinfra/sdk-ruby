# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # PixDispute object
  #
  # A PixDispute is a request to investigate a Pix transaction that is suspected of
  # fraud or that resulted from a system malfunction. It maps the network of
  # transactions linked to the reported one for analysis.
  #
  # When you initialize a PixDispute, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends a list of objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - reference_id [string]: end_to_end_id of the transaction being reported. ex: 'E20018183202201201450u34sDGd19lz'
  # - method [string]: method of the dispute. Options: 'scam', 'unauthorized', 'coercion', 'invasion', 'other'
  # - operator_email [string]: contact email of the operator responsible for the PixDispute. ex: 'ruby-sdk@starkinfra.com'
  # - operator_phone [string]: contact phone number of the operator responsible for the PixDispute. ex: '+5511999999999'
  #
  # ## Parameters (conditionally required):
  # - description [string, default nil]: details for the investigation. Required when method == 'other'; optional otherwise.
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
  # - min_transaction_amount [integer, default nil]: minimum transaction amount considered for the graph creation. ex: 100
  # - max_transaction_count [integer, default nil]: maximum number of transactions considered for the graph creation. ex: 10
  # - max_hop_interval [integer, default nil]: mean time between transactions considered for the graph creation. ex: 3600
  # - max_hop_count [integer, default nil]: depth considered for the graph creation. ex: 5
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixDispute is created. ex: '5656565656565656'
  # - bacen_id [string]: central bank's unique PixDispute id. ex: '817fc523-9e9d-40ab-9e53-dacb71454a05'
  # - flow [string]: direction of the PixDispute. Options: 'in' for received disputes, 'out' for disputes you created.
  # - status [string]: current PixDispute status. Options: 'created', 'delivered', 'analysed', 'processing', 'closed', 'failed', 'canceled'
  # - transactions [list of PixDispute::Transaction objects]: list of Transaction objects linked to the PixDispute.
  # - created [DateTime]: creation datetime for the PixDispute. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixDispute. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixDispute < StarkCore::Utils::Resource
    attr_reader :reference_id, :method, :operator_email, :operator_phone, :description, :tags, :min_transaction_amount,
                :max_transaction_count, :max_hop_interval, :max_hop_count, :id, :bacen_id, :flow, :status,
                :transactions, :created, :updated
    def initialize(
      reference_id:, method:, operator_email:, operator_phone:, description: nil, tags: nil,
      min_transaction_amount: nil, max_transaction_count: nil, max_hop_interval: nil, max_hop_count: nil,
      id: nil, bacen_id: nil, flow: nil, status: nil, transactions: nil, created: nil, updated: nil
    )
      super(id)
      @reference_id = reference_id
      @method = method
      @operator_email = operator_email
      @operator_phone = operator_phone
      @description = description
      @tags = tags
      @min_transaction_amount = min_transaction_amount
      @max_transaction_count = max_transaction_count
      @max_hop_interval = max_hop_interval
      @max_hop_count = max_hop_count
      @bacen_id = bacen_id
      @flow = flow
      @status = status
      @transactions = PixDispute::Transaction.parse_transactions(transactions)
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create PixDisputes
    #
    # Send a list of PixDispute objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - disputes [list of PixDispute objects]: list of PixDispute objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixDispute objects with updated attributes
    def self.create(disputes, user: nil)
      StarkInfra::Utils::Rest.post(entities: disputes, user: user, **resource)
    end

    # # Retrieve a specific PixDispute
    #
    # Receive a single PixDispute object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixDispute object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixDisputes
    #
    # Receive a generator of PixDispute objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'delivered']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixDispute objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, ids: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixDisputes
    #
    # Receive a list of up to 100 PixDispute objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your disputes.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'delivered']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixDispute objects with updated attributes
    # - cursor to retrieve the next page of PixDispute objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, ids: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Cancel a PixDispute entity
    #
    # Cancel a PixDispute entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: PixDispute unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled PixDispute object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'PixDispute',
        resource_maker: proc { |json|
          PixDispute.new(
            id: json['id'],
            reference_id: json['reference_id'],
            method: json['method'],
            operator_email: json['operator_email'],
            operator_phone: json['operator_phone'],
            description: json['description'],
            tags: json['tags'],
            min_transaction_amount: json['min_transaction_amount'],
            max_transaction_count: json['max_transaction_count'],
            max_hop_interval: json['max_hop_interval'],
            max_hop_count: json['max_hop_count'],
            bacen_id: json['bacen_id'],
            flow: json['flow'],
            status: json['status'],
            transactions: json['transactions'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end

require_relative('transaction')
