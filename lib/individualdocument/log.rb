# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('IndividualDocument')
require_relative('../utils/resource')

module StarkInfra
  class IndividualDocument
    # # IndividualDocument::Log object
    #
    # Every time an IndividualDocument entity is updated, a corresponding IndividualDocument::Log is generated for the entity.
    # This Log is never generated by the user, but it can be retrieved to check additional information on the IndividualDocument.
    #
    # ## Attributes (return-only):
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - document [IndividualDocument]: IndividualDocument entity to which the log refers to.
    # - errors [list of strings]: list of errors linked to this IndividualDocument event
    # - type [string]: type of the IndividualDocument event which triggered the log creation. ex: 'approved', 'canceled', 'confirmed', 'denied', 'reversed', 'voided'.
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Log < StarkInfra::Utils::Resource
      attr_reader :id, :document, :errors, :type, :created
      def initialize(id: nil, document: nil, errors: nil, type: nil, created: nil)
        super(id)
        @document = document
        @errors = errors
        @type = type
        @created = StarkInfra::Utils::Checks.check_datetime(created)
      end

      # # Retrieve a specific IndividualDocument::Log
      #
      # Receive a single IndividualDocument::Log object previously created by the Stark Infra API by passing its id
      #
      # ## Parameters (required):
      # - id [string]: object unique id. ex: '5656565656565656'
      #
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - IndividualDocument::Log object with updated attributes
      def self.get(id, user: nil)
        StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
      end

      # # Retrieve IndividualDocument::Logs
      #
      # Receive a generator of IndividualDocument::Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ['created', 'canceled', 'processing', 'failed', 'success']
      # - document_ids [list of strings, default nil]: list of IndividualDocument ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - generator of IndividualDocument::Log objects with updated attributes
      def self.query(ids: nil, limit: nil, after: nil, before: nil, types: nil, document_ids: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_stream(
          ids: ids,
          limit: limit,
          after: after,
          before: before,
          types: types,
          document_ids: document_ids,
          user: user,
          **resource
        )
      end

      # # Retrieve paged IndividualDocument::Logs
      #
      # Receive a list of up to 100 IndividualDocument::Log objects previously created in the Stark Infra API and the cursor to the next page.
      # Use this function instead of query if you want to manually page your documents.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: ['created', 'canceled', 'processing', 'failed', 'success']
      # - document_ids [list of strings, default nil]: list of document ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - list of IndividualDocument::Log objects with updated attributes
      # - cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, ids: nil, limit: nil, after: nil, before: nil, types: nil, document_ids: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_page(
          cursor: cursor,
          limit: limit,
          after: after,
          before: before,
          types: types,
          document_ids: document_ids,
          user: user,
          **resource
        )
      end

      def self.resource
        request_maker = StarkInfra::IndividualDocument.resource[:resource_maker]
        {
          resource_name: 'IndividualDocumentLog',
          resource_maker: proc { |json|
            Log.new(
              id: json['id'],
              document: StarkInfra::Utils::API.from_api_json(request_maker, json['document']),
              errors: json['errors'],
              type: json['type'],
              created: json['created']
            )
          }
        }
      end
    end
  end
end
