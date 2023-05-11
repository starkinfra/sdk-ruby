# frozen_string_literal: true

require('json')
require('starkbank-ecdsa')
require_relative('../error')
require_relative('../utils/rest')
require_relative('../utils/parse')
require_relative('../utils/cache')
require_relative('../utils/checks')
require_relative('../utils/resource')
require_relative('../pixrequest/log')
require_relative('../pixreversal/log')

module StarkInfra
  # # Webhook Event object
  #
  # An Event is the notification received from the subscription to the Webhook.
  # Events cannot be created, but may be retrieved from the Stark Infra API to
  # list all generated updates on entities.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the event is created. ex: '5656565656565656'
  # - log [Log]: a Log object from one the subscription services (PixRequestLog, PixReversalLog)
  # - created [DateTime]: creation datetime for the notification event. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - is_delivered [bool]: true if the event has been successfully delivered to the user url. ex: False
  # - workspace_id [string]: ID of the Workspace that generated this event. Mostly used when multiple Workspaces have Webhooks registered to the same endpoint. ex: '4545454545454545'
  # - subscription [string]: service that triggered this event. ex: 'pix-request.in', 'pix-request.out'
  class Event < StarkInfra::Utils::Resource
    attr_reader :id, :log, :created, :is_delivered, :workspace_id, :subscription
    def initialize(id:, log:, created:, is_delivered:, workspace_id:, subscription:)
      super(id)
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @is_delivered = is_delivered
      @workspace_id = workspace_id
      @subscription = subscription

      resource = {
        'pix-key': StarkInfra::PixKey::Log.resource,
        'pix-claim': StarkInfra::PixClaim::Log.resource,
        'pix-chargeback': StarkInfra::PixChargeback::Log.resource,
        'pix-infraction': StarkInfra::PixInfraction::Log.resource,
        'pix-request.in': StarkInfra::PixRequest::Log.resource,
        'pix-request.out': StarkInfra::PixRequest::Log.resource,
        'pix-reversal.in': StarkInfra::PixReversal::Log.resource,
        'pix-reversal.out': StarkInfra::PixReversal::Log.resource,
        'issuing-card': StarkInfra::IssuingCard::Log.resource,
        'issuing-invoice': StarkInfra::IssuingInvoice::Log.resource,
        'issuing-purchase': StarkInfra::IssuingPurchase::Log.resource,
        'credit-note': StarkInfra::CreditNote::Log.resource,
      }[subscription.to_sym]

      @log = log
      @log = StarkInfra::Utils::API.from_api_json(resource[:resource_maker], log) unless resource.nil?
    end

    # # Retrieve a specific notification Event
    #
    # Receive a single notification Event object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - Event object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve notification Events
    #
    # Receive a generator of notification Event objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - is_delivered [bool, default nil]: bool to filter successfully delivered events. ex: true or false
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of Event objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, is_delivered: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        user: user,
        limit: limit,
        after: after,
        before: before,
        is_delivered: is_delivered,
        **resource
      )
    end

    # # Retrieve paged Events
    #
    # Receive a list of up to 100 Event objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - is_delivered [bool, default nil]: bool to filter successfully delivered events. ex: true or false
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of Event objects with updated attributes
    # - cursor to retrieve the next page of Event objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, is_delivered: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        is_delivered: is_delivered,
        user: user,
        **resource
      )
    end

    # # Delete a notification Event
    #
    # Delete a notification Event entity previously created in the Stark Infra API by its ID
    #
    # ## Parameters (required):
    # - id [string]: Event unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - deleted Event object
    def self.delete(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    # # Update notification Event entity
    #
    # Update a notification Event by its id.
    # If is_delivered is true, the event will no longer be returned on queries with is_delivered=false.
    #
    # ## Parameters (required):
    # - id [list of strings]: Event unique ids. ex: '5656565656565656'
    # - is_delivered [bool]: If true and event hasn't been delivered already, event will be set as delivered. ex: true
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - target Event with updated attributes
    def self.update(id, is_delivered:, user: nil)
      StarkInfra::Utils::Rest.patch_id(id: id, user: user, is_delivered: is_delivered, **resource)
    end

    # # Create single notification Event from a content string
    #
    # Create a single Event object received from event listening at subscribed user endpoint.
    # If the provided digital signature does not check out with the StarkInfra public key, a
    # StarkInfra.Error.InvalidSignatureError will be raised.
    #
    # ## Parameters (required):
    # - content [string]: response content from request received at user endpoint (not parsed)
    # - signature [string]: base-64 digital signature received at response header 'Digital-Signature'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - Parsed Event object
    def self.parse(content:, signature:, user: nil)
      StarkInfra::Utils::Parse.parse_and_verify(
        content: content,
        signature: signature,
        user: user,
        resource: resource,
        key: 'event'
      )
    end

    class << self
      private

      def resource
        {
          resource_name: 'Event',
          resource_maker: proc { |json|
            Event.new(
              id: json['id'],
              log: json['log'],
              created: json['created'],
              is_delivered: json['is_delivered'],
              workspace_id: json['workspace_id'],
              subscription: json['subscription']
            )
          }
        }
      end
    end
  end
end
