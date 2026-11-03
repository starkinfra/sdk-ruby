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
  # - scheduled [DateTime, Date or string]: date of transfer execution. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - tax_id [string]: credit receiver's tax ID (CPF or CNPJ). ex: '20.018.183/0001-80'
  #
  # ## Parameters (conditionally required):
  # Each `type` value requires its own subset of these fields: "sac", "price", "american" and "bullet" require nominal_interest and initial_due; "sac" and "price" require exactly one of count or initial_amount (count is also required for "american") plus interval; only "custom" requires invoices, leaving the others unused. For every type, including "custom", exactly one of nominal_amount or amount must also be provided.
  # - invoices [list of CreditNote::Invoice objects]: list of CreditNote::Invoice objects to be created and sent to the credit receiver. ex: [Invoice, Invoice]
  # - nominal_amount [integer]: amount in cents transferred to the credit receiver, before deductions, for every type including "custom". Provide exactly one of nominal_amount or amount; the other value, along with tax_amount and the interest rates, is computed from the invoice schedule. ex: 11234 (= R$ 112.34)
  # - amount [integer]: net amount in cents to be disbursed to the credit receiver, for every type including "custom". Provide exactly one of nominal_amount or amount; the other value, along with tax_amount and the interest rates, is computed from the invoice schedule.
  # - nominal_interest [float]: yearly nominal interest rate of the credit note, in percentage. ex: 12.5
  # - initial_due [DateTime, Date or string]: date of the first invoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - count [integer]: quantity of invoices for payment. ex: 12
  # - initial_amount [integer]: value of the first invoice in cents. ex: 1234 (= R$12.34)
  # - interval [string]: interval between invoices. ex: 'year', 'month'
  #
  # ## Parameters (optional):
  # - rebate_amount [integer, default nil]: credit analysis fee deducted from lent amount. ex: 11234 (= R$ 112.34)
  #
  # ## Attributes (return-only):
  # - interest [float]: yearly effective interest rate of the credit note, in percentage. ex: 12.5
  # - tax_amount [integer]: tax amount included in the credit note. ex: 100
  class CreditNotePreview < StarkCore::Utils::SubResource
    attr_reader :type, :nominal_amount, :scheduled, :tax_id, :invoices, :nominal_interest, :initial_due, :count,
                :initial_amount, :interval, :rebate_amount, :amount, :interest, :tax_amount
    def initialize(
      type:, nominal_amount: nil, scheduled: nil, tax_id: nil, invoices: nil, nominal_interest: nil,
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
