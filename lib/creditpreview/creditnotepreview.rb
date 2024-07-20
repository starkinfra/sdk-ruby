# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # CreditNotePreview object
  #
  # A CreditNotePreview is used to preview a CCB contract between the borrower and lender with a specific table type.
  #
  # When you initialize a CreditPreview, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - type [string]: table type that defines the amortization system. Options: 'sac', 'price', 'american', 'bullet', 'custom'
  # - nominal_amount [integer]: amount in cents transferred to the credit receiver, before deductions. ex: 11234 (= R$ 112.34)
  # - scheduled [DateTime, Date or string]: date of transfer execution. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - tax_id [string]: credit receiver's tax ID (CPF or CNPJ). ex: '20.018.183/0001-80'
  #
  # ## Parameters (conditionally required):
  # - invoices [list of CreditNote::Invoice objects]: list of CreditNote.Invoice objects to be created and sent to the credit receiver.
  # - nominal_interest [float]: yearly nominal interest rate of the credit note, in percentage. ex: 12.5
  # - initial_due [DateTime, Date or string]: date of the first invoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0), Date.new(2020, 3, 10) or '2020-03-10'
  # - count [integer]: quantity of invoices for payment. ex: 12
  # - initial_amount [integer]: value of the first invoice in cents. ex: 1234 (= R$12.34)
  # - interval [string]: interval between invoices. ex: 'year', 'month'
  #
  # ## Parameters (optional):
  # - rebate_amount [integer, default nil]: credit analysis fee deducted from lent amount. ex: 11234 (= R$ 112.34)
  #
  # ## Attributes (return-only):
  # - amount [integer]: credit note value in cents. ex: 1234 (= R$ 12.34)
  # - interest [float]: yearly effective interest rate of the credit note, in percentage. ex: 12.5
  # - tax_amount [integer]: tax amount included in the credit note. ex: 100
  class CreditNotePreview < StarkCore::Utils::SubResource
    attr_reader :type, :nominal_amount, :scheduled, :tax_id, :invoices, :nominal_interest, :initial_due, :count,
                :initial_amount, :interval, :rebate_amount, :amount, :interest, :tax_amount
    def initialize(
      type:, nominal_amount:, scheduled:, tax_id:, invoices: nil, nominal_interest: nil,
      initial_due: nil, count: nil, initial_amount: nil, interval: nil, rebate_amount: nil,
      amount: nil, interest: nil, tax_amount: nil
    )
      @type = type
      @nominal_amount = nominal_amount
      @scheduled = scheduled
      @tax_id = tax_id
      @invoices = Invoice.parse_invoices(invoices)
      @nominal_interest = nominal_interest
      @initial_due = initial_due
      @count = count
      @initial_amount = initial_amount
      @interval = interval
      @rebate_amount = rebate_amount
      @amount = amount
      @interest = interest
      @tax_amount = tax_amount
    end

    def self.resource
      {
        resource_name: 'CreditNotePreview',
        resource_maker: proc { |json|
          CreditNotePreview.new(
            type: json['type'],
            nominal_amount: json['nominal_amount'],
            scheduled: json['scheduled'],
            tax_id: json['tax_id'],
            invoices: json['invoices'],
            nominal_interest: json['nominal_interest'],
            initial_due: json['initial_due'],
            count: json['count'],
            initial_amount: json['initial_amount'],
            interval: json['interval'],
            rebate_amount: json['rebate_amount'],
            amount: json['amount'],
            interest: json['interest'],
            tax_amount: json['tax_amount']
          )
        }
      }
    end
  end
end
