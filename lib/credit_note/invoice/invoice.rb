# frozen_string_literal: true

require('starkcore')
require_relative('../../utils/rest')

module StarkInfra

  # CreditNote::Invoice object
  #
  # Invoice issued after the contract is signed, to be paid by the credit receiver.
  #
  # ## Parameters (required):
  # - amount [integer]: Invoice value in cents. Minimum = 1 (any value will be accepted). ex: 1234 (= R$ 12.34)
  #
  # ## Parameters (optional):
  # - due [DateTime, Date or string, default now + 2 days]: Invoice due date in UTC ISO format. DateTime.new(2020, 3, 10, 10, 30, 0, 0) for immediate invoices and '2020-10-28' for scheduled invoices
  # - expiration [integer, default 604800]: time interval in seconds between scheduled date and expiration date. ex: 123456789
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['employees', 'monthly']
  # - descriptions [list of CreditNote::Invoice::Description objects or hash, default nil]: list Description objects. ex: [Description.new()]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when Invoice is created. ex: '5656565656565656'
  # - name [string]: payer name. ex: 'Iron Bank S.A.'
  # - tax_id [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - pdf [string]: public Invoice PDF URL. ex: 'https://invoice.starkbank.com/pdf/d454fa4e524441c1b0c1a729457ed9d8'
  # - link [string]: public Invoice webpage URL. ex: 'https://my-workspace.sandbox.starkbank.com/invoicelink/d454fa4e524441c1b0c1a729457ed9d8'
  # - fine [float, default 2.0]: Invoice fine for overdue payment in %. ex: 2.5
  # - interest [float, default 1.0]: Invoice monthly interest in overdue payment in %. ex: 5.2
  # - nominal_amount [integer]: Invoice emission value in cents (will change if invoice is updated, but not if it's paid). ex: 400000
  # - fine_amount [integer]: Invoice fine value calculated over nominal_amount. ex: 20000
  # - interest_amount [integer]: Invoice interest value calculated over nominal_amount. ex: 10000
  # - discount_amount [integer]: Invoice discount value calculated over nominal_amount. ex: 3000
  # - discounts [list of CreditNote::Invoice::Discount objects]: list of Discount objects. ex: [Discount.new()]
  # - brcode [string]: BR Code for the Invoice payment. ex: '00020101021226800014br.gov.bcb.pix2558invoice.starkbank.com/f5333103-3279-4db2-8389-5efe335ba93d5204000053039865802BR5913Arya Stark6009Sao Paulo6220051656565656565656566304A9A0'
  # - status [string]: current Invoice status. ex: 'registered' or 'paid'
  # - fee [integer]: fee charged by this Invoice. ex: 200 (= R$ 2.00).
  # - transaction_ids [list of strings]: ledger transaction ids linked to this Invoice (if there are more than one, all but the first are reversals or failed reversal chargebacks). ex: ['19827356981273']
  # - created [DateTime]: creation datetime for the Invoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the Invoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class Invoice < StarkCore::Utils::Resource
    attr_reader :amount, :id, :due, :expiration, :tags, :descriptions, :name, :tax_id, :pdf, :link, :fine, :interest,
                :nominal_amount, :fine_amount, :interest_amount, :discount_amount, :discounts, :brcode, :status, :fee,
                :transaction_ids, :created, :updated
    def initialize(
      amount:, id: nil,  due: nil, expiration: nil, tags: nil, descriptions: nil, name: nil, tax_id: nil,
      pdf: nil, link: nil, fine: nil, interest: nil, nominal_amount: nil, fine_amount: nil,
      interest_amount: nil, discount_amount: nil, discounts: nil, brcode: nil, status: nil, fee: nil,
      transaction_ids: nil, created: nil, updated: nil
    )
      super(id)
      @tax_id = tax_id
      @amount = amount
      @due = due
      @expiration = expiration
      @tags = tags
      @descriptions = Description.parse_descriptions(descriptions)
      @name = name
      @tax_id = tax_id
      @pdf = pdf
      @link = link
      @fine = fine
      @interest = interest
      @nominal_amount = nominal_amount
      @fine_amount = fine_amount
      @interest_amount = interest_amount
      @discount_amount = discount_amount
      @discounts = Discount.parse_discounts(discounts)
      @brcode = brcode
      @status = status
      @fee = fee
      @transaction_ids = transaction_ids
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    def self.parse_invoices(invoices)
      resource_maker = StarkInfra::Invoice.resource[:resource_maker]
      return invoices if invoices.nil?

      parsed_invoices = []
      invoices.each do |invoice|
        unless invoice.is_a? Invoice
          invoice = StarkCore::Utils::API.from_api_json(resource_maker, invoice)
        end
        parsed_invoices << invoice
      end
      parsed_invoices
    end

    def self.resource
      {
        resource_name: 'Invoice',
        resource_maker: proc { |json|
          Invoice.new(
            id: json['id'],
            amount: json['amount'],
            due: json['due'],
            expiration: json['expiration'],
            fine: json['fine'],
            interest: json['interest'],
            tags: json['tags'],
            descriptions: json['descriptions'],
            name: json['name'],
            tax_id: json['tax_id'],
            pdf: json['pdf'],
            link: json['link'],
            nominal_amount: json['nominal_amount'],
            fine_amount: json['fine_amount'],
            interest_amount: json['interest_amount'],
            discount_amount: json['discount_amount'],
            discounts: json['discounts'],
            brcode: json['brcode'],
            status: json['status'],
            fee: json['fee'],
            transaction_ids: json['transaction_ids'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
