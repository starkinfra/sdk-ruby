# frozen_string_literal: false

require_relative('../user')
require_relative('../test_helper.rb')

describe(StarkInfra::IssuingProduct, '#issuing-product#') do
  it 'query' do
    products = StarkInfra::IssuingProduct.query
    products.each do |product|
      expect(product.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      products, cursor = StarkInfra::IssuingProduct.page(limit: 5, cursor: cursor)

      products.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end
end
