# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/parse')
require('starkcore')

module StarkInfra
  # # PixReversal object
  #
  # PixReversals are instant payments used to revert PixRequests. You can
  # only revert inbound PixRequests.
  #
  # When you initialize a PixReversal, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the list of created objects.
  #
  # ## Parameters (required):
  # - amount [integer]: amount in cents to be reversed from PixRequest. ex: 1234 (= R$ 12.34)
  # - external_id [string]: string that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: 'my-internal-id-123456'
  # - end_to_end_id [string]: central bank's unique transaction ID. ex: 'E79457883202101262140HHX553UPqeq'
  # - reason [string]: reason why the PixRequest is being reversed. Options are 'bankError', 'fraud', 'pixWithdrawError', 'refund3ByEndCustomer'
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for reference when searching for PixReversals. ex: ['employees', 'monthly']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixReversal is created. ex: '5656565656565656'.
  # - return_id [string]: central bank's unique reversal transaction ID. ex: 'D20018183202202030109X3OoBHG74wo'.
  # - fee [string]: fee charged by this PixReversal. ex: 200 (= R$ 2.00)
  # - status [string]: current PixReversal status. ex: 'registered' or 'paid'
  # - flow [string]: direction of money flow. ex: 'in' or 'out'
  # - created [DateTime]: creation datetime for the PixReversal. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixReversal. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixReversal < StarkCore::Utils::Resource
    attr_reader :amount, :external_id, :end_to_end_id, :reason, :tags, :id, :return_id,
                :fee, :status, :flow, :created, :updated
    def initialize(
      amount:, external_id:, end_to_end_id:, reason:, tags: nil, id: nil, return_id: nil, fee: nil,
      status: nil, flow: nil, created: nil, updated: nil
    )
      super(id)
      @amount = amount
      @external_id = external_id
      @end_to_end_id = end_to_end_id
      @reason = reason
      @tags = tags
      @return_id = return_id
      @fee = fee
      @status = status
      @flow = flow
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create PixReversals
    #
    # Send a list of PixReversal objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - reversals [list of PixReversal objects]: list of PixReversal objects to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixReversal objects with updated attributes
    def self.create(reversals, user: nil)
      StarkInfra::Utils::Rest.post(entities: reversals, user: user, **resource)
    end

    # # Retrieve a specific PixReversal
    #
    # Receive a single PixReversal object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixReversal object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixReversals
    #
    # Receive a generator of PixReversal objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - return_ids [list of strings, default nil]: central bank's unique reversal transaction ID. ex: ['D20018183202202030109X3OoBHG74wo', 'D20018183202202030109X3OoBHG72rd'].
    # - external_ids [list of strings, default nil]: url safe string that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: ['my-internal-id-123456', 'my-internal-id-654321']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixReversal objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, return_ids: nil, external_ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        ids: ids,
        return_ids: return_ids,
        external_ids: external_ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixReversals
    #
    # Receive a list of up to 100 PixReversal objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your reversals.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'paid' or 'registered'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - return_ids [list of strings, default nil]: central bank's unique reversal transaction ID. ex: ['D20018183202202030109X3OoBHG74wo', 'D20018183202202030109X3OoBHG72rd'].
    # - external_ids [list of strings, default nil]: url safe string that must be unique among all your PixReversals. Duplicated external IDs will cause failures. By default, this parameter will block any PixReversal that repeats amount and receiver information on the same date. ex: ['my-internal-id-123456', 'my-internal-id-654321']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixReversal objects with updated attributes
    # - cursor to retrieve the next page of PixReversal objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, return_ids: nil, external_ids: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: StarkCore::Utils::Checks.check_date(after),
        before: StarkCore::Utils::Checks.check_date(before),
        status: status,
        tags: tags,
        ids: ids,
        return_ids: return_ids,
        external_ids: external_ids,
        user: user,
        **resource
      )
    end

    # # Create single verified PixReversal object from a content string
    #
    # Create a single PixReversal object from a content string received from a handler listening at a subscribed user endpoint.
    # If the provided digital signature does not check out with the StarkInfra public key, a
    # StarkInfra.Error.InvalidSignatureError will be raised.
    #
    # ## Parameters (required):
    # - content [string]: response content from reversal received at user endpoint (not parsed)
    # - signature [string]: base-64 digital signature received at response header 'Digital-Signature'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - Parsed PixReversal object
    def self.parse(content:, signature:, user: nil)
      reversal = StarkInfra::Utils::Parse.parse_and_verify(
        content: content,
        signature: signature,
        user: user,
        resource: resource
      )

      !reversal.fee.nil? ? reversal.fee : 0
      !reversal.tags.nil? ? reversal.tags : []
      !reversal.external_id.nil? ? reversal.external_id : ''
      !reversal.description.nil? ? reversal.description : ''

      reversal
    end

    # Helps you respond to a PixReversal authorization
    #
    ## Parameters (required):
    # - status [string]: response to the authorization. ex: 'approved' or 'denied'
    #
    ## Parameters (conditionally required):
    # - reason [string, default nil]: denial reason. Options: 'invalidAccountNumber', 'blockedAccount', 'accountClosed', 'invalidAccountType', 'invalidTransactionType', 'taxIdMismatch', 'invalidTaxId', 'orderRejected', 'reversalTimeExpired', 'settlementFailed'
    #
    ## Return:
    # - Dumped JSON string that must be returned to us
    def self.response(status:, reason: nil)
      response = {
        authorization: {
          status: status,
          reason: reason
        }
      }.to_json

      response
    end

    def self.resource
      {
        resource_name: 'PixReversal',
        resource_maker: proc { |json|
          PixReversal.new(
            id: json['id'],
            amount: json['amount'],
            external_id: json['external_id'],
            end_to_end_id: json['end_to_end_id'],
            reason: json['reason'],
            tags: json['tags'],
            return_id: json['return_id'],
            fee: json['fee'],
            status: json['status'],
            flow: json['flow'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
