# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # PixInfraction object
  #
  # PixInfractions are used to report transactions that are suspected of
  # fraud, to request a refund or to reverse a refund.
  # When you initialize a PixInfraction, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - reference_id [string]: end_to_end_id or return_id of the transaction being reported. ex: 'E20018183202201201450u34sDGd19lz'
  # - type [string]: type of infraction report. Options: 'fraud', 'reversal', 'reversalChargeback'
  #
  # ## Parameters (optional):
  # - description [string, default nil]: description for any details that can help with the infraction investigation.
  # - tags [list of strings, default nil]:  list of strings for tagging. ex: ['travel', 'food']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixInfraction is created. ex: '5656565656565656'
  # - credited_bank_code [string]: bank_code of the credited Pix participant in the reported transaction. ex: '20018183'
  # - debited_bank_code [string]: bank_code of the debited Pix participant in the reported transaction. ex: '20018183'
  # - flow [string]: direction of the PixInfraction flow. Options: 'out' if you created the PixInfraction, 'in' if you received the PixInfraction.
  # - analysis [string]: analysis that led to the result.
  # - reported_by [string]: agent that reported the PixInfraction. Options: 'debited', 'credited'.
  # - result [string]: result after the analysis of the PixInfraction by the receiving party. Options: 'agreed', 'disagreed'
  # - status [string]: current PixInfraction status. Options: 'created', 'failed', 'delivered', 'closed', 'canceled'.
  # - created [DateTime]: creation datetime for the PixInfraction. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the PixInfraction. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixInfraction < StarkInfra::Utils::Resource
    attr_reader :reference_id, :type, :description, :tags, :id, :credited_bank_code, :flow, :analysis,
                :debited_bank_code, :reported_by, :result, :status, :created, :updated
    def initialize(
      reference_id:, type:, description: nil, id: nil, tags: nil, credited_bank_code: nil, debited_bank_code: nil,
      flow: nil, analysis: nil, reported_by: nil, result: nil, status: nil, created: nil, updated: nil
    )
      super(id)
      @reference_id = reference_id
      @type = type
      @description = description
      @tags = tags
      @credited_bank_code = credited_bank_code
      @flow = flow
      @analysis = analysis
      @debited_bank_code = debited_bank_code
      @reported_by = reported_by
      @result = result
      @status = status
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    # # Create PixInfractions
    #
    # Send a list of PixInfraction objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - infractions [list of PixInfraction objects]: list of PixInfraction objects to be created in the API. ex: [PixInfraction.new()]
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixInfraction objects with updated attributes
    def self.create(infractions, user: nil)
      StarkInfra::Utils::Rest.post(entities: infractions, user: user, **resource)
    end

    # # Retrieve a specific PixInfraction
    #
    # Receive a single PixInfraction object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixInfraction object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixInfractions
    #
    # Receive a generator of PixInfraction objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - type [string]: filter for the type of retrieved PixInfractions. Options: 'fraud', 'reversal', 'reversalChargeback'
    # - flow [string, default nil]: direction of the PixInfraction flow. Options: 'out' if you created the PixInfraction, 'in' if you received the PixInfraction.
    # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixInfraction objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, ids: nil, type: nil, flow: nil, tags: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        type: type,
        flow: flow,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixInfractions
    #
    # Receive a list of up to 100 PixInfraction objects previously created in the Stark infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your infractions.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - type [string, default nil]: filter for the type of retrieved PixInfractions. Options: 'fraud', 'reversal', 'reversalChargeback'
    # - flow [string, default nil]: direction of the PixInfraction flow. Options: 'out' if you created the PixInfraction, 'in' if you received the PixInfraction.
    # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixInfraction objects with updated attributes
    # - cursor to retrieve the next page of PixInfraction objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, ids: nil, flow: nil, tags: nil, type: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        flow: flow,
        tags: tags,
        type: type,
        user: user,
        **resource
      )
    end

    # # Update a PixInfraction entity
    #
    # Respond to a received PixInfraction.
    #
    # ## Parameters (required):
    # - id [string]: PixInfraction unique id. ex: '5656565656565656'
    # - result [string]: result after the analysis of the PixInfraction. Options: 'agreed', 'disagreed'
    #
    # ## Parameters (optional):
    # - analysis [string, nil]: analysis that led to the result.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - updated PixInfraction object
    def self.update(id, result:, analysis: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(id: id, result: result, analysis: analysis, user: user, **resource)
    end

    # # Cancel a PixInfraction entity
    #
    # Cancel a PixInfraction entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: PixInfraction unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled PixInfraction object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'PixInfraction',
        resource_maker: proc { |json|
          PixInfraction.new(
            id: json['id'],
            reference_id: json['reference_id'],
            type: json['type'],
            description: json['description'],
            tags: json['tags'],
            credited_bank_code: json['credited_bank_code'],
            debited_bank_code: json['debited_bank_code'],
            flow: json['flow'],
            analysis: json['analysis'],
            reported_by: json['reported_by'],
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
