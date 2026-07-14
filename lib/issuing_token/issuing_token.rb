# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../utils/parse')

module StarkInfra
  # # IssuingToken object
  #
  # The IssuingToken object displays the information of the tokens created in your Workspace.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingToken is created. ex: '5656565656565656'
  # - card_id [string]: card ID which the token is bounded to. ex: '5656565656565656'
  # - wallet_id [string]: wallet provider which the token is bounded to. ex: 'google'
  # - wallet_name [string]: wallet name. ex: 'GOOGLE'
  # - merchant_id [string]: merchant unique id. ex: '5656565656565656'
  # - status [string]: current IssuingToken status. ex: 'active', 'blocked', 'canceled', 'frozen' or 'pending'
  # - wallet_device_score [number]: Device score informed by the digital wallet.
  # - wallet_account_score [number]: Account score informed by the digital wallet
  # - updated [DateTime]: latest update datetime for the IssuingToken. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingToken. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  #
  # ## Attributes (authorization request only):
  # - external_id [string]: a unique string among all your IssuingTokens, used to avoid resource duplication. ex: 'DSHRMC00002626944b0e3b539d4d459281bdba90c2588791'
  # - tags [list of strings]: list of strings for reference when searching for IssuingToken. ex: ['employees', 'monthly']
  # - activation_code [string]: activation code received through the bank app or sms. ex: '481632'
  # - method_code [string]: provisioning method. Options: 'app', 'token', 'manual', 'server' or 'browser'
  # - device_type [string]: device type used for tokenization. ex: 'Phone'
  # - device_name [string]: device name used for tokenization. ex: 'My phone'
  # - device_serial_number [string]: device serial number used for tokenization. ex: '2F6D63'
  # - device_os_name [string]: device operational system name used for tokenization. ex: 'Android'
  # - device_os_version [string]: device operational system version used for tokenization. ex: '4.4.4'
  # - device_imei [string]: device imei used for tokenization. ex: '352099001761481'
  # - wallet_instance_id [string]: unique id refered to the wallet app in the current device. ex: '71583be4777eb89aaf0345eebeb82594f096615ed17862d0'
  class IssuingToken < StarkCore::Utils::Resource
    attr_reader :card_id, :wallet_id, :wallet_name, :merchant_id, :status, :external_id, :tags, :activation_code,
                :method_code, :device_type, :device_name, :device_serial_number, :device_os_name, :device_os_version,
                :device_imei, :wallet_instance_id, :wallet_device_score, :wallet_account_score, :id, :updated, :created
    def initialize(
      card_id: nil, wallet_id: nil, wallet_name: nil, merchant_id: nil, status: nil, external_id: nil,
      tags: nil, activation_code: nil, method_code: nil, device_type: nil, device_name: nil,
      device_serial_number: nil, device_os_name: nil, device_os_version: nil, device_imei: nil,
      wallet_instance_id: nil, wallet_device_score: nil, wallet_account_score: nil, id: nil, updated: nil, created: nil
    )
      super(id)
      @card_id = card_id
      @wallet_id = wallet_id
      @wallet_name = wallet_name
      @merchant_id = merchant_id
      @status = status
      @external_id = external_id
      @tags = tags
      @activation_code = activation_code
      @method_code = method_code
      @device_type = device_type
      @device_name = device_name
      @device_serial_number = device_serial_number
      @device_os_name = device_os_name
      @device_os_version = device_os_version
      @device_imei = device_imei
      @wallet_instance_id = wallet_instance_id
      @wallet_device_score = wallet_device_score
      @wallet_account_score = wallet_account_score
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
      @created = StarkCore::Utils::Checks.check_datetime(created)
    end

    # # Retrieve a specific IssuingToken
    #
    # Receive a single IssuingToken object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingToken object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingTokens
    #
    # Receive a generator of IssuingToken objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: current IssuingToken status. ex: 'active', 'blocked', 'canceled', 'frozen' or 'pending'
    # - card_ids [list of strings, default nil]: list of card_ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - external_ids [list of strings, default nil]: external IDs. ex: ['DSHRMC00002626944b0e3b539d4d459281bdba90c2588791', 'DSHRMC00002626941c531164a0b14c66ad9602ee716f1e85']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingToken objects with updated attributes
    def self.query(limit: nil, after: nil, before: nil, status: nil, card_ids: nil, tags: nil, ids: nil, external_ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        limit: limit,
        after: after,
        before: before,
        status: status,
        card_ids: card_ids,
        tags: tags,
        ids: ids,
        external_ids: external_ids,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingTokens
    #
    # Receive a list of up to 100 IssuingToken objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - status [string, default nil]: current IssuingToken status. ex: 'active', 'blocked', 'canceled', 'frozen' or 'pending'
    # - card_ids [list of strings, default nil]: list of card_ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - tags [list of strings, default nil]: tags to filter retrieved objects. ex: ['tony', 'stark']
    # - ids [list of strings, default nil]: list of ids to filter retrieved objects. ex: ['5656565656565656', '4545454545454545']
    # - external_ids [list of strings, default nil]: external IDs. ex: ['DSHRMC00002626944b0e3b539d4d459281bdba90c2588791', 'DSHRMC00002626941c531164a0b14c66ad9602ee716f1e85']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingToken objects with updated attributes
    # - cursor to retrieve the next page of IssuingToken objects
    def self.page(cursor: nil, limit: nil, after: nil, before: nil, status: nil, card_ids: nil, tags: nil, ids: nil, external_ids: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        after: after,
        before: before,
        status: status,
        card_ids: card_ids,
        tags: tags,
        ids: ids,
        external_ids: external_ids,
        user: user,
        **resource
      )
    end

    # # Update IssuingToken entity
    #
    # Update an IssuingToken by passing id.
    #
    # ## Parameters (required):
    # - id [string]: IssuingToken id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - status [string, default nil]: You may block the IssuingToken by passing 'blocked' or activate by passing 'active' in the status. ex: 'active', 'blocked'
    # - tags [list of strings, default nil]: list of strings for tagging. ex: ['travel', 'food']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - target IssuingToken with updated attributes
    def self.update(id, status: nil, tags: nil, user: nil)
      StarkInfra::Utils::Rest.patch_id(
        id: id,
        status: status,
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Cancel an IssuingToken entity
    #
    # Cancel an IssuingToken entity previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: IssuingToken unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - canceled IssuingToken object
    def self.cancel(id, user: nil)
      StarkInfra::Utils::Rest.delete_id(id: id, user: user, **resource)
    end

    # # Create a single verified IssuingToken request from a content string
    #
    # Use this method to parse and verify the authenticity of the request received at the informed endpoint.
    # Token requests are posted to your registered endpoint whenever IssuingTokens are received.
    # If the provided digital signature does not check out with the StarkInfra public key, a
    # StarkInfra::Error::InvalidSignatureError will be raised.
    #
    # ## Parameters (required):
    # - content [string]: response content from request received at user endpoint (not parsed)
    # - signature [string]: base-64 digital signature received at response header 'Digital-Signature'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - Parsed IssuingToken object
    def self.parse(content:, signature:, user: nil)
      StarkInfra::Utils::Parse.parse_and_verify(content: content, signature: signature, user: user, resource: resource, key: nil)
    end

    # # Helps you respond to an IssuingToken authorization request
    #
    # When a new tokenization is triggered by your user, a POST request will be made to your registered URL to get
    # your decision to complete the tokenization.
    # The POST request must be answered in the following format, within 2 seconds, and with an HTTP status code 200.
    #
    # ## Parameters (required):
    # - status [string]: sub-issuer response to the authorization. ex: 'approved' or 'denied'
    #
    # ## Parameters (conditionally required):
    # - reason [string, default nil]: denial reason. Options: 'other', 'bruteForce', 'subIssuerError', 'lostCard', 'invalidCard', 'invalidHolder', 'expiredCard', 'canceledCard', 'blockedCard', 'invalidExpiration', 'invalidSecurityCode', 'missingTokenAuthorizationUrl', 'maxCardTriesExceeded', 'maxWalletInstanceTriesExceeded'
    # - activation_methods [list of hashes, default nil]: list of hashes with 'type' and 'value' string pairs
    # - design_id [string, default nil]: design unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - tags [list of strings, default nil]: tags to filter retrieved object. ex: ['tony', 'stark']
    #
    # ## Return:
    # - Dumped JSON string that must be returned to us on the IssuingToken request
    def self.response_authorization(status:, reason: nil, activation_methods: nil, design_id: nil, tags: nil)
      params = {
        'authorization': {
          'status': status,
          'reason': reason.nil? ? '' : reason,
          'activationMethods': activation_methods,
          'designId': design_id,
          'tags': tags
        }
      }

      params.to_json
    end

    # # Helps you respond to an IssuingToken activation request
    #
    # When a new token activation is triggered by your user, a POST request will be made to your registered URL for
    # you to confirm the activation code you informed to them. You may identify this request through the present
    # activation_code in the payload.
    # The POST request must be answered in the following format, within 2 seconds, and with an HTTP status code 200.
    #
    # ## Parameters (required):
    # - status [string]: sub-issuer response to the activation. ex: 'approved' or 'denied'
    #
    # ## Parameters (optional):
    # - reason [string, default nil]: denial reason. Options: 'other', 'bruteForce', 'subIssuerError', 'lostCard', 'invalidCard', 'invalidHolder', 'expiredCard', 'canceledCard', 'blockedCard', 'invalidExpiration', 'invalidSecurityCode', 'missingTokenAuthorizationUrl', 'maxCardTriesExceeded', 'maxWalletInstanceTriesExceeded'
    # - tags [list of strings, default nil]: tags to filter retrieved object. ex: ['tony', 'stark']
    #
    # ## Return:
    # - Dumped JSON string that must be returned to us on the IssuingToken request
    def self.response_activation(status:, reason: nil, tags: nil)
      params = {
        'authorization': {
          'status': status,
          'reason': reason.nil? ? '' : reason,
          'tags': tags
        }
      }

      params.to_json
    end

    def self.resource
      {
        resource_name: 'IssuingToken',
        resource_maker: proc { |json|
          IssuingToken.new(
            id: json['id'],
            card_id: json['card_id'],
            wallet_id: json['wallet_id'],
            wallet_name: json['wallet_name'],
            merchant_id: json['merchant_id'],
            status: json['status'],
            external_id: json['external_id'],
            tags: json['tags'],
            activation_code: json['activation_code'],
            method_code: json['method_code'],
            device_type: json['device_type'],
            device_name: json['device_name'],
            device_serial_number: json['device_serial_number'],
            device_os_name: json['device_os_name'],
            device_os_version: json['device_os_version'],
            device_imei: json['device_imei'],
            wallet_instance_id: json['wallet_instance_id'],
            wallet_device_score: json['wallet_device_score'],
            wallet_account_score: json['wallet_account_score'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
