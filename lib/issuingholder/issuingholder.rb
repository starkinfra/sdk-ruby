# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # IssuingHolder object
  #
  # The IssuingHolder describes a card holder that may group several cards.
  #
  # When you initialize a IssuingHolder, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - name [string]: card holder name.
  # - tax_id [string]: card holder tax ID
  # - external_id [string] card holder external ID
  #
  # ## Parameters (optional):
  # - rules [list of IssuingRule objects, default nil]: [EXPANDABLE] list of holder spending rules.
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingHolder is created. ex: '5656565656565656'
  # - status [string]: current IssuingHolder status. ex: 'active', 'blocked', 'canceled'
  # - updated [DateTime]: latest update datetime for the IssuingHolder. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingHolder < StarkInfra::Utils::Resource
    attr_reader :id, :name, :tax_id, :external_id, :rules, :tags, :status, :updated, :created
    def initialize(
      name:, tax_id:, external_id:, rules: nil, tags: nil, id: nil, status: nil, updated: nil, created: nil
    )
      super(id)
      @name = name
      @tax_id = tax_id
      @external_id = external_id
      @rules = StarkInfra::IssuingRule.parse_rules(rules)
      @tags = tags
      @status = status
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    # # Create IssuingHolders
    #
    # Send a list of IssuingHolder objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - holders [list of IssuingHolder objects]: list of IssuingHolder objects to be created in the API
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: fields to expand information. Options: ['rules']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingHolder objects with updated attributes
    def self.create(holders:, expand: nil, user: nil)
      StarkInfra::Utils::Rest.post(entities: holders, expand: expand, user: user, **resource)
    end

    # # Retrieve a specific IssuingHolder
    #
    # Receive a single IssuingHolder object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: fields to expand information. ex: ['rules']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - IssuingHolder object with updated attributes
    def self.get(id, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, expand: expand, user: user, **resource)
    end

    # # Retrieve IssuingHolders
    #
    # Receive a generator of IssuingHolder objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['active', 'blocked', 'canceled']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - expand [string, default nil]: fields to expand information. ex: ['rules']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingHolders objects with updated attributes
    def self.query(limit: nil, ids: nil, after: nil, before: nil, status: nil, tags: nil, expand: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        ids: ids,
        after: after,
        before: before,
        status: status,
        tags: tags,
        expand: expand,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingHolders
    #
    # Receive a list of up to 100 IssuingHolders objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your logs.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['active', 'blocked', 'canceled']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - expand [string, default nil]: fields to expand information. ex: ['rules']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingHolders objects with updated attributes
    # - cursor to retrieve the next page of IssuingHolders objects
    def self.page(cursor: nil, limit: nil, ids: nil, after: nil, before: nil, status: nil, tags: nil, expand: nil,
                  user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        ids: ids,
        after: after,
        before: before,
        status: status,
        tags: tags,
        expand: expand,
        user: user,
        **resource
      )
    end

    # # Update IssuingHolder entity
    #
    # Update an IssuingHolder by passing id, if it hasn't been paid yet.
    #
    # ## Parameters (required):
    # - id [string]: IssuingHolder id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - status [string, default nil]: You may block the IssuingHolder by passing 'blocked' in the status
    # - name [string, default nil]: card holder name.
    # - tags [list of strings, default nil]: list of strings for tagging
    # - rules [list of IssuingRule objects, default nil]: list of objects that represent the holder's spending rules.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - target IssuingHolder with updated attributes
    def self.update(id, status: nil, name: nil, tags: nil, rules: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        status: status,
        name: name,
        tags: tags,
        rules: rules,
        user: user,
        **resource
      )
    end

    # # Cancel an IssuingHolder entity
    #
    # Cancel an IssuingHolder entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: IssuingHolder unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled IssuingHolder object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'IssuingHolder',
        resource_maker: proc { |json|
          IssuingHolder.new(
            id: json['id'],
            name: json['name'],
            tax_id: json['tax_id'],
            external_id: json['external_id'],
            rules: json['rules'],
            tags: json['tags'],
            status: json['status'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
