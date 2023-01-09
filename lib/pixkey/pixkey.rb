# frozen_string_literal: true

require_relative('../utils/rest')
require('starkcore')

module StarkInfra
  # # PixKey object
  # PixKeys link bank account information to key ids.
  # Key ids are a convenient way to search and pass bank account information.
  #
  # When you initialize a Pix Key, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the objects
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - account_created [DateTime or string]: opening Date or DateTime for the linked account. ex: '2020-03-10T10:30:00.000000+00:00' or DateTime.new(2020, 3, 10, 10, 30, 0, 0).
  # - account_number [string]: number of the linked account. ex: '76543'.
  # - account_type [string]: type of the linked account. Options: 'checking', 'savings', 'salary' or 'payment'.
  # - branch_code [string]: branch code of the linked account. ex: '1234'.
  # - name [string]: holder's name of the linked account. ex: 'Jamie Lannister'.
  # - tax_id [string]: holder's taxId (CPF/CNPJ) of the linked account. ex: '012.345.678-90'.
  #
  # ## Parameters (optional):
  # - id [string, default nil]: id of the registered PixKey. Allowed types are: CPF, CNPJ, phone number or email. If this parameter is not passed, an EVP will be created. ex: '+5511989898989'
  # - tags [list of strings, default nil]: list of strings for reference when searching for PixKeys. ex: ['employees', 'monthly']
  #
  # ## Attributes (return-only):
  # - owned [DateTime]: datetime when the key was owned by the holder. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - owner_type [string]: type of the owner of the PixKey. Options: 'business' or 'individual'.
  # - status [string]: current PixKey status. Options: 'created', 'registered', 'canceled', 'failed'
  # - bank_code [string]: bank_code of the account linked to the Pix Key. ex: '20018183'.
  # - bank_name [string]: name of the bank that holds the account linked to the PixKey. ex: 'StarkBank'
  # - type [string]: type of the PixKey. Options: 'cpf', 'cnpj', 'phone', 'email' and 'evp',
  # - created [DateTime]: creation datetime for the PixKey. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class PixKey < StarkCore::Utils::Resource
    attr_reader :account_created, :account_number, :account_type, :branch_code, :name, :tax_id, :id,
                :tags, :owned, :owner_type, :status, :bank_code, :bank_name, :type, :created
    def initialize(
      account_created:, account_number:, account_type:, branch_code:, name:, tax_id:, id: nil, tags: nil, owned: nil,
      owner_type: nil, status: nil, bank_code: nil, bank_name: nil, type: nil, created: nil
    )
      super(id)
      @account_created = account_created
      @account_number = account_number
      @account_type = account_type
      @branch_code = branch_code
      @name = name
      @tax_id = tax_id
      @tags = tags
      @owned = StarkCore::Utils::Checks.check_datetime(owned)
      @owner_type = owner_type
      @status = status
      @bank_code = bank_code
      @bank_name = bank_name
      @type = type
      @created = StarkCore::Utils::Checks.check_datetime(created)
    end

    # # Create a PixKey
    #
    # Send a PixKey objects for creation in the Stark Infra API
    #
    # ## Parameters (required):
    # - key [PixKey object]: PixKey object to be created in the API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixKey object with updated attributes
    def self.create(key, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: key, user: user, **resource)
    end

    # # Retrieve a specific PixKey
    #
    # Receive a single PixKey object previously created in the Stark Infra API by passing its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '+5511989898989'
    # - payer_id [string]: tax id (CPF/CNPJ) of the individual or business requesting the PixKey information. This id is used by the Central Bank to limit request rates. ex: '20.018.183/0001-80'.
    #
    # ## Parameters (optional):
    # - end_to_end_id [string, default nil]: central bank's unique transaction id. If the request results in the creation of a PixRequest, the same end_to_end_id should be used. If this parameter is not passed, one end_to_end_id will be automatically created. Example: 'E00002649202201172211u34srod19le'
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - PixKey object with updated attributes
    def self.get(id, payer_id:, end_to_end_id: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(
        id: id,
        payer_id: payer_id,
        end_to_end_id: end_to_end_id,
        user: user,
        **resource
      )
    end

    # # Retrieve PixKeys
    #
    # Receive a generator of PixKey objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['+5511989898989', '+5511967676767']
    # - type [string, default nil]: filter for the type of retrieved PixKeys. Options: 'cpf', 'cnpj', 'phone', 'email' and 'evp'
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of PixKey objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, type: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        tags: tags,
        ids: ids,
        type: type,
        user: user,
        **resource
      )
    end

    # # Retrieve paged PixKeys
    #
    # Receive a list of up to 100 PixKey objects previously created in the Stark infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your keys.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created or updated only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created or updated only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: filter for status of retrieved objects. ex: 'success' or 'failed'
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['+5511989898989', '+5511967676767']
    # - type [string, default nil]: filter for the type of retrieved PixKeys. Options: 'cpf', 'cnpj', 'phone', 'email' and 'evp'
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of PixKey objects with updated attributes
    # - cursor to retrieve the next page of PixKey objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, tags: nil, ids: nil, type: nil, user: nil)
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
        type: type,
        user: user,
        **resource
      )
    end

    # # Update a PixKey entity
    #
    # Respond to a received PixKey.
    #
    # ## Parameters (required):
    # - id [string]: PixKey unique id. ex: '+5511989898989'
    # - reason [string]: reason why the PixKey is being patched. Options: 'branchTransfer', 'reconciliation' or 'userRequested'.
    #
    # ## Parameters (optional):
    # - account_created [Date, DateTime or string, default nil]: opening Date or DateTime for the account to be linked. ex: '2022-01-01', Date.new(2020, 3, 10) or DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - account_number [string, default nil]: number of the account to be linked. ex: '76543'.
    # - account_type [string, default nil]: type of the account to be linked. Options: 'checking', 'savings', 'salary' or 'payment'.
    # - branch_code [string, default nil]: branch code of the account to be linked. ex: 1234'.
    # - name [string, default nil]: holder's name of the account to be linked. ex: 'Jamie Lannister'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - updated PixKey object
    def self.update(id, reason:, account_created: nil, account_number: nil, account_type: nil, branch_code: nil, name: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        reason: reason,
        account_created: account_created,
        account_number: account_number,
        account_type: account_type,
        branch_code: branch_code,
        name: name,
        user: user,
        **resource
      )
    end

    # # Cancel a PixKey entity
    #
    # Cancel a PixKey entity previously created in the Stark Infra API
    #
    # ## Parameters (required):
    # - id [string]: PixKey unique id. ex: '+5511989898989'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled PixKey object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    def self.resource
      {
        resource_name: 'PixKey',
        resource_maker: proc { |json|
          PixKey.new(
            id: json['id'],
            account_created: json['account_created'],
            account_number: json['account_number'],
            account_type: json['account_type'],
            branch_code: json['branch_code'],
            name: json['name'],
            tax_id: json['tax_id'],
            tags: json['tags'],
            owned: json['owned'],
            owner_type: json['owner_type'],
            status: json['status'],
            bank_code: json['bank_code'],
            bank_name: json['bank_name'],
            type: json['type'],
            created: json['created']
          )
        }
      }
    end
  end
end
