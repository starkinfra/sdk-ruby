# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IssuingStock, '#issuing-stock#') do
  it 'query' do
    stocks = StarkInfra::IssuingStock.query(limit: 100)

    stocks.each do |stock|
      expect(stock.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      stocks, cursor = StarkInfra::IssuingStock.page(limit: 1, cursor: cursor)

      stocks.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(2)
  end

  it 'query and get' do
    stock = StarkInfra::IssuingStock.query(limit: 1, expand: ["balance"]).first

    stock = StarkInfra::IssuingStock.get(stock.id, expand: ["balance"])
    expect(stock.id).wont_be_nil
  end
end
