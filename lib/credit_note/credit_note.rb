# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('invoice/invoice')
require_relative('invoice/discount')
require_relative('invoice/description')
require_relative('../credit_note/transfer')

require('starkcore')

module StarkInfra
  # # CreditNote object
  #
  # CreditNotes are used to generate CCB contracts between you and your customers.
  #
  # When you initialize a CreditNote, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - template_id [string]: ID of the contract template on which the credit note will be based. ex: '0123456789101112'
  # - name [string]: credit receiver's full name. ex: 'Edward Stark'
  # - tax_id [string]: credit receiver's tax ID (CPF or CNPJ). ex: '20.018.183/0001-80'
  # - scheduled [DateTime, Date or string]: date of transfer execution. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - invoices [list of CreditNote::Invoice objects]: list of Invoice objects to be created and sent to the credit receiver. ex: [Invoice.new(), Invoice.new()]
  # - payment [CreditNote::Transfer object]: payment entity to be created and sent to the credit receiver. ex: Transfer.new()
  # - signers [list of CreditSigner objects]: signer's name, contact and delivery method for the signature request. ex: [CreditSigner.new(), CreditSigner.new()]
  # - external_id [string]: a string that must be unique among all your CreditNotes, used to avoid resource duplication. ex: 'my-internal-id-123456'
  # - street_line_1 [string]: credit receiver main address. ex: 'Av. Paulista, 200'
  # - street_line_2 [string]: credit receiver address complement. ex: 'Apto. 123'
  # - district [string]: credit receiver address district / neighbourhood. ex: 'Bela Vista'
  # - city [string]: credit receiver address city. ex: 'Rio de Janeiro'
  # - state_code [string]: credit receiver address state. ex: 'GO'
  # - zip_code [string]: credit receiver address zip code. ex: '01311-200'
  #
  # ## Parameters (conditionally required):
  # - payment_type [string]: payment type, inferred from the payment parameter if it is not a hash. ex: 'transfer'
  # - nominal_amount [integer]: CreditNote value in cents. The nominal_amount parameter is required when amount is not sent. ex: 1234 (= R$ 12.34)
  # - amount [integer]: amount in cents transferred to the credit receiver, before deductions. The amount parameter is required when nominal_amount is not sent. ex: 1234 (= R$ 12.34)
  #
  # ## Parameters (optional):
  # - rebate_amount [integer, default nil]: credit analysis fee deducted from lent amount. ex: 11234 (= R$ 112.34)
  # - tags [list of strings, default nil]: list of strings for reference when searching for CreditNotes. ex: ['employees', 'monthly']
  # - expiration [integer, default 604800]: time interval in seconds between scheduled date and expiration date. ex: 123456789
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the CreditNote is created. ex: '5656565656565656'
  # - document_id [string]: ID of the signed document to execute this CreditNote. ex: '4545454545454545'
  # - status [string]: current status of the CreditNote. ex: 'canceled', 'created', 'expired', 'failed', 'processing', 'signed', 'success'
  # - transaction_ids [list of strings]: ledger transaction ids linked to this CreditNote. ex: ['19827356981273']
  # - workspace_id [string]: ID of the Workspace that generated this CreditNote. ex: '4545454545454545'
  # - tax_amount [integer]: tax amount included in the CreditNote. ex: 100
  # - nominal_interest [float]: yearly nominal interest rate of the CreditNote, in percentage. ex: 11.5
  # - interest [float]: yearly effective interest rate of the credit note, in percentage. ex: 12.5
  # - created [DateTime]: creation datetime for the CreditNote. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the CreditNote. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class CreditNote < StarkCore::Utils::Resource
    attr_reader :template_id, :name, :tax_id, :scheduled, :invoices, :payment, :signers, :external_id,
                :street_line_1, :street_line_2, :district, :city, :state_code, :zip_code, :payment_type,
                :nominal_amount, :amount, :rebate_amount, :tags, :expiration, :id,  :document_id, :status,
                :transaction_ids, :workspace_id, :tax_amount, :nominal_interest, :interest, :created, :updated
    def initialize(
      template_id:, name:, tax_id:, scheduled:, invoices:, payment:, signers:, external_id:,
      street_line_1:, street_line_2:, district:, city:, state_code:, zip_code:, payment_type: nil,
      nominal_amount: nil, amount: nil, rebate_amount: nil, tags: nil, expiration: nil, id: nil,
      document_id: nil, status: nil, transaction_ids: nil, workspace_id: nil, tax_amount: nil,
      nominal_interest: nil, interest: nil, created: nil, updated: nil
    )
      super(id)
      @template_id = template_id
      @name = name
      @tax_id = tax_id
      @scheduled = scheduled
      @invoices = Invoice.parse_invoices(invoices)
      @signers = CreditSigner.parse_signers(signers)
      @external_id = external_id
      @street_line_1 = street_line_1
      @street_line_2 = street_line_2
      @district = district
      @city = city
      @state_code = state_code
      @zip_code = zip_code
      @nominal_amount = nominal_amount
      @amount = amount
      @rebate_amount = rebate_amount
      @tags = tags
      @expiration = expiration
      @document_id = document_id
      @status = status
      @transaction_ids = transaction_ids
      @workspace_id = workspace_id
      @tax_amount = tax_amount
      @nominal_interest = nominal_interest
      @interest = interest
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)

      payment_info = CreditNote.parse_payment(payment, payment_type)
      @payment = payment_info['payment']
      @payment_type = payment_info['payment_type']
    end

    # # Create CreditNotes
    #
    # Send a list of CreditNote objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - notes [list of CreditNote objects]: list of CreditNote objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of CreditNote objects with updated attributes
    def self.create(notes, user: nil)
      StarkInfra::Utils::Rest.post(entities: notes, user: user, **resource)
    end

    # # Retrieve a specific CreditNote
    #
    # Receive a single CreditNote object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - CreditNote object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve CreditNotes
    #
    # Receive a generator of CreditNote objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: ["canceled", "created", "expired", "failed", "processing", "signed", "success"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of CreditNote objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged CreditNotes
    #
    # Receive a list of up to 100 CreditNote objects previously created in the Stark infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your notes.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: ["canceled", "created", "expired", "failed", "processing", "signed", "success"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of CreditNote objects with updated attributes
    # - cursor to retrieve the next page of CreditNote objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, user: nil)
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
        user: user,
        **resource
      )
    end

    # # Cancel a CreditNote entity
    #
    # Cancel a CreditNote entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled CreditNote object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.parse_payment(payment, payment_type)
      resource_maker = { 'transfer' => Transfer.resource[:resource_maker] }
      if payment.is_a?(Hash)
        begin
          parsed_payment = StarkCore::Utils::API.from_api_json(resource_maker[payment_type], payment)
          return { 'payment' => parsed_payment, 'payment_type' => payment_type }

        rescue StandardError
          return { 'payment' => payment, 'payment_type' => payment_type }

        end
      end

      return { 'payment' => payment, 'payment_type' => payment_type } if payment_type

      if payment.class == StarkInfra::Transfer
        return { 'payment' => payment, 'payment_type' => 'transfer' }
      end

      raise 'payment must be either ' + 'a dictionary, ' \
            'a CreditNote.Transfer, but not a ' + payment.class.to_s
    end

    def self.resource
      {
        resource_name: 'CreditNote',
        resource_maker: proc { |json|
          CreditNote.new(
            id: json['id'],
            template_id: json['template_id'],
            name: json['name'],
            tax_id: json['tax_id'],
            scheduled: json['scheduled'],
            invoices: json['invoices'],
            payment: json['payment'],
            signers: json['signers'],
            external_id: json['external_id'],
            street_line_1: json['street_line_1'],
            street_line_2: json['street_line_2'],
            district: json['district'],
            city: json['city'],
            state_code: json['state_code'],
            zip_code: json['zip_code'],
            payment_type: json['payment_type'],
            nominal_amount: json['nominal_amount'],
            amount: json['amount'],
            rebate_amount: json['rebate_amount'],
            tags: json['tags'],
            expiration: json['expiration'],
            document_id: json['document_id'],
            status: json['status'],
            transaction_ids: json['transaction_ids'],
            workspace_id: json['workspace_id'],
            tax_amount: json['tax_amount'],
            nominal_interest: json['nominal_interest'],
            interest: json['interest'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
