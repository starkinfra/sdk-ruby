# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingPurchase object
  #
  # Displays the IssuingPurchase objects created in your Workspace.
  #
  # ## Attributes (return-only):
  # - holder_name [string]: card holder name. ex: 'Tony Stark'
  # - product_id [string]: unique card product number (BIN) registered within the card network. ex: "53810200"
  # - card_id [string]: unique id returned when IssuingCard is created. ex: '5656565656565656'
  # - card_ending [string]: last 4 digits of the card number. ex: '1234'
  # - purpose [string]: purchase purpose. ex: 'purchase'
  # - amount [integer]: IssuingPurchase value in cents. Minimum = 0. ex: 1234 (= R$ 12.34)
  # - tax [integer]: IOF amount taxed for international purchases. ex: 1234 (= R$ 12.34)
  # - issuer_amount [integer]: issuer amount. ex: 1234 (= R$ 12.34)
  # - issuer_currency_code [string]: issuer currency code. ex: 'USD'
  # - issuer_currency_symbol [string]: issuer currency symbol. ex: '$'
  # - merchant_amount [integer]: merchant amount. ex: 1234 (= R$ 12.34)
  # - merchant_currency_code [string]: merchant currency code. ex: 'USD'
  # - merchant_category_type [string]: merchant category type. ex 'food'
  # - merchant_currency_symbol [string]: merchant currency symbol. ex: '$'
  # - merchant_category_code [string]: merchant category code. ex: 'fastFoodRestaurants'
  # - merchant_country_code [string]: merchant country code. ex: 'USA'
  # - acquirer_id [string]: acquirer ID. ex: '5656565656565656'
  # - merchant_id [string]: merchant ID. ex: '5656565656565656'
  # - merchant_name [string]: merchant name. ex: 'Google Cloud Platform'
  # - merchant_fee [integer]: fee charged by the merchant to cover specific costs, such as ATM withdrawal logistics, etc. ex: 200 (= R$ 2.00)
  # - wallet_id [string]: virtual wallet ID. ex: '5656565656565656'
  # - method_code [string]: method code. Options: 'chip', 'token', 'server', 'manual', 'magstripe' or 'contactless'
  # - score [float]: internal score calculated for the authenticity of the purchase. nil in case of insufficient data. ex: 7.6
  # - end_to_end_id [string]: Unique id used to identify the transaction through all of its life cycle, even before the purchase is denied or approved and gets its usual id. ex: '679cd385-642b-49d0-96b7-89491e1249a5'
  # - tags [string]: list of strings for tagging returned by the sub-issuer during the authorization. ex: ['travel', 'food']
  #
  # ## Attributes (IssuingPurchase only):
  # - id [string]: unique id returned when IssuingPurchase is created. ex: '5656565656565656'
  # - issuing_transaction_ids [string]: ledger transaction ids linked to this Purchase
  # - status [string]: current IssuingCard status. Options: 'approved', 'canceled', 'denied', 'confirmed', 'voided'
  # - description [string]: IssuingPurchase description. ex: 'Office Supplies'
  # - metadata [dictionary object]: dictionary object used to store additional information about the IssuingPurchase object. ex: { authorizationId: 'OjZAqj' }
  # - zip_code [string]: zip code of the merchant location. ex: '02101234'
  # - updated [DateTime]: latest update datetime for the IssuingPurchase. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - created [DateTime]: creation datetime for the IssuingPurchase. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  #
  # ## Attributes (authorization request only):
  # - is_partial_allowed [bool]: true if the merchant allows partial purchases. ex: False
  # - card_tags [list of strings]: tags of the IssuingCard responsible for this purchase. ex: ['travel', 'food']
  # - holder_id [string]: card holder ID. ex: '5656565656565656'
  # - holder_tags [list of strings]: tags of the IssuingHolder responsible for this purchase. ex: ['technology', 'john snow']
  class IssuingPurchase < StarkCore::Utils::Resource
    attr_reader :id, :holder_name, :product_id, :card_id, :card_ending, :purpose, :amount, :tax, :issuer_amount, :issuer_currency_code,
                :issuer_currency_symbol, :merchant_amount, :merchant_currency_code, :merchant_currency_symbol,
                :merchant_category_code, :merchant_category_type, :merchant_country_code, :acquirer_id, :merchant_id, :merchant_name,
                :merchant_fee, :wallet_id, :method_code, :score, :end_to_end_id, :tags,
                :issuing_transaction_ids, :status, :description, :metadata, :zip_code, :updated, :created, :is_partial_allowed, :card_tags, :holder_id, :holder_tags

    def initialize(
      id: nil, holder_name: nil, product_id: nil, card_id: nil, card_ending: nil, purpose: nil, amount: nil, tax: nil, issuer_amount: nil,
      issuer_currency_code: nil, issuer_currency_symbol: nil, merchant_amount: nil, merchant_currency_code: nil,
      merchant_currency_symbol: nil, merchant_category_code: nil, merchant_category_type: nil, merchant_country_code: nil, acquirer_id: nil,
      merchant_id: nil, merchant_name: nil, merchant_fee: nil, wallet_id: nil, method_code: nil, score: nil,
      end_to_end_id: nil, tags: nil, issuing_transaction_ids: nil, status: nil, description: nil, metadata: nil, zip_code: nil, updated: nil, created: nil,
      is_partial_allowed: nil, card_tags:nil, holder_id: nil, holder_tags:nil
    )
      super(id)
      @holder_name = holder_name
      @product_id = product_id
      @card_id = card_id
      @card_ending = card_ending
      @purpose = purpose
      @amount = amount
      @tax = tax
      @issuer_amount = issuer_amount
      @issuer_currency_code = issuer_currency_code
      @issuer_currency_symbol = issuer_currency_symbol
      @merchant_amount = merchant_amount
      @merchant_currency_code = merchant_currency_code
      @merchant_currency_symbol = merchant_currency_symbol
      @merchant_category_code = merchant_category_code
      @merchant_category_type = merchant_category_type
      @merchant_country_code = merchant_country_code
      @acquirer_id = acquirer_id
      @merchant_id = merchant_id
      @merchant_name = merchant_name
      @merchant_fee = merchant_fee
      @wallet_id = wallet_id
      @method_code = method_code
      @score = score
      @end_to_end_id = end_to_end_id
      @tags = tags
      @issuing_transaction_ids = issuing_transaction_ids
      @status = status
      @description = description
      @metadata = metadata
      @zip_code = zip_code
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @is_partial_allowed = is_partial_allowed
      @card_tags = card_tags
      @holder_id = holder_id
      @holder_tags = holder_tags

    end

    # # Retrieve a specific IssuingPurchase
    #
    # Receive a single IssuingPurchase object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingPurchase object with updated attributes
    def self.get(id, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, user: user, **resource)
    end

    # # Retrieve IssuingPurchases
    #
    # Receive a generator of IssuingPurchases objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 09)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - end_to_end_ids [list of strings, default nil]: central bank's unique transaction ID. ex: 'E79457883202101262140HHX553UPqeq'
    # - holder_ids [list of strings, default nil]: card holder IDs. ex: ['5656565656565656', '4545454545454545']
    # - card_ids [list of strings, default nil]: card  IDs. ex: ['5656565656565656', '4545454545454545']
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['approved', 'canceled', 'denied', 'confirmed', 'voided']
    # - ids [list of strings, default nil]: purchase IDs. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingPurchases objects with updated attributes
    def self.query(ids: nil, limit: nil, after: nil, before: nil, end_to_end_ids: nil, holder_ids: nil, card_ids: nil, status: nil, user: nil)
                
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_stream(
        ids: ids,
        limit: limit,
        after: after,
        before: before,
        end_to_end_ids: end_to_end_ids,
        holder_ids: holder_ids,
        card_ids: card_ids,
        status: status,
        user: user,
        **resource
      )
    end

    # # Retrieve paged IssuingPurchases
    #
    # Receive a list of up to 100 IssuingPurchases objects previously created in the Stark Infra API and the cursor
    # to the next page. Use this function instead of query if you want to manually page your invoices.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - limit [integer, default 100]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil]: date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil]: date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - end_to_end_ids [list of strings, default nil]: central bank's unique transaction ID. ex: 'E79457883202101262140HHX553UPqeq'
    # - holder_ids [list of strings, default nil]: card holder IDs. ex: ['5656565656565656', '4545454545454545']
    # - card_ids [list of strings, default nil]: card  IDs. ex: ['5656565656565656', '4545454545454545']
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['approved', 'canceled', 'denied', 'confirmed', 'voided']
    # - ids [list of strings, default nil]: purchase IDs. ex: ['5656565656565656', '4545454545454545']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingPurchases objects with updated attributes
    # - cursor to retrieve the next page of IssuingPurchases objects
    def self.page(cursor: nil, ids: nil, limit: nil, after: nil, before: nil, end_to_end_ids: nil, holder_ids: nil,
                  card_ids: nil, status: nil, user: nil)
      after = StarkCore::Utils::Checks.check_date(after)
      before = StarkCore::Utils::Checks.check_date(before)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        ids: ids,
        limit: limit,
        after: after,
        before: before,
        end_to_end_ids: end_to_end_ids,
        holder_ids: holder_ids,
        card_ids: card_ids,
        status: status,
        user: user,
        **resource
      )
    end

    # # Create a single verified IssuingPurchase authorization request from a content string
    #
    # Use this method to parse and verify the authenticity of the authorization request received at the informed endpoint.
    # Authorization requests are posted to your registered endpoint whenever IssuingPurchases are received.
    # They present IssuingPurchase data that must be analyzed and answered with approval or declination.
    # If the provided digital signature does not check out with the StarkInfra public key, a stark.exception.InvalidSignatureException will be raised.
    # If the authorization request is not answered within 2 seconds or is not answered with an HTTP status code 200 the
    # IssuingPurchase will go through the pre-configured stand-in validation.
    #
    # ## Parameters (required):
    # - content [string]: response content from request received at user endpoint (not parsed)
    # - signature [string]: base-64 digital signature received at response header 'Digital-Signature'
    #
    # # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - Parsed IssuingPurchase object
    def self.parse(content:, signature:, user: nil)
      StarkCore::Utils::Parse.parse_and_verify(
        content: content,
        signature: signature,
        user: user,
        key: nil,
        **resource
      )
    end

    # # Helps you respond IssuingPurchase request
    #
    # ## Parameters (required):
    # - status [string]: sub-issuer response to the authorization. ex: 'approved' or 'denied'
    #
    # ## Parameters (conditionally required):
    # - reason [string]: denial reason. Options: 'other', 'blocked', 'lostCard', 'stolenCard', 'invalidPin', 'invalidCard', 'cardExpired', 'issuerError', 'concurrency', 'standInDenial', 'subIssuerError', 'invalidPurpose', 'invalidZipCode', 'invalidWalletId', 'inconsistentCard', 'settlementFailed', 'cardRuleMismatch', 'invalidExpiration', 'prepaidInstallment', 'holderRuleMismatch', 'insufficientBalance', 'tooManyTransactions', 'invalidSecurityCode', 'invalidPaymentMethod', 'confirmationDeadline', 'withdrawalAmountLimit', 'insufficientCardLimit', 'insufficientHolderLimit'
    #
    # # ## Parameters (optional):
    # - amount [integer, default nil]: amount in cents that was authorized. ex: 1234 (= R$ 12.34)
    # - tags [list of strings, default nil]: tags to filter retrieved object. ex: ['tony', 'stark']
    #
    # ## Return:
    # - Dumped JSON string that must be returned to us on the IssuingPurchase request
    def self.response(
      status:, reason:, amount:, tags:
    )
      params = {
        'status': status,
        'reason': reason,
        'amount': amount,
        'tags': tags
      }

      params.to_json
    end

    def self.resource
      {
        resource_name: 'IssuingPurchase',
        resource_maker: proc { |json|
          IssuingPurchase.new(
            id: json['id'],
            holder_name: json['holder_name'],
            product_id: json['product_id'],
            card_id: json['card_id'],
            card_ending: json['card_ending'],
            purpose: json['purpose'],
            amount: json['amount'],
            tax: json['tax'],
            issuer_amount: json['issuer_amount'],
            issuer_currency_code: json['issuer_currency_code'],
            issuer_currency_symbol: json['issuer_currency_symbol'],
            merchant_amount: json['merchant_amount'],
            merchant_currency_code: json['merchant_currency_code'],
            merchant_currency_symbol: json['merchant_currency_symbol'],
            merchant_category_code: json['merchant_category_code'],
            merchant_category_type: json['merchant_category_type'],
            merchant_country_code: json['merchant_country_code'],
            acquirer_id: json['acquirer_id'],
            merchant_id: json['merchant_id'],
            merchant_name: json['merchant_name'],
            merchant_fee: json['merchant_fee'],
            wallet_id: json['wallet_id'],
            method_code: json['method_code'],
            score: json['score'],
            end_to_end_id: json['end_to_end_id'],
            tags: json['tags'],
            issuing_transaction_ids: json['issuing_transaction_ids'],
            status: json['status'],
            description: json['description'],
            metadata: json['metadata'],
            zip_code: json['zip_code'],
            updated: json['updated'],
            created: json['created'],
            is_partial_allowed: json['is_partial_allowed'],
            card_tags: json['card_tags'],
            holder_id: json['holder_id'],
            holder_tags: json['holder_tags']
          )
        }
      }
    end
  end
end
