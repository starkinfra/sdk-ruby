# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/parse')

module StarkInfra
  # # CreditNote object
  #
  # CreditNotes are used to generate CCB contracts between you and your customers.
  # When you initialize a CreditNote, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - template_id [string]: ID of the contract template on which the credit note will be based. ex: template_id='0123456789101112'
  # - name [string]: credit receiver's full name. ex: name='Edward Stark'
  # - tax_id [string]: credit receiver's tax ID (CPF or CNPJ). ex: '20.018.183/0001-80'
  # - nominal_amount [integer]: amount in cents transferred to the credit receiver, before deductions. ex: nominal_amount=11234 (= R$ 112.34)
  # - scheduled [DateTime, Date or string, default now]: date of transfer execution. ex: scheduled=DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - invoices [list of CreditNote::Invoice objects]: list of Invoice objects to be created and sent to the credit receiver. ex: invoices=[CreditNote::Invoice.new(), CreditNote::Invoice.new()]
  # - payment [CreditNote::Transfer object]: payment entity to be created and sent to the credit receiver. ex: payment=CreditNote::Transfer.new()
  # - signers [list of CreditNote::Signer objects]: signer's name, contact and delivery method for the signature request. ex: signers=[CreditNote::Signer.new(), CreditNote::Signer.new()]
  # - external_id [string]: a string that must be unique among all your CreditNotes, used to avoid resource duplication. ex: 'my-internal-id-123456'
  #
  # ## Parameters (conditionally required):
  # - payment_type [string]: payment type, inferred from the payment parameter if it is not a hash. ex: 'transfer'
  #
  # Parameters (optional):
  # - rebate_amount [integer, default nil]: credit analysis fee deducted from lent amount. ex: rebate_amount=11234 (= R$ 112.34)
  # - tags [list of strings, default nil]: list of strings for reference when searching for CreditNotes. ex: tags=['employees', 'monthly']
  #
  # Attributes (return-only):
  # - id [string]: unique id returned when the CreditNote is created. ex: '5656565656565656'
  # - amount [integer]: CreditNote value in cents. ex: 1234 (= R$ 12.34)
  # - expiration [integer]: time interval in seconds between due date and expiration date. ex: 123456789
  # - document_id [string]: ID of the signed document to execute this CreditNote. ex: '4545454545454545'
  # - status [string]: current status of the CreditNote. ex: 'canceled', 'created', 'expired', 'failed', 'processing', 'signed', 'success'
  # - transaction_ids [list of strings]: ledger transaction ids linked to this CreditNote. ex: ['19827356981273']
  # - workspace_id [string]: ID of the Workspace that generated this CreditNote. ex: '4545454545454545'
  # - tax_amount [integer]: tax amount included in the CreditNote. ex: 100
  # - interest [float]: yearly effective interest rate of the credit note, in percentage. ex: 12.5
  # - created [DateTime]: creation datetime for the CreditNote. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the CreditNote. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class CreditNote < StarkInfra::Utils::Resource
    attr_reader :template_id, :name, :tax_id, :nominal_amount, :scheduled, :invoices, :payment, :signers, :external_id, :payment_type, :rebate_amount, :tags, :id, :amount, :expiration, :document_id, :status, :transaction_ids, :workspace_id, :tax_amount, :interest, :created, :updated
    def initialize(
      template_id:, name:, tax_id:, nominal_amount:, scheduled:, invoices:, payment:,
      signers:, external_id:, payment_type: nil, rebate_amount: nil, tags: nil, id: nil, amount: nil,
      expiration: nil, document_id: nil, status: nil, transaction_ids: nil, workspace_id: nil,
      tax_amount: nil, interest: nil, created: nil, updated: nil
    )
      super(id)
      @template_id = template_id
      @name = name
      @tax_id = tax_id
      @nominal_amount = nominal_amount
      @scheduled = scheduled
      @invoices = CreditNote::Invoice.parse_invoices(invoices)
      @signers = CreditNote::Signer.parse_signers(signers)
      @external_id = external_id
      @rebate_amount = rebate_amount
      @tags = tags
      @amount = amount
      @expiration = expiration
      @document_id = document_id
      @status = status
      @transaction_ids = transaction_ids
      @workspace_id = workspace_id
      @tax_amount = tax_amount
      @interest = interest
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)

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
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of CreditNote objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
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
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'paid' or 'registered'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of CreditNote objects with updated attributes
    # - cursor to retrieve the next page of CreditNote objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
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

    # # Cancel a specific CreditNote
    #
    # Cancel a single CreditNote object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled CreditNote object with updated attributes
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.parse_payment(payment, payment_type)
      resource_map = { 'transfer' => Transfer.resource[:resource_maker] }
      if payment.is_a?(Hash)
        begin
          parsed_payment = StarkInfra::Utils::API.from_api_json(resource_map[payment_type], payment)
          return { 'payment' => parsed_payment, 'payment_type' => payment_type }
        rescue StandardError
          return { 'payment' => payment, 'payment_type' => payment_type }
        end
      end

      return { 'payment' => payment, 'payment_type' => payment_type} if payment_type
      if payment.class == StarkInfra::Transfer
        return { 'payment' => payment, 'payment_type' => 'transfer'}
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
            nominal_amount: json['nominal_amount'],
            scheduled: json['scheduled'],
            invoices: json['invoices'],
            payment: json['payment'],
            signers: json['signers'],
            external_id: json['external_id'],
            payment_type: json['payment_type'],
            rebate_amount: json['rebate_amount'],
            tags: json['tags'],
            amount: json['amount'],
            expiration: json['expiration'],
            document_id: json['document_id'],
            status: json['status'],
            transaction_ids: json['transaction_ids'],
            workspace_id: json['workspace_id'],
            tax_amount: json['tax_amount'],
            interest: json['interest'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end

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
    # - amount [integer]: amount in cents to be transferred. ex: 1234 (= R$ 12.34)
    # - external_id [string]: url safe string that must be unique among all your transfers. Duplicated external_ids will cause failures. By default, this parameter will block any transfer that repeats amount and receiver information on the same date. ex: 'my-internal-id-123456'
    # - scheduled [DateTime, Date or string]: date or datetime when the transfer will be processed. May be pushed to next business day if necessary. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - description [string]: optional description to override default description to be shown in the bank statement. ex: 'Payment for service #1234'
    # - id [string]: unique id returned when the transfer is created. ex: '5656565656565656'
    # - fee [integer]: fee charged when the Transfer is processed. ex: 200 (= R$ 2.00)
    # - status [string]: current transfer status. ex: 'success' or 'failed'
    # - transaction_ids [list of strings]: ledger Transaction IDs linked to this Transfer (if there are two, the second is the chargeback). ex: ['19827356981273']
    # - created [DateTime]: creation datetime for the transfer. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - updated [DateTime]: latest update datetime for the transfer. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Transfer < StarkInfra::Utils::Resource
      attr_reader :tax_id, :name, :bank_code, :branch_code, :account_number, :amount, :account_type, :external_id, :scheduled, :description, :tags, :fee, :status, :created, :updated, :transaction_ids
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
              tax_id: json['tax_id'],
              name: json['name'],
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

    # # CreditNote::Signer object
    #
    # The Signer object stores the CreditNote signer's information.
    #
    # ## Parameters (required):
    # - name [string]: signer's name. ex: 'Tony Stark'
    # - contact [string]: signer's contact information. ex: 'tony@starkindustries.com'
    # - method [string]: delivery method for the contract. ex: 'link'
    class Signer < StarkInfra::Utils::SubResource
      attr_reader :name, :contact, :method
      def initialize(name:, contact:, method:)
        @name = name
        @contact = contact
        @method = method
      end

      def self.parse_signers(signers)
        return signers if signers.nil?

        parsed_signers = []
        signers.each do |signer|
          unless signer.is_a? Signer
            signer = StarkInfra::Utils::API.from_api_json(resource[:resource_maker], signer)
          end
          parsed_signers << signer
        end
        parsed_signers
      end

      def self.resource
        {
          resource_name: 'Signer',
          resource_maker: proc { |json|
            Signer.new(
              name: json['name'],
              contact: json['contact'],
              method: json['method']
            )
          }
        }
      end
    end

    # CreditNote::Invoice object
    # Invoice object to be issued after contract signature and paid by the credit receiver.
    #
    # ## Parameters (required):
    # - amount [integer]: Invoice value in cents. Minimum = 1 (any value will be accepted). ex: 1234 (= R$ 12.34)
    #
    # ## Parameters (optional):
    # - due [DateTime, Date or string, default now + 2 days]: Invoice due date in UTC ISO format. ex: '2020-10-28T17:59:26.249976+00:00' for immediate invoices and '2020-10-28' for scheduled invoices
    # - expiration [integer, default 5097600 (59 days)]: time interval in seconds between due date and expiration date. ex: 123456789
    # - fine [float, default 2.0]: Invoice fine for overdue payment in %. ex: 2.5
    # - interest [float, default 1.0]: Invoice monthly interest in overdue payment in %. ex: 5.2
    # - tags [list of strings, default nil]: list of strings for tagging
    # - descriptions [list of CreditNote::Invoice::Description objects, default nil]: list Description objects. ex: [CreditNote::Invoice::Description.new()]
    #
    # ## Attributes (return-only):
    # - id [string]: unique id returned when Invoice is created. ex: '5656565656565656'
    # - name [string]: payer name. ex: 'Iron Bank S.A.'
    # - tax_id [string]: payer tax ID (CPF or CNPJ) with or without formatting. ex: '01234567890' or '20.018.183/0001-80'
    # - pdf [string]: public Invoice PDF URL. ex: 'https://invoice.starkbank.com/pdf/d454fa4e524441c1b0c1a729457ed9d8'
    # - link [string]: public Invoice webpage URL. ex: 'https://my-workspace.sandbox.starkbank.com/invoicelink/d454fa4e524441c1b0c1a729457ed9d8'
    # - nominal_amount [integer]: Invoice emission value in cents (will change if invoice is updated, but not if it's paid). ex: 400000
    # - fine_amount [integer]: Invoice fine value calculated over nominal_amount. ex: 20000
    # - interest_amount [integer]: Invoice interest value calculated over nominal_amount. ex: 10000
    # - discount_amount [integer]: Invoice discount value calculated over nominal_amount. ex: 3000
    # - discounts [list of CreditNote::Invoice::Discount objects]: list of Discount objects. ex: [CreditNote::Invoice::Discount.new()]
    # - brcode [string]: BR Code for the Invoice payment. ex: '00020101021226800014br.gov.bcb.pix2558invoice.starkbank.com/f5333103-3279-4db2-8389-5efe335ba93d5204000053039865802BR5913Arya Stark6009Sao Paulo6220051656565656565656566304A9A0'
    # - status [string]: current Invoice status. ex: 'registered' or 'paid'
    # - fee [integer]: fee charged by this Invoice. ex: 200 (= R$ 2.00)
    # - transaction_ids [list of strings]: ledger transaction ids linked to this Invoice (if there are more than one, all but the first are reversals or failed reversal chargebacks). ex: ['19827356981273']
    # - created [DateTime]: creation datetime for the Invoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - updated [DateTime]: latest update datetime for the Invoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Invoice < StarkInfra::Utils::Resource
      attr_reader :id, :amount, :due, :expiration, :fine, :interest, :tags, :descriptions, :name, :tax_id, :pdf, :link, :nominal_amount, :fine_amount, :interest_amount, :discount_amount, :discounts, :brcode, :status, :fee, :transaction_ids, :created, :updated
      def initialize(
        amount:, due: nil, expiration: nil, fine: nil, interest: nil, tags: nil, descriptions: nil,
        id: nil, name: nil, tax_id: nil, pdf: nil, link: nil, nominal_amount: nil, fine_amount: nil,
        interest_amount: nil, discount_amount: nil, discounts: nil, brcode: nil, status: nil, fee: nil,
        transaction_ids: nil, created: nil, updated: nil
      )
        super(id)
        @tax_id = tax_id
        @amount = amount
        @due = due
        @expiration = expiration
        @fine = fine
        @interest = interest
        @tags = tags
        @descriptions = Description.parse_descriptions(descriptions)
        @name = name
        @tax_id = tax_id
        @pdf = pdf
        @link = link
        @nominal_amount = nominal_amount
        @fine_amount = fine_amount
        @interest_amount = interest_amount
        @discount_amount = discount_amount
        @discounts = Discount.parse_discounts(discounts)
        @brcode = brcode
        @status = status
        @fee = fee
        @transaction_ids = transaction_ids
        @created = StarkInfra::Utils::Checks.check_datetime(created)
        @updated = StarkInfra::Utils::Checks.check_datetime(updated)
      end

      def self.parse_invoices(invoices)
        return invoices if invoices.nil?
        parsed_invoices = []
        invoices.each do |invoice|
          unless invoice.is_a? Invoice
            invoice = StarkInfra::Utils::API.from_api_json(resource[:resource_maker], invoice)
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

      # # CreditNote::Invoice::Discount object
      #
      # Invoice discount information.
      #
      # ## Parameters (required):
      # - percentage [float]: percentage of discount applied until specified due date
      # - due [DateTime or string]: due datetime for the discount
      class Discount < StarkInfra::Utils::SubResource
        attr_reader :percentage, :due
        def initialize(percentage:, due:)
          @percentage = percentage
          @due = due
        end

        def self.parse_discounts(discounts)
          return discounts if discounts.nil?

          parsed_discounts = []
          discounts.each do |discount|
            unless discount.is_a? Discount
              discount = StarkInfra::Utils::API.from_api_json(resource[:resource_maker], discount)
            end
            parsed_discounts << discount
          end
          parsed_discounts
        end

        def self.resource
          {
            resource_name: 'Discount',
            resource_maker: proc { |json|
              Discount.new(
                percentage: json['percentage'],
                due: json['due']
              )
            }
          }
        end
      end

      # # CreditNote::Invoice::Description object
      #
      # Invoice description information.
      #
      # ## Parameters (required):
      # - key [string]: Description for the value. ex: 'Taxes'
      #
      # ## Parameters (optional):
      # - value [string]: amount related to the described key. ex: 'R$100,00'
      class Description < StarkInfra::Utils::SubResource
        attr_reader :percentage, :due
        def initialize(key:, value:)
          @key = key
          @value = value
        end

        def self.parse_descriptions(descriptions)
          return descriptions if descriptions.nil?
          parsed_descriptions = []
          descriptions.each do |description|
            unless description.is_a? Description
              description = StarkInfra::Utils::API.from_api_json(resource[:resource_maker], description)
            end
            parsed_descriptions << description
          end
          parsed_descriptions
        end

        def self.resource
          {
            resource_name: 'Description',
            resource_maker: proc { |json|
              Description.new(
                key: json['key'],
                value: json['value']
              )
            }
          }
        end
      end
    end
  end
end
