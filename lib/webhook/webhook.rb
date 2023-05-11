# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # Webhook object
  #
  # A Webhook is used to subscribe to notification events on a user-selected endpoint.
  # Currently available services for subscription are contract, credit-note, signer, issuing-card, issuing-invoice, issuing-purchase, pix-request.in, pix-request.out, pix-reversal.in, pix-reversal.out, pix-claim, pix-key, pix-chargeback, pix-infraction.
  #
  # ## Parameters (required):
  # - url [string]: URL that will be notified when an event occurs.
  # - subscriptions [list of strings]: list of any non-empty combination of the available services. ex: ['contract', 'credit-note', 'signer', 'issuing-card', 'issuing-invoice', 'issuing-purchase', 'pix-request.in', 'pix-request.out', 'pix-reversal.in', 'pix-reversal.out', 'pix-claim', 'pix-key', 'pix-chargeback', 'pix-infraction']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the webhook is created. ex: '5656565656565656'
  class Webhook < StarkInfra::Utils::Resource
    attr_reader :url, :subscriptions, :id
    def initialize(url:, subscriptions:, id: nil)
      super(id)
      @url = url
      @subscriptions = subscriptions
    end

    # # Create Webhook
    #
    # Send a single Webhook for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - webhook [Webhook object]: Webhook to be created to receive Events. ex: Webhook.new()
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - Webhook object with updated attributes
    def self.create(webhook, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: webhook, user: user, **resource)
    end

    # # Retrieve a specific Webhook
    #
    # Receive a single Webhook object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - Webhook object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve Webhooks
    #
    # Receive a generator of Webhook objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of Webhook objects with updated attributes
    def self.query(limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(user: user, limit: limit, **resource)
    end

    # # Retrieve paged Webhooks
    #
    # Receive a list of up to 100 Webhook objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of Webhook objects with updated attributes
    # - cursor to retrieve the next page of Webhook objects
    def self.page(cursor: nil, limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        user: user,
        **resource
      )
    end

    # # Delete a Webhook entity
    #
    # Delete a Webhook entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: Webhook unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - deleted Webhook object
    def self.delete(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'Webhook',
        resource_maker: proc { |json|
          Webhook.new(
            id: json['id'],
            url: json['url'],
            subscriptions: json['subscriptions']
          )
        }
      }
    end
  end
end
