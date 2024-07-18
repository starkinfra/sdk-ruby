# frozen_string_literal: false

require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::MerchantCategory, '#merchant-category#') do
  it 'query' do
    categories = StarkInfra::MerchantCategory.query(search: 'food').to_a

    categories.each do |category|
      assert !category.nil?
      expect(categories.length).must_equal(10)
    end
  end
end
