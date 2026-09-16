# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # BusinessAccountRequest object
  #
  # Request to open a Stark Infra account for a company. Each of the company's owners completes an
  # identity verification through an independent webview, delivered as the owner's validator_link. The
  # API runs the approval flow asynchronously, moving the request through 'created' -> 'processing' ->
  # ('approved' | 'denied'); 'failed' when the request could not be processed.
  #
  # When you initialize a BusinessAccountRequest, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - address [BusinessAccountRequest::Address object]: company's structured address. ex: StarkInfra::BusinessAccountRequest::Address.new(street: 'Av. Faria Lima', number: '2000', neighborhood: 'Itaim Bibi', city: 'Sao Paulo', state: 'SP', zip_code: '04538-132')
  # - revenue [integer]: company's annual revenue in cents. ex: 100000000 (= R$ 1,000,000.00)
  # - name [string]: company's legal name (minimum 5 characters). ex: 'Stark Bank S.A.'
  # - tax_id [string]: company's tax ID (CNPJ). ex: '20.018.183/0001-80'
  # - owners [list of BusinessAccountRequest::Owner objects]: list of 1 to 10 company owners. ex: [StarkInfra::BusinessAccountRequest::Owner.new(tax_id: '012.345.678-90', name: 'Jamie Lannister', role: 'partner')]
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for reference when searching for BusinessAccountRequests. ex: ['employees', 'monthly']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the BusinessAccountRequest is created. ex: '5656565656565656'
  # - account_type [string]: type of the account. ex: 'business'
  # - flags [list of hashes]: flags that motivated the decision, populated when the request is denied. Each flag has a code and a message. ex: [{'code' => 'failedIdentityProof', 'message' => 'O representante: 012.345.678-90 falhou na verificação de identidade.'}]
  # - status [string]: current status of the BusinessAccountRequest. Options: 'created', 'processing', 'approved', 'denied', 'failed'
  # - created [DateTime]: creation datetime for the BusinessAccountRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the BusinessAccountRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class BusinessAccountRequest < StarkCore::Utils::Resource
    attr_reader :address, :revenue, :name, :tax_id, :owners, :tags, :id, :account_type, :flags, :status, :created, :updated
    def initialize(address:, revenue:, name:, tax_id:, owners:, tags: nil, id: nil, account_type: nil,
                   flags: nil, status: nil, created: nil, updated: nil)
      super(id)
      @address = BusinessAccountRequest.parse_address(address)
      @revenue = revenue
      @name = name
      @tax_id = tax_id
      @owners = BusinessAccountRequest.parse_owners(owners)
      @tags = tags
      @account_type = account_type
      @flags = flags
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create BusinessAccountRequests
    #
    # Send a list of BusinessAccountRequest objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - requests [list of BusinessAccountRequest objects]: list of BusinessAccountRequest objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of BusinessAccountRequest objects with updated attributes
    def self.create(requests, user: nil)
      StarkInfra::Utils::Rest.post(entities: requests, user: user, **resource)
    end

    # # Retrieve a specific BusinessAccountRequest
    #
    # Receive a single BusinessAccountRequest object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - BusinessAccountRequest object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve BusinessAccountRequests
    #
    # Receive a generator of BusinessAccountRequest objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'processing', 'approved', 'denied', 'failed']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of BusinessAccountRequest objects with updated attributes
    def self.query(limit: nil, status: nil, tags: nil, ids: nil, after: nil, before: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        status: status,
        tags: tags,
        ids: ids,
        after: after,
        before: before,
        user: user,
        **resource
      )
    end

    # # Retrieve paged BusinessAccountRequests
    #
    # Receive a list of up to 100 BusinessAccountRequest objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 50
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['created', 'processing', 'approved', 'denied', 'failed']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of BusinessAccountRequest objects with updated attributes
    # - cursor to retrieve the next page of BusinessAccountRequest objects
    def self.page(cursor: nil, limit: nil, status: nil, tags: nil, ids: nil, after: nil, before: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        status: status,
        tags: tags,
        ids: ids,
        after: after,
        before: before,
        user: user,
        **resource
      )
    end

    def self.parse_address(address)
      return nil if address.nil?
      return address if address.is_a?(Address)

      address_maker = Address.resource[:resource_maker]
      StarkCore::Utils::API.from_api_json(address_maker, address)
    end

    def self.parse_owners(owners)
      return nil if owners.nil?

      owner_maker = Owner.resource[:resource_maker]
      owners.map do |owner|
        owner.is_a?(Owner) ? owner : StarkCore::Utils::API.from_api_json(owner_maker, owner)
      end
    end

    def self.resource
      {
        resource_name: 'BusinessAccountRequest',
        resource_maker: proc { |json|
          BusinessAccountRequest.new(
            id: json['id'],
            address: json['address'],
            revenue: json['revenue'],
            name: json['name'],
            tax_id: json['tax_id'],
            owners: json['owners'],
            tags: json['tags'],
            account_type: json['account_type'],
            flags: json['flags'],
            status: json['status'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end

    # # BusinessAccountRequest::Address object
    #
    # The Address object is the structured address of the company referenced by a
    # BusinessAccountRequest. It is embedded on the parent's address field and has no endpoints of its own.
    #
    # ## Parameters (required):
    # - street [string]: street name. ex: 'Av. Faria Lima'
    # - number [string]: street number. ex: '2000'
    # - neighborhood [string]: neighborhood / district. ex: 'Itaim Bibi'
    # - city [string]: city. ex: 'Sao Paulo'
    # - state [string]: state (BR 2-letter code). ex: 'SP'
    # - zip_code [string]: ZIP code (BR CEP), formatted or digit-only. ex: '04538-132'
    #
    # ## Parameters (optional):
    # - complement [string, default nil]: address complement. ex: 'Sala 42'
    class Address < StarkCore::Utils::SubResource
      attr_reader :street, :number, :neighborhood, :city, :state, :zip_code, :complement
      def initialize(street:, number:, neighborhood:, city:, state:, zip_code:, complement: nil)
        @street = street
        @number = number
        @neighborhood = neighborhood
        @city = city
        @state = state
        @zip_code = zip_code
        @complement = complement
      end

      def self.resource
        {
          resource_name: 'Address',
          resource_maker: proc { |json|
            Address.new(
              street: json['street'],
              number: json['number'],
              neighborhood: json['neighborhood'],
              city: json['city'],
              state: json['state'],
              zip_code: json['zip_code'],
              complement: json['complement']
            )
          }
        }
      end
    end

    # # BusinessAccountRequest::Owner object
    #
    # The Owner object represents a company owner referenced by a BusinessAccountRequest. Each owner
    # completes its own identity verification through an independent webview. It is embedded on the
    # parent's owners field and has no endpoints of its own.
    #
    # ## Parameters (required):
    # - tax_id [string]: owner's tax ID (CPF). ex: '012.345.678-90'
    # - name [string]: owner's full name (minimum 5 characters). ex: 'Jamie Lannister'
    # - role [string]: owner's role in the company. Options: 'partner', 'representative'
    #
    # ## Attributes (return-only):
    # - identity_id [string]: unique id of the identity verification linked to this owner. ex: '5709594221805568'
    # - validator_link [string]: webview link to be delivered to the owner to complete biometrics and document capture. Treat it as a credential: deliver it through a secure channel and never log it.
    # - status [string]: current status of the owner verification. Options: 'created', 'approved', 'denied'
    class Owner < StarkCore::Utils::SubResource
      attr_reader :tax_id, :name, :role, :identity_id, :validator_link, :status
      def initialize(tax_id:, name:, role:, identity_id: nil, validator_link: nil, status: nil)
        @tax_id = tax_id
        @name = name
        @role = role
        @identity_id = identity_id
        @validator_link = validator_link
        @status = status
      end

      def self.resource
        {
          resource_name: 'Owner',
          resource_maker: proc { |json|
            Owner.new(
              tax_id: json['tax_id'],
              name: json['name'],
              role: json['role'],
              identity_id: json['identity_id'],
              validator_link: json['validator_link'],
              status: json['status']
            )
          }
        }
      end
    end
  end
end
