# frozen_string_literal: true

require('starkcore')
require_relative('credit_note')
require_relative('../utils/rest')

module StarkInfra
  class CreditNote
    # # CreditNote::Log object
    #
    # Every time a CreditNote entity is modified, a corresponding CreditNote::Log
    # is generated for the entity. This log is never generated by the
    # user.
    #
    # ## Attributes (return-only):
    # - id [string]: unique id returned when the log is created. ex: '5656565656565656'
    # - note [CreditNote]: CreditNote entity to which the log refers to.
    # - errors [list of strings]: list of errors linked to this CreditNote event.
    # - type [string]: type of the CreditNote event which triggered the log creation. Options: 'canceled', 'created', 'expired', 'failed', 'refunded', 'registered', 'sending', 'sent', 'signed', 'success'
    # - created [DateTime]: creation datetime for the log. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Log < StarkCore::Utils::Resource
      attr_reader :id, :created, :type, :errors, :note
      def initialize(id:, created:, type:, errors:, note:)
        super(id)
        @note = note
        @errors = errors
        @type = type
        @created = StarkCore::Utils::Checks.check_datetime(created)
      end

      # # Retrieve a specific CreditNote::Log
      #
      # Receive a single CreditNote::Log object previously created by the Stark Infra API by passing its id
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

      # # Retrieve CreditNote::Logs
      #
      # Receive a generator of CreditNote::Log objects previously created in the Stark Infra API
      #
      # ## Parameters (optional):
      # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter retrieved objects by types. Options: 'canceled', 'created', 'expired', 'failed', 'refunded', 'registered', 'sending', 'sent', 'signed', 'success'
      # - note_ids [list of strings, default nil]: list of CreditNote ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - list of Log objects with updated attributes
      def self.query(limit: nil, after: nil, before: nil, types: nil, note_ids: nil, user: nil)
        after = StarkCore::Utils::Checks.check_date(after)
        before = StarkCore::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_stream(
          limit: limit,
          after: after,
          before: before,
          types: types,
          note_ids: note_ids,
          user: user,
          **resource
        )
      end

      # # Retrieve paged CreditNote::Logs
      #
      # Receive a list of up to 100 CreditNote::Log objects previously created in the Stark Infra API and the cursor to the next page.
      # Use this function instead of query if you want to manually page your notes.
      #
      # ## Parameters (optional):
      # - cursor [string, default nil]: cursor returned on the previous page function call
      # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
      # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
      # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
      # - types [list of strings, default nil]: filter retrieved objects by types. Options: 'canceled', 'created', 'expired', 'failed', 'refunded', 'registered', 'sending', 'sent', 'signed', 'success'
      # - note_ids [list of strings, default nil]: list of CreditNote ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
      #
      # ## Return:
      # - list of Log objects with updated attributes
      # - Cursor to retrieve the next page of Log objects
      def self.page(cursor: nil, limit: nil, after: nil, before: nil, types: nil, note_ids: nil, user: nil)
        after = StarkCore::Utils::Checks.check_date(after)
        before = StarkCore::Utils::Checks.check_date(before)
        StarkInfra::Utils::Rest.get_page(
          cursor: cursor,
          limit: limit,
          after: after,
          before: before,
          types: types,
          note_ids: note_ids,
          user: user,
          **resource
        )
      end

      def self.resource
        note_maker = StarkInfra::CreditNote.resource[:resource_maker]
        {
          resource_name: 'CreditNoteLog',
          resource_maker: proc { |json|
            Log.new(
              id: json['id'],
              note: StarkCore::Utils::API.from_api_json(note_maker, json['note']),
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
