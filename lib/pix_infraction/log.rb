# frozen_string_literal: true

require('starkcore')
require_relative('pix_infraction')
require_relative('../utils/rest')

module StarkInfra
  class PixInfraction
    # # PixInfraction::Log object
    #
    # Every time a PixInfraction entity is modified, a corresponding PixInfraction::Log
    # is generated for the entity. This log is never generated by the
    # user.
    #
    # ## Attributes (return-only):
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - infraction [PixInfraction]: PixInfraction entity to which the log refers to.
    # - type [string]: type of the PixInfraction event which triggered the log creation. Options: 'created', 'failed', 'delivering', 'delivered', 'closed', 'canceled'
    # - errors [list of strings]: list of errors linked to this PixInfraction event.
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Log < StarkCore::Utils::Resource
      attr_reader :id, :created, :type, :errors, :infraction
      def initialize(id:, created:, type:, errors:, infraction:)
        super(id)
        @infraction = infraction
        @type = type
        @errors = errors
        @created = StarkCore::Utils::Checks.check_datetime(created)
      end

      # # Retrieve a specific PixInfraction::Log
      #
      # Receive a single PixInfraction::Log object previously created by the Stark Infra API by passing its id
      #
      # ## Parameters (required):
      # - id [string]: object unique id. ex: '5656565656565656'
      #
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - PixInfraction::Log object with updated attributes
      def self.get(id, user: nil)
        StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
      end

      # # Retrieve PixInfraction::Logs
      #
      # Receive a generator of PixInfraction::Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter retrieved objects by their types. Options: 'created', 'failed', 'delivering', 'delivered', 'closed', 'canceled'
      # - infraction_ids [list of strings, default nil]: list of PixInfraction ids to filter retrieved objects. ex: %w[5656565656565656 4545454545454545]
      # - ids [list of strings, default nil]: Log ids to filter PixInfraction Logs. ex: ['5656565656565656']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - list of PixInfraction::Log objects with updated attributes
      def self.query(ids: nil, limit: nil, after: nil, before: nil, types: nil, infraction_ids: nil, user: nil)
        after = StarkCore::Utils::Checks.check_date(after)
        before = StarkCore::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_stream(
          ids: ids,
          limit: limit,
          after: after,
          before: before,
          types: types,
          infraction_ids: infraction_ids,
          user: user,
          **resource
        )
      end

      # # Retrieve paged PixInfraction::Logs
      #
      # Receive a list of up to 100 PixInfraction::Log objects previously created in the Stark Infra API and the cursor to the next page.
      # Use this function instead of query if you want to manually page your infractions.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter retrieved objects by their types. Options: 'created', 'failed', 'delivering', 'delivered', 'closed', 'canceled'
      # - infraction_ids [list of strings, default nil]: list of PixInfraction ids to filter retrieved objects. ex: %w[5656565656565656 4545454545454545]
      # - ids [list of strings, default nil]: Log ids to filter PixInfraction Logs. ex: ['5656565656565656']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - list of PixInfraction::Log objects with updated attributes
      # - Cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, ids: nil, limit: nil, after: nil, before: nil, types: nil, infraction_ids: nil, user: nil)
        after = StarkCore::Utils::Checks.check_date(after)
        before = StarkCore::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_page(
          cursor: cursor,
          ids: ids,
          limit: limit,
          after: after,
          before: before,
          types: types,
          infraction_ids: infraction_ids,
          user: user,
          **resource
        )
      end

      def self.resource
        infraction_maker = StarkInfra::PixInfraction.resource[:resource_maker]
        {
          resource_name: 'PixInfractionLog',
          resource_maker: proc { |json|
            Log.new(
              id: json['id'],
              infraction: StarkCore::Utils::API.from_api_json(infraction_maker, json['infraction']),
              type: json['type'],
              errors: json['errors'],
              created: json['created'],
            )
          }
        }
      end
    end
  end
end
