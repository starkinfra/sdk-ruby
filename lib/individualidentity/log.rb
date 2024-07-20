# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('IndividualIdentity')

module StarkInfra
  class IndividualIdentity
    # # IndividualIdentity::Log object
    #
    # Every time an IndividualIdentity entity is updated, a corresponding IndividualIdentity::Log is generated for the entity.
    # This Log is never generated by the user, but it can be retrieved to check additional information on the IndividualIdentity.
    #
    # ## Attributes (return-only):
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - identity [IndividualIdentity]: IndividualIdentity entity to which the log refers to.
    # - errors [list of strings]: list of errors linked to this IndividualIdentity event
    # - type [string]: type of the IndividualIdentity event which triggered the log creation. ex: "created", "canceled", "processing", "failed", "success"
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Log < StarkCore::Utils::Resource
      attr_reader :id, :identity, :errors, :type, :created
      def initialize(id: nil, identity: nil, errors: nil, type: nil, created: nil)
        super(id)
        @identity = identity
        @errors = errors
        @type = type
        @created = StarkCore::Utils::Checks.check_datetime(created)
      end

      # # Retrieve a specific IndividualIdentity::Log
      #
      # Receive a single IndividualIdentity::Log object previously created by the Stark Infra API by passing its id
      #
      # ## Parameters (required):
      # - id [string]: object unique id. ex: '5656565656565656'
      #
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - IndividualIdentity::Log object with updated attributes
      def self.get(id, user: nil)
        StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
      end

      # # Retrieve IndividualIdentity::Logs
      #
      # Receive a generator of IndividualIdentity::Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: "created", "canceled", "processing", "failed", "success"
      # - identity_ids [list of strings, default nil]: list of identity ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - generator of IndividualIdentity::Log objects with updated attributes
      def self.query(limit: nil, after: nil, before: nil, types: nil, identity_ids: nil, user: nil)
        after = StarkCore::Utils::Checks.check_date(after)
        before = StarkCore::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_stream(
          limit: limit,
          after: after,
          before: before,
          types: types,
          identity_ids: identity_ids,
          user: user,
          **resource
        )
      end

      # # Retrieve paged IndividualIdentity::Logs
      #
      # Receive a list of up to 100 IndividualIdentity::Log objects previously created in the Stark Infra API and the cursor to the next page.
      # Use this function instead of query if you want to manually page your identities.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter for log event types. ex: "created", "canceled", "processing", "failed", "success"
      # - identity_ids [list of strings, default nil]: list of identity ids to filter logs. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      #
      # ## Return:
      # - list of IndividualIdentity::Log objects with updated attributes
      # - cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, limit: nil, after: nil, before: nil, types: nil, identity_ids: nil, user: nil)
        after = StarkCore::Utils::Checks.check_date(after)
        before = StarkCore::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_page(
          cursor: cursor,
          limit: limit,
          after: after,
          before: before,
          types: types,
          identity_ids: identity_ids,
          user: user,
          **resource
        )
      end

      def self.resource
        request_maker = StarkInfra::IndividualIdentity.resource[:resource_maker]
        {
          resource_name: 'IndividualIdentityLog',
          resource_maker: proc { |json|
            Log.new(
              id: json['id'],
              identity: StarkCore::Utils::API.from_api_json(request_maker, json['identity']),
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
