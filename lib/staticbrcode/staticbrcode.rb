# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../utils/parse')

module StarkInfra
  # # StaticBrcode object
  #
  # A StaticBrcode stores account information in the form of a PixKey and can be used to create
  # Pix transactions easily.
  #
  # When you initialize a StaticBrcode, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  ## Parameters (required):
  # - name [string]: receiver's name. ex: 'Tony Stark'
  # - key_id [string]: receiver's Pixkey id. ex: '+5541999999999'
  # - city [string, default São Paulo]: receiver's city name. ex: 'Rio de Janeiro'
  #
  # ## Parameters (optional):
  # - amount [integer, default nil]: positive integer that represents the amount in cents of the resulting Pix transaction. If the amount is zero, the sender can choose any amount in the moment of payment. ex: 1234 (= R$ 12.34)
  # - cashier_bank_code [string, default None]: Cashier's bank code. ex: "20018183".
  # - reconciliation_id [string, default nil]: id to be used for conciliation of the resulting Pix transaction. This id must have up to 25 alphanumeric digits ex: 'ah27s53agj6493hjds6836v49'
  # - description [string, default None]: optional description to override default description to be shown in the bank statement. ex: "Payment for service #1234"
  # - tags [list of strings, default nil]:  list of strings for tagging. ex: ['travel', 'food']
  #
  # ## Attributes (return-only):
  # - id [string]: id returned on creation, this is the BR Code. ex: '00020126360014br.gov.bcb.pix0114+552840092118152040000530398654040.095802BR5915Jamie Lannister6009Sao Paulo620705038566304FC6C'
  # - uuid [string]: unique uuid returned when a StaticBrcode is created. ex: '97756273400d42ce9086404fe10ea0d6'
  # - url [string]: url link to the BR Code image. ex: 'https://brcode-h.development.starkinfra.com/static-qrcode/97756273400d42ce9086404fe10ea0d6.png'
  # - created [DateTime]: creation datetime for the StaticBrcode. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the StaticBrcode. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class StaticBrcode < StarkCore::Utils::Resource
    attr_reader :name, :key_id, :city, :amount, :cashier_bank_code, :description, :reconciliation_id, :id, :tags, :uuid, :url, :created, :updated
    def initialize(
      name:, key_id:, city:, amount:, cashier_bank_code: nil, description: nil, reconciliation_id: nil, id: nil, tags:nil, uuid: nil, url: nil, created: nil, updated: nil
    )
      super(id)
      @name = name
      @key_id = key_id
      @city = city
      @amount = amount
      @reconciliation_id = reconciliation_id
      @cashier_bank_code = cashier_bank_code
      @description = description
      @tags = tags
      @uuid = uuid
      @url = url
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create StaticBrcodes
    #
    # Send a list of StaticBrcode objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - brcodes [list of StaticBrcode objects]: list of StaticBrcode objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of StaticBrcode objects with updated attributes
    def self.create(brcodes, user: nil)
      StarkInfra::Utils::Rest.post(entities: brcodes, user: user, **resource)
    end

    # # Retrieve a specific StaticBrcode
    #
    # Receive a single StaticBrcode object previously created in the Stark Infra API by its uuid
    #
    # ## Parameters (required):
    # - uuid [string]: object's unique uuid. ex: '97756273400d42ce9086404fe10ea0d6'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - StaticBrcode object with updated attributes
    def self.get(uuid, user: nil)
      StarkInfra::Utils::Rest.get_id(id: uuid, user: user, **resource)
    end

    # # Retrieve StaticBrcodes
    #
    # Receive a generator of StaticBrcode objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - uuids [list of strings, default nil]: list of uuids to filter retrieved objects. ex: ['901e71f2447c43c886f58366a5432c4b', '4e2eab725ddd495f9c98ffd97440702d']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of StaticBrcode objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, uuids: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        uuids: uuids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve StaticBrcodes
    #
    # Receive a list of StaticBrcode objects previously created in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - uuids [list of strings, default nil]: list of uuids to filter retrieved objects. ex: ['901e71f2447c43c886f58366a5432c4b', '4e2eab725ddd495f9c98ffd97440702d']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of StaticBrcode objects with updated attributes
    # - cursor to retrieve the next page of StaticBrcode objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, tags: nil, uuids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        uuids: uuids,
        tags: tags,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'StaticBrcode',
        resource_maker: proc { |json|
          StaticBrcode.new(
            id: json['id'],
            name: json['name'],
            key_id: json['key_id'],
            city: json['city'],
            amount: json['amount'],
            reconciliation_id: json['reconciliation_id'],
            cashier_bank_code: json['cashier_bank_code'],
            description: json['description'],
            tags: json['tags'],
            uuid: json['uuid'],
            url: json['url'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
