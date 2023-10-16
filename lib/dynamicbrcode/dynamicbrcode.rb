# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/parse')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # DynamicBrcode object
  #
  # BR Codes store information represented by Pix QR Codes, which are used to
  # send or receive Pix transactions in a convenient way.
  # DynamicBrcodes represent charges with information that can change at any time,
  # since all data needed for the payment is requested dynamically to an URL stored
  # in the BR Code. Stark Infra will receive the GET request and forward it to your
  # registered endpoint with a GET request containing the UUID of the BR Code for
  # identification.
  #
  # When you initialize a DynamicBrcode, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - name [string]: receiver's name. ex: 'Tony Stark'
  # - city [string]: receiver's city name. ex: 'Rio de Janeiro'
  # - external_id [string]: string that must be unique among all your DynamicBrcodes. Duplicated external ids will cause failures. ex: 'my-internal-id-123456'
  #
  # ## Parameters (optional):
  # - type [string, default 'instant']: type of the DynamicBrcode. Options: 'instant', 'due'
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
  #
  # ## Attributes (return-only):
  # - id [string]: id returned on creation, this is the BR Code. ex: '00020126360014br.gov.bcb.pix0114+552840092118152040000530398654040.095802BR5915Jamie Lannister6009Sao Paulo620705038566304FC6C'
  # - uuid [string]: unique uuid returned when the DynamicBrcode is created. ex: '4e2eab725ddd495f9c98ffd97440702d'
  # - url [string]: url link to the BR Code image. ex: 'https://brcode-h.development.starkinfra.com/dynamic-qrcode/901e71f2447c43c886f58366a5432c4b.png'
  # - created [DateTime]: creation datetime for the DynamicBrcode. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the DynamicBrcode. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class DynamicBrcode < StarkInfra::Utils::Resource
    attr_reader :name, :city, :external_id, :type, :tags, :id, :uuid, :url, :updated, :created
    def initialize(name:, city:, external_id:, type: nil, tags: nil, id: nil, uuid: nil, url: nil, updated: nil, created: nil)
      super(id)
      @name = name
      @city = city
      @external_id = external_id
      @type = type
      @tags = tags
      @uuid = uuid
      @url = url
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    # # Create DynamicBrcodes
    #
    # Send a list of DynamicBrcode objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - brcodes [list of DynamicBrcode objects]: list of DynamicBrcode objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of DynamicBrcode objects with updated attributes
    def self.create(brcodes, user: nil)
      StarkInfra::Utils::Rest.post(entities: brcodes, user: user, **resource)
    end

    # # Retrieve a specific DynamicBrcode
    #
    # Receive a single DynamicBrcode object previously created in the Stark Infra API by its uuid
    #
    # ## Parameters (required):
    # - uuid [string]: object's unique uuid. ex: '901e71f2447c43c886f58366a5432c4b'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - DynamicBrcode object with updated attributes
    def self.get(uuid, user: nil)
      StarkInfra::Utils::Rest.get_id(id: uuid, user: user, **resource)
    end

    # # Retrieve DynamicBrcodes
    #
    # Receive a generator of DynamicBrcode objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - external_ids [list of strings, default nil]: list of external_ids to filter retrieved objects. ex: ['my_external_id1', 'my_external_id2']
    # - uuids [list of strings, default nil]: list of uuids to filter retrieved objects. ex: ['901e71f2447c43c886f58366a5432c4b', '4e2eab725ddd495f9c98ffd97440702d']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of DynamicBrcode objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, external_ids: nil, uuids: nil, tags: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        external_ids: external_ids,
        uuids: uuids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve DynamicBrcodes
    #
    # Receive a list of DynamicBrcode objects previously created in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - external_ids [list of strings, default nil]: list of external_ids to filter retrieved objects. ex: ['my_external_id1', 'my_external_id2']
    # - uuids [list of strings, default nil]: list of uuids to filter retrieved objects. ex: ['901e71f2447c43c886f58366a5432c4b', '4e2eab725ddd495f9c98ffd97440702d']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of DynamicBrcode objects with updated attributes
    # - cursor to retrieve the next page of DynamicBrcode objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, tags: nil, uuids: nil, external_ids: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        external_ids: external_ids,
        uuids: uuids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Helps you respond to a due DynamicBrcode Read
    #
    # When a Due DynamicBrcode is read by your user, a GET request containing the Brcode's
    # UUID will be made to your registered URL to retrieve additional information needed
    # to complete the transaction.
    # The get request must be answered in the following format, within 5 seconds, and with
    # an HTTP status code 200.
    #
    # ## Parameters (required):
    # - version [integer]: integer that represents how many times the BR Code was updated.
    # - created [DateTime or string]: creation datetime in ISO format of the DynamicBrcode. ex: "2020-03-10T10:30:00.000000+00:00" or DateTime.new(2020, 3, 10, 10, 30, 0, 0).
    # - due [Date or string]: requested payment due datetime in ISO format. ex: "2020-03-10T10:30:00.000000+00:00" or DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - key_id [string]: receiver's PixKey id. Can be a taxId (CPF/CNPJ), a phone number, an email or an alphanumeric sequence (EVP). ex: '+5511989898989'
    # - status [string]: BR Code status. Options: "created", "overdue", "paid", "canceled" or "expired"
    # - reconciliation_id [string]: id to be used for conciliation of the resulting Pix transaction. This id must have from to 26 to 35 alphanumeric characters' ex: "cd65c78aeb6543eaaa0170f68bd741ee"
    # - nominal_amount [integer]: positive integer that represents the amount in cents of the resulting Pix transaction. ex: 1234 (= R$ 12.34)
    # - sender_name [string]: sender's full name. ex: "Anthony Edward Stark"
    # - sender_tax_id [string]: sender's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: '01.001.001/0001-01'
    # - receiver_name [string]: receiver's full name. ex: "Jamie Lannister"
    # - receiver_tax_id [string]: receiver's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: '012.345.678-90'
    # - receiver_street_line [string]: receiver's main address. ex: "Av. Paulista, 200"
    # - receiver_city [string]: receiver's address city name. ex: "Sao Paulo"
    # - receiver_state_code [string]: receiver's address state code. ex: "SP"
    # - receiver_zip_code [string]: receiver's address zip code. ex: "01234-567"
    #
    # ## Parameters (optional):
    # - expiration [integer]: time in seconds counted from the creation datetime until the DynamicBrcode expires. After expiration, the BR Code cannot be paid anymore.
    # - fine [float, default 2.0]: Percentage charged if the sender pays after the due datetime. ex. 2.0
    # - interest [float, default 1.0]: Interest percentage charged if the sender pays after the due datetime. ex: 1.5
    # - discounts [list of dictionaries, default nil]: discount amount applied if the sender pays at a specific datetime before the due datetime.
    # - description [string, default nil]: additional information to be shown to the sender at the moment of payment. ex: 'Response Due DynamicBrocde'
    #
    # ## Return:
    # - Dumped JSON string that must be returned to us
    def self.response_due(
      version: , created: , due: , key_id: , status: , reconciliation_id: , nominal_amount: ,
      sender_name: , sender_tax_id: , receiver_name: , receiver_tax_id: , receiver_street_line: ,
      receiver_city: , receiver_state_code: , receiver_zip_code: , expiration: , fine: , interest: ,
      discounts: , description:
    )

      params = {
        'version': version,
        'created': created,
        'due': due,
        'keyId': key_id,
        'status': status,
        'reconciliationId': reconciliation_id,
        'nominalAmount': nominal_amount,
        'senderName': sender_name,
        'senderTaxId': sender_tax_id,
        'receiverName': receiver_name,
        'receiverTaxId': receiver_tax_id,
        'receiverStreetLine': receiver_street_line,
        'receiverCity': receiver_city,
        'receiverStateCode': receiver_state_code,
        'receiverZipCode': receiver_zip_code,
        'expiration': expiration,
        'fine': fine,
        'interest': interest,
        'discounts': Discount.parse_discounts(discounts),
        'description': description
      }

      params.to_json
    end

    # # Helps you respond to an instant DynamicBrcode Read
    #
    # When an instant DynamicBrcode is read by your user, a GET request containing the BR Code's UUID will be made
    # to your registered URL to retrieve additional information needed to complete the transaction.
    # The get request must be answered in the following format within 5 seconds and with an HTTP status code 200.
    #
    # ## Parameters (required):
    # - version [integer]: integer that represents how many times the BR Code was updated.
    # - created [DateTime or string]: creation datetime of the DynamicBrcode. ex: "2020-03-10T10:30:00.000000+00:00" or DateTime.new(2020, 3, 10, 10, 30, 0, 0).
    # - key_id [string]: receiver's PixKey id. Can be a tax_id (CPF/CNPJ), a phone number, an email or an alphanumeric sequence (EVP). ex: '+5511989898989'
    # - status [string]: BR Code status. Options: 'created', 'overdue', 'paid', 'canceled' or 'expired'
    # - reconciliation_id [string]: id to be used for conciliation of the resulting Pix transaction. This id must have from to 26 to 35 alphanumeric characters' ex: "cd65c78aeb6543eaaa0170f68bd741ee"
    # - amount [integer]: positive integer that represents the amount in cents of the resulting Pix transaction. ex: 1234 (= R$ 12.34)
    #
    # ## Parameters (required):
    # - cashier_type [string, default nil]: cashier's type. Required if the cashAmount is different from 0. Options: 'merchant', 'participant' and 'other'
    # - cashier_bank_code [string, default nil]: cashier's bank code. Required if the cash_amount is different from 0. ex: '20018183'
    #
    # ## Parameters (optional):
    # - expiration [integer, default nil]: time in seconds counted from the creation datetime until the DynamicBrcode expires. After expiration, the BR Code cannot be paid anymore. ex: 123456789
    # - cash_amount [integer, default nil]: amount to be withdrawn from the cashier in cents. ex: 1000 (= R$ 10.00)
    # - sender_name [string, default nil]: sender's full name. ex: 'Anthony Edward Stark'
    # - sender_tax_id [string, default nil]: sender's CPF (11 digits formatted or unformatted) or CNPJ (14 digits formatted or unformatted). ex: '01.001.001/0001-01'
    # - amount_type [string, default 'fixed']: amount type of the BR Code. If the amount type is 'custom' the Brcode's amount can be changed by the sender at the moment of payment. Options: 'fixed' or 'custom'
    # - description [string, default nil]: additional information to be shown to the sender at the moment of payment. ex: 'Response Instant DynamicBrocde'
    #
    # ## Return:
    # # - Dumped JSON string that must be returned to us
    def self.response_instant(
      version:, created:, key_id:, status:, reconciliation_id:, amount:, cashier_type:,
      cashier_bank_code:, cash_amount:, expiration:, sender_name:, sender_tax_id:,
      amount_type:, description:
    )
      params = {
        'version': version,
        'created': created,
        'keyId': key_id,
        'status': status,
        'reconciliationId': reconciliation_id,
        'amount': amount,
        'cashierType': cashier_type,
        'cashierBankCode': cashier_bank_code,
        'cashAmount': cash_amount,
        'expiration': expiration,
        'senderName': sender_name,
        'senderTaxId': sender_tax_id,
        'amountType': amount_type,
        'description': description
      }

      params.to_json
    end

    # # Verify a DynamicBrcode Read
    #
    # When a DynamicBrcode is read by your user, a GET request will be made to your registered URL to
    # retrieve additional information needed to complete the transaction.
    # Use this method to verify the authenticity of a GET request received at your registered endpoint.
    # If the provided digital signature does not check out with the StarkInfra public key,
    # a stark.exception.InvalidSignatureException will be raised.
    #
    # ## Parameters (required):
    # - uuid [string]: unique uuid of the DynamicBrcode, passed as a path variable in the DynamicBrcode Read request. ex: "4e2eab725ddd495f9c98ffd97440702d"
    # - signature [string]: base-64 digital signature received at response header 'Digital-Signature'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - verified Brcode's uuid.
    def self.verify(uuid:, signature:, user: nil)
      StarkInfra::Utils::Parse.verify(content: uuid, signature: signature, user: user)
    end

    def self.resource
      {
        resource_name: 'DynamicBrcode',
        resource_maker: proc { |json|
          DynamicBrcode.new(
            id: json['id'],
            name: json['name'],
            city: json['city'],
            external_id: json['external_id'],
            type: json['type'],
            tags: json['tags'],
            uuid: json['uuid'],
            url: json['url'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end

    # # DynamicBrcode.Discount object
    #
    # Used to define a Discount in the BR Code
    #
    # ## Parameters (required):
    # - percentage [integer]: discount percentage that will be applied. ex: 2.5
    # - due [DateTime or string, default now + 2 days]: Date after when the discount will be overdue in UTC ISO format. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0) or "2020-03-10T10:30:00.000000+00:00"
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

          if discount.is_a? DynamicBrcode::Discount
            discount = StarkInfra::Utils::API.api_json(discount)
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
  end
end
