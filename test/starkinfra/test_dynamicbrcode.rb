# frozen_string_literal: false

require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::DynamicBrcode, '#dynamic-brcode#') do
  it 'query' do
    previews = StarkInfra::DynamicBrcode.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      tags: %w[travel food]
    ).to_a

    previews.each do |preview|
      assert !preview.nil?
      expect(previews.length).must_equal(0)
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      previews, cursor = StarkInfra::DynamicBrcode.page(
        cursor: cursor,
        limit: 4,
        after: '2022-01-01',
        before: '2023-02-01',
        tags: %w[travel food]
      )

      previews.each do |preview|
        expect(ids).wont_include(preview.id)
        ids << preview.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'get' do
    brcodes = StarkInfra::DynamicBrcode.query(limit: 1).to_a

    brcodes.each do |brcode|
      assert !brcode.nil?
      brcode = StarkInfra::DynamicBrcode.get(brcode.uuid)
      assert !brcode.nil?
    end
  end

  it 'create' do
    preview_brcode = ExampleGenerator.dynamicbrcode_example
    previews = StarkInfra::DynamicBrcode.create([preview_brcode])

    previews.each do |preview|
      assert !preview.nil?
    end
  end

uuid = 'a1eeacffaacd43a3b5632bb89161df31'
valid_signature = 'MEUCIQDrQx4EUYt5WqHR63+4LjSxzdJPcxfpw1ETDebJ8ZTa4gIgIuBgy1sfnCvtL36cBjX6z43EZsrcSZhd+mBs+EiKSIA='
invalid_signature = 'MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk='

  it 'valid signature success' do
    preview = StarkInfra::DynamicBrcode.verify(signature: valid_signature, uuid: uuid)
    assert !preview.nil?
  end

  it 'invalid signature success' do
    begin
      preview = StarkInfra::DynamicBrcode.verify(signature: invalid_signature, uuid: uuid)
      assert !preview.nil?
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'invalid signature was not detected')
    end
  end

  it 'response due' do
    discount = ExampleGenerator.dynamic_brcode_discount_example

    due = StarkInfra::DynamicBrcode.response_due(
      version: 1,
      created: '2020-03-10T10:30:00.000000+00:00',
      due: '2020-03-10T10:30:00.000000+00:00',
      key_id: '+5511989898989',
      status: 'paid',
      reconciliation_id: 'cd65c78aeb6543eaaa0170f68bd741ee',
      nominal_amount: 100,
      sender_name: 'Jamie Lannister',
      sender_tax_id: '20.018.183/0001-8',
      receiver_name: 'Anthony Edward Stark',
      receiver_tax_id: '012.345.678-90',
      receiver_street_line: 'Av. Paulista, 200',
      receiver_city: 'Sao Paulo',
      receiver_state_code: 'SP',
      receiver_zip_code: '01234-567',
      expiration: '82000',
      fine: 2,
      interest: 1,
      discounts: discount,
      description: 'Java test'
    )
    assert !due.nil?
  end

  it 'response instant' do
    instant = StarkInfra::DynamicBrcode.response_instant(
      version: 1,
      created: '2020-03-10T10:30:00.000000+00:00',
      key_id: '+5511989898989',
      status: 'paid',
      reconciliation_id: 'cd65c78aeb6543eaaa0170f68bd741ee',
      amount: 1000,
      expiration: '82000',
      cashier_type: 'merchant',
      cashier_bank_code: '20018183',
      cash_amount: 1000,
      sender_name: 'Anthony Edward Stark',
      sender_tax_id: '20.018.183/0001-8',
      amount_type: 'fixed',
      description: 'Java test'
    )
    assert !instant.nil?
  end
end
