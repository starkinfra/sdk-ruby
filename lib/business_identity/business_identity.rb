# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../utils/parse')

module StarkInfra
  # # BusinessIdentity object
  #
  # A BusinessIdentity represents a company to be validated. It can have several business attachments
  # attached to it, which are used to validate the identity of the company. Once a business identity is created,
  # business attachments must be attached to it using the created method of the business attachment resource. When all
  # the required business attachments are attached to a business identity it can be sent to validation by patching its
  # status to processing.
  #
  # When you initialize a BusinessIdentity, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - tax_id [string]: company's tax ID (CNPJ). ex: "20.018.183/0001-80"
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for reference when searching for BusinessIdentities. ex: ["employees", "monthly"]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the BusinessIdentity is created. ex: "5656565656565656"
  # - name [string]: company's full name. ex: "Stark Bank S.A."
  # - tax_id_status [string]: current status of the tax ID. ex: "active"
  # - insight_tax_id [string]: tax ID returned by the validation insight. ex: "20018183000180"
  # - insight_document_type [string]: document type returned by the validation insight. ex: "cnpj"
  # - num_pages [integer]: number of pages of the attached documents. ex: 3
  # - representatives [string]: JSON string with the company's representatives.
  # - attachments [list of strings]: list of BusinessAttachment ids attached to the BusinessIdentity. ex: ["5656565656565656", "4545454545454545"]
  # - rules [string]: JSON string with the validation rules.
  # - status [string]: current status of the BusinessIdentity. Options: "created", "pending", "canceled", "processing", "success", "failed"
  # - created [DateTime]: creation datetime for the BusinessIdentity. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the BusinessIdentity. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class BusinessIdentity < StarkCore::Utils::Resource
    attr_reader :tax_id, :tags, :id, :name, :tax_id_status, :insight_tax_id, :insight_document_type, :num_pages,
                :representatives, :attachments, :rules, :status, :created, :updated
    def initialize(tax_id:, tags: nil, id: nil, name: nil, tax_id_status: nil, insight_tax_id: nil,
                   insight_document_type: nil, num_pages: nil, representatives: nil, attachments: nil, rules: nil,
                   status: nil, created: nil, updated: nil)
      super(id)
      @tax_id = tax_id
      @tags = tags
      @name = name
      @tax_id_status = tax_id_status
      @insight_tax_id = insight_tax_id
      @insight_document_type = insight_document_type
      @num_pages = num_pages
      @representatives = representatives
      @attachments = attachments
      @rules = rules
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create BusinessIdentities
    #
    # Send a list of BusinessIdentity objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - identities [list of BusinessIdentity objects]: list of BusinessIdentity objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of BusinessIdentity objects with updated attributes
    def self.create(identities, user: nil)
      StarkInfra::Utils::Rest.post(entities: identities, user: user, **resource)
    end

    # # Retrieve a specific BusinessIdentity
    #
    # Receive a single BusinessIdentity object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: "5656565656565656"
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - BusinessIdentity object with updated attributes
    def self.get(uuid, user: nil)
      StarkInfra::Utils::Rest.get_id(id: uuid, user: user, **resource)
    end

    # # Retrieve BusinessIdentities
    #
    # Receive a generator of BusinessIdentity objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "pending", "canceled", "processing", "success", "failed"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - tax_ids [list of strings, default nil]: list of tax ids to filter retrieved objects. ex: ["20.018.183/0001-80"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of BusinessIdentity objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, tax_ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        ids: ids,
        tax_ids: tax_ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged BusinessIdentities
    #
    # Receive a list of up to 100 BusinessIdentity objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "pending", "canceled", "processing", "success", "failed"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - tax_ids [list of strings, default nil]: list of tax ids to filter retrieved objects. ex: ["20.018.183/0001-80"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of BusinessIdentity objects with updated attributes
    # - cursor to retrieve the next page of BusinessIdentity objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, tax_ids: nil, user: nil)
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
        tax_ids: tax_ids,
        user: user,
        **resource
      )
    end

    # # Update BusinessIdentity entity
    #
    # Update a BusinessIdentity by passing id.
    #
    # ## Parameters (required):
    # - id [string]: BusinessIdentity unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - status [string, default nil]: You may send BusinessAttachments to validation by passing 'processing' in the status
    # - tags [list of strings, default nil]: list of strings for reference when searching for BusinessIdentities. ex: ["employees", "monthly"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - target BusinessIdentity with updated attributes
    def self.update(id, status: nil, tags: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        status: status,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Cancel a BusinessIdentity entity
    #
    # Cancel a BusinessIdentity entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: BusinessIdentity unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled BusinessIdentity object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'BusinessIdentity',
        resource_maker: proc { |json|
          BusinessIdentity.new(
            tax_id: json['tax_id'],
            tags: json['tags'],
            id: json['id'],
            name: json['name'],
            tax_id_status: json['tax_id_status'],
            insight_tax_id: json['insight_tax_id'],
            insight_document_type: json['insight_document_type'],
            num_pages: json['num_pages'],
            representatives: json['representatives'],
            attachments: json['attachments'],
            rules: json['rules'],
            status: json['status'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
