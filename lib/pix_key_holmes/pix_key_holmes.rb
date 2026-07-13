# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # PixKeyHolmes object
  #
  # A PixKeyHolmes investigates the registration status of a Pix Key in the
  # Central Bank's DICT. You open one per key you want to check; the API
  # resolves it asynchronously and reports back whether the key is registered.
  #
  # When you initialize a PixKeyHolmes, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - key_id [string]: Pix Key to be investigated. ex: "+5511989898989", "11.222.333/0001-00", "valid@sandbox.com"
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for reference when searching for PixKeyHolmes. ex: ["travel", "food"]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixKeyHolmes is created. ex: "5656565656565656"
  # - result [string]: investigation result once the case is solved. ex: "registered", "unregistered"
  # - status [string]: current status of the PixKeyHolmes. ex: "created", "solving", "solved", "failed"
  # - created [DateTime]: creation datetime for the PixKeyHolmes. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixKeyHolmes. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixKeyHolmes < StarkCore::Utils::Resource
    attr_reader :key_id, :tags, :id, :result, :status, :updated, :created
    def initialize(key_id:, tags: nil, id: nil, result: nil, status: nil, updated: nil, created: nil)
      super(id)
      @key_id = key_id
      @tags = tags
      @id = id
      @result = result
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create PixKeyHolmes
    #
    # Send a list of PixKeyHolmes objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - holmes [list of PixKeyHolmes objects]: list of PixKeyHolmes objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixKeyHolmes objects with updated attributes
    def self.create(holmes, user: nil)
      StarkInfra::Utils::Rest.post(entities: holmes, user: user, **resource)
    end

    # # Retrieve PixKeyHolmes
    #
    # Receive a generator of PixKeyHolmes objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. The live API accepts only "solved" or "solving" as filter values. ex: ["solved", "solving"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ["travel", "food"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixKeyHolmes objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Retrieve PixKeyHolmes
    #
    # Receive a list of up to 100 PixKeyHolmes objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. The live API accepts only "solved" or "solving" as filter values. ex: ["solved", "solving"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ["travel", "food"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixKeyHolmes objects with updated attributes
    # - cursor to retrieve the next page of PixKeyHolmes objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        ids: ids,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'PixKeyHolmes',
        resource_maker: proc { |json|
          PixKeyHolmes.new(
            key_id: json['key_id'],
            tags: json['tags'],
            id: json['id'],
            result: json['result'],
            status: json['status'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
