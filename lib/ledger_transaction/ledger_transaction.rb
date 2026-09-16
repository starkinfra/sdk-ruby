# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../ledger/rule')

module StarkInfra
  # # LedgerTransaction object
  #
  # LedgerTransactions are used to track the balance of a given amount by inserting LedgerTransactions to them.
  # They can represent a bank account, a digital wallet, an inventory product, etc.
  #
  # ## Parameters (required):
  # - amount [integer]: amount of the transaction. ex: 11234
  # - ledger_id [string]: id of the Ledger containing the transaction. ex: '5656565656565656'
  # - external_id [string]: string that must be unique among all your LedgerTransactions in a single Ledger. ex: 'my-internal-id-123456'
  # - source [string]: source of the LedgerTransaction. ex: 'bank-transfer/123'
  #
  # ## Parameters (optional):
  # - fee [integer]: fee applied to the LedgerTransaction. ex: 100
  # - rules [list of Ledger::Rule objects, default []]: list of Rule objects linked to the LedgerTransaction. Rules are used to overwrite the Ledger's rules for this transaction. ex: [Ledger::Rule.new(key: 'minimumBalance', value: 0)]
  # - metadata [dictionary, default {}]: dictionary object used to store additional information about the LedgerTransaction object. ex: { 'orderId': '123', 'orderType': 'purchase' }
  # - tags [list of strings, default []]: list of strings for reference when searching for LedgerTransactions. ex: ['transfer/123', 'savings']
  # - created [DateTime or string, default nil]: datetime to backdate the transaction, used to import existing transaction history. Cannot be in the future; when creating multiple transactions in one request, their created values must be in chronological order. Defaults to the current datetime when omitted.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the LedgerTransaction is created. ex: '5656565656565656'
  # - balance [integer]: Ledger's balance after the transaction. ex: 11234
  class LedgerTransaction < StarkCore::Utils::Resource
    attr_reader :amount, :ledger_id, :external_id, :source, :id, :balance, :fee, :rules, :metadata, :tags, :created
    def initialize(
      amount:, ledger_id:, external_id:, source:, id: nil, balance: nil, fee: nil, rules: nil,
      metadata: nil, tags: nil, created: nil
    )
      super(id)
      @amount = amount
      @ledger_id = ledger_id
      @external_id = external_id
      @source = source
      @balance = balance
      @fee = fee
      @rules = StarkInfra::Ledger::Rule.parse_rules(rules)
      @metadata = metadata
      @tags = tags
      @created = StarkCore::Utils::Checks.check_datetime(created)
    end

    # # Create LedgerTransactions
    #
    # Send a list of LedgerTransaction objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - transactions [list of LedgerTransaction objects]: list of LedgerTransaction objects to be created in the Stark Infra API. You can send up to 500 objects in a single request, targeting different ledgers if needed; each is applied to its Ledger in the order sent, and the resulting balance is returned for each one.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of LedgerTransaction objects with updated attributes
    def self.create(transactions, user: nil)
      StarkInfra::Utils::Rest.post(entities: transactions, user: user, **resource)
    end

    # # Retrieve a specific LedgerTransaction
    #
    # Receive a single LedgerTransaction object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - LedgerTransaction object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve LedgerTransactions
    #
    # Receive a generator of LedgerTransaction objects previously created in the Stark Infra API
    #
    # ## Parameters (conditionally-required):
    # - ledger_id [string, default nil]: id of the Ledger containing the transaction. Either ledger_id or ids must be provided. If both are sent, the query will be filtered by both. ex: '5656565656565656'
    # - ids [list of strings, default nil]: list of LedgerTransaction ids to filter retrieved objects. Either ledger_id or ids must be provided. If both are sent, the query will be filtered by both. ex: ['5656565656565656', '4545454545454545']
    #
    # ## Parameters (optional):
    # - flow [string, default nil]: direction of the transaction. ex: 'in' or 'out'
    # - tags [list of strings, default nil]: list of tags to filter retrieved objects. ex: ['transfer/123', 'savings']
    # - external_ids [list of strings, default nil]: list of LedgerTransaction external ids to filter retrieved objects. ex: ['my-internal-id-123456', 'my-internal-id-654321']
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - limit [integer, default 100, maximum 1000]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of LedgerTransaction objects with updated attributes
    def self.query(ledger_id: nil, flow: nil, tags: nil, external_ids: nil, after: nil, before: nil,
                    ids: nil, limit: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        ledger_id: ledger_id,
        flow: flow,
        tags: tags,
        external_ids: external_ids,
        after: after,
        before: before,
        ids: ids,
        limit: limit,
        user: user,
        **resource
      )
    end

    # # Retrieve paged LedgerTransactions
    #
    # Receive a list of LedgerTransaction objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (conditionally-required):
    # - ledger_id [string, default nil]: id of the Ledger containing the transaction. Either ledger_id or ids must be provided. If both are sent, the query will be filtered by both. ex: '5656565656565656'
    # - ids [list of strings, default nil]: list of LedgerTransaction ids to filter retrieved objects. Either ledger_id or ids must be provided. If both are sent, the query will be filtered by both. ex: ['5656565656565656', '4545454545454545']
    #
    # ## Parameters (optional):
    # - flow [string, default nil]: direction of the transaction. ex: 'in' or 'out'
    # - tags [list of strings, default nil]: list of tags to filter retrieved objects. ex: ['transfer/123', 'savings']
    # - external_ids [list of strings, default nil]: list of LedgerTransaction external ids to filter retrieved objects. ex: ['my-internal-id-123456', 'my-internal-id-654321']
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - limit [integer, default 100, maximum 1000]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of LedgerTransaction objects with updated attributes
    # - cursor to retrieve the next page of LedgerTransaction objects
    def self.page(ledger_id: nil, flow: nil, tags: nil, external_ids: nil, after: nil, before: nil,
                  ids: nil, limit: nil, cursor: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        ledger_id: ledger_id,
        flow: flow,
        tags: tags,
        external_ids: external_ids,
        after: after,
        before: before,
        ids: ids,
        limit: limit,
        cursor: cursor,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'LedgerTransaction',
        resource_maker: proc { |json|
          LedgerTransaction.new(
            id: json['id'],
            amount: json['amount'],
            ledger_id: json['ledger_id'],
            external_id: json['external_id'],
            source: json['source'],
            balance: json['balance'],
            fee: json['fee'],
            rules: json['rules'],
            metadata: json['metadata'],
            tags: json['tags'],
            created: json['created']
          )
        }
      }
    end
  end
end
