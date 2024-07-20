# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../utils/parse')

module StarkInfra
  # # PixRequest object
  #
  # PixRequests are used to receive or send instant payments to accounts
  # hosted in any Pix participant.
  #
  # When you initialize a PixRequest, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - amount [integer]: amount in cents to be transferred. ex: 11234 (= R$ 112.34)
  # - external_id [string]: url safe string that must be unique among all your PixRequests. Duplicated external ids will cause failures. By default, this parameter will block any PixRequests that repeats amount and receiver information on the same date. ex: 'my-internal-id-123456'
  # - sender_name [string]: sender full name. ex: 'Anthony Edward Stark'
  # - sender_tax_id [string]: sender tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - sender_branch_code [string]: sender bank account branch code. Use '-' in case there is a verifier digit. ex: '1357-9'
  # - sender_account_number [string]: sender bank account number. Use '-' before the verifier digit. ex: '876543-2'
  # - sender_account_type [string, default 'checking']: sender bank account type. ex: 'checking', 'savings', 'salary' or 'payment'
  # - receiver_name [string]: receiver full name. ex: 'Anthony Edward Stark'
  # - receiver_tax_id [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - receiver_bank_code [string]: code of the receiver bank institution in Brazil. ex: '20018183' or '341'
  # - receiver_account_number [string]: receiver bank account number. Use '-' before the verifier digit. ex: '876543-2'
  # - receiver_branch_code [string]: receiver bank account branch code. Use '-' in case there is a verifier digit. ex: '1357-9'
  # - receiver_account_type [string]: receiver bank account type. ex: 'checking', 'savings', 'salary' or 'payment'
  # - end_to_end_id [string]: central bank's unique transaction ID. ex: 'E79457883202101262140HHX553UPqeq'
  #
  # ## Parameters (conditionally-required):
  # - cashier_type [string]: Cashier's type. Required if the cash_amount is different from 0. Options: 'merchant', 'participant' and 'other'
  # - cashier_bank_code [string]: Cashier's bank code. Required if the cash_amount is different from 0. ex: '20018183'
  #
  # ## Parameters (optional):
  # - cash_amount [integer, default nil]: Amount to be withdrawal from the cashier in cents. ex: 1000 (= R$ 10.00)
  # - receiver_key_id [string, default nil]: Receiver's dict key. Example: tax id (CPF/CNPJ).
  # - description [string, default nil]: optional description to override default description to be shown in the bank statement. ex: 'Payment for service #1234'
  # - reconciliation_id [string, default nil]: Reconciliation ID linked to this payment. ex: 'b77f5236-7ab9-4487-9f95-66ee6eaf1781'
  # - initiator_tax_id [string, default nil]: Payment initiator's tax id (CPF/CNPJ). ex: '01234567890' or '20.018.183/0001-80'
  # - tags [list of strings, default nil]: list of strings for reference when searching for PixRequests. ex: ['employees', 'monthly']
  # - method [string, default nil]: execution method of creation of the Pix. ex: 'manual', 'payerQrcode', 'dynamicQrcode'.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixRequest is created. ex: '5656565656565656'
  # - fee [integer]: fee charged when PixRequest is paid. ex: 200 (= R$ 2.00)
  # - status [string]: current PixRequest status. ex: 'registered' or 'paid'
  # - flow [string]: direction of money flow. ex: 'in' or 'out'
  # - sender_bank_code [string]: code of the sender bank institution in Brazil. ex: '20018183'
  # - created [DateTime]: creation datetime for the PixRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixRequest < StarkCore::Utils::Resource
    attr_reader :amount, :external_id, :sender_name, :sender_tax_id, :sender_branch_code, :sender_account_number,
                :sender_account_type, :receiver_name, :receiver_tax_id, :receiver_bank_code, :receiver_account_number,
                :receiver_branch_code, :receiver_account_type, :end_to_end_id, :cashier_type,
                :cashier_bank_code, :cash_amount, :receiver_key_id, :description, :reconciliation_id, :initiator_tax_id,
                :tags, :method, :id, :fee, :status, :flow, :sender_bank_code, :created, :updated
    def initialize(
      amount:, external_id:, sender_name:, sender_tax_id:, sender_branch_code:, sender_account_number:, 
      sender_account_type:, receiver_name:, receiver_tax_id:, receiver_bank_code:, receiver_account_number:, 
      receiver_branch_code:, receiver_account_type:, end_to_end_id:, cashier_type: nil, cashier_bank_code: nil,
      cash_amount: nil, receiver_key_id: nil, description: nil, reconciliation_id: nil, initiator_tax_id: nil,
      tags: nil, method: nil, id: nil, fee: nil, status:nil, flow: nil, sender_bank_code: nil, created: nil, updated: nil
    )
      super(id)
      @amount = amount
      @external_id = external_id
      @sender_name = sender_name
      @sender_tax_id = sender_tax_id
      @sender_branch_code = sender_branch_code
      @sender_account_number = sender_account_number
      @sender_account_type = sender_account_type
      @receiver_name = receiver_name
      @receiver_tax_id = receiver_tax_id
      @receiver_bank_code = receiver_bank_code
      @receiver_account_number = receiver_account_number
      @receiver_branch_code = receiver_branch_code
      @receiver_account_type = receiver_account_type
      @end_to_end_id = end_to_end_id
      @cashier_type = cashier_type
      @cashier_bank_code = cashier_bank_code
      @cash_amount = cash_amount
      @receiver_key_id = receiver_key_id
      @description = description
      @reconciliation_id = reconciliation_id
      @initiator_tax_id = initiator_tax_id
      @tags = tags
      @method = method
      @fee = fee
      @status = status
      @flow = flow
      @sender_bank_code = sender_bank_code
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create PixRequests
    #
    # Send a list of PixRequest objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - requests [list of PixRequest objects]: list of PixRequest objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixRequest objects with updated attributes
    def self.create(requests, user: nil)
      StarkInfra::Utils::Rest.post(entities: requests, user: user, **resource)
    end

    # # Retrieve a specific PixRequest
    #
    # Receive a single PixRequest object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixRequest object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixRequests
    #
    # Receive a generator of PixRequest objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - end_to_end_ids [list of strings, default nil]: central bank's unique transaction IDs. ex: ['E79457883202101262140HHX553UPqeq', 'E79457883202101262140HHX553UPxzx']
    # - external_ids [list of strings, default nil]: url safe strings that must be unique among all your PixRequests. Duplicated external IDs will cause failures. By default, this parameter will block any PixRequests that repeats amount and receiver information on the same date. ex: ['my-internal-id-123456', 'my-internal-id-654321']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixRequest objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, end_to_end_ids: nil, external_ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        ids: ids,
        end_to_end_ids: end_to_end_ids,
        external_ids: external_ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixRequests
    #
    # Receive a list of up to 100 PixRequest objects previously created in the Stark infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'paid' or 'registered'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - end_to_end_ids [list of strings, default nil]: central bank's unique transaction IDs. ex: ['E79457883202101262140HHX553UPqeq', 'E79457883202101262140HHX553UPxzx']
    # - external_ids [list of strings, default nil]: url safe strings that must be unique among all your PixRequests. Duplicated external IDs will cause failures. By default, this parameter will block any PixRequests that repeats amount and receiver information on the same date. ex: ['my-internal-id-123456', 'my-internal-id-654321']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixRequest objects with updated attributes
    # - cursor to retrieve the next page of PixRequest objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, end_to_end_ids: nil, external_ids: nil, user: nil)
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
        end_to_end_ids: end_to_end_ids,
        external_ids: external_ids,
        user: user,
        **resource
      )
    end

    # # Create single verified PixRequest object from a content string
    #
    # Create a single PixRequest object from a content string received from a handler listening at a subscribed user endpoint.
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
    # - Parsed PixRequest object
    def self.parse(content:, signature:, user: nil)
      request = StarkCore::Utils::Parse.parse_and_verify(content: content, signature: signature, user: user, resource: resource)

      !request.fee.nil? ? request.fee : 0
      !request.tags.nil? ? request.tags : []
      !request.external_id.nil?  ? request.external_id : ''
      !request.description.nil?  ? request.description : ''

      request
    end

    # Helps you respond to a PixRequest authorization
    #
    ## Parameters (required):
    # - status [string]: response to the authorization. ex: 'approved' or 'denied'
    #
    ## Parameters (conditionally required):
    # - reason [string, default nil]: denial reason. Options: 'invalidAccountNumber', 'blockedAccount', 'accountClosed', 'invalidAccountType', 'invalidTransactionType', 'taxIdMismatch', 'invalidTaxId', 'orderRejected', 'reversalTimeExpired', 'settlementFailed'
    #
    ## Return:
    # - Dumped JSON string that must be returned to us
    def self.response(status:, reason: nil)
      response = {
        authorization: {
          status: status,
          reason: reason
        }
      }.to_json

      response
    end

    def self.resource
      {
        resource_name: 'PixRequest',
        resource_maker: proc { |json|
          PixRequest.new(
            id: json['id'],
            amount: json['amount'],
            external_id: json['external_id'],
            sender_name: json['sender_name'],
            sender_tax_id: json['sender_tax_id'],
            sender_branch_code: json['sender_branch_code'],
            sender_account_number: json['sender_account_number'],
            sender_account_type: json['sender_account_type'],
            receiver_name: json['receiver_name'],
            receiver_tax_id: json['receiver_tax_id'],
            receiver_bank_code: json['receiver_bank_code'],
            receiver_account_number: json['receiver_account_number'],
            receiver_branch_code: json['receiver_branch_code'],
            receiver_account_type: json['receiver_account_type'],
            end_to_end_id: json['end_to_end_id'],
            cashier_type: json['cashier_type'],
            cashier_bank_code: json['cashier_bank_code'],
            cash_amount: json['cash_amount'],
            receiver_key_id: json['receiver_key_id'],
            description: json['description'],
            reconciliation_id: json['reconciliation_id'],
            initiator_tax_id: json['initiator_tax_id'],
            tags: json['tags'],
            method: json['method'],
            fee: json['fee'],
            status: json['status'],
            flow: json['flow'],
            sender_bank_code: json['sender_bank_code'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
