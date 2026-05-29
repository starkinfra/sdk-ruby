# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IndividualAccountAttachment object
  #
  # Supporting document (identity document, driver's license) attached to an IndividualAccountRequest
  # for the account-approval flow. The caller uploads the raw image bytes and a MIME content type;
  # the SDK encodes them as a data: URL before sending.
  #
  # When you initialize an IndividualAccountAttachment, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - type [string]: type of the IndividualAccountAttachment. Options: 'drivers-license-front', 'drivers-license-back', 'identity-front', 'identity-back'
  # - content [string]: raw image bytes of the picture. After encoding, becomes a data:<contentType>;base64,<payload> URL.
  # - account_request_id [string]: id of the parent IndividualAccountRequest. ex: '5656565656565656'
  #
  # ## Parameters (optional):
  # - content_type [string, default nil]: content MIME type. Consumed as input only to build the data: URL; never sent as its own wire field. ex: 'image/png' or 'image/jpeg'
  # - tags [list of strings, default nil]: list of strings for reference when searching for IndividualAccountAttachments. ex: ['employees', 'monthly']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the IndividualAccountAttachment is created. ex: '5656565656565656'
  # - status [string]: current status of the IndividualAccountAttachment. Options: 'created', 'success', 'failed', 'deleted'
  # - created [DateTime]: creation datetime for the IndividualAccountAttachment. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IndividualAccountAttachment < StarkCore::Utils::Resource
    attr_reader :type, :content, :content_type, :account_request_id, :tags, :id, :status, :created
    def initialize(type:, content:, account_request_id:, content_type: nil, tags: nil, id: nil, status: nil, created: nil)
      super(id)
      @type = type
      @account_request_id = account_request_id
      @tags = tags
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @content = content
      @content_type = content_type

      if @content_type
        @content = "data:#{content_type};base64,#{Base64.encode64(content)}"
        @content_type = nil
      end
    end

    # # Create IndividualAccountAttachments
    #
    # Send a list of IndividualAccountAttachment objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - attachments [list of IndividualAccountAttachment objects]: list of IndividualAccountAttachment objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IndividualAccountAttachment objects with updated attributes
    def self.create(attachments, user: nil)
      StarkInfra::Utils::Rest.post(entities: attachments, user: user, **resource)
    end

    # # Retrieve a specific IndividualAccountAttachment
    #
    # Receive a single IndividualAccountAttachment object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IndividualAccountAttachment object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IndividualAccountAttachments
    #
    # Receive a generator of IndividualAccountAttachment objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'created'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IndividualAccountAttachment objects with updated attributes
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

    # # Retrieve paged IndividualAccountAttachments
    #
    # Receive a list of up to 100 IndividualAccountAttachment objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'created'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IndividualAccountAttachment objects with updated attributes
    # - cursor to retrieve the next page of IndividualAccountAttachment objects
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

    # # Cancel an IndividualAccountAttachment entity
    #
    # Cancel an IndividualAccountAttachment entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: IndividualAccountAttachment unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled IndividualAccountAttachment object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'IndividualAccountAttachment',
        resource_maker: proc { |json|
          IndividualAccountAttachment.new(
            type: json['type'],
            content: json['content'],
            content_type: json['content_type'],
            account_request_id: json['account_request_id'],
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
