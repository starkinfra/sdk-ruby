# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingBillingTransaction object
  #
  # The IssuingBillingTransaction objects created in your Workspace report the
  # transactions that compose the billing invoices of your Issuing operation.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingBillingTransaction is created. ex: '5656565656565656'
  # - amount [integer]: transaction amount in cents. ex: 1234 (= R$ 12.34)
  # - invoice_id [string]: id of the parent billing invoice the transaction belongs to. May be nil when the transaction is not tied to an invoice. ex: '5656565656565656'
  # - installment [integer]: installment number of the transaction. ex: 1
  # - installment_count [integer]: total number of installments of the transaction. ex: 12
  # - balance [integer]: remaining issuing balance in cents after the transaction. ex: 1234 (= R$ 12.34)
  # - holder_name [string]: card holder name. ex: 'Tony Stark'
  # - source [string]: transaction source. ex: 'issuing-purchase'
  # - external_id [string]: external transaction id. ex: 'my-external-id-123456'
  # - description [string]: transaction description. ex: 'Purchase at Stark Store'
  # - card_ending [string]: last 4 digits of the card number. ex: '1234'
  # - tax [integer]: IOF amount in cents applied to the transaction
  # - rate [float]: Conversion rate applied to international transactions
  # - merchant_amount [integer]: merchant amount in cents. ex: 1234 (= R$ 12.34)
  # - merchant_currency_code [string]: merchant currency code in ISO 4217 format. ex: 'USD'
  # - created [DateTime]: creation datetime for the IssuingBillingTransaction. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingBillingTransaction < StarkCore::Utils::Resource
    attr_reader :id, :amount, :invoice_id, :installment, :installment_count, :balance, :holder_name, :source,
                :external_id, :description, :card_ending, :tax, :rate, :merchant_amount, :merchant_currency_code,
                :created
    def initialize(
      id: nil, amount: nil, invoice_id: nil, installment: nil, installment_count: nil, balance: nil,
      holder_name: nil, source: nil, external_id: nil, description: nil, card_ending: nil, tax: nil, rate: nil,
      merchant_amount: nil, merchant_currency_code: nil, created: nil
    )
      super(id)
      @amount = amount
      @invoice_id = invoice_id
      @installment = installment
      @installment_count = installment_count
      @balance = balance
      @holder_name = holder_name
      @source = source
      @external_id = external_id
      @description = description
      @card_ending = card_ending
      @tax = tax
      @rate = rate
      @merchant_amount = merchant_amount
      @merchant_currency_code = merchant_currency_code
      @created = StarkCore::Utils::Checks.check_datetime(created)
    end

    # # Retrieve IssuingBillingTransactions
    #
    # Receive a generator of IssuingBillingTransaction objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - invoice_id [string, default nil]: filter for transactions of a specific billing invoice. ex: '5656565656565656'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingBillingTransaction objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, invoice_id: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        invoice_id: invoice_id,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingBillingTransactions
    #
    # Receive a list of up to 100 IssuingBillingTransaction objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - invoice_id [string, default nil]: filter for transactions of a specific billing invoice. ex: '5656565656565656'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingBillingTransaction objects with updated attributes
    # - cursor to retrieve the next page of IssuingBillingTransaction objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, invoice_id: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        invoice_id: invoice_id,
        tags: tags,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingBillingTransaction',
        resource_maker: proc { |json|
          IssuingBillingTransaction.new(
            id: json['id'],
            amount: json['amount'],
            invoice_id: json['invoice_id'],
            installment: json['installment'],
            installment_count: json['installment_count'],
            balance: json['balance'],
            holder_name: json['holder_name'],
            source: json['source'],
            external_id: json['external_id'],
            description: json['description'],
            card_ending: json['card_ending'],
            tax: json['tax'],
            rate: json['rate'],
            merchant_amount: json['merchant_amount'],
            merchant_currency_code: json['merchant_currency_code'],
            created: json['created']
          )
        }
      }
    end
  end
end
