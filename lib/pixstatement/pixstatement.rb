# frozen_string_literal: true

require_relative('../utils/rest')
require('starkcore')

module StarkInfra
  # # PixStatement object
  #
  # The PixStatement object stores information about all the transactions that
  # happened on a specific day at your settlment account according to the Central Bank.
  # It must be created by the user before it can be accessed.
  # This feature is only available for direct participants.
  #
  # When you initialize a PixStatement, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - after [Date or string]: transactions that happened at this date are stored in the PixStatement, must be the same as before. ex: Date.new(2020, 3, 10) or '2020-03-10'
  # - before [Date or string]: transactions that happened at this date are stored in the PixStatement, must be the same as after. ex: Date.new(2020, 3, 10) or '2020-03-10'
  # - type [string]: type of entities to include in statement. Options: 'interchange', 'interchangeTotal', 'transaction'
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixStatement is created. ex: '5656565656565656'
  # - status [string]: current PixStatement status. ex: 'success' or 'failed'
  # - transaction_count [integer]: number of transactions that happened during the day that the PixStatement was requested. ex: 11
  # - created [DateTime]: creation datetime for the PixStatement. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixStatement. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixStatement < StarkCore::Utils::Resource
    attr_reader :after, :before, :type, :id, :status, :transaction_count, :created, :updated
    def initialize(after:, before:, type:, id: nil, status: nil, transaction_count: nil, created: nil, updated: nil)
      super(id)
      @after = StarkCore::Utils::Checks.check_date(after)
      @before = StarkCore::Utils::Checks.check_date(before)
      @type = type
      @status = status
      @transaction_count = transaction_count
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create a PixStatement object
    #
    # Create a PixStatements linked to your workspace in the Stark Infra API
    # 
    # ## Parameters (required):
    # - statement [PixStatement object]: PixStatement object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixStatement object with updated attributes.
    def self.create(statement, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: statement, user: user, **resource)
    end

    # # Retrieve a specific PixStatement object
    #
    # Receive a single PixStatement object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixStatement object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixStatement objects
    #
    # Receive a generator of PixStatements objects previously created in the Stark Infra API.
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixStatement objects with updated attributes
    def self.query(limit: nil, ids: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixStatements
    #
    # Receive a list of up to 100 PixStatements objects previously created in the Stark infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your statements.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixStatement objects with updated attributes
    # - cursor to retrieve the next page of PixStatement objects
    def self.page(cursor: nil, limit: nil, ids: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # # Retrieve a .cvs PixStatement
    #
    # Retrieve a specific PixStatement by its ID in a .csv file.
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixStatement .csv file
    def self.csv(id, user: nil)
      StarkInfra::Utils::Rest.get_content(id: id, user: user, sub_resource_name: 'csv', **resource)
    end

    def self.resource
      {
        resource_name: 'PixStatement',
        resource_maker: proc { |json|
          PixStatement.new(
            id: json['id'],
            after: json['after'],
            before: json['before'],
            type: json['type'],
            status: json['status'],
            transaction_count: json['transaction_count'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
