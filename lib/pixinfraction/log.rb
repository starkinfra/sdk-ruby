# frozen_string_literal: true

require_relative('pixinfraction')
require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  class PixInfraction
    # # PixInfraction::Log object
    #
    # Every time a PixInfraction entity is modified, a corresponding PixInfraction::Log
    # is generated for the entity. This log is never generated by the
    # user.
    #
    # ## Attributes:
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - type [string]: type of the PixInfraction event which triggered the log creation. Options: 'created', 'failed', 'delivering', 'delivered', 'closed', 'canceled'
    # - errors [list of strings]: list of errors linked to this PixInfraction event.
    # - infraction [PixInfraction]: PixInfraction entity to which the log refers to.
    class Log < StarkInfra::Utils::Resource
      attr_reader :id, :created, :type, :errors, :infraction
      def initialize(id:, created:, type:, errors:, infraction:)
        super(id)
        @created = StarkInfra::Utils::Checks.check_datetime(created)
        @type = type
        @errors = errors
        @infraction = infraction
      end

      # # Retrieve a specific Log
      #
      # Receive a single Log object previously created by the Stark Infra API by passing its id
      #
      # ## Parameters (required):
      # - id [string]: object unique id. ex: '5656565656565656'
      #
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - Log object with updated attributes
      def self.get(id, user: nil)
        StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
      end

      # # Retrieve Logs
      #
      # Receive a generator of Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - ids [list of strings, default nil]: Log ids to filter PixInfraction Logs. ex: ['5656565656565656']
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter retrieved objects by their types. Options: 'created', 'failed', 'delivering', 'delivered', 'closed', 'canceled'
      # - infraction_ids [list of strings, default nil]: list of PixInfraction ids to filter retrieved objects. ex: %w[5656565656565656 4545454545454545]
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - list of Log objects with updated attributes
      def self.query(ids: nil, limit: nil, after: nil, before: nil, types: nil, infraction_ids: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
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

      # # Retrieve paged Logs
      #
      # Receive a list of up to 100 Log objects previously created in the Stark Infra API and the cursor to the next page.
      # Use this function instead of query if you want to manually page your infractions.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - ids [list of strings, default nil]: Log ids to filter PixInfraction Logs. ex: ['5656565656565656']
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter retrieved objects by their types. Options: 'created', 'failed', 'delivering', 'delivered', 'closed', 'canceled'
      # - infraction_ids [list of strings, default nil]: list of PixInfraction ids to filter retrieved objects. ex: %w[5656565656565656 4545454545454545]
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - list of Log objects with updated attributes
      # - Cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, ids: nil, limit: nil, after: nil, before: nil, types: nil, infraction_ids: nil, user: nil)
        after = StarkInfra::Utils::Checks.check_date(after)
        before = StarkInfra::Utils::Checks.check_date(before)
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
              created: json['created'],
              type: json['type'],
              errors: json['errors'],
              infraction: StarkInfra::Utils::API.from_api_json(infraction_maker, json['infraction'])
            )
          }
        }
      end
    end
  end
end
