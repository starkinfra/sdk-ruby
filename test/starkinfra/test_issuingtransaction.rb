# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')
require_relative('../user')

describe(StarkInfra::IssuingTransaction, '#issuing-transaction#') do
  it 'query' do
    transactions = StarkInfra::IssuingTransaction.query(limit: 5)
    transactions.each do |transaction|
      puts transaction
      expect(transaction.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    transactions = nil
    (0..1).step(1) do
      transactions, cursor = StarkInfra::IssuingTransaction.page(limit: 5, cursor: cursor)
      transactions.each do |transaction|
        expect(ids).wont_include(transaction.id)
        ids << transaction.id
      end
      break if cursor.nil?
    end
  end

  it 'query and get' do
    transaction = StarkInfra::IssuingTransaction.query(limit: 1).first
    transaction = StarkInfra::IssuingTransaction.get(transaction.id)
    puts transaction
    expect(transaction.id).wont_be_nil
  end
end
