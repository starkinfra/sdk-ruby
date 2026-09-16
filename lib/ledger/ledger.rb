# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('rule')

module StarkInfra
  # # Ledger object
  #
  # Ledgers are used to track the balance of a given amount by inserting LedgerTransactions to them.
  # They can represent a bank account, a digital wallet, an inventory product, etc.
  #
  # ## Parameters (required):
  # - external_id [string]: string that must be unique among all your Ledgers. ex: 'my-internal-id-123456'
  #
  # ## Parameters (optional):
  # - rules [list of Ledger::Rule objects, default []]: list of Rule objects linked to the Ledger. Rules are used to limit the balance of the Ledger. ex: [Ledger::Rule.new(key: 'minimumBalance', value: 0)]
  # - tags [list of strings, default []]: list of strings for reference when searching for Ledgers. ex: ['account/123', 'savings']
  # - metadata [dictionary, default {}]: dictionary object used to store additional information about the Ledger object. ex: { 'accountId': '123', 'accountType': 'savings' }
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the Ledger is created. ex: '5656565656565656'
  # - created [DateTime]: creation datetime for the Ledger. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the Ledger. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class Ledger < StarkCore::Utils::Resource
    attr_reader :external_id, :rules, :tags, :metadata, :id, :created, :updated
    def initialize(external_id:, id: nil, rules: nil, tags: nil, metadata: nil, created: nil, updated: nil)
      super(id)
      @external_id = external_id
      @rules = StarkInfra::Ledger::Rule.parse_rules(rules)
      @tags = tags
      @metadata = metadata
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create Ledgers
    #
    # Send a list of Ledger objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - ledgers [list of Ledger objects]: list of Ledger objects to be created in the Stark Infra API. You can send up to 100 Ledger objects in a single request.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of Ledger objects with updated attributes
    def self.create(ledgers, user: nil)
      StarkInfra::Utils::Rest.post(entities: ledgers, user: user, **resource)
    end

    # # Retrieve a specific Ledger
    #
    # Receive a single Ledger object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - Ledger object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve Ledgers
    #
    # Receive a generator of Ledger objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - ids [list of strings, default nil]: list of Ledger ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - external_ids [list of strings, default nil]: list of Ledger external ids to filter retrieved objects. ex: ['my-internal-id-123456', 'my-internal-id-654321']
    # - tags [list of strings, default nil]: list of tags to filter retrieved objects. ex: ['account/123', 'savings']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of Ledger objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, ids: nil, external_ids: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        ids: ids,
        external_ids: external_ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged Ledgers
    #
    # Receive a list of up to 100 Ledger objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - ids [list of strings, default nil]: list of Ledger ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - external_ids [list of strings, default nil]: list of Ledger external ids to filter retrieved objects. ex: ['my-internal-id-123456', 'my-internal-id-654321']
    # - tags [list of strings, default nil]: list of tags to filter retrieved objects. ex: ['account/123', 'savings']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of Ledger objects with updated attributes
    # - cursor to retrieve the next page of Ledger objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, ids: nil, external_ids: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        ids: ids,
        external_ids: external_ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Update Ledger
    #
    # Update a Ledger by passing id.
    #
    # ## Parameters (required):
    # - id [string]: Ledger id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - rules [list of Ledger::Rule objects, default nil]: list of Rule objects linked to the Ledger. Rules are used to limit the balance of the Ledger. ex: [Ledger::Rule.new(key: 'minimumBalance', value: 0)]
    # - tags [list of strings, default nil]: list of strings for reference when searching for Ledgers. ex: ['account/123', 'savings']
    # - metadata [dictionary, default nil]: dictionary object used to store additional information about the Ledger object. ex: { 'accountId': '123', 'accountType': 'savings' }
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - target Ledger object with updated attributes
    def self.update(id, rules: nil, tags: nil, metadata: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        rules: rules,
        tags: tags,
        metadata: metadata,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'Ledger',
        resource_maker: proc { |json|
          Ledger.new(
            id: json['id'],
            external_id: json['external_id'],
            rules: json['rules'],
            tags: json['tags'],
            metadata: json['metadata'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
