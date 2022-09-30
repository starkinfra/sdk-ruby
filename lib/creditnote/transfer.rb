# frozen_string_literal: true

require_relative('../utils/api')
require_relative('../utils/rest')
require_relative('../utils/sub_resource')

module StarkInfra

  # # CreditNote::Transfer object
  #
  # Transfer sent to the credit receiver after the contract is signed.
  #
  # ## Parameters (required):
  # - name [string]: receiver full name. ex: 'Anthony Edward Stark'
  # - tax_id [string]: receiver tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - bank_code [string]: code of the receiver bank institution in Brazil. ex: '20018183'
  # - branch_code [string]: receiver bank account branch. Use '-' in case there is a verifier digit. ex: '1357-9'
  # - account_number [string]: receiver bank account number. Use '-' before the verifier digit. ex: '876543-2'
  #
  # ## Parameters (optional):
  # - account_type [string, default 'checking']: Receiver bank account type. This parameter only has effect on Pix Transfers. ex: 'checking', 'savings', 'salary' or 'payment'
  # - tags [list of strings, default nil]: list of strings for reference when searching for transfers. ex: ['employees', 'monthly']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the transfer is created. ex: '5656565656565656'
  # - amount [integer]: amount in cents to be transferred. ex: 1234 (= R$ 12.34)
  # - external_id [string]: url safe string that must be unique among all your transfers. Duplicated external_ids will cause failures. By default, this parameter will block any transfer that repeats amount and receiver information on the same date. ex: 'my-internal-id-123456'
  # - scheduled [DateTime]: date or datetime when the transfer will be processed. May be pushed to next business day if necessary. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - description [string]: optional description to override default description to be shown in the bank statement. ex: 'Payment for service #1234'
  # - fee [integer]: fee charged when the Transfer is processed. ex: 200 (= R$ 2.00)
  # - status [string]: current transfer status. ex: 'success' or 'failed'
  # - transaction_ids [list of strings]: ledger Transaction IDs linked to this Transfer (if there are two, the second is the chargeback). ex: ['19827356981273']
  # - created [DateTime]: creation datetime for the transfer. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the transfer. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class Transfer < StarkInfra::Utils::Resource
    attr_reader :id, :name, :tax_id, :bank_code, :branch_code, :account_number, :account_type, :tags, :amount, :external_id,
                :scheduled, :description, :fee, :status, :created, :updated, :transaction_ids
    def initialize(
      name:, tax_id:, bank_code:, branch_code:, account_number:, account_type: nil,
      tags: nil, id: nil, amount: nil, external_id: nil, scheduled: nil,
      description: nil, fee: nil, status: nil, created: nil, updated: nil,
      transaction_ids: nil
    )
      super(id)
      @name = name
      @tax_id = tax_id
      @bank_code = bank_code
      @branch_code = branch_code
      @account_number = account_number
      @account_type = account_type
      @tags = tags
      @amount = amount
      @external_id = external_id
      @scheduled = scheduled
      @description = description
      @fee = fee
      @status = status
      @transaction_ids = transaction_ids
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    def self.resource
      {
        resource_name: 'Transfer',
        resource_maker: proc { |json|
          Transfer.new(
            id: json['id'],
            name: json['name'],
            tax_id: json['tax_id'],
            bank_code: json['bank_code'],
            branch_code: json['branch_code'],
            account_number: json['account_number'],
            amount: json['amount'],
            account_type: json['account_type'],
            external_id: json['external_id'],
            scheduled: json['scheduled'],
            description: json['description'],
            tags: json['tags'],
            fee: json['fee'],
            status: json['status'],
            created: json['created'],
            updated: json['updated'],
            transaction_ids: json['transaction_ids']
          )
        }
      }
    end
  end
end
