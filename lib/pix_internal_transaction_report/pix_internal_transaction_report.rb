# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')


module StarkInfra
  # # PixInternalTransactionReport object
  #
  # Transactions that happen internally — outside of the SPI — must be reported to
  # the Central Bank so they are reflected in the participant's statements. A
  # PixInternalTransactionReport is the report you create for each such transaction.
  #
  # When you initialize a PixInternalTransactionReport, the entity will not be
  # automatically created in the Stark Infra API. The 'create' function sends the
  # objects to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - amount [integer]: amount in cents of the reported transaction. ex: 1234 (= R$ 12.34)
  # - created [DateTime or string]: datetime when the reported transaction occurred. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - end_to_end_id [string]: central bank's unique transaction id. ex: 'E20018183202201201213u34sav898j'
  # - method [string]: execution method of the transaction. ex: 'contactless', 'dict', 'dynamicQrcode', 'initiator', 'manual', 'payerQrcode', 'staticContactless', 'staticQrcode' or 'subscription'
  # - reference_type [string]: type of the reported transaction. ex: 'request' or 'reversal'
  # - sender_account_number [string]: sender's bank account number. ex: '876543-2'
  # - sender_branch_code [string]: sender's bank account branch code. ex: '1357-9'
  # - sender_account_type [string]: sender's bank account type. ex: 'checking', 'savings', 'salary' or 'payment'
  # - sender_bank_code [string]: sender's participant code (ISPB). ex: '20018183'
  # - sender_tax_id [string]: sender's tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - receiver_account_number [string]: receiver's bank account number. ex: '876543-2'
  # - receiver_branch_code [string]: receiver's bank account branch code. ex: '1357-9'
  # - receiver_account_type [string]: receiver's bank account type. ex: 'checking', 'savings', 'salary' or 'payment'
  # - receiver_bank_code [string]: receiver's participant code (ISPB). ex: '20018183'
  # - receiver_tax_id [string]: receiver's tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  #
  # ## Parameters (conditionally-required):
  # - return_id [string, default nil]: central bank's unique reversal id. Required when reference_type is 'reversal'. ex: 'D20018183202201201213u34sav898j'
  #
  # ## Parameters (optional):
  # - receiver_key_id [string, default nil]: receiver's Pix key. ex: '+5511989898989'
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixInternalTransactionReport is created. ex: '5656565656565656'
  # - status [string]: current PixInternalTransactionReport status. ex: 'created', 'failed', 'sent' or 'success'
  # - updated [DateTime]: latest update datetime for the PixInternalTransactionReport. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixInternalTransactionReport < StarkCore::Utils::Resource
    attr_reader :amount, :created, :end_to_end_id, :method, :reference_type, :sender_account_number,
                :sender_branch_code, :sender_account_type, :sender_bank_code, :sender_tax_id,
                :receiver_account_number, :receiver_branch_code, :receiver_account_type, :receiver_bank_code,
                :receiver_tax_id, :receiver_key_id, :return_id, :id, :status, :updated
    def initialize(
      amount:, created:, end_to_end_id:, method:, reference_type:, sender_account_number:, sender_branch_code:,
      sender_account_type:, sender_bank_code:, sender_tax_id:, receiver_account_number:, receiver_branch_code:,
      receiver_account_type:, receiver_bank_code:, receiver_tax_id:, receiver_key_id: nil, return_id: nil,
      id: nil, status: nil, updated: nil
    )
      super(id)
      @amount = amount
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @end_to_end_id = end_to_end_id
      @method = method
      @reference_type = reference_type
      @sender_account_number = sender_account_number
      @sender_branch_code = sender_branch_code
      @sender_account_type = sender_account_type
      @sender_bank_code = sender_bank_code
      @sender_tax_id = sender_tax_id
      @receiver_account_number = receiver_account_number
      @receiver_branch_code = receiver_branch_code
      @receiver_account_type = receiver_account_type
      @receiver_bank_code = receiver_bank_code
      @receiver_tax_id = receiver_tax_id
      @receiver_key_id = receiver_key_id
      @return_id = return_id
      @status = status
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create PixInternalTransactionReports
    #
    # Send a list of PixInternalTransactionReport objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - reports [list of PixInternalTransactionReport objects]: list of PixInternalTransactionReport objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixInternalTransactionReport objects with updated attributes
    def self.create(reports, user: nil)
      StarkInfra::Utils::Rest.post(entities: reports, user: user, **resource)
    end

    # # Retrieve a specific PixInternalTransactionReport
    #
    # Receive a single PixInternalTransactionReport object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixInternalTransactionReport object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixInternalTransactionReports
    #
    # Receive a generator of PixInternalTransactionReport objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['success'] or ['sent', 'failed']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixInternalTransactionReport objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixInternalTransactionReports
    #
    # Receive a list of up to 100 PixInternalTransactionReport objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['success'] or ['sent', 'failed']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixInternalTransactionReport objects with updated attributes
    # - cursor to retrieve the next page of PixInternalTransactionReport objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'PixInternalTransactionReport',
        resource_maker: proc { |json|
          PixInternalTransactionReport.new(
            id: json['id'],
            amount: json['amount'],
            created: json['created'],
            end_to_end_id: json['end_to_end_id'],
            method: json['method'],
            reference_type: json['reference_type'],
            sender_account_number: json['sender_account_number'],
            sender_branch_code: json['sender_branch_code'],
            sender_account_type: json['sender_account_type'],
            sender_bank_code: json['sender_bank_code'],
            sender_tax_id: json['sender_tax_id'],
            receiver_account_number: json['receiver_account_number'],
            receiver_branch_code: json['receiver_branch_code'],
            receiver_account_type: json['receiver_account_type'],
            receiver_bank_code: json['receiver_bank_code'],
            receiver_tax_id: json['receiver_tax_id'],
            receiver_key_id: json['receiver_key_id'],
            return_id: json['return_id'],
            status: json['status'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
