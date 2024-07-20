# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../utils/parse')

module StarkInfra
  # # IndividualIdentity object
  #
  # An IndividualDocument represents an individual to be validated. It can have several individual documents attached
  # to it, which are used to validate the identity of the individual. Once an individual identity is created, individual
  # documents must be attached to it using the created method of the individual document resource. When all the required
  # individual documents are attached to an individual identity it can be sent to validation by patching its status to 
  # processing.
  #
  # When you initialize a IndividualIdentity, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - name [string]: individual's full name. ex: "Edward Stark".
  # - tax_id [string]: individual's tax ID (CPF). ex: "594.739.480-42"
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for reference when searching for IndividualIdentities. ex: ["employees", "monthly"]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the IndividualIdentity is created. ex: "5656565656565656"
  # - status [string]: current status of the IndividualIdentity. Options: "created", "canceled", "processing", "failed", "success"
  # - created [DateTime]: creation datetime for the IndividualIdentity. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IndividualIdentity < StarkCore::Utils::Resource
    attr_reader :name, :tax_id, :tags, :id, :status, :created
    def initialize(name:, tax_id:, tags: nil, id: nil, status: nil, created: nil)
      super(id)
      @name = name
      @tax_id = tax_id
      @tags = tags
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
    end

    # # Create IndividualIdentities
    #
    # Send a list of IndividualIdentity objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - identities [list of IndividualIdentity objects]: list of IndividualIdentity objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IndividualIdentity objects with updated attributes
    def self.create(identities, user: nil)
      StarkInfra::Utils::Rest.post(entities: identities, user: user, **resource)
    end

    # # Retrieve a specific IndividualIdentity
    #
    # Receive a single IndividualIdentity object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: "5656565656565656"
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - IndividualIdentity object with updated attributes
    def self.get(uuid, user: nil)
      StarkInfra::Utils::Rest.get_id(id: uuid, user: user, **resource)
    end

    # # Retrieve IndividualIdentities
    #
    # Receive a generator of IndividualIdentity objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "canceled", "processing", "failed", "success"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IndividualIdentity objects with updated attributes
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

    # # Retrieve paged IndividualIdentities
    #
    # Receive a list of up to 100 IndividualIdentity objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "canceled", "processing", "failed", "success"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IndividualIdentity objects with updated attributes
    # - cursor to retrieve the next page of IndividualIdentity objects
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

    # # Update IndividualIdentity entity
    #
    # Update an IndividualIdentity by passing id.
    #
    # ## Parameters (required):
    # - id [string]: IndividualIdentity unique id. ex: '5656565656565656'
    # - status [string]: You may send IndividualDocuments to validation by passing 'processing' in the status
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - target IndividualIdentity with updated attributes
    def self.update(id, status:, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        status: status,
        user: user,
        **resource
      )
    end

    # # Cancel an IndividualIdentity entity
    #
    # Cancel an IndividualIdentity entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: IndividualIdentity unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled IndividualIdentity object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'IndividualIdentity',
        resource_maker: proc { |json|
          IndividualIdentity.new(
            name: json['name'],
            tax_id: json['tax_id'],
            tags: json['tags'],
            id: json['id'],
            status: json['status'],
            created: json['created']
          )
        }
      }
    end
  end
end
