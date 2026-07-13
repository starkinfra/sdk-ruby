# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../utils/parse')

module StarkInfra
  # # BusinessAttachment object
  #
  # Business attachments are files containing documents of a company that must be attached to a business
  # identity to be used for its validation.
  #
  # When you initialize a BusinessAttachment, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - name [string]: name of the BusinessAttachment. ex: "articles-of-incorporation.pdf"
  # - content [string]: Base64 data url of the file or its raw bytes. ex: data:application/pdf;base64,JVBERi0xLjQ...
  # - business_identity_id [string]: Unique id of BusinessIdentity. ex: "5656565656565656"
  #
  # ## Parameters (optional):
  # - content_type [string, default nil]: content MIME type. This parameter is required as input only. ex: "image/png" or "application/pdf"
  # - tags [list of strings, default nil]: list of strings for reference when searching for BusinessAttachments. ex: ["employees", "monthly"]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the BusinessAttachment is created. ex: "5656565656565656"
  # - attachment_id [string]: Unique id of the attached file. ex: "5656565656565656"
  # - status [string]: current status of the BusinessAttachment. Options: "created", "canceled", "approved", "denied"
  # - created [DateTime]: creation datetime for the BusinessAttachment. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the BusinessAttachment. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class BusinessAttachment < StarkCore::Utils::Resource
    attr_reader :name, :content, :content_type, :business_identity_id, :tags, :id, :attachment_id, :status, :created, :updated
    def initialize(name:, content:, business_identity_id:, content_type: nil, tags: nil, id: nil, attachment_id: nil,
                   status: nil, created: nil, updated: nil)
      super(id)
      @name = name
      @business_identity_id = business_identity_id
      @tags = tags
      @attachment_id = attachment_id
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
      @content = content
      @content_type = content_type

      if @content_type
        @content = "data:#{content_type};base64,#{Base64.encode64(content)}"
        @content_type = nil
      end
    end

    # # Create BusinessAttachments
    #
    # Send a list of BusinessAttachment objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - attachments [list of BusinessAttachment objects]: list of BusinessAttachment objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of BusinessAttachment objects with updated attributes
    def self.create(attachments, user: nil)
      StarkInfra::Utils::Rest.post(entities: attachments, user: user, **resource)
    end

    # # Retrieve a specific BusinessAttachment
    #
    # Receive a single BusinessAttachment object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: "5656565656565656"
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: fields to expand information. ex: ["content"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - BusinessAttachment object with updated attributes
    def self.get(id, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, expand: expand, user: user, **resource)
    end

    # # Retrieve BusinessAttachments
    #
    # Receive a generator of BusinessAttachment objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. Options: ["created", "canceled", "approved", "denied"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of BusinessAttachment objects with updated attributes
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

    # # Retrieve paged BusinessAttachments
    #
    # Receive a list of up to 100 BusinessAttachment objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. Options: ["created", "canceled", "approved", "denied"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of BusinessAttachment objects with updated attributes
    # - cursor to retrieve the next page of BusinessAttachment objects
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

    # # Cancel a BusinessAttachment entity
    #
    # Cancel a BusinessAttachment entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: BusinessAttachment unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled BusinessAttachment object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'BusinessAttachment',
        resource_maker: proc { |json|
          BusinessAttachment.new(
            name: json['name'],
            content: json['content'],
            content_type: json['content_type'],
            business_identity_id: json['business_identity_id'],
            tags: json['tags'],
            id: json['id'],
            attachment_id: json['attachment_id'],
            status: json['status'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
