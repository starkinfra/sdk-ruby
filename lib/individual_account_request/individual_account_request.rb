# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IndividualAccountRequest object
  #
  # Request to open a Stark Infra account for an individual. The caller submits the individual's
  # identifying data and income, and the API runs the approval flow asynchronously. Supporting
  # documents are uploaded as IndividualAccountAttachment objects referencing this request.
  #
  # When you initialize an IndividualAccountRequest, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - name [string]: full legal name of the individual. ex: 'Tony Stark'
  # - tax_id [string]: individual's Brazilian CPF. ex: '012.345.678-90' or '01234567890'
  # - address [IndividualAccountRequest::Address object]: structured residential address.
  # - income [integer]: monthly income in cents. Must be >= 0. ex: 1000000 (= R$ 10,000.00)
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for reference when searching for IndividualAccountRequests. ex: ['employees', 'monthly']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the IndividualAccountRequest is created. ex: '5656565656565656'
  # - status [string]: current status of the IndividualAccountRequest. Options: 'approved', 'created', 'denied', 'processing', 'updated'
  # - account_type [string]: account type of the request. Always 'individual' for this resource. ex: 'individual'
  # - flags [list of strings]: server-side review flags. Empty unless the request triggered a manual-review condition.
  # - created [DateTime]: creation datetime for the IndividualAccountRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the IndividualAccountRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IndividualAccountRequest < StarkCore::Utils::Resource
    attr_reader :name, :tax_id, :address, :income, :tags, :id, :status, :account_type, :flags, :created, :updated
    def initialize(
      name:, tax_id:, address:, income:, tags: nil,
      id: nil, status: nil, account_type: nil, flags: nil, created: nil, updated: nil
    )
      super(id)
      @name = name
      @tax_id = tax_id
      @address = IndividualAccountRequest::Address.parse_address(address)
      @income = income
      @tags = tags
      @status = status
      @account_type = account_type
      @flags = flags
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create IndividualAccountRequests
    #
    # Send a list of IndividualAccountRequest objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - requests [list of IndividualAccountRequest objects]: list of IndividualAccountRequest objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IndividualAccountRequest objects with updated attributes
    def self.create(requests, user: nil)
      # Output-only fields (id, status, account_type, flags, created, updated) are
      # rejected by the API on POST with "Unknown parameters in JSON: ...". Strip
      # them from a shallow dup so the caller's objects are unmodified. The core
      # serializer (StarkCore::Utils::API.build_entity_hash) skips nil ivars.
      stripped = requests.map do |req|
        copy = req.dup
        %i[@id @status @account_type @flags @created @updated].each do |ivar|
          copy.instance_variable_set(ivar, nil)
        end
        copy
      end
      StarkInfra::Utils::Rest.post(entities: stripped, user: user, **resource)
    end

    # # Retrieve a specific IndividualAccountRequest
    #
    # Receive a single IndividualAccountRequest object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IndividualAccountRequest object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IndividualAccountRequests
    #
    # Receive a generator of IndividualAccountRequest objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'created'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IndividualAccountRequest objects with updated attributes
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

    # # Retrieve paged IndividualAccountRequests
    #
    # Receive a list of up to 100 IndividualAccountRequest objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'created'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IndividualAccountRequest objects with updated attributes
    # - cursor to retrieve the next page of IndividualAccountRequest objects
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

    # # Update an IndividualAccountRequest entity
    #
    # Update an IndividualAccountRequest by passing its id.
    #
    # ## Parameters (required):
    # - id [string]: IndividualAccountRequest unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - name [string, default nil]: replace the legal name. ex: 'Tony Stark'
    # - tax_id [string, default nil]: replace the CPF. ex: '012.345.678-90'
    # - address [IndividualAccountRequest::Address object, default nil]: replace the address as a whole object.
    # - income [integer, default nil]: replace monthly income in cents. ex: 1000000
    # - status [string, default nil]: manual state transition. ex: 'processing'
    # - tags [list of strings, default nil]: replace tag list. ex: ['employees', 'monthly']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - target IndividualAccountRequest with updated attributes
    def self.update(id, name: nil, tax_id: nil, address: nil, income: nil, status: nil, tags: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        name: name,
        tax_id: tax_id,
        address: address,
        income: income,
        status: status,
        tags: tags,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IndividualAccountRequest',
        resource_maker: proc { |json|
          IndividualAccountRequest.new(
            id: json['id'],
            name: json['name'],
            tax_id: json['tax_id'],
            address: json['address'],
            income: json['income'],
            tags: json['tags'],
            status: json['status'],
            account_type: json['account_type'],
            flags: json['flags'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end

    # # IndividualAccountRequest::Address object
    #
    # Structured residential address embedded as the `address` field on an IndividualAccountRequest.
    # Serialized as a nested JSON object on the wire (never flattened).
    #
    # ## Parameters (required):
    # - street [string]: street name. ex: 'Rua do Estilo Barroco'
    # - number [string]: street number. ex: '648'
    # - neighborhood [string]: neighborhood / district. ex: 'Santo Amaro'
    # - city [string]: city. ex: 'SP'
    # - state [string]: state (BR 2-letter code). ex: 'SP'
    # - zip_code [string]: ZIP code (BR CEP). ex: '05724005'
    class Address < StarkCore::Utils::SubResource
      attr_reader :street, :number, :neighborhood, :city, :state, :zip_code
      def initialize(street: nil, number: nil, neighborhood: nil, city: nil, state: nil, zip_code: nil)
        @street = street
        @number = number
        @neighborhood = neighborhood
        @city = city
        @state = state
        @zip_code = zip_code
      end

      def self.parse_address(address)
        return address if address.nil? || address.is_a?(IndividualAccountRequest::Address)

        StarkCore::Utils::API.from_api_json(resource[:resource_maker], address)
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
              zip_code: json['zip_code']
            )
          }
        }
      end
    end
  end
end
