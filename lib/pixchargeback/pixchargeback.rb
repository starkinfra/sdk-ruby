# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')

module StarkInfra
  # # PixChargeback object
  #
  # A Pix chargeback can be created when fraud is detected on a transaction or a system malfunction
  # results in an erroneous transaction.
  # It notifies another participant of your request to reverse the payment they have received.
  # When you initialize a PixChargeback, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  #
  # ## Parameters (required):
  # - amount [integer]: amount in cents to be reversed. ex: 11234 (= R$ 112.34)
  # - reference_id [string]: end_to_end_id or return_id of the transaction to be reversed. ex: 'E20018183202201201450u34sDGd19lz'
  # - reason [string]: reason why the reversal was requested. Options: 'fraud', 'flaw', 'reversalChargeback'
  #
  # ## Parameters (optional):
  # - description [string, default nil]: description for the PixChargeback. ex: 'Payment for service #1234'
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when PixChargeback is created. ex: '5656565656565656'
  # - analysis [string]: analysis that led to the result.
  # - bacen_id [string]: central bank's unique UUID that identifies the PixChargeback.
  # - sender_bank_code [string]: bank_code of the Pix participant that created the PixChargeback. ex: '20018183'
  # - receiver_bank_code [string]: bank_code of the Pix participant that received the PixChargeback. ex: '20018183'
  # - rejection_reason [string]: reason for the rejection of the Pix chargeback. Options: 'noBalance', 'accountClosed', 'unableToReverse'
  # - reversal_reference_id [string]: return id of the reversal transaction. ex: 'D20018183202202030109X3OoBHG74wo'.
  # - id [string]: unique id returned when the PixChargeback is created. ex: '5656565656565656'
  # - result [string]: result after the analysis of the PixChargeback by the receiving party. Options: 'rejected', 'accepted', 'partiallyAccepted'
  # - status [string]: current PixChargeback status. Options: 'created', 'failed', 'delivered', 'closed', 'canceled'.
  # - created [DateTime]: creation datetime for the PixChargeback. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixChargeback. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixChargeback < StarkInfra::Utils::Resource
    attr_reader :amount, :reference_id, :reason, :description, :id, :analysis, :bacen_id, :sender_bank_code,
                :receiver_bank_code, :rejection_reason, :reversal_reference_id, :result, :status, :created, :updated
    def initialize(
      amount:, reference_id:, reason:, description: nil, id: nil, analysis: nil, bacen_id: nil,
      sender_bank_code: nil, receiver_bank_code: nil, rejection_reason: nil, reversal_reference_id: nil,
      result: nil, status: nil, created: nil, updated: nil
    )
      super(id)
      @amount = amount
      @reference_id = reference_id
      @reason = reason
      @description = description
      @analysis = analysis
      @bacen_id = bacen_id
      @sender_bank_code = sender_bank_code
      @receiver_bank_code = receiver_bank_code
      @rejection_reason = rejection_reason
      @reversal_reference_id = reversal_reference_id
      @result = result
      @status = status
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    # # Create PixChargebacks
    #
    # Send a list of PixChargeback objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - chargebacks [list of PixChargeback objects]: list of PixChargeback objects to be created in the API. ex: [PixChargeback.new()]
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixChargeback objects with updated attributes
    def self.create(chargebacks, user: nil)
      StarkInfra::Utils::Rest.post(entities: chargebacks, user: user, **resource)
    end

    # # Retrieve a specific PixChargeback
    #
    # Receive a single PixChargeback object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixChargeback object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixChargebacks
    #
    # Receive a generator of PixChargeback objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixChargeback objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, ids: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixChargebacks
    #
    # Receive a list of up to 100 PixChargeback objects previously created in the Stark infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your chargebacks.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixChargeback objects with updated attributes
    # - cursor to retrieve the next page of PixChargeback objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, ids: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        user: user,
        **resource
      )
    end

    # # Update a PixChargeback entity
    #
    # Respond to a received PixChargeback.
    #
    # ## Parameters (required):
    # - id [string]: PixChargeback unique id. ex: '5656565656565656'
    # - result [string]: result of the PixChargeback. Options: 'rejected', 'accepted', 'partiallyAccepted'.
    #
    # ## Parameters (conditionally required):
    # - rejection_reason [string, default nil]: if the PixChargeback is rejected a reason is required. Options: 'noBalance', 'accountClosed', 'unableToReverse',
    # - reversal_reference_id [string, default nil]: return_id of the reversal transaction. ex: 'D20018183202201201450u34sDGd19lz'
    #
    # ## Parameters (optional):
    # - analysis [string, default nil]: description of the analysis that led to the result.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - updated PixChargeback object
    def self.update(id, result:, rejection_reason: nil, reversal_reference_id: nil, analysis: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        result: result,
        rejection_reason: rejection_reason,
        analysis: analysis,
        reversal_reference_id: reversal_reference_id,
        user: user,
        **resource
      )
    end

    # # Cancel a PixChargeback entity
    #
    # Cancel a PixChargeback entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: PixChargeback unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled PixChargeback object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'PixChargeback',
        resource_maker: proc { |json|
          PixChargeback.new(
            amount: json['amount'],
            reference_id: json['reference_id'],
            reason: json['reason'],
            description: json['description'],
            id: json['id'],
            analysis: json['analysis'],
            bacen_id: json['bacen_id'],
            sender_bank_code: json['sender_bank_code'],
            receiver_bank_code: json['receiver_bank_code'],
            rejection_reason: json['rejection_reason'],
            reversal_reference_id: json['reversal_reference_id'],
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
