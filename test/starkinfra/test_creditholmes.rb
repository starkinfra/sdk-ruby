# frozen_string_literal: false

require_relative('../user')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::CreditHolmes, '#credit-holmes#') do
  it 'query' do
    holmes = StarkInfra::CreditHolmes.query(limit: 100)

    holmes.each do |sherlock|
      expect(sherlock.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      holmes, cursor = StarkInfra::CreditHolmes.page(limit: 5, cursor: cursor)

      holmes.each do |sherlock|
        expect(ids).wont_include(sherlock.id)
        ids << sherlock.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    holmes = StarkInfra::CreditHolmes.query(limit: 1).first

    sherlock = StarkInfra::CreditHolmes.get(holmes.id)
    expect(sherlock.id).wont_be_nil
  end

  it 'create' do
    holmes = StarkInfra::CreditHolmes.create([ExampleGenerator.credit_holmes_example()])

    holmes.each do |sherlock|
      expect(sherlock.id).wont_be_nil
    end
  end
end
