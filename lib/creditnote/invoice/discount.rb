# frozen_string_literal: true

require_relative('../../utils/api')
require_relative('../../utils/rest')
require_relative('../../utils/sub_resource')

module StarkInfra

  # # CreditNote::Invoice::Discount object
  #
  # Invoice discount information.
  #
  # ## Parameters (required):
  # - percentage [float]: percentage of discount applied until specified due date. ex: 2.5
  # - due [DateTime or string]: due datetime for the discount. ex: '2020-03-10T10:30:00.000000+00:00' or DateTime.new(2020, 3, 10, 10, 30, 0, 0).
  class Discount < StarkInfra::Utils::SubResource
    attr_reader :percentage, :due
    def initialize(percentage:, due:)
      @percentage = percentage
      @due = due
    end

    def self.parse_discounts(discounts)
      resource_maker = StarkInfra::Discount.resource[:resource_maker]
      return discounts if discounts.nil?

      parsed_discounts = []
      discounts.each do |discount|
        unless discount.is_a? Discount
          discount = StarkInfra::Utils::API.from_api_json(resource_maker, discount)
        end
        parsed_discounts << discount
      end
      parsed_discounts
    end

    def self.resource
      {
        resource_name: 'Discount',
        resource_maker: proc { |json|
          Discount.new(
            percentage: json['percentage'],
            due: json['due']
          )
        }
      }
    end
  end
end
