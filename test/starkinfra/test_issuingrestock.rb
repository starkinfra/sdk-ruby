# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IssuingRestock, '#issuing-request#') do
  it 'query' do
    restocks = StarkInfra::IssuingRestock.query(limit: 100)

    restocks.each do |restock|
      expect(restock.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      restock, cursor = StarkInfra::IssuingRestock.page(limit: 5, cursor: cursor)

      restock.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    restock = StarkInfra::IssuingRestock.query(limit: 1).first
    restock = StarkInfra::IssuingRestock.get(restock.id)
    expect(restock.id).wont_be_nil
  end

  it 'create' do
    restocks = StarkInfra::IssuingRestock.create(restocks: [ExampleGenerator.issuing_restock_example])
    restocks.each do |restock|
      expect(restock.id).wont_be_nil
    end
  end
end
