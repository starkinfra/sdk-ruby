# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # IssuingDesign object
  #
  # The IssuingDesign object displays information on the card and card package designs available to your Workspace.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingDesign is created. ex: "5656565656565656"
  # - name [string]: card or package design name. ex: "stark-plastic-dark-001"
  # - embosser_ids [list of strings]: list of embosser unique ids. ex: ["5136459887542272", "5136459887542273"]
  # - type [string]: card or package design type. Options: "card", "envelope"
  # - updated [DateTime]: latest update datetime for the IssuingDesign. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingDesign. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingDesign < StarkInfra::Utils::Resource
    attr_reader :id, :name, :embosser_ids, :type, :updated, :created
    def initialize(
      id: nil, name: nil, embosser_ids: nil, type: nil, updated: nil, created: nil
    )
      super(id)
      @name = name,
      @embosser_ids = embosser_ids,
      @type = type,
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
      @created = StarkInfra::Utils::Checks.check_datetime(created)
    end

    # # Retrieve a specific IssuingDesign
    #
    # Receive a single IssuingDesign object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingDesign object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingDesigns
    #
    # Receive a generator of IssuingDesigns objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingDesigns objects with updated attributes
    def self.query(limit: nil, ids: nil, tags: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        ids: ids,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingDesigns
    #
    # Receive a list of IssuingDesigns objects previously created in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingDesign objects with updated attributes
    # - cursor to retrieve the next page of IssuingDesign objects
    def self.page(cursor: nil, limit: nil, status: nil, tags: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        status: status,
        tags: tags,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'IssuingDesign',
        resource_maker: proc { |json|
          IssuingDesign.new(
            id: json['id'],
            name: json['name'],
            embosser_ids: json['embosser_ids'],
            type: json['type'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
