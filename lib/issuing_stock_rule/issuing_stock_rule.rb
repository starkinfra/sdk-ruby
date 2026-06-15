# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingStockRule object
  #
  # The IssuingStockRule object displays the notification rules attached to an IssuingStock.
  # When the linked stock balance reaches the minimum_balance, the recipients listed in
  # emails and phones are notified.
  #
  # ## Parameters (required):
  # - minimum_balance [integer]: stock balance threshold that triggers a notification. ex: 10000
  # - stock_id [string]: IssuingStock unique id the rule is linked to. ex: '5136459887542272'
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['card', 'corporate']
  # - emails [list of strings, default nil]: emails notified when the stock reaches the minimum balance. ex: ['john.doe@enterprise.com']
  # - phones [list of strings, default nil]: phones notified when the stock reaches the minimum balance. ex: ['+5511912345678']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingStockRule is created. ex: '5664445921492992'
  # - status [string]: current IssuingStockRule status. ex: 'active', 'canceled'
  # - created [DateTime]: creation datetime for the IssuingStockRule. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the IssuingStockRule. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingStockRule < StarkCore::Utils::Resource
    attr_reader :minimum_balance, :stock_id, :tags, :emails, :phones, :id, :status, :created, :updated
    def initialize(
      minimum_balance:, stock_id:, tags: nil, emails: nil, phones: nil,
      id: nil, status: nil, created: nil, updated: nil
    )
      super(id)
      @minimum_balance = minimum_balance
      @stock_id = stock_id
      @tags = tags
      @emails = emails
      @phones = phones
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create IssuingStockRules
    #
    # Send a list of IssuingStockRule objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - rules [list of IssuingStockRule objects]: list of IssuingStockRule objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingStockRule objects with updated attributes
    def self.create(rules:, user: nil)
      StarkInfra::Utils::Rest.post(entities: rules, user: user, **resource)
    end

    # # Retrieve a specific IssuingStockRule
    #
    # Receive a single IssuingStockRule object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5664445921492992'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingStockRule object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingStockRules
    #
    # Receive a generator of IssuingStockRule objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['active', 'canceled']
    # - stock_ids [list of strings, default nil]: list of stock_ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['card', 'corporate']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingStockRule objects with updated attributes
    def self.query(
      limit: nil, after: nil, before: nil, status: nil, stock_ids: nil,
      ids: nil, tags: nil, user: nil
    )
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        stock_ids: stock_ids,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingStockRules
    #
    # Receive a list of up to 100 IssuingStockRule objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['active', 'canceled']
    # - stock_ids [list of strings, default nil]: list of stock_ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['card', 'corporate']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingStockRule objects with updated attributes
    # - cursor to retrieve the next page of IssuingStockRule objects
    def self.page(
      cursor: nil, limit: nil, after: nil, before: nil, status: nil, stock_ids: nil,
      ids: nil, tags: nil, user: nil
    )
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        stock_ids: stock_ids,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Update IssuingStockRule entity
    #
    # Update an IssuingStockRule by passing id.
    #
    # ## Parameters (required):
    # - id [string]: IssuingStockRule unique id. ex: '5664445921492992'
    #
    # ## Parameters (optional):
    # - minimum_balance [integer, default nil]: new stock balance threshold that triggers a notification. ex: 20000
    # - tags [list of strings, default nil]: new list of strings for tagging. ex: ['card', 'corporate']
    # - emails [list of strings, default nil]: new list of emails notified when the stock reaches the minimum balance. ex: ['john.doe@enterprise.com']
    # - phones [list of strings, default nil]: new list of phones notified when the stock reaches the minimum balance. ex: ['+5511912345678']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - target IssuingStockRule with updated attributes
    def self.update(id, minimum_balance: nil, tags: nil, emails: nil, phones: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        minimum_balance: minimum_balance,
        tags: tags,
        emails: emails,
        phones: phones,
        user: user,
        **resource
      )
    end

    # # Cancel an IssuingStockRule entity
    #
    # Cancel an IssuingStockRule entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: IssuingStockRule unique id. ex: '5664445921492992'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled IssuingStockRule object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'IssuingStockRule',
        resource_maker: proc { |json|
          IssuingStockRule.new(
            minimum_balance: json['minimum_balance'],
            stock_id: json['stock_id'],
            tags: json['tags'],
            emails: json['emails'],
            phones: json['phones'],
            id: json['id'],
            status: json['status'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
