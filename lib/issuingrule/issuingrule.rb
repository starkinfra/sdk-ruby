# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # IssuingRule object
  #
  # The IssuingRule object displays the spending rules of IssuingCards and IssuingHolders created in your Workspace.
  #
  # ## Parameters (required):
  # - name [string]: rule name. ex: 'Travel' or 'Food'
  # - amount [integer]: maximum amount that can be spent in the informed interval. ex: 200000 (= R$ 2000.00)
  #
  # ## Parameters (optional):
  # - id [string, default nil]: unique id returned when an IssuingRule is created, used to update a specific IssuingRule. ex: '5656565656565656'
  # - interval [string, default 'lifetime']: interval after which the rule amount counter will be reset to 0. ex: 'instant', 'day', 'week', 'month', 'year' or 'lifetime'
  # - currency_code [string, default 'BRL']: code of the currency that the rule amount refers to. ex: 'BRL' or 'USD'
  # - categories [list of MerchantCategories, default nil]: merchant categories accepted by the rule. ex: [MerchantCategory(code='fastFoodRestaurants')]
  # - countries [list of MerchantCountries, default nil]: countries accepted by the rule. ex: [MerchantCountry(code='BRA')]
  # - methods [list of CardMethods, default nil]: card purchase methods accepted by the rule. ex: [CardMethod(code='magstripe')]
  #
  # ## Attributes (expanded return-only):
  # - counter_amount [integer]: current rule spent amount. ex: 1000
  # - currency_symbol [string]: currency symbol. ex: 'R$'
  # - currency_name [string]: currency name. ex: 'Brazilian Real'
  class IssuingRule < StarkCore::Utils::Resource
    attr_reader :name, :interval, :amount, :currency_code, :counter_amount, :currency_name, :currency_symbol,
                :categories, :countries, :methods
    def initialize(
      name:, amount:, id: nil, interval: nil, currency_code: nil, categories: nil, countries: nil, methods: nil,
      counter_amount: nil, currency_symbol: nil, currency_name: nil
    )
      super(id)
      @name = name
      @amount = amount
      @interval = interval
      @currency_code = currency_code
      @categories = IssuingRule.parse_categories(categories)
      @countries = IssuingRule.parse_categories(countries)
      @methods = IssuingRule.parse_categories(methods)
      @counter_amount = counter_amount
      @currency_symbol = currency_symbol
      @currency_name = currency_name
    end

    def self.parse_categories(categories)
      resource_maker = StarkInfra::MerchantCategory.resource[:resource_maker]
      return categories if categories.nil?

      parsed_categories = []
      categories.each do |category|
        unless category.is_a? MerchantCategory
          category = StarkCore::Utils::API.from_api_json(resource_maker, category)
        end
        parsed_categories << category
      end
      parsed_categories
    end

    def self.parse_countries(countries)
      resource_maker = StarkInfra::MerchantCountry.resource[:resource_maker]
      return countries if countries.nil?

      parsed_countries = []
      countries.each do |country|
        unless country.is_a? MerchantCountry
          country = StarkCore::Utils::API.from_api_json(resource_maker, country)
        end
        parsed_countries << country
      end
      parsed_countries
    end

    def self.parse_methods(methods)
      resource_maker = StarkInfra::CardMethod.resource[:resource_maker]
      return methods if methods.nil?

      parsed_methods = []
      methods.each do |method|
        unless method.is_a? CardMethod
          method = StarkCore::Utils::API.from_api_json(resource_maker, method)
        end
        parsed_methods << method
      end
      parsed_methods
    end

    def self.parse_rules(rules)
      rule_maker = StarkInfra::IssuingRule.resource[:resource_maker]
      return rules if rules.nil?

      parsed_rules = []
      rules.each do |rule|
        unless rule.is_a? IssuingRule
          rule = StarkCore::Utils::API.from_api_json(rule_maker, rule)
        end
        parsed_rules << rule
      end
      parsed_rules
    end

    def self.resource
      {
        resource_name: 'IssuingRule',
        resource_maker: proc { |json|
          IssuingRule.new(
            name: json['name'],
            amount: json['amount'],
            interval: json['interval'],
            currency_code: json['currency_code'],
            categories: json['categories'],
            countries: json['countries'],
            methods: json['methods'],
            counter_amount: json['counter_amount'],
            currency_symbol: json['currency_symbol'],
            currency_name: json['currency_name']
          )
        }
      }
    end
  end
end

