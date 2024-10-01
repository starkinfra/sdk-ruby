# frozen_string_literal: true
require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # CreditHolmes object
  #
  # CreditHolmes are used to obtain debt information on your customers.
  # Before you create a CreditHolmes, make sure you have your customer's express
  # authorization to verify their information in the Central Bank's SCR.
  #
  # When you initialize a CreditHolmes, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - tax_id [string]: customer's tax ID (CPF or CNPJ) for whom the credit operations will be verified. ex: "20.018.183/0001-80"
  #
  # ## Parameters (optional):
  # - competence [string, default 'two months before current date']: competence month of the operation verification, format: "YYYY-MM". ex: "2021-04"
  # - tags [list of strings, default []]: list of strings for reference when searching for CreditHolmes. ex: ["credit", "operation"]
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the CreditHolmes is created. ex: "5656565656565656"
  # - result [dictionary]: result of the investigation after the case is solved.
  # - status [string]: current status of the CreditHolmes. ex: "created", "failed", "success"
  # - created [DateTime]: creation datetime for the CreditHolmes. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the CreditHolmes. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class CreditHolmes < StarkCore::Utils::Resource
    attr_reader :tax_id, :competence, :tags, :id, :result, :status, :updated, :created
    def initialize(tax_id:, competence: nil, tags: nil, id: nil, result: nil, status: nil, updated: nil, created: nil)
      super(id)
      @tax_id = tax_id
      @competence = competence
      @tags = tags
      @id = id
      @result = result
      @status = status
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create CreditHolmes
    #
    # Send a list of CreditHolmes objects for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - holmes [list of CreditHolmes objects]: list of CreditHolmes objects to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of CreditHolmes object with updated attributes
    def self.create(holmes, user: nil)
      StarkInfra::Utils::Rest.post(entities: holmes, user: user, **resource)
    end

    # # Retrieve a specific CreditHolmes
    #
    # Receive a single CreditHolmes object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: "5656565656565656"
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - CreditHolmes object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve CreditHolmes
    #
    # Receive a generator of CreditHolmes objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: "created", "failed", "success"
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of CreditHolmes objects with updated attributes
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

    # # Retrieve CreditHolmes
    #
    # Receive a list of up to 100 CreditHolmes objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: "created", "failed", "success"
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ["tony", "stark"]
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ["5656565656565656", "4545454545454545"]
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of CreditHolmes objects with updated attributes
    # - cursor to retrieve the next page of CreditHolmes objects
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

    def self.resource
      {
        resource_name: 'CreditHolmes',
        resource_maker: proc { |json|
          CreditHolmes.new(
            tax_id: json['tax_id'],
            competence: json['competence'],
            tags: json['tags'],
            id: json['id'],
            result: json['result'],
            status: json['status'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
