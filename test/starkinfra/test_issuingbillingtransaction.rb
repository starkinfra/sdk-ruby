# frozen_string_literal: true

require_relative('../test_helper.rb')


describe(StarkInfra::IssuingBillingTransaction, '#issuing-billing-transaction#') do
  it 'query' do
    transactions = StarkInfra::IssuingBillingTransaction.query(limit: 5).to_a
    transactions.each do |transaction|
      expect(transaction.id).wont_be_nil
    end
  end

  it 'query params' do
    transactions = StarkInfra::IssuingBillingTransaction.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      tags: %w[1 2 3]
    ).to_a
    expect(transactions.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      transactions, cursor = StarkInfra::IssuingBillingTransaction.page(limit: 5, cursor: cursor)

      transactions.each do |transaction|
        expect(ids).wont_include(transaction.id)
        ids << transaction.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'page params' do
    transactions = StarkInfra::IssuingBillingTransaction.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      tags: %w[1 2 3]
    ).to_a
    expect(transactions.length).must_equal(2)
  end

  it 'query by invoice id' do
    invoice = StarkInfra::IssuingBillingInvoice.query(limit: 1).to_a[0]

    transactions = StarkInfra::IssuingBillingTransaction.query(limit: 5, invoice_id: invoice.id).to_a
    transactions.each do |transaction|
      expect(transaction.id).wont_be_nil
    end
  end

  it 'query nonexistent invoice id raises input error' do
    begin
      StarkInfra::IssuingBillingTransaction.query(limit: 1, invoice_id: 'nonexistent-invoice-id').to_a
    rescue StarkInfra::Error::InputErrors
    else
      raise(StandardError, 'nonexistent invoice_id did not raise InputErrors')
    end
  end
end
