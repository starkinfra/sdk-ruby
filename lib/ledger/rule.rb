require_relative('../utils/rest')

module StarkInfra
  class Ledger
    # # Ledger::Rule object
    #
    # The Ledger::Rule object modifies the behavior of Ledger objects when passed as an argument upon their creation or update.
    #
    # ## Parameters (required):
    # - key [string]: Rule to be customized, describes what Ledger behavior will be altered. ex: 'minimumBalance', 'maximumBalance'
    # - value [integer]: Value of the rule. ex: 1000
    class Rule < StarkCore::Utils::SubResource
      attr_reader :key, :value
      def initialize(key:, value:)
        @key = key
        @value = value
      end

      # # Parse Ledger::Rules
      #
      # Converts a list of hashes (or Rule objects) received from the API into a list of Ledger::Rule objects.
      #
      # ## Parameters (required):
      # - rules [list of hashes or Ledger::Rule objects]: list to be parsed.
      #
      # ## Return:
      # - list of parsed Ledger::Rule objects
      def self.parse_rules(rules)
        resource_maker = StarkInfra::Ledger::Rule.resource[:resource_maker]
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
