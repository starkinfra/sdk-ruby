# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')
require_relative('../user')

describe(StarkInfra::IssuingInvoice, '#issuing-invoice#') do
  it 'query' do
    invoices = StarkInfra::IssuingInvoice.query(limit: 5)
    invoices.each do |invoice|
      expect(invoice.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    invoices = nil
    (0..1).step(1) do
      invoices, cursor = StarkInfra::IssuingInvoice.page(limit: 5, cursor: cursor)
      invoices.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
  end

  it 'query and get' do
    invoice = StarkInfra::IssuingInvoice.query(limit: 1).first
    invoice = StarkInfra::IssuingInvoice.get(invoice.id)
    expect(invoice.id).wont_be_nil
  end

  it 'create' do
    invoice_id = StarkInfra::IssuingInvoice.create(ExampleGenerator.issuinginvoice_example).id
    expect(invoice_id).wont_be_nil
  end
end
