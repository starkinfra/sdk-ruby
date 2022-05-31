# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')
require('json')

module StarkInfra
  # # IssuingAuthorization object
  #
  # An IssuingAuthorization presents purchase data to be analysed and answered with an approval or a declination.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the IssuingAuthorization is created. ex: '5656565656565656'
  # - end_to_end_id [string]: central bank's unique transaction ID. ex: "E79457883202101262140HHX553UPqeq"
  # - amount [integer]: IssuingPurchase value in cents. Minimum = 0. ex: 1234 (= R$ 12.34)
  # - tax [integer]: IOF amount taxed for international purchases. ex: 1234 (= R$ 12.34)
  # - card_id [string]: unique id returned when IssuingCard is created. ex: "5656565656565656"
  # - issuer_amount [integer]: issuer amount. ex: 1234 (= R$ 12.34)
  # - issuer_currency_code [string]: issuer currency code. ex: "USD"
  # - merchant_amount [integer]: merchant amount. ex: 1234 (= R$ 12.34)
  # - merchant_currency_code [string]: merchant currency code. ex: "USD"
  # - merchant_category_code [string]: merchant category code. ex: "fastFoodRestaurants"
  # - merchant_country_code [string]: merchant country code. ex: "USA"
  # - acquirer_id [string]: acquirer ID. ex: "5656565656565656"
  # - merchant_id [string]: merchant ID. ex: "5656565656565656"
  # - merchant_name [string]: merchant name. ex: "Google Cloud Platform"
  # - merchant_fee [integer]: merchant fee charged. ex: 200 (= R$ 2.00)
  # - wallet_id [string]: virtual wallet ID. ex: "googlePay"
  # - method_code [string]: method code. ex: "chip", "token", "server", "manual", "magstripe" or "contactless"
  # - score [float]: internal score calculated for the authenticity of the purchase. nil in case of insufficient data. ex: 7.6
  # - is_partial_allowed [bool]: true if the the merchant allows partial purchases. ex: False
  # - purpose [string]: purchase purpose. ex: "purchase"
  # - card_tags [list of strings]: tags of the IssuingCard responsible for this purchase. ex: ["travel", "food"]
  # - holder_tags [list of strings]: tags of the IssuingHolder responsible for this purchase. ex: ["technology", "john snow"]
  class IssuingAuthorization < StarkInfra::Utils::Resource
    attr_reader :id, :end_to_end_id, :amount, :tax, :card_id, :issuer_amount, :issuer_currency_code, :merchant_amount,
                :merchant_currency_code, :merchant_category_code, :merchant_country_code, :acquirer_id, :merchant_id,
                :merchant_name, :merchant_fee, :wallet_id, :method_code, :score, :is_partial_allowed, :purpose,
                :card_tags, :holder_tags
    def initialize(
      id: nil, end_to_end_id: nil, amount: nil, tax: nil, card_id: nil, issuer_amount: nil,
      issuer_currency_code: nil, merchant_amount: nil, merchant_currency_code: nil,
      merchant_category_code: nil, merchant_country_code: nil, acquirer_id: nil, merchant_id: nil,
      merchant_name: nil, merchant_fee: nil, wallet_id: nil, method_code: nil, score: nil,
      is_partial_allowed: nil, purpose: nil, card_tags: nil, holder_tags: nil
    )
      super(id)
      @end_to_end_id = end_to_end_id
      @amount = amount
      @tax = tax
      @card_id = card_id
      @issuer_amount = issuer_amount
      @issuer_currency_code = issuer_currency_code
      @merchant_amount = merchant_amount
      @merchant_currency_code = merchant_currency_code
      @merchant_category_code = merchant_category_code
      @merchant_country_code = merchant_country_code
      @acquirer_id = acquirer_id
      @merchant_id = merchant_id
      @merchant_name = merchant_name
      @merchant_fee = merchant_fee
      @wallet_id = wallet_id
      @method_code = method_code
      @score = score
      @is_partial_allowed = is_partial_allowed
      @purpose = purpose
      @card_tags = card_tags
      @holder_tags = holder_tags
    end

    # # Create single IssuingAuthorization from a content string
    #
    # Create a single IssuingAuthorization object received from IssuingAuthorization at the informed endpoint.
    # If the provided digital signature does not check out with the StarkInfra public key, a
    # StarkInfra.Error.InvalidSignatureError will be raised.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - IssuingAuthorization object with updated attributes
    def self.parse(content:, signature:, user: nil)
      StarkInfra::Utils::Parse.parse_and_verify(content: content, signature: signature, user: user, resource: resource)
    end

    # # Helps you respond IssuingAuthorization requests.
    #
    # ## Parameters (required):
    # - status [string]: sub-issuer response to the authorization. ex: 'accepted' or 'denied'
    #
    # ## Parameters (optional):
    # - amount [integer, default 0]: amount in cents that was authorized. ex: 1234 (= R$ 12.34)
    # - reason [string, default '']: denial reason. ex: 'other'
    # - tags [list of strings, default []]: tags to filter retrieved object. ex: ['tony', 'stark']
    #
    # ## Return:
    # - Dumped JSON string that must be returned to us on the IssuingAuthorization request
    def self.response(status:, amount: nil, reason: nil, tags: nil)
      response_hash = {
        "status": status,
        "amount": amount || 0,
        "reason": reason || '',
        "tags": tags || []
      }
      response_hash.to_json
    end

    def self.resource
      {
        resource_name: 'IssuingAuthorization',
        resource_maker: proc { |json|
          IssuingAuthorization.new(
            id: json['id'],
            end_to_end_id: json['end_to_end_id'],
            amount: json['amount'],
            tax: json['tax'],
            card_id: json['card_id'],
            issuer_amount: json['issuer_amount'],
            issuer_currency_code: json['issuer_currency_code'],
            merchant_amount: json['merchant_amount'],
            merchant_currency_code: json['merchant_currency_code'],
            merchant_category_code: json['merchant_category_code'],
            merchant_country_code: json['merchant_country_code'],
            acquirer_id: json['acquirer_id'],
            merchant_id: json['merchant_id'],
            merchant_name: json['merchant_name'],
            merchant_fee: json['merchant_fee'],
            wallet_id: json['wallet_id'],
            method_code: json['method_code'],
            score: json['score'],
            is_partial_allowed: json['is_partial_allowed'],
            purpose: json['purpose'],
            card_tags: json['card_tags'],
            holder_tags: json['holder_tags']
          )
        }
      }
    end
  end
end
