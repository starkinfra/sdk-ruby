# frozen_string_literal: true

require_relative('../utils/rest')
require_relative('../utils/checks')
require_relative('../utils/resource')

module StarkInfra
  # # PixClaim object
  #
  # A Pix Claim is a request to transfer a Pix Key from an account hosted at another
  # Pix participant to an account under your bank code. Pix Claims must always be requested by the claimer.
  #
  # When you initialize a PixClaim, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - account_created [Date, DateTime or string]: opening Date or DateTime for the account claiming the PixKey. ex: '2022-01-01', Date.new(2020, 3, 10) or DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - account_number [string]: number of the account claiming the PixKey. ex: '76543'.
  # - account_type [string]: type of the account claiming the PixKey. Options: 'checking', 'savings', 'salary' or 'payment'.
  # - branch_code [string]: branch code of the account claiming the PixKey. ex: 1234'.
  # - name [string]: holder's name of the account claiming the PixKey. ex: 'Jamie Lannister'.
  # - tax_id [string]: holder's taxId of the account claiming the PixKey (CPF/CNPJ). ex: '012.345.678-90'.
  # - key_id [string]: id of the registered Pix Key to be claimed. Allowed keyTypes are CPF, CNPJ, phone number or email. ex: '+5511989898989'.
  #
  # ## Parameters (optional):
  # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the PixClaim is created. ex: '5656565656565656'
  # - status [string]: current PixClaim status. Options: 'created', 'failed', 'delivered', 'confirmed', 'success', 'canceled'
  # - type [string]: type of Pix Claim. Options: 'ownership', 'portability'.
  # - key_type [string]: keyType of the claimed Pix Key. Options: 'CPF', 'CNPJ', 'phone' or 'email'
  # - flow [string]: direction of the Pix Claim. Options: 'in' if you received the PixClaim or 'out' if you created the PixClaim.
  # - claimer_bank_code [string]: bank_code of the Pix participant that created the PixClaim. ex: '20018183'.
  # - claimed_bank_code [string]: bank_code of the account donating the PixClaim. ex: '20018183'.
  # - created [DateTime]: creation datetime for the PixClaim. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: update datetime for the PixClaim. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixClaim < StarkInfra::Utils::Resource
    attr_reader :account_created, :account_number, :account_type, :branch_code, :name, :tax_id, :key_id,
                :tags, :id, :status, :type, :key_type, :flow, :claimer_bank_code, :claimed_bank_code, :created, :updated
    def initialize(
      account_created:, account_number:, account_type:, branch_code:, name:,
      tax_id:, key_id:, tags: nil, id: nil, status: nil, type: nil, key_type: nil, flow: nil,
      claimer_bank_code: nil, claimed_bank_code: nil, created: nil, updated: nil
    )
      super(id)
      @account_created = account_created
      @account_number = account_number
      @account_type = account_type
      @branch_code = branch_code
      @name = name
      @tax_id = tax_id
      @key_id = key_id
      @tags = tags
      @status = status
      @type = type
      @key_type = key_type
      @flow = flow
      @claimer_bank_code = claimer_bank_code
      @claimed_bank_code = claimed_bank_code
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
    end

    # # Create a PixClaim object
    #
    # Create a PixClaim to request the transfer of a Pix Key from an account
    # hosted at another Pix participants to an account under you bank code.
    #
    # ## Parameters (required):
    # - claim [PixClaim object]: PixClaim object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixClaim object with updated attributes
    def self.create(claim, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: claim, user: user, **resource)
    end

    # # Retrieve a PixClaim object
    #
    # Retrieve a PixClaim object linked to your Workspace in the Stark Infra API by its id.
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixClaim object that corresponds to the given id.
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve PixClaims
    #
    # Receive a generator of PixClaim objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. Options: 'created', 'failed', 'delivered', 'confirmed', 'success', 'canceled'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - type [string, default nil]: filter for the type of retrieved PixClaims. Options: 'ownership' or 'portability'
    # - key_type [string, default nil]: filter for the PixKey type of retrieved PixClaims. Options: 'cpf', 'cnpj', 'phone', 'email' and 'evp',
    # - key_id [string, default nil]: filter PixClaims linked to a specific PixKey id. Example: '+5511989898989'.
    # - flow [string, default nil]: direction of the Pix Claim. Options: 'in' if you received the PixClaim or 'out' if you created the PixClaim.
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixClaim objects with updated attributes
    def self.query(
      limit: nil, after: nil, before: nil, status: nil, ids: nil,
      type: nil, flow: nil, tags: nil, key_type: nil, key_id: nil, user: nil
    )
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
        key_type: key_type,
        key_id: key_id,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixClaims
    #
    # Receive a list of up to 100 PixClaim objects previously created in the Stark infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your claims.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. Options: 'created', 'failed', 'delivered', 'confirmed', 'success', 'canceled'
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - type [string, default nil]: filter for the type of retrieved PixClaims. Options: 'ownership' or 'portability'
    # - key_type [string, default nil]: filter for the PixKey type of retrieved PixClaims. Options: 'cpf', 'cnpj', 'phone', 'email' and 'evp',
    # - key_id [string, default nil]: filter PixClaims linked to a specific PixKey id. Example: '+5511989898989'.
    # - flow [string, default nil]: direction of the Pix Claim. Options: 'in' if you received the PixClaim or 'out' if you created the PixClaim.
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixClaim objects with updated attributes
    # - cursor to retrieve the next page of PixClaim objects
    def self.page(
      cursor: nil, limit: nil, after: nil, before: nil, status: nil, ids: nil,
      type: nil, flow: nil, tags: nil, key_type: nil, key_id: nil, user: nil
    )
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        ids: ids,
        type: type,
        flow: flow,
        tags: tags,
        key_type: key_type,
        key_id: key_id,
        user: user,
        **resource
      )
    end

    # # Update a PixClaim entity
    #
    # Respond to a received PixClaim.
    #
    # ## Parameters (required):
    # - id [string]: PixClaim unique id. ex: '5656565656565656'
    # - status [string]: patched status for Pix Claim. Options: 'confirmed' and 'canceled'
    #
    # ## Parameters (optional):
    # - reason [string, default 'userRequested']: reason why the PixClaim is being patched. Options: 'fraud', 'userRequested', 'accountClosure'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - updated PixClaim object
    def self.update(id, status:, reason: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        status: status,
        reason: reason,
        user: user,
        **resource
      )
    end

    def self.resource
      {
        resource_name: 'PixClaim',
        resource_maker: proc { |json|
          PixClaim.new(
            id: json['id'],
            account_created: json['account_created'],
            account_number: json['account_number'],
            account_type: json['account_type'],
            branch_code: json['branch_code'],
            name: json['name'],
            tax_id: json['tax_id'],
            key_id: json['key_id'],
            tags: json['tags'],
            status: json['status'],
            type: json['type'],
            key_type: json['key_type'],
            flow: json['flow'],
            claimer_bank_code: json['claimer_bank_code'],
            claimed_bank_code: json['claimed_bank_code'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
