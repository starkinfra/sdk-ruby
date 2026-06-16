require_relative('../utils/rest')

module StarkInfra
  class CreditNote
    # # CreditNote::Rule object
    #
    # The CreditNote::Rule object modifies the behavior of CreditNote objects when passed as an argument upon their creation.
    #
    # ## Parameters (required):
    # - key [string]: Rule to be customized, describes what CreditNote behavior will be altered. ex: 'invoiceCreationMode'
    # - value [string]: value of the rule. ex: 'scheduled', 'instant' or 'never'
    class Rule < StarkCore::Utils::SubResource
      attr_reader :key, :value
      def initialize(key:, value:)
        @key = key
        @value = value
      end

      def self.parse_rules(rules)
        resource_maker = StarkInfra::CreditNote::Rule.resource[:resource_maker]
        return rules if rules.nil?

        parsed_rules = []
        rules.each do |rule|
          unless rule.is_a? Rule
            rule = StarkCore::Utils::API.from_api_json(resource_maker, rule)
          end
          parsed_rules << rule
        end
        return parsed_rules
      end

      def self.resource
      {
        resource_name: 'Rule',
        resource_maker: proc { |json|
          Rule.new(
            key: json['key'],
            value: json['value']
          )
        }
      }
      end
    end
  end
end
