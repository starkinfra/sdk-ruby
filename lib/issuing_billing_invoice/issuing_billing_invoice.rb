# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingBillingInvoice object
  #
  # The IssuingBillingInvoice objects created in your Workspace report the
  # billing cycle charges of your Issuing operation.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingBillingInvoice is created. ex: '5656565656565656'
  # - tax_id [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - name [string]: payer name. ex: 'Iron Bank S.A.'
  # - fine [float]: Fine percentage applied when paid after the due date. ex: 2.0
  # - interest [float]: Monthly interest percentage applied when paid after the due date. ex: 1.0
  # - amount [integer]: invoice amount in cents. ex: 1234 (= R$ 12.34)
  # - nominal_amount [integer]: nominal amount of the invoice in cents. ex: 1234 (= R$ 12.34)
  # - status [string]: current IssuingBillingInvoice status. ex: 'created', 'paid', 'overdue'
  # - brcode [string]: BR Code for the invoice payment. ex: '00020101021226930014br.gov.bcb.pix2571brcode-h.development.starkinfra.com'
  # - link [string]: public invoice webpage URL. ex: 'https://starkbank-card-issuer.sandbox.starkbank.com/billinginvoicelink/97de4d51e8984c459639a645ce920abb'
  # - due [DateTime]: invoice due and expiration datetime in UTC ISO format. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - period_start [DateTime]: billing cycle start datetime. Maps to wire field 'start'. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - period_end [DateTime]: billing cycle end datetime. Maps to wire field 'end'. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingBillingInvoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the IssuingBillingInvoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingBillingInvoice < StarkCore::Utils::Resource
    attr_reader :id, :tax_id, :name, :fine, :interest, :amount, :nominal_amount, :status, :brcode, :link,
                :due, :period_start, :period_end, :created, :updated
    def initialize(
      id: nil, tax_id: nil, name: nil, fine: nil, interest: nil, amount: nil, nominal_amount: nil, status: nil,
      brcode: nil, link: nil, due: nil, period_start: nil, period_end: nil, created: nil, updated: nil
    )
      super(id)
      @tax_id = tax_id
      @name = name
      @fine = fine
      @interest = interest
      @amount = amount
      @nominal_amount = nominal_amount
      @status = status
      @brcode = brcode
      @link = link
      @due = StarkCore::Utils::Checks.check_datetime(due)
      @period_start = StarkCore::Utils::Checks.check_datetime(period_start)
      @period_end = StarkCore::Utils::Checks.check_datetime(period_end)
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Retrieve a specific IssuingBillingInvoice
    #
    # Receive a single IssuingBillingInvoice object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingBillingInvoice object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingBillingInvoices
    #
    # Receive a generator of IssuingBillingInvoice objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'paid', 'overdue']
    # - id [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingBillingInvoice objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, id: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        id: id,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingBillingInvoices
    #
    # Receive a list of up to 100 IssuingBillingInvoice objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'paid', 'overdue']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingBillingInvoice objects with updated attributes
    # - cursor to retrieve the next page of IssuingBillingInvoice objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingBillingInvoice',
        resource_maker: proc { |json|
          IssuingBillingInvoice.new(
            id: json['id'],
            tax_id: json['tax_id'],
            name: json['name'],
            fine: json['fine'],
            interest: json['interest'],
            amount: json['amount'],
            nominal_amount: json['nominal_amount'],
            status: json['status'],
            brcode: json['brcode'],
            link: json['link'],
            due: json['due'],
            period_start: json['start'],
            period_end: json['end'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
