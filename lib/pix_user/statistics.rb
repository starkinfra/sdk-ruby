require_relative('../utils/rest')

module StarkInfra
  class PixUser
    # # PixUser::Statistics object
    #
    # The PixUser::Statistics object stores fraud statistics data of a Pix user.
    #
    # ## Attributes (return-only):
    # - value [integer]: aggregated value of the statistic. ex: 3
    # - type [string]: type of the statistic. ex: 'infractions'
    # - source [string]: source of the statistic. ex: 'keyManagement'
    # - after [DateTime]: start datetime considered for the statistic aggregation. ex: DateTime.new(2020, 4, 23, 23, 0, 0)
    # - updated [DateTime]: latest update datetime for the statistic. ex: DateTime.new(2020, 4, 23, 23, 0, 0)
    class Statistics < StarkCore::Utils::SubResource
      attr_reader :value, :type, :source, :after, :updated
      def initialize(value: nil, type: nil, source: nil, after: nil, updated: nil)
        @value = value
        @type = type
        @source = source
        @after = StarkCore::Utils::Checks.check_datetime(after)
        @updated = StarkCore::Utils::Checks.check_datetime(updated)
      end

      # # Parse PixUser::Statistics
      #
      # Converts a list of hashes (or Statistics objects) received from the API into a list of PixUser::Statistics objects.
      #
      # ## Parameters (required):
      # - statistics [list of hashes or PixUser::Statistics objects]: list to be parsed.
      #
      # ## Return:
      # - list of parsed PixUser::Statistics objects
      def self.parse_statistics(statistics)
        resource_maker = StarkInfra::PixUser::Statistics.resource[:resource_maker]
        return statistics if statistics.nil?

        parsed_statistics = []
        statistics.each do |statistic|
          unless statistic.is_a? Statistics
            statistic = StarkCore::Utils::API.from_api_json(resource_maker, statistic)
          end
          parsed_statistics << statistic
        end
        return parsed_statistics
      end

      def self.resource
      {
        resource_name: 'Statistics',
        resource_maker: proc { |json|
          Statistics.new(
            value: json['value'],
            type: json['type'],
            source: json['source'],
            after: json['after'],
            updated: json['updated']
          )
        }
      }
      end
    end
  end
end
