# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/parse')


module StarkInfra
  # # PixReversal object
  #
  # When you initialize a PixReversal, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - amount [integer]: amount in cents to be reversed from PixRequest. ex: 1234 (= R$ 12.34)
  # - external_id [string]: url safe string that must be unique among all your PixReversals. Duplicated external ids will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: "my-internal-id-123456"
  # - end_to_end_id [string]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
  # - reason [string]: reason why the PixRequest is being reversed. Options are "bankError", "fraud", "pixWithdrawError", "refund3ByEndCustomer"
  #
  # ## Parameters (optional):
  # - tags [string, default nill]: [list of strings]: list of strings for reference when searching for PixReversals. ex: ["employees", "monthly"]
  #
  # ## Attributes (return-only):
  # - id [string, default nil]: unique id returned when the PixReversal is created. ex: "5656565656565656".
  # - return_id [string]: central bank's unique reversal transaction ID. ex: "D20018183202202030109X3OoBHG74wo".
  # - bank_code [string]: code of the bank institution in Brazil. ex: "20018183" or "341"
  # - fee [string]: fee charged by this PixReversal. ex: 200 (= R$ 2.00)
  # - status [string]: current PixReversal status. ex: "registered" or "paid"
  # - flow [string]: direction of money flow. ex: "in" or "out"
  # - created [Datetime, default nil]: creation datetime for the PixReversal. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [Datetime, default nil]: latest update datetime for the PixReversal. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)

  class PixReversal < StarkInfra::Utils::Resource;
    attr_reader :amount, :external_id, :end_to_end_id, :reason, :tags, :id, :return_id, :bank_code, :fee, :status, :flow, :created, :updated
    def initialize(
      amount:, external_id:, end_to_end_id:, reason:, tags: nil, id: nil, return_id: nil, bank_code: nil, fee: nil, 
      status: nil, flow: nil, created: nil, updated: nil
    )
      created = StarkInfra::Utils::Checks.check_datetime(created)
      updated = StarkInfra::Utils::Checks.check_datetime(updated)
      super(id)
      @amount = amount
      @external_id = external_id
      @end_to_end_id = end_to_end_id
      @reason = reason
      @tags = tags
      @return_id = return_id
      @bank_code = bank_code
      @fee = fee
      @staus = status
      @flow = flow
      @created = created
      @updated = updated
    end

    # # Create PixRversals
    #
    # Send a list of PixRversal objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - reversals [list of PixRversal objects]: list of PixRversal objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixRversal objects with updated attributes
    def self.create(reversals, user: nil)
      StarkInfra::Utils::Rest.post(entities: reversals, user: user, **resource)
    end

    # # Retrieve a specific PixRversal
    #
    # Receive a single PixRversal object previously created in the Stark Bank API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixRversal object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixRversals
    #
    # Receive a generator of PixRversal objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - fields [list of strings, default None]: parameters to be retrieved from PixRequest objects. ex: ["amount", "id"]
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date, DateTime, Time or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date, DateTime, Time or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - return_ids [list of strings, default None]: central bank's unique reversal transaction ID. ex: ["D20018183202202030109X3OoBHG74wo", "D20018183202202030109X3OoBHG72rd"].
    # - external_ids [list of strings, default None]: url safe string that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    # - user [Organization/Project object]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixRversal objects with updated attributes
    def self.query(fields:nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, return_ids: nil, external_ids: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(
        fields: fields,
        limit: limit,
        after: StarkInfra::Utils::Checks.check_date(after),
        before: StarkInfra::Utils::Checks.check_date(before),
        status: status,
        tags: tags,
        ids: ids,
        return_ids: return_ids,
        external_ids: external_ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixRversals
    #
    # Receive a list of up to 100 PixRversal objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - fields [list of strings, default None]: parameters to be retrieved from PixRequest objects. ex: ["amount", "id"]
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date, DateTime, Time or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date, DateTime, Time or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'paid' or 'registered'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - return_ids [list of strings, default None]: central bank's unique reversal transaction ID. ex: ["D20018183202202030109X3OoBHG74wo", "D20018183202202030109X3OoBHG72rd"].
    # - external_ids [list of strings, default None]: url safe string that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: ["my-internal-id-123456", "my-internal-id-654321"]
    # - user [Organization/Project object]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixRversal objects with updated attributes and cursor to retrieve the next page of PixRversal objects
    def self.page(cursor: nil, fields:nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, return_ids: nil, external_ids: nil, user: nil)
      return StarkInfra::Utils::Rest.get_page(
        fields: fields,
        cursor: cursor,
        limit: limit,
        after: StarkInfra::Utils::Checks.check_date(after),
        before: StarkInfra::Utils::Checks.check_date(before),
        status: status,
        tags: tags,
        ids: ids,
        return_ids: return_ids,
        external_ids: external_ids,
        user: user,
        **resource
      )
    end

    def self.parse(content:, signature:, user: nil)
      # # Create single verified PixReversal object from a content string
      # 
      # Create a single PixReversal object from a content string received from a handler listening at a subscribed user endpoint.
      # If the provided digital signature does not check out with the StarkInfra public key, a
      # starkinfra.exception.InvalidSignatureException will be raised.
      # 
      # ## Parameters (required):
      # - content [string]: response content from revrsal received at user endpoint (not parsed)
      # - signature [string]: base-64 digital signature received at response header "Digital-Signature"
      # 
      # ## Parameters (optional):
      # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
      # 
      # ## Return:
      # - Parsed PixReversal object
      return StarkInfra::Utils::Parse.parse_and_verify(content: content, signature: signature, user: user, resource: resource)
    end      

    def self.resource
      {
        resource_name: 'PixReversal',
        resource_maker: proc { |json|
          PixReversal.new(
            amount: json['amount'],
            external_id: json['external_id'],
            end_to_end_id: json['end_to_end_id'],
            reason: json['reason'],
            tags: json['tags'],
            id: json['id'],
            return_id: json['return_id'],
            bank_code: json['bank_code'],
            fee: json['fee'],
            status: json['status'],
            flow: json['flow'],
            created: json['created'],
            updated: json['updated'],
          )
        }
      }
    end
  end
end