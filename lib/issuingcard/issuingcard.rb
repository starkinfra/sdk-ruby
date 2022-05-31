# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')

module StarkInfra
  # # IssuingCard object
  #
  # The IssuingCard object displays the information of the cards created in your Workspace.
  # Sensitive information will only be returned when the 'expand' parameter is used, to avoid security concerns.
  #
  # ## Parameters (required):
  # - holder_name [string]: card holder name. ex: 'Tony Stark'
  # - holder_tax_id [string]: card holder tax ID. ex: '012.345.678-90'
  # - holder_external_id [string] card holder unique id, generated by the user to avoid duplicated holders. ex: 'my-entity/123'
  #
  # ## Parameters (optional):
  # - display_name [string, default nil]: card displayed name. ex: 'ANTHONY STARK'
  # - rules [list of IssuingRule objects, default nil]: [EXPANDABLE] list of card spending rules.
  # - bin_id [string, default nil]: BIN ID to which the card is bound. ex: '53810200'
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
  # - street_line_1 [string, default nil]: card holder main address. ex: 'Av. Paulista, 200'
  # - street_line_2 [string, default nil]: card holder address complement. ex: 'Apto. 123'
  # - district [string, default nil]: card holder address district / neighbourhood. ex: 'Bela Vista'
  # - city [string, default nil]: card holder address city. ex: 'Rio de Janeiro'
  # - state_code [string, default nil]: card holder address state. ex: 'GO'
  # - zip_code [string, default nil]: card holder address zip code. ex: '01311-200'
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingCard is created. ex: '5656565656565656'
  # - holder_id [string]: card holder unique id. ex: '5656565656565656'
  # - type [string]: card type. ex: 'virtual'
  # - status [string]: current IssuingCard status. ex: 'active', 'blocked', 'canceled', 'expired'.
  # - number [string]: [EXPANDABLE] masked card number. Expand to unmask the value. ex: '123'.
  # - security_code [string]: [EXPANDABLE] masked card verification value (cvv). Expand to unmask the value. ex: '123'.
  # - expiration [string]: [EXPANDABLE] masked card expiration datetime. Expand to unmask the value. ex: '2032-02-29T23:59:59.999999+00:00'.
  # - created [DateTime]: creation datetime for the IssuingCard. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the IssuingCard. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingCard < StarkInfra::Utils::Resource
    attr_reader :id, :holder_id, :holder_name, :holder_tax_id, :holder_external_id, :type, :display_name, :status,
      :rules, :bin_id, :street_line_1, :street_line_2, :district, :city, :state_code, :zip_code, :tags, :number,
      :security_code, :expiration, :created, :updated
    def initialize(
      holder_name:, holder_tax_id:, holder_external_id:, id: nil, holder_id: nil, type: nil,
      display_name: nil, status: nil, rules: nil, bin_id: nil, street_line_1: nil, street_line_2: nil, district: nil,
      city: nil, state_code: nil, zip_code: nil, tags: nil, number: nil, security_code: nil, expiration: nil,
      created: nil, updated: nil
    )
      super(id)
      @holder_name = holder_name
      @holder_tax_id = holder_tax_id
      @holder_external_id = holder_external_id
      @holder_id = holder_id
      @type = type
      @display_name = display_name
      @status = status
      @rules = StarkInfra::IssuingRule.parse_rules(rules)
      @bin_id = bin_id
      @street_line_1 = street_line_1
      @street_line_2 = street_line_2
      @district = district
      @city = city
      @state_code = state_code
      @zip_code = zip_code
      @tags = tags
      @number = number
      @security_code = security_code
      @expiration = expiration
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    # # Create IssuingCards
    #
    # Send a list of IssuingCard objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - cards [list of IssuingCard objects]: list of IssuingCard objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingCard objects with updated attributes
    def self.create(cards:, expand: nil, user: nil)
      StarkInfra::Utils::Rest.post(entities: cards, expand: expand, user: user, **resource)
    end

    # # Retrieve a specific IssuingCard
    #
    # Receive a single IssuingCard object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: fields to expand information. ex: ['rules', 'securityCode', 'number', 'expiration']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingCard object with updated attributes
    def self.get(id, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, expand: expand, user: user, **resource)
    end

    # # Retrieve IssuingCards
    #
    # Receive a generator of IssuingCards objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - after [DateTime or string, default nil] date filter for objects created only after specified date. ex: DateTime.new(2020, 3, 10)
    # - before [DateTime or string, default nil] date filter for objects created only before specified date. ex: DateTime.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['active', 'blocked', 'canceled', 'expired']
    # - types [list of strings, default nil]: card type. ex: ['virtual']
    # - holder_ids [list of strings]: card holder IDs. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - expand [list of strings, default []]: fields to expand information. ex: ['rules', 'security_code', 'number', 'expiration']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingCards objects with updated attributes
    def self.query(limit: nil, ids: nil, after: nil, before: nil, status: nil, types: nil, holder_ids: nil, tags: nil,
                   expand: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        ids: ids,
        after: after,
        before: before,
        status: status,
        types: types,
        holder_ids: holder_ids,
        tags: tags,
        expand: expand,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingCards
    #
    # Receive a list of IssuingCards objects previously created in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - after [DateTime or string, default nil] date filter for objects created only after specified date. ex: DateTime.new(2020, 3, 10)
    # - before [DateTime or string, default nil] date filter for objects created only before specified date. ex: DateTime.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['active', 'blocked', 'canceled', 'expired']
    # - types [list of strings, default nil]: card type. ex: ['virtual']
    # - holder_ids [list of strings]: card holder IDs. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - expand [list of strings, default []]: fields to expand information. ex: ['rules', 'security_code', 'number', 'expiration']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingCards objects with updated attributes
    # - cursor to retrieve the next page of IssuingCards objects
    def self.page(cursor: nil, limit: nil, ids: nil, after: nil, before: nil, status: nil, types: nil, holder_ids: nil,
                  tags: nil, expand: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        ids: ids,
        after: after,
        before: before,
        status: status,
        types: types,
        holder_ids: holder_ids,
        tags: tags,
        expand: expand,
        user: user,
        **resource
      )
    end

    # # Update IssuingCard entity
    #
    # Update an IssuingCard by passing id.
    #
    # ## Parameters (required):
    # - id [string]: IssuingCard unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - status [string, default nil]: You may block the IssuingCard by passing 'blocked' or activate by passing 'active' in the status
    # - display_name [string, default nil]: card displayed name
    # - rules [list of IssuingRule objects, default nil]: [EXPANDABLE] list of card spending rules.
    # - tags [list of strings, default nil]: list of strings for tagging
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - target IssuingCard with updated attributes
    def self.update(id, status: nil, display_name: nil, rules: nil, tags: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        status: status,
        display_name: display_name,
        rules: rules,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Cancel an IssuingCard entity
    #
    # Cancel an IssuingCard entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: IssuingCard unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled IssuingCard object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'IssuingCard',
        resource_maker: proc { |json|
          IssuingCard.new(
            id: json['id'],
            holder_id: json['holder_id'],
            holder_name: json['holder_name'],
            holder_tax_id: json['holder_tax_id'],
            holder_external_id: json['holder_external_id'],
            type: json['type'],
            display_name: json['display_name'],
            status: json['status'],
            rules: json['rules'],
            bin_id: json['bin_id'],
            street_line_1: json['street_line_1'],
            street_line_2: json['street_line_2'],
            district: json['district'],
            city: json['city'],
            state_code: json['state_code'],
            zip_code: json['zip_code'],
            tags: json['tags'],
            number: json['number'],
            security_code: json['security_code'],
            expiration: json['expiration'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
