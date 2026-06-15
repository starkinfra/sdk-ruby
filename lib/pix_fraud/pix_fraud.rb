# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # PixFraud object
  #
  # PixFrauds are used to report a PixKey or taxId when a fraud
  # has been confirmed.
  # When you initialize a PixFraud, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - external_id [string]: end_to_end_id or return_id of the transaction being reported. ex: 'E20018183202201201450u34sDGd19lz'
  # - type [string]: type of PixFraud. Options: 'identity', 'mule', 'scam', 'other'
  # - tax_id [string]: user tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  #
  # ## Parameters (optional):
  # - key_id [string, default nil]: marked PixKey id. ex: '+5511989898989'
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['fraudulent']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixFraud is created. ex: '5656565656565656'
  # - bacen_id [string]: unique transaction id returned from Central Bank. ex: 'ccf9bd9c-e99d-999e-bab9-b999ca999f99'
  # - status [string]: current PixFraud status. Options: 'created', 'failed', 'registered', 'canceled'.
  # - created [DateTime]: creation datetime for the PixFraud. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixFraud. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixFraud < StarkCore::Utils::Resource
    attr_reader :external_id, :type, :tax_id, :key_id, :tags, :id, :bacen_id, :status, :created, :updated
    def initialize(
      external_id:, type:, tax_id:, key_id: nil, tags: nil,
      id: nil, bacen_id: nil, status: nil, created: nil, updated: nil
    )
      super(id)
      @external_id = external_id
      @type = type
      @tax_id = tax_id
      @key_id = key_id
      @tags = tags
      @bacen_id = bacen_id
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create PixFrauds
    #
    # Send a list of PixFraud objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - frauds [list of PixFraud objects]: list of PixFraud objects to be created in the API. ex: [PixFraud.new()]
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixFraud objects with updated attributes
    def self.create(frauds, user: nil)
      StarkInfra::Utils::Rest.post(entities: frauds, user: user, **resource)
    end

    # # Retrieve a specific PixFraud
    #
    # Receive a single PixFraud object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixFraud object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixFrauds
    #
    # Receive a generator of PixFraud objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. Options: 'created', 'failed', 'registered', 'canceled'.
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: list of strings for tagging. ex: ['fraudulent']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixFraud objects with updated attributes
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

    # # Retrieve paged PixFrauds
    #
    # Receive a list of up to 100 PixFraud objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your frauds.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. Options: 'created', 'failed', 'registered', 'canceled'.
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: list of strings for tagging. ex: ['fraudulent']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixFraud objects with updated attributes
    # - cursor to retrieve the next page of PixFraud objects
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

    # # Cancel a PixFraud entity
    #
    # Cancel a PixFraud entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: PixFraud unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled PixFraud object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'PixFraud',
        resource_maker: proc { |json|
          PixFraud.new(
            id: json['id'],
            external_id: json['external_id'],
            type: json['type'],
            tax_id: json['tax_id'],
            key_id: json['key_id'],
            tags: json['tags'],
            bacen_id: json['bacen_id'],
            status: json['status'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
