# frozen_string_literal: false

require('securerandom')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::LedgerTransaction, '#ledger-transaction#') do
  it 'create' do
    ledger = StarkInfra::Ledger.create([ExampleGenerator.ledger_example]).first
    transaction = StarkInfra::LedgerTransaction.create([ExampleGenerator.ledger_transaction_example(ledger.id)]).first
    expect(transaction.id).wont_be_nil
  end

  it 'query' do
    transactions = StarkInfra::LedgerTransaction.query(limit: 1)

    transactions.each do |transaction|
      expect(transaction.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      transactions, cursor = StarkInfra::LedgerTransaction.page(limit: 2, cursor: cursor)

      transactions.each do |transaction|
        expect(ids).wont_include(transaction.id)
        ids << transaction.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(4)
  end

  it 'query and get' do
    transaction = StarkInfra::LedgerTransaction.query(limit: 1).first

    transaction = StarkInfra::LedgerTransaction.get(transaction.id)
    expect(transaction.id).wont_be_nil
  end
end
