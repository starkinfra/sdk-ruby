# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::IssuingPurchase, '#issuing-purchase#') do
  it 'query' do
    purchases = StarkInfra::IssuingPurchase.query(limit: 5)
    purchases.each do |purchase|
      expect(purchase.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      purchases, cursor = StarkInfra::IssuingPurchase.page(limit: 5, cursor: cursor)

      purchases.each do |purchase|
        expect(ids).wont_include(purchase.id)
        expect(purchase.metadata).wont_be_nil
        ids << purchase.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    purchase = StarkInfra::IssuingPurchase.query(limit: 1).first

    purchase = StarkInfra::IssuingPurchase.get(purchase.id)
    expect(purchase.id).wont_be_nil
    expect(purchase.metadata).wont_be_nil
  end

  it 'update' do
    purchase = StarkInfra::IssuingPurchase.query(limit: 1).to_a[0]
    skip('no IssuingPurchase available in this workspace') if purchase.nil?

    description = 'updated by ruby sdk test'
    tags = %w[updated tags]
    updated_purchase = StarkInfra::IssuingPurchase.update(purchase.id, description: description, tags: tags)
    expect(updated_purchase.description).must_equal(description)
  end

  it 'query exposes installment_count' do
    purchases = StarkInfra::IssuingPurchase.query(limit: 5)
    purchases.each do |purchase|
      expect(purchase.id).wont_be_nil
      expect(purchase.respond_to?(:installment_count)).must_equal(true)
      expect(purchase.installment_count).must_be_kind_of(Integer) unless purchase.installment_count.nil?
    end
  end

  it 'get exposes installment_count' do
    purchase = StarkInfra::IssuingPurchase.query(limit: 1).first

    purchase = StarkInfra::IssuingPurchase.get(purchase.id)
    expect(purchase.respond_to?(:installment_count)).must_equal(true)
    expect(purchase.installment_count).must_be_kind_of(Integer) unless purchase.installment_count.nil?
  end
end
