# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # PixPullSubscription object
  #
  # A PixPullSubscription is a recurring Pix debit authorization. It defines the frequency, amount,
  # and required payer authorizations for a series of Pix debits to be pulled from the sender by
  # the receiver. Each cycle of an active subscription is triggered by a PixPullRequest whose
  # subscription_id references the subscription's id.
  #
  # When you initialize a PixPullSubscription, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - bacen_id [string]: Central Bank's unique recurrency id. Identifies the subscription in the Pix infrastructure.
  # - external_id [string]: url safe string that must be unique among all your Pix Pull Subscriptions. Used for idempotency. ex: 'my-internal-id-123456'
  # - installment_start [DateTime or string]: start datetime of settlements allowed for this subscription. ex: '2020-10-28T17:59:26.249976+00:00'
  # - interval [string]: cycle definition. Options: 'week', 'month', 'quarter', 'semester', 'year'
  # - receiver_name [string]: receiver's full name. ex: 'Edward Stark'
  # - receiver_tax_id [string]: receiver's tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - sender_account_number [string]: sender's bank account number. Use '-' before the verifier digit. ex: '876543-2'
  # - sender_bank_code [string]: sender's bank institution code in Brazil. ex: '20018183'
  # - sender_branch_code [string]: sender's bank account branch code. Use '-' in case there is a verifier digit. ex: '1357-9'
  # - sender_tax_id [string]: sender's tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - type [string]: subscription journey type. Options: 'push', 'qrcode', 'qrcodeAndPayment', 'paymentAndOrQrcode'
  #
  # ## Parameters (conditionally-required):
  # - amount [integer, default nil]: amount in cents charged every cycle. Required if the subscription has a fixed amount. ex: 1234 (= R$ 12.34)
  # - amount_min_limit [integer, default nil]: floor value for the maximum amount the sender can set when approving. Required if the subscription has a variable amount. ex: 1234 (= R$ 12.34)
  #
  # ## Parameters (optional):
  # - description [string, default nil]: additional information delivered to the sender. ex: 'Payment for service #1234'
  # - due [DateTime or string, default nil]: due date for the sender's answer (approval or denial). ex: '2020-10-28T17:59:26.249976+00:00'
  # - installment_end [DateTime or string, default nil]: end datetime of settlements allowed for this subscription. ex: '2020-10-28T17:59:26.249976+00:00'
  # - receiver_bank_code [string, default nil]: receiver's bank institution code. Defaults to the workspace's primary institution when omitted. ex: '20018183'
  # - reference_code [string, default nil]: commercial-relation identifier. May be a contract number, order id, or client code. ex: 'contract-123'
  # - pull_retry_limit [integer, default nil]: max number of retries the receiver may issue for a single failed pull cycle. ex: 3
  # - sender_city_code [string, default nil]: IBGE code of the payer's city. ex: '3550308'
  # - sender_final_name [string, default nil]: final sender name when the sender differs from the originating institution. ex: 'Edward Stark'
  # - sender_final_tax_id [string, default nil]: final sender tax ID. Same format rules as sender_tax_id. ex: '01234567890' or '20.018.183/0001-80'
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['employees', 'monthly']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixPullSubscription is created. ex: '5656565656565656'
  # - status [string]: current PixPullSubscription status. Options: 'created', 'pending', 'failed', 'denied', 'approved', 'active', 'expired', 'canceled'
  # - flow [string]: direction of money flow. Options: 'in', 'out'
  # - created [DateTime]: creation datetime for the PixPullSubscription. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixPullSubscription. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixPullSubscription < StarkCore::Utils::Resource
    attr_reader :bacen_id, :external_id, :installment_start, :interval, :receiver_name, :receiver_tax_id,
                :sender_account_number, :sender_bank_code, :sender_branch_code, :sender_tax_id, :type,
                :amount, :amount_min_limit, :description, :due, :installment_end, :receiver_bank_code,
                :reference_code, :pull_retry_limit, :sender_city_code, :sender_final_name, :sender_final_tax_id,
                :tags, :id, :status, :flow, :created, :updated
    def initialize(
      bacen_id:, external_id:, installment_start:, interval:, receiver_name:, receiver_tax_id:,
      sender_account_number:, sender_bank_code:, sender_branch_code:, sender_tax_id:, type:,
      amount: nil, amount_min_limit: nil, description: nil, due: nil, installment_end: nil,
      receiver_bank_code: nil, reference_code: nil, pull_retry_limit: nil, sender_city_code: nil,
      sender_final_name: nil, sender_final_tax_id: nil, tags: nil, id: nil, status: nil, flow: nil,
      created: nil, updated: nil
    )
      super(id)
      @bacen_id = bacen_id
      @external_id = external_id
      @installment_start = StarkCore::Utils::Checks.check_datetime(installment_start)
      @interval = interval
      @receiver_name = receiver_name
      @receiver_tax_id = receiver_tax_id
      @sender_account_number = sender_account_number
      @sender_bank_code = sender_bank_code
      @sender_branch_code = sender_branch_code
      @sender_tax_id = sender_tax_id
      @type = type
      @amount = amount
      @amount_min_limit = amount_min_limit
      @description = description
      @due = StarkCore::Utils::Checks.check_datetime(due == '' ? nil : due)
      @installment_end = StarkCore::Utils::Checks.check_datetime(installment_end == '' ? nil : installment_end)
      @receiver_bank_code = receiver_bank_code
      @reference_code = reference_code
      @pull_retry_limit = pull_retry_limit
      @sender_city_code = sender_city_code
      @sender_final_name = sender_final_name
      @sender_final_tax_id = sender_final_tax_id
      @tags = tags
      @status = status
      @flow = flow
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create PixPullSubscriptions
    #
    # Send a list of PixPullSubscription objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - subscriptions [list of PixPullSubscription objects]: list of PixPullSubscription objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixPullSubscription objects with updated attributes
    def self.create(subscriptions, user: nil)
      StarkInfra::Utils::Rest.post(entities: subscriptions, user: user, **resource)
    end

    # # Retrieve a specific PixPullSubscription
    #
    # Receive a single PixPullSubscription object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixPullSubscription object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixPullSubscriptions
    #
    # Receive a generator of PixPullSubscription objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['active', 'canceled']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['employees', 'monthly']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixPullSubscription objects with updated attributes
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

    # # Retrieve paged PixPullSubscriptions
    #
    # Receive a list of up to 100 PixPullSubscription objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your subscriptions.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['active', 'canceled']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['employees', 'monthly']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixPullSubscription objects with updated attributes
    # - cursor to retrieve the next page of PixPullSubscription objects
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

    # # Update PixPullSubscriptions
    #
    # A Pix Subscription can be patched for three distinct purposes - to update, confirm or deny it.
    # As the receiver, you can approve or deny the subscription if the subscription type is 'subscriptionAndPayment'.
    # As the sender, you can confirm or deny a delivered subscription.
    #
    # ## Parameters (required):
    # - id [string]: PixPullSubscription unique id. ex: '5656565656565656'
    # - patch_data [hash]: hash containing the attributes to be updated. ex: { status: 'approved', sender_city_code: '3550308' }
    #     ## Parameters (required):
    #     - status [string]: new status of the Pix Subscription.
    #     ## Parameters (conditionally-required):
    #     - sender_city_code [string]: IBGE code of the payer's city. Required if you are confirming the subscription.
    #     - reason [string]: reason why the Pix Subscription is being patched. Options: 'accountClosed', 'accountBlocked', 'invalidBranchCode', 'notRecognizedBySender', 'userRejected', 'notOffered'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - updated PixPullSubscription object
    def self.update(id, patch_data: nil, user: nil)
      patch_data ||= {}
      StarkInfra::Utils::Rest.patch_id(id: id, user: user, **patch_data, **resource)
    end

    # # Cancel a PixPullSubscription entity
    #
    # Cancel a PixPullSubscription entity previously created in the Stark Infra API.
    # The reason is sent as a query parameter, not in the request body.
    #
    # ## Parameters (required):
    # - id [string]: PixPullSubscription unique id. ex: '5656565656565656'
    # - reason [string]: reason for the cancellation. As receiver: 'accountClosed', 'receiverOrganizationClosed', 'receiverInternalError', 'fraud', 'receiverUserRequested'. As sender: 'accountClosed', 'senderDeceased', 'fraud', 'senderUserRequested'.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled PixPullSubscription object
    def self.cancel(id, reason:, user: nil)
      response = StarkInfra::Utils::Rest.delete_raw(
        path: "/pix-pull-subscription/#{id}",
        query: { reason: reason },
        user: user,
        raiseException: true
      )
      maker = resource[:resource_maker]
      StarkCore::Utils::API.from_api_json(maker, response.json['subscription'])
    end

    def self.resource
      {
        resource_name: 'PixPullSubscription',
        resource_maker: proc { |json|
          PixPullSubscription.new(
            id: json['id'],
            bacen_id: json['bacen_id'],
            external_id: json['external_id'],
            installment_start: json['installment_start'],
            interval: json['interval'],
            receiver_name: json['receiver_name'],
            receiver_tax_id: json['receiver_tax_id'],
            sender_account_number: json['sender_account_number'],
            sender_bank_code: json['sender_bank_code'],
            sender_branch_code: json['sender_branch_code'],
            sender_tax_id: json['sender_tax_id'],
            type: json['type'],
            amount: json['amount'],
            amount_min_limit: json['amount_min_limit'],
            description: json['description'],
            due: json['due'],
            installment_end: json['installment_end'],
            receiver_bank_code: json['receiver_bank_code'],
            reference_code: json['reference_code'],
            pull_retry_limit: json['pull_retry_limit'],
            sender_city_code: json['sender_city_code'],
            sender_final_name: json['sender_final_name'],
            sender_final_tax_id: json['sender_final_tax_id'],
            tags: json['tags'],
            status: json['status'],
            flow: json['flow'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
