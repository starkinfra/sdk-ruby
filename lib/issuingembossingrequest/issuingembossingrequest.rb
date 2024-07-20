# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingEmbossingRequest object
  #
  # The IssuingEmbossingRequest object displays the information of embossing requests in your Workspace.
  #
  # ## Parameters (required):
  # - card_id [string]: id of the IssuingCard to be embossed. ex "5656565656565656"
  # - kit_id [string]: card embossing kit id. ex "5656565656565656"
  # - display_name_1 [string]: card displayed name. ex: "ANTHONY STARK"
  # - shipping_city [string]: shipping city. ex: "NEW YORK"
  # - shipping_country_code [string]: shipping country code. ex: "US"
  # - shipping_district [string]: shipping district. ex: "NY"
  # - shipping_state_code [string]: shipping state code. ex: "NY"
  # - shipping_street_line_1 [string]: shipping main address. ex: "AVENUE OF THE AMERICAS"
  # - shipping_street_line_2 [string]: shipping address complement. ex: "Apt. 6"
  # - shipping_service [string]: shipping service. ex: "loggi"
  # - shipping_tracking_number [string]: shipping tracking number. ex: "5656565656565656"
  # - shipping_zip_code [string]: shipping zip code. ex: "12345-678"
  #
  # ## Parameters (optional):
  # - embosser_id [string, default nil]: id of the card embosser. ex: "5656565656565656"
  # - display_name_2 [string, default nil]: card displayed name. ex: "IT Services"
  # - display_name_3 [string, default nil]: card displayed name. ex: "StarkBank S.A."
  # - shipping_phone [string, deafult nil]: shipping phone. ex: "+5511999999999"
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ["card", "corporate"]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingEmbossingRequest is created. ex: "5656565656565656"
  # - fee [integer]: fee charged when IssuingEmbossingRequest is created. ex: 1000
  # - status [string]: status of the IssuingEmbossingRequest. ex: "created", "processing", "success", "failed"
  # - updated [DateTime]: latest update datetime for the IssuingEmbossingRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingEmbossingRequest. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingEmbossingRequest < StarkCore::Utils::Resource
    attr_reader :card_id, :kit_id, :display_name_1, :shipping_city, :shipping_country_code, 
                :shipping_district, :shipping_state_code, :shipping_street_line_1, :shipping_street_line_2, 
                :shipping_service, :shipping_tracking_number, :shipping_zip_code, :embosser_id, :display_name_2, 
                :display_name_3, :shipping_phone, :tags, :id, :fee, :status, :created, :updated
    def initialize(
      card_id:, kit_id:, display_name_1:, shipping_city:, 
      shipping_country_code:, shipping_district:, shipping_state_code:, shipping_street_line_1:, 
      shipping_street_line_2:, shipping_service:, shipping_tracking_number:, shipping_zip_code:, 
      embosser_id: nil, display_name_2: nil, display_name_3: nil, shipping_phone: nil, 
      tags: nil, id: nil, fee: nil, status: nil, updated: nil, created: nil
    )
      super(id)
      @card_id = card_id
      @kit_id = kit_id
      @display_name_1 = display_name_1
      @shipping_city = shipping_city
      @shipping_country_code = shipping_country_code
      @shipping_district = shipping_district
      @shipping_state_code = shipping_state_code
      @shipping_street_line_1 = shipping_street_line_1
      @shipping_street_line_2 = shipping_street_line_2
      @shipping_service = shipping_service
      @shipping_tracking_number = shipping_tracking_number
      @shipping_zip_code = shipping_zip_code
      @embosser_id = embosser_id
      @display_name_2 = display_name_2
      @display_name_3 = display_name_3
      @shipping_phone = shipping_phone
      @tags = tags
      @fee = fee
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create IssuingEmbossingRequests
    #
    # Send a list of IssuingEmbossingRequest objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - requests [list of IssuingEmbossingRequest objects]: list of IssuingEmbossingRequest objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingEmbossingRequest objects with updated attributes
    def self.create(requests:, user: nil)
      StarkInfra::Utils::Rest.post(entities: requests, user: user, **resource)
    end

    # # Retrieve a specific IssuingEmbossingRequest
    #
    # Receive a single IssuingEmbossingRequest object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingEmbossingRequest object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingEmbossingRequests
    #
    # Receive a generator of IssuingEmbossingRequests objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "success", "failed"]
    # - card_ids [list of string, default nil]: list of card_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingEmbossingRequests objects with updated attributes
    def self.query( 
      limit: nil, after: nil, before: nil, status: nil, card_ids: nil, ids: nil, 
      tags: nil, user: nil
    )
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        card_ids: card_ids,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingEmbossingRequests
    #
    # Receive a list of up to 100 IssuingEmbossingRequest objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ["created", "processing", "success", "failed"]
    # - card_ids [list of string, default nil]: list of card_ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingEmbossingRequests objects with updated attributes
    # - cursor to retrieve the next page of IssuingEmbossingRequests objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, card_ids: nil, ids: nil, tags: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        card_ids: card_ids,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingEmbossingRequest',
        resource_maker: proc { |json|
          IssuingEmbossingRequest.new(
            card_id: json['card_id'],
            kit_id: json['kit_id'],
            display_name_1: json['display_name_1'],
            shipping_city: json['shipping_city'],
            shipping_country_code: json['shipping_country_code'],
            shipping_district: json['shipping_district'],
            shipping_state_code: json['shipping_state_code'],
            shipping_street_line_1: json['shipping_street_line_1'],
            shipping_street_line_2: json['shipping_street_line_2'],
            shipping_service: json['shipping_service'],
            shipping_tracking_number: json['shipping_tracking_number'],
            shipping_zip_code: json['shipping_zip_code'],
            embosser_id: json['embosser_id'],
            display_name_2: json['display_name_2'],
            display_name_3: json['display_name_3'],
            shipping_phone: json['shipping_phone'],
            tags: json['tags'],
            id: json['id'],
            fee: json['fee'],
            status: json['status'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
