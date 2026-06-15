# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IssuingStockRule, '#issuing-stock-rule#') do
  it 'query' do
    rules = StarkInfra::IssuingStockRule.query(limit: 10)

    rules.each do |rule|
      expect(rule.id).wont_be_nil
      expect(rule.id).must_be_kind_of(String)
    end
  end

  it 'page' do
    rules, cursor = StarkInfra::IssuingStockRule.page(limit: 3)

    rules.each do |rule|
      expect(rule.id).wont_be_nil
    end
    expect(cursor).wont_be_nil
  end

  it 'create, update and cancel' do
    stock = StarkInfra::IssuingStock.query(limit: 1).to_a[0]

    StarkInfra::IssuingStockRule.query(stock_ids: [stock.id], status: ['active']).each do |existing|
      StarkInfra::IssuingStockRule.cancel(existing.id)
    end

    rule = StarkInfra::IssuingStockRule.create(
      rules: [
        StarkInfra::IssuingStockRule.new(
          minimum_balance: 10_000,
          stock_id: stock.id,
          tags: %w[card corporate],
          emails: ['john.doe@enterprise.com'],
          phones: ['+5511912345678']
        )
      ]
    ).first
    expect(rule.id).wont_be_nil
    expect(rule.id).must_be_kind_of(String)

    rule = StarkInfra::IssuingStockRule.update(rule.id, minimum_balance: 20_000)
    expect(rule.minimum_balance).must_equal(20_000)

    rule = StarkInfra::IssuingStockRule.cancel(rule.id)
    expect(rule.status).must_equal('canceled')
  end
end
