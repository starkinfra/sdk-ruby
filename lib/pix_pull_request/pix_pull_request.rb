# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # PixPullRequest object
  #
  # A PixPullRequest is a command sent to the payer's bank to trigger the automatic debit
  # linked to an active PixPullSubscription. It confirms the receiver's intent to collect the
  # agreed amount within the current billing cycle and initiates the settlement process
  # through the Pix infrastructure. Each pull request references a parent subscription via
  # subscription_id.
  #
  # When you initialize a PixPullRequest, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - amount [integer]: amount to be charged in cents. ex: 11234 (= R$ 112.34)
  # - due [DateTime or string]: due date for answering with an approval or denial. ex: '2020-10-28T17:59:26.249976+00:00'
  # - end_to_end_id [string]: Central Bank's unique transaction id. ex: 'E00002649202201172211u34srod19le'
  # - receiver_account_number [string]: receiver's bank account number. Use '-' before the verifier digit. ex: '876543-2'
  # - receiver_account_type [string]: receiver's account type. Options: 'checking', 'savings', 'salary', 'payment'
  # - receiver_bank_code [string]: receiver's bank code. ex: '20018183'
  # - reconciliation_id [string]: id used for conciliation of the resulting Pix transaction. Up to 25 alphanumeric chars. ex: '123456'
  # - subscription_id [string]: unique id of the parent PixPullSubscription. ex: '5656565656565656'
  #
  # ## Parameters (optional):
  # - attempt_type [string, default nil]: defines the type of attempt. Options: 'default', 'instantRetry', 'scheduledRetry'
  # - description [string, default nil]: additional information to be delivered to the sender. ex: 'Payment for service #1234'
  # - receiver_branch_code [string, default nil]: receiver's branch code. ex: '1357-9'
  # - tags [list of strings, default nil]: free-form labels for filtering. ex: ['employees', 'monthly']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixPullRequest is created. ex: '5656565656565656'
  # - status [string]: current PixPullRequest status. Options: 'created', 'processing', 'scheduled', 'denied', 'success', 'canceled', 'expired'
  # - flow [string]: direction of money flow. Options: 'in', 'out'
  # - receiver_name [string]: receiver's full name (filled in by the Pix infrastructure during settlement). ex: 'Edward Stark'
  # - receiver_tax_id [string]: receiver's tax ID (CPF or CNPJ). ex: '01234567890' or '20.018.183/0001-80'
  # - sender_bank_code [string]: sender's bank institution code in Brazil. ex: '20018183'
  # - sender_final_name [string]: sender's final name when the sender differs from the originating institution. ex: 'Edward Stark'
  # - sender_tax_id [string]: sender's tax ID (CPF or CNPJ). ex: '01234567890' or '20.018.183/0001-80'
  # - subscription_bacen_id [string]: bacen_id of the parent subscription, denormalized for convenience.
  # - created [DateTime]: creation datetime for the PixPullRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixPullRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixPullRequest < StarkCore::Utils::Resource
    attr_reader :amount, :due, :end_to_end_id, :receiver_account_number, :receiver_account_type,
                :receiver_bank_code, :reconciliation_id, :subscription_id, :attempt_type, :description,
                :receiver_branch_code, :tags, :id, :status, :flow, :receiver_name, :receiver_tax_id,
                :sender_bank_code, :sender_final_name, :sender_tax_id, :subscription_bacen_id,
                :created, :updated
    def initialize(
      amount:, due:, end_to_end_id:, receiver_account_number:, receiver_account_type:,
      receiver_bank_code:, reconciliation_id:, subscription_id:,
      attempt_type: nil, description: nil, receiver_branch_code: nil, tags: nil,
      id: nil, status: nil, flow: nil, receiver_name: nil, receiver_tax_id: nil,
      sender_bank_code: nil, sender_final_name: nil, sender_tax_id: nil,
      subscription_bacen_id: nil, created: nil, updated: nil
    )
      super(id)
      @amount = amount
      @due = StarkCore::Utils::Checks.check_datetime(due == '' ? nil : due)
      @end_to_end_id = end_to_end_id
      @receiver_account_number = receiver_account_number
      @receiver_account_type = receiver_account_type
      @receiver_bank_code = receiver_bank_code
      @reconciliation_id = reconciliation_id
      @subscription_id = subscription_id
      @attempt_type = attempt_type
      @description = description
      @receiver_branch_code = receiver_branch_code
      @tags = tags
      @status = status
      @flow = flow
      @receiver_name = receiver_name
      @receiver_tax_id = receiver_tax_id
      @sender_bank_code = sender_bank_code
      @sender_final_name = sender_final_name
      @sender_tax_id = sender_tax_id
      @subscription_bacen_id = subscription_bacen_id
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create PixPullRequests
    #
    # Send a list of PixPullRequest objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - requests [list of PixPullRequest objects]: list of PixPullRequest objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixPullRequest objects with updated attributes
    def self.create(requests, user: nil)
      StarkInfra::Utils::Rest.post(entities: requests, user: user, **resource)
    end

    # # Retrieve a specific PixPullRequest
    #
    # Receive a single PixPullRequest object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixPullRequest object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixPullRequests
    #
    # Receive a generator of PixPullRequest objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'created'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['employees', 'monthly']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - subscription_ids [list of strings, default nil]: list of parent subscription ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixPullRequest objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, subscription_ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        ids: ids,
        subscription_ids: subscription_ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixPullRequests
    #
    # Receive a list of up to 100 PixPullRequest objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'active']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['employees', 'monthly']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - subscription_ids [list of strings, default nil]: list of parent subscription ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixPullRequest objects with updated attributes
    # - cursor to retrieve the next page of PixPullRequest objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, subscription_ids: nil, user: nil)
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
        subscription_ids: subscription_ids,
        user: user,
        **resource
      )
    end

    # # Update a PixPullRequest entity
    #
    # Update a PixPullRequest entity previously created in the Stark Infra API.
    # The patch payload accepts at minimum status ('scheduled' or 'denied') and a
    # conditionally-required reason (one of 'senderAccountClosed', 'senderAccountBlocked',
    # 'amountNotAllowed').
    #
    # ## Parameters (required):
    # - id [string]: PixPullRequest unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - patch_data [hash, default nil]: hash of fields to be updated. ex: { status: 'denied', reason: 'amountNotAllowed' }
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - updated PixPullRequest object
    def self.update(id, patch_data: nil, user: nil)
      patch_data ||= {}
      StarkInfra::Utils::Rest.patch_id(id: id, user: user, **patch_data, **resource)
    end

    # # Cancel a PixPullRequest entity
    #
    # Cancel a PixPullRequest entity previously created in the Stark Infra API.
    # The reason is sent as a query parameter, not in the request body.
    #
    # ## Parameters (required):
    # - id [string]: PixPullRequest unique id. ex: '5656565656565656'
    # - reason [string]: reason for the cancellation. As receiver: 'accountClosed', 'receiverOrganizationClosed', 'receiverInternalError', 'fraud', 'receiverUserRequested'. As sender: 'accountClosed', 'senderDeceased', 'fraud', 'senderUserRequested'.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled PixPullRequest object
    def self.cancel(id, reason:, user: nil)
      response = StarkInfra::Utils::Rest.delete_raw(
        path: "/pix-pull-request/#{id}",
        query: { reason: reason },
        user: user,
        raiseException: true
      )
      maker = resource[:resource_maker]
      StarkCore::Utils::API.from_api_json(maker, response.json['request'])
    end

    def self.resource
      {
        resource_name: 'PixPullRequest',
        resource_maker: proc { |json|
          PixPullRequest.new(
            id: json['id'],
            amount: json['amount'],
            due: json['due'],
            end_to_end_id: json['end_to_end_id'],
            receiver_account_number: json['receiver_account_number'],
            receiver_account_type: json['receiver_account_type'],
            receiver_bank_code: json['receiver_bank_code'],
            reconciliation_id: json['reconciliation_id'],
            subscription_id: json['subscription_id'],
            attempt_type: json['attempt_type'],
            description: json['description'],
            receiver_branch_code: json['receiver_branch_code'],
            tags: json['tags'],
            status: json['status'],
            flow: json['flow'],
            receiver_name: json['receiver_name'],
            receiver_tax_id: json['receiver_tax_id'],
            sender_bank_code: json['sender_bank_code'],
            sender_final_name: json['sender_final_name'],
            sender_tax_id: json['sender_tax_id'],
            subscription_bacen_id: json['subscription_bacen_id'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
