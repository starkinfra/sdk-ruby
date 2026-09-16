# frozen_string_literal: false

require('securerandom')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::Ledger, '#ledger#') do
  it 'create' do
    ledger = StarkInfra::Ledger.create([ExampleGenerator.ledger_example]).first
    expect(ledger.id).wont_be_nil
  end

  it 'query' do
    ledgers = StarkInfra::Ledger.query(limit: 1)

    ledgers.each do |ledger|
      expect(ledger.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      ledgers, cursor = StarkInfra::Ledger.page(limit: 2, cursor: cursor)

      ledgers.each do |ledger|
        expect(ids).wont_include(ledger.id)
        ids << ledger.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(4)
  end

  it 'query and get' do
    ledger = StarkInfra::Ledger.query(limit: 1).first

    ledger = StarkInfra::Ledger.get(ledger.id)
    expect(ledger.id).wont_be_nil
  end

  it 'create and update' do
    ledger = StarkInfra::Ledger.create([ExampleGenerator.ledger_example]).first

    updated = StarkInfra::Ledger.update(ledger.id, tags: ['test', 'testing'])
    expect(updated.id).must_equal(ledger.id)
    expect(updated.tags).must_equal(['test', 'testing'])
  end
end
