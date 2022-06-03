# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')

module StarkInfra
  # # IssuingInvoice object
  #
  # The IssuingInvoice objects created in your Workspace load your Issuing balance when paid.
  #
  # ## Parameters (required):
  # - amount [integer]: IssuingInvoice value in cents. ex: 1234 (= R$ 12.34)
  #
  # ## Parameters (optional):
  # - tax_id [string, default sub-issuer tax ID]: payer tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
  # - name [string, default sub-issuer name]: payer name. ex: 'Iron Bank S.A.'
  # - tags [list of strings, default []]: list of strings for tagging. ex: ['travel', 'food']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingInvoice is created. ex: '5656565656565656'
  # - status [string]: current IssuingInvoice status. ex: 'created', 'expired', 'overdue', 'paid'
  # - issuing_transaction_id [string]: ledger transaction ids linked to this IssuingInvoice. ex: 'issuing-invoice/5656565656565656'
  # - updated [DateTime]: latest update datetime for the IssuingInvoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingInvoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingInvoice < StarkInfra::Utils::Resource
    attr_reader :amount, :id, :name, :tax_id, :status, :issuing_transaction_id, :tags, :updated, :created
    def initialize(
      amount:, id: nil, name: nil, tax_id: nil, status: nil, issuing_transaction_id: nil, tags: nil, updated: nil, created: nil
    )
      super(id)
      @amount = amount
      @name = name
      @tax_id = tax_id
      @status = status
      @issuing_transaction_id = issuing_transaction_id
      @tags = tags
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    # # Create an IssuingInvoice
    #
    # Send a single IssuingInvoice object for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - invoice [IssuingInvoice object]: IssuingInvoice object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingInvoice object with updated attributes
    def self.create(invoice, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: invoice, user: user, **resource)
    end

    # # Retrieve a specific IssuingInvoice
    #
    # Receive a single IssuingInvoice object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingInvoice object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingInvoices
    #
    # Receive a generator of IssuingInvoices objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'expired', 'overdue', 'paid']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingInvoices objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingInvoices
    #
    # Receive a list of IssuingInvoices objects previously created in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'expired', 'overdue', 'paid']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingInvoice objects with updated attributes
    # - cursor to retrieve the next page of IssuingInvoice objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
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
        resource_name: 'IssuingInvoice',
        resource_maker: proc { |json|
          IssuingInvoice.new(
            id: json['id'],
            amount: json['amount'],
            name: json['name'],
            tax_id: json['tax_id'],
            status: json['status'],
            issuing_transaction_id: json['issuing_transaction_id'],
            tags: json['tags'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
