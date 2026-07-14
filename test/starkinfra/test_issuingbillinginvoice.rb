# frozen_string_literal: true

require_relative('../test_helper.rb')


describe(StarkInfra::IssuingBillingInvoice, '#issuing-billing-invoice#') do
  it 'query' do
    invoices = StarkInfra::IssuingBillingInvoice.query(limit: 5).to_a
    invoices.each do |invoice|
      expect(invoice.id).wont_be_nil
    end
  end

  it 'query params' do
    invoices = StarkInfra::IssuingBillingInvoice.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'paid',
      tags: %w[1 2 3],
      id: %w[1 2 3]
    ).to_a
    expect(invoices.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      invoices, cursor = StarkInfra::IssuingBillingInvoice.page(limit: 5, cursor: cursor)

      invoices.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'page params' do
    invoices = StarkInfra::IssuingBillingInvoice.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'paid',
      tags: %w[1 2 3]
    ).to_a
    expect(invoices.length).must_equal(2)
  end

  it 'query and get' do
    invoice = StarkInfra::IssuingBillingInvoice.query(limit: 1).to_a[0]

    get_invoice = StarkInfra::IssuingBillingInvoice.get(invoice.id)
    expect(invoice.id).must_equal(get_invoice.id)
  end
end
