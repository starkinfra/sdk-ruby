# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')

module StarkInfra
  # # IssuingPurchase object
  #
  # Displays the IssuingPurchase objects created in your Workspace.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when IssuingPurchase is created. ex: '5656565656565656'
  # - holder_name [string]: card holder name. ex: 'Tony Stark'
  # - card_id [string]: unique id returned when IssuingCard is created. ex: '5656565656565656'
  # - card_ending [string]: last 4 digits of the card number. ex: '1234'
  # - amount [integer]: IssuingPurchase value in cents. Minimum = 0. ex: 1234 (= R$ 12.34)
  # - tax [integer]: IOF amount taxed for international purchases. ex: 1234 (= R$ 12.34)
  # - issuer_amount [integer]: issuer amount. ex: 1234 (= R$ 12.34)
  # - issuer_currency_code [string]: issuer currency code. ex: 'USD'
  # - issuer_currency_symbol [string]: issuer currency symbol. ex: '$'
  # - merchant_amount [integer]: merchant amount. ex: 1234 (= R$ 12.34)
  # - merchant_currency_code [string]: merchant currency code. ex: 'USD'
  # - merchant_currency_symbol [string]: merchant currency symbol. ex: '$'
  # - merchant_category_code [string]: merchant category code. ex: 'fastFoodRestaurants'
  # - merchant_country_code [string]: merchant country code. ex: 'USA'
  # - acquirer_id [string]: acquirer ID. ex: '5656565656565656'
  # - merchant_id [string]: merchant ID. ex: '5656565656565656'
  # - merchant_name [string]: merchant name. ex: 'Google Cloud Platform'
  # - merchant_fee [integer]: fee charged by the merchant to cover specific costs, such as ATM withdrawal logistics, etc. ex: 200 (= R$ 2.00)
  # - wallet_id [string]: virtual wallet ID. ex: '5656565656565656'
  # - method_code [string]: method code. ex: 'chip', 'token', 'server', 'manual', 'magstripe' or 'contactless'
  # - score [float]: internal score calculated for the authenticity of the purchase. nil in case of insufficient data. ex: 7.6
  # - issuing_transaction_ids [string]: ledger transaction ids linked to this Purchase
  # - end_to_end_id [string]: Unique id used to identify the transaction through all of its life cycle, even before the purchase is denied or accepted and gets its usual id. Example: endToEndId='679cd385-642b-49d0-96b7-89491e1249a5'
  # - status [string]: current IssuingCard status. ex: 'approved', 'canceled', 'denied', 'confirmed', 'voided'
  # - tags [string]: list of strings for tagging returned by the sub-issuer during the authorization. ex: ['travel', 'food']
  # - created [DateTime]: creation datetime for the IssuingPurchase. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the IssuingPurchase. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class IssuingPurchase < StarkInfra::Utils::Resource
    attr_reader :id, :holder_name, :card_id, :card_ending, :amount, :tax, :issuer_amount, :issuer_currency_code,
                :issuer_currency_symbol, :merchant_amount, :merchant_currency_code, :merchant_currency_symbol,
                :merchant_category_code, :merchant_country_code, :acquirer_id, :merchant_id, :merchant_name,
                :merchant_fee, :wallet_id, :method_code, :score, :issuing_transaction_ids, :end_to_end_id, :status,
                :tags, :updated, :created

    def initialize(
      id: nil, holder_name: nil, card_id: nil, card_ending: nil, amount: nil, tax: nil, issuer_amount: nil,
      issuer_currency_code: nil, issuer_currency_symbol: nil, merchant_amount: nil, merchant_currency_code: nil,
      merchant_currency_symbol: nil, merchant_category_code: nil, merchant_country_code: nil, acquirer_id: nil,
      merchant_id: nil, merchant_name: nil, merchant_fee: nil, wallet_id: nil, method_code: nil, score: nil,
      issuing_transaction_ids: nil, end_to_end_id: nil, status: nil, tags: nil, updated: nil, created: nil
    )
      super(id)
      @holder_name = holder_name
      @card_id = card_id
      @card_ending = card_ending
      @amount = amount
      @tax = tax
      @issuer_amount = issuer_amount
      @issuer_currency_code = issuer_currency_code
      @issuer_currency_symbol = issuer_currency_symbol
      @merchant_amount = merchant_amount
      @merchant_currency_code = merchant_currency_code
      @merchant_currency_symbol = merchant_currency_symbol
      @merchant_category_code = merchant_category_code
      @merchant_country_code = merchant_country_code
      @acquirer_id = acquirer_id
      @merchant_id = merchant_id
      @merchant_name = merchant_name
      @merchant_fee = merchant_fee
      @wallet_id = wallet_id
      @method_code = method_code
      @score = score
      @issuing_transaction_ids = issuing_transaction_ids
      @end_to_end_id = end_to_end_id
      @status = status
      @tags = tags
      @created = StarkInfra::Utils::Checks.check_datetime(created)
      @updated = StarkInfra::Utils::Checks.check_datetime(updated)
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

    # # Retrieve IssuingPurchase
    #
    # Receive a generator of IssuingPurchases objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - ids [list of strings, default nil]: purchase IDs. ex: ['5656565656565656', '4545454545454545']
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 09)
    # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - end_to_end_ids [list of strings, default []]: central bank's unique transaction ID. ex: 'E79457883202101262140HHX553UPqeq'
    # - holder_ids [list of strings, default []]: card holder IDs. ex: ['5656565656565656', '4545454545454545']
    # - card_ids [list of strings, default []]: card  IDs. ex: ['5656565656565656', '4545454545454545']
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['approved', 'canceled', 'denied', 'confirmed', 'voided']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - generator of IssuingPurchases objects with updated attributes
    def self.query(ids: nil, limit: nil, after: nil, before: nil, end_to_end_ids: nil, holder_ids: nil, card_ids: nil,
                   status: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
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
    # Receive a list of IssuingPurchase objects previously created in the Stark Infra API and the cursor to the next page.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call.
    # - ids [list of strings, default nil]: purchase IDs. ex: ['5656565656565656', '4545454545454545']
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Max = 100. ex: 35
    # - after [Date or string, default nil] date filter for objects created only after specified date. ex: Date.new(2020, 3, 10)
    # - before [Date or string, default nil] date filter for objects created only before specified date. ex: Date.new(2020, 3, 10)
    # - end_to_end_ids [list of strings, default []]: central bank's unique transaction ID. ex: 'E79457883202101262140HHX553UPqeq'
    # - holder_ids [list of strings, default []]: card holder IDs. ex: ['5656565656565656', '4545454545454545']
    # - card_ids [list of strings, default []]: card  IDs. ex: ['5656565656565656', '4545454545454545']
    # - status [list of strings, default nil]: filter for status of retrieved objects. ex: ['approved', 'canceled', 'denied', 'confirmed', 'voided']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if starkinfra.user was set before function call
    #
    # ## Return:
    # - list of IssuingPurchases objects with updated attributes
    # - cursor to retrieve the next page of IssuingPurchases objects
    def self.page(cursor: nil, ids: nil, limit: nil, after: nil, before: nil, end_to_end_ids: nil, holder_ids: nil,
                  card_ids: nil, status: nil, user: nil)
      after = StarkInfra::Utils::Checks.check_date(after)
      before = StarkInfra::Utils::Checks.check_date(before)
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

    def self.resource
      {
        resource_name: 'IssuingPurchase',
        resource_maker: proc { |json|
          IssuingPurchase.new(
            id: json['id'],
            holder_name: json['holder_name'],
            card_id: json['card_id'],
            card_ending: json['card_ending'],
            amount: json['amount'],
            tax: json['tax'],
            issuer_amount: json['issuer_amount'],
            issuer_currency_code: json['issuer_currency_code'],
            issuer_currency_symbol: json['issuer_currency_symbol'],
            merchant_amount: json['merchant_amount'],
            merchant_currency_code: json['merchant_currency_code'],
            merchant_currency_symbol: json['merchant_currency_symbol'],
            merchant_category_code: json['merchant_category_code'],
            merchant_country_code: json['merchant_country_code'],
            acquirer_id: json['acquirer_id'],
            merchant_id: json['merchant_id'],
            merchant_name: json['merchant_name'],
            merchant_fee: json['merchant_fee'],
            wallet_id: json['wallet_id'],
            method_code: json['method_code'],
            score: json['score'],
            issuing_transaction_ids: json['issuing_transaction_ids'],
            end_to_end_id: json['end_to_end_id'],
            status: json['status'],
            tags: json['tags'],
            updated: json['updated'],
            created: json['created']
          )
        }
      }
    end
  end
end
