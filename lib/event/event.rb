# frozen_string_literal: true

require('json')
require('starkbank-ecdsa')
require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/cache')
require_relative('../error')
require_relative('../pixrequest/log')
require_relative('../pixreversal/log')
require_relative('../utils/parse')


module StarkInfra
  # # Webhook Event object
  #
  # An Event is the notification received from the subscription to the Webhook.
  # Events cannot be created, but may be retrieved from the Stark Infra API to
  # list all generated updates on entities.
  #
  # ## Attributes:
  # - id [string]: unique id returned when the event is created. ex: '5656565656565656'
  # - log [Log]: a Log object from one the subscription services (TransferLog, InvoiceLog, BoletoLog, BoletoPaymentlog or UtilityPaymentLog)
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
        'pix-request.in': StarkInfra::PixRequest::Log.resource,
        'pix-request.out': StarkInfra::PixRequest::Log.resource,
        'pix-reversal.in': StarkInfra::PixReversal::Log.resource,
        'pix-reversal.out': StarkInfra::PixReversal::Log.resource,
      }[subscription.to_sym]

      @log = log
      @log = StarkInfra::Utils::API.from_api_json(resource[:resource_maker], log) unless resource.nil?
    end

    # # Create single notification Event from a content string
    #
    # Create a single Event object received from event listening at subscribed user endpoint.
    # If the provided digital signature does not check out with the StarkInfra public key, a
    # starkinfra.exception.InvalidSignatureException will be raised.
    #
    # ## Parameters (required):
    # - content [string]: response content from request received at user endpoint (not parsed)
    # - signature [string]: base-64 digital signature received at response header 'Digital-Signature'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - Parsed Event object
    def self.parse(content:, signature:, user: nil)
      return StarkInfra::Utils::Parse.parse_and_verify(content: content, signature: signature, user: user, resource: resource, key: 'event')
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

