# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/parse')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # IndividualDocument object
  #
  # Individual documents are images containing either side of a document or a selfie
  # to be used in a matching validation. When created, they must be attached to an individual
  # identity to be used for its validation.
  #
  # When you initialize a IndividualDocument, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - type [string]: type of the IndividualDocument. Options: "drivers-license-front", "drivers-license-back", "identity-front", "identity-back" or "selfie"
  # - content [string]: Base64 data url of the picture. ex: data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAASABIAAD...
  # - content_type [string]: content MIME type. This parameter is required as input only. ex: "image/png" or "image/jpeg"
  # - identity_id [string]: Unique id of IndividualIdentity. ex: "5656565656565656"
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for reference when searching for IndividualDocuments. ex: ["employees", "monthly"]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the IndividualDocument is created. ex: "5656565656565656"
  # - status [string]: current status of the IndividualDocument. Options: "created", "canceled", "processing", "failed", "success"
  # - created [DateTime]: creation datetime for the IndividualDocument. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IndividualDocument < StarkInfra::Utils::Resource
    attr_reader :type, :content, :content_type, :identity_id, :tags, :id, :status, :created 
    def initialize(type:, content:, content_type:, identity_id:, tags: nil, id: nil, status: nil, created: nil)
      super(id)
      @type = type
      @identity_id = identity_id
      @tags = tags
      @status = status
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @content = content
      @content_type = content_type

      if @content_type
        @content = "data:#{content_type};base64,#{Base64.encode64(content)}"
        @content_type = nil
      end
    end

    # # Create IndividualDocuments
    #
    # Send a list of IndividualDocument objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - documents [list of IndividualDocument objects]: list of IndividualDocument objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IndividualDocument object with updated attributes
    def self.create(documents, user: nil)
      StarkInfra::Utils::Rest.post(entities: documents, user: user, **resource)
    end

    # # Retrieve a specific IndividualDocument
    #
    # Receive a single IndividualDocument object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: "5656565656565656"
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - IndividualDocument object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IndividualDocuments
    #
    # Receive a generator of IndividualDocument objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. Options: ["created", "canceled", "processing", "failed", "success"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IndividualDocument objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
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

    # # Retrieve paged IndividualDocuments
    #
    # Receive a list of up to 100 IndividualDocument objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. Options: ["created", "canceled", "processing", "failed", "success"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IndividualDocument objects with updated attributes
    # - cursor to retrieve the next page of IndividualDocument objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
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
        resource_name: 'IndividualDocument',
        resource_maker: proc { |json|
          IndividualDocument.new(
            type: json['type'],
            content: json['content'],
            content_type: json['content_type'],
            identity_id: json['identity_id'],
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
