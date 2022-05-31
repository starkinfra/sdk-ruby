# frozen_string_literal: true

require_relative('../utils/resource')
require_relative('../utils/rest')
require_relative('../utils/checks')

module StarkInfra
  # # IssuingRule object
  #
  # The IssuingRule object displays the spending rules of IssuingCards and IssuingHolders created in your Workspace.
  #
  # ## Parameters (required):
  # - name [string]: rule name. ex: 'Travel' or 'Food'
  # - amount [integer]: maximum amount that can be spent in the informed interval. ex: 200000 (= R$ 2000.00)
  # - interval [string]: interval after which the rule amount counter will be reset to 0. ex: 'instant', 'day', 'week', 'month', 'year' or 'lifetime'
  # ## Parameters (optional):
  # - currency_code [string, default 'BRL']: code of the currency that the rule amount refers to. ex: 'BRL' or 'USD'
  # - categories [list of strings, default []]: merchant categories accepted by the rule. ex: ['eatingPlacesRestaurants', 'travelAgenciesTourOperators']
  # - countries [list of strings, default []]: countries accepted by the rule. ex: ['BRA', 'USA']
  # - methods [list of strings, default []]: card purchase methods accepted by the rule. ex: ['chip', 'token', 'server', 'manual', 'magstripe', 'contactless']
  # ## Attributes (expanded return-only):
  # - counter_amount [integer]: current rule spent amount. ex: 1000
  # - currency_symbol [string]: currency symbol. ex: 'R$'
  # - currency_name [string]: currency name. ex: 'Brazilian Real'
  # ## Attributes (return-only):
  # - id [string]: unique id returned when Rule is created. ex: '5656565656565656'
  class IssuingRule < StarkInfra::Utils::Resource
    attr_reader :name, :interval, :amount, :currency_code, :counter_amount, :currency_name, :currency_symbol, :categories, :countries, :methods
    def initialize(name:, interval:, amount:, currency_code: nil, counter_amount: nil, currency_name: nil,
      currency_symbol: nil, categories: nil, countries: nil, methods: nil
    )
      super(id)
      @name = name
      @interval = interval
      @amount = amount
      @currency_code = currency_code
      @counter_amount = counter_amount
      @currency_name = currency_name
      @currency_symbol = currency_symbol
      @categories = categories
      @countries = countries
      @methods = methods
    end

    def self.parse_rules(rules)
      parsed_rules = []
      rule_maker = StarkInfra::IssuingRule.resource[:resource_maker]
      return rules if rules.nil?

      rules.each do |rule|
        if rule.is_a? IssuingRule
          parsed_rules.append(rule)
          next
        end
        parsed_rules.append(StarkInfra::Utils::API.from_api_json(rule_maker, rule))
      end
      parsed_rules
    end

    def self.resource
      {
        resource_name: 'IssuingRule',
        resource_maker: proc { |json|
          IssuingRule.new(
            name: json[:name],
            interval: json[:interval],
            amount: json[:amount],
            currency_code: json[:currency_code],
            counter_amount: json[:counter_amount],
            currency_name: json[:currency_name],
            currency_symbol: json[:currency_symbol],
            categories: json[:categories],
            countries: json[:countries],
            methods: json[:methods]
          )
        }
      }
    end
  end
end

