# frozen_string_literal: true
require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # BrcodePreview object
  #
  # A BrcodePreview is used to get information from a BR Code you received to check the information before paying it.
  #
  # Parameters (required):
  # - id [string]: BR Code string for the Pix payment. This is also de information directly encoded in a QR Code. ex: '00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A'
  # - payer_id [string]: tax id (CPF/CNPJ) of the individual or business requesting the PixKey information. This id is used by the Central Bank to limit request rates. ex: "20.018.183/0001-80"
  #
  # Parameters (optional):
  # - end_to_end_id [string]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
  #
  # Attributes (return-only):
  # - account_number [string]: Payment receiver account number. ex: '1234567'
  # - account_type [string]: Payment receiver account type. ex: 'checking'
  # - amount [integer]: Value in cents that this payment is expecting to receive. If 0, any value is accepted. ex: 123 (= R$1,23)
  # - amount_type [string]: amount type of the BR Code. If the amount type is 'custom' the BR Code's amount can be changed by the sender at the moment of payment. Options: 'fixed' or 'custom'
  # - bank_code [string]: Payment receiver bank code. ex: '20018183'
  # - branch_code [string]: Payment receiver branch code. ex: '0001'
  # - cash_amount [integer]: Amount to be withdrawn from the cashier in cents. ex: 1000 (= R$ 10.00)
  # - cashier_bank_code [string]: Cashier's bank code. ex: '20018183'
  # - cashier_type [string]: Cashier's type. Options: 'merchant', 'participant' and 'other'
  # - discount_amount [integer]: Discount value calculated over nominal_amount. ex: 3000
  # - fine_amount [integer]: Fine value calculated over nominal_amount. ex: 20000
  # - key_id [string]: Receiver's PixKey id. ex: '+5511989898989'
  # - interest_amount [integer]: Interest value calculated over nominal_amount. ex: 10000
  # - name [string]: Payment receiver name. ex: 'Tony Stark'
  # - nominal_amount [integer]: BR Code emission amount, without fines, fees and discounts. ex: 1234 (= R$ 12.34)
  # - reconciliation_id [string]: Reconciliation ID linked to this payment. If the BR Code is dynamic, the reconciliation_id will have from 26 to 35 alphanumeric characters, ex: 'cd65c78aeb6543eaaa0170f68bd741ee'. If the brcode is static, the reconciliation_id will have up to 25 alphanumeric characters 'ah27s53agj6493hjds6836v49'
  # - reduction_amount [integer]: Reduction value to discount from nominal_amount. ex: 1000
  # - scheduled [DateTime]: date of payment execution. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0).
  # - status [string]: Payment status. ex: 'active', 'paid', 'canceled' or 'unknown'
  # - tax_id [string]: Payment receiver tax ID. ex: '012.345.678-90'
  class BrcodePreview < StarkCore::Utils::Resource
    attr_reader :id, :payer_id, :end_to_end_id, :account_number, :account_type, :amount, :amount_type, :bank_code, :branch_code, :cash_amount,
                :cashier_bank_code, :cashier_type, :discount_amount, :fine_amount, :key_id, :interest_amount, :name,
                :nominal_amount, :reconciliation_id, :reduction_amount, :scheduled, :status, :tax_id
    def initialize(
      id:, payer_id:, end_to_end_id: nil, account_number: nil, account_type: nil, amount: nil, amount_type: nil, bank_code: nil,
      branch_code: nil, cash_amount: nil, cashier_bank_code:nil, cashier_type:nil, discount_amount: nil,
      fine_amount: nil, key_id: nil, interest_amount: nil, name: nil, nominal_amount: nil,
      reconciliation_id: nil, reduction_amount: nil, scheduled: nil, status: nil, tax_id: nil
    )
      super(id)
      @payer_id = payer_id
      @end_to_end_id = end_to_end_id
      @account_number = account_number
      @account_type = account_type
      @amount = amount
      @amount_type = amount_type
      @bank_code = bank_code
      @branch_code = branch_code
      @cash_amount = cash_amount
      @cashier_bank_code = cashier_bank_code
      @cashier_type = cashier_type
      @discount_amount = discount_amount
      @fine_amount = fine_amount
      @interest_amount = interest_amount
      @key_id = key_id
      @name = name
      @nominal_amount = nominal_amount
      @reconciliation_id = reconciliation_id
      @reduction_amount = reduction_amount
      @scheduled = scheduled
      @status = status
      @tax_id = tax_id
    end

    # # Retrieve BrcodePreviews
    #
    # Process BR Codes before paying them.
    #
    # ## Parameters (required):
    # - previews [list of BrcodePreview objects]: List of BrcodePreview objects to preview. ex: [starkinfra.BrcodePreview('00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a8520400005303986540510.005802BR5908T'Challa6009Sao Paulo62090505123456304B14A')]
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of BrcodePreview objects with updated attributes
    def self.create(previews, user: nil)
      StarkInfra::Utils::Rest.post(entities: previews, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'BrcodePreview',
        resource_maker: proc { |json|
          BrcodePreview.new(
            id: json['id'],
            payer_id: json['payer_id'],
            end_to_end_id: json['end_to_end_id'],
            account_number: json['account_number'],
            account_type: json['account_type'],
            amount: json['amount'],
            amount_type: json['amount_type'],
            bank_code: json['bank_code'],
            branch_code: json['branch_code'],
            cash_amount: json['cash_amount'],
            cashier_bank_code: json['cashier_bank_code'],
            cashier_type: json['cashier_type'],
            discount_amount: json['discount_amount'],
            fine_amount: json['fine_amount'],
            key_id: json['key_id'],
            interest_amount: json['interest_amount'],
            name: json['name'],
            nominal_amount: json['nominal_amount'],
            reconciliation_id: json['reconciliation_id'],
            reduction_amount: json['reduction_amount'],
            scheduled: json['scheduled'],
            status: json['status'],
            tax_id: json['tax_id']
          )
        }
      }
    end
  end
end
