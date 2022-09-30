# frozen_string_literal: false

require_relative('../user')
require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::MerchantCountry, '#merchant-country#') do
  it 'query' do
    countries = StarkInfra::MerchantCountry.query(search: 'brazil').to_a

    countries.each do |country|
      assert !country.nil?
      expect(countries.length).must_equal(1)
    end
  end
end
