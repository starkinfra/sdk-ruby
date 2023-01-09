# frozen_string_literal: false

require_relative('../user')
require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixReversal, '#pix-reversal#') do
  it 'query params' do
    reversals = StarkInfra::PixReversal.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'success',
      tags: %w[1 2 3],
      ids: %w[1 2 3],
      return_ids: %w[1 2 3],
      external_ids: %w[1 2 3]
    ).to_a
    expect(reversals.length).must_equal(0)
  end

  it 'page params' do
    reversals = StarkInfra::PixReversal.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'success',
      tags: %w[1 2 3],
      ids: %w[1 2 3],
      return_ids: %w[1 2 3],
      external_ids: %w[1 2 3]
    ).to_a
    expect(reversals.length).must_equal(2)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      reversals, cursor = StarkInfra::PixReversal.page(limit: 5, cursor: cursor)

      reversals.each do |reversal|
        expect(ids).wont_include(reversal.id)
        ids << reversal.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    reversals = StarkInfra::PixReversal.query(limit: 10).to_a
    expect(reversals.length).must_equal(10)
    reversals_ids_expected = []
    reversals.each do |reversal|
      reversals_ids_expected.push(reversal.id)
    end

    reversals_ids_result = []
    StarkInfra::PixReversal.query(limit: 10, ids: reversals_ids_expected).each do |reversal|
      reversals_ids_result.push(reversal.id)
    end

    reversals_ids_expected = reversals_ids_expected.sort
    reversals_ids_result = reversals_ids_result.sort
    expect(reversals_ids_expected).must_equal(reversals_ids_result)
  end

  it 'create and get' do
    pix_reversal = ExampleGenerator::pixreversal_example
    reversal = StarkInfra::PixReversal.create([pix_reversal])[0]

    reversal_get = StarkInfra::PixReversal.get(reversal.id)
    expect(reversal.id).must_equal(reversal_get.id)
  end

  it 'parse with right signature' do
    event = StarkInfra::PixReversal.parse(
      content: '{"amount": "10", "external_id": "82635892395", "end_to_end_id": "E20018183202201201450u34sDGd19lz", "reason": "bankError", "tags": ["teste","sdk"], "senderAccountType": "payment", "fee": 0, "receiverName": "Cora", "cashierType": "", "externalId": "", "method": "manual", "status": "processing", "updated": "2022-02-16T17:23:53.980250+00:00", "description": "", "tags": [], "receiverKeyId": "", "cashAmount": 0, "senderBankCode": "20018183", "senderBranchCode": "0001", "bankCode": "34052649", "senderAccountNumber": "5647143184367616", "receiverAccountNumber": "5692908409716736", "initiatorTaxId": "", "receiverTaxId": "34.052.649/0001-78", "created": "2022-02-16T17:23:53.980238+00:00", "flow": "in", "endToEndId": "E20018183202202161723Y4cqxlfLFcm", "amount": 1, "receiverAccountType": "checking", "reconciliationId": "", "receiverBankCode": "34052649"}',
      signature: "MEUCIQC7FVhXdripx/aXg5yNLxmNoZlehpyvX3QYDXJ8o02X2QIgVwKfJKuIS5RDq50NC/+55h/7VccDkV1vm8Q/7jNu0VM="
    )
    expect(event).wont_be_nil
  end

  it 'parse with wrong signature' do
    begin
      StarkInfra::PixReversal.parse(
        content: '{"amount": "10", "external_id": "82635892395", "end_to_end_id": "E20018183202201201450u34sDGd19lz", "reason": "bankError", "tags": ["teste","sdk"], "senderAccountType": "payment", "fee": 0, "receiverName": "Cora", "cashierType": "", "externalId": "", "method": "manual", "status": "processing", "updated": "2022-02-16T17:23:53.980250+00:00", "description": "", "tags": [], "receiverKeyId": "", "cashAmount": 0, "senderBankCode": "20018183", "senderBranchCode": "0001", "bankCode": "34052649", "senderAccountNumber": "5647143184367616", "receiverAccountNumber": "5692908409716736", "initiatorTaxId": "", "receiverTaxId": "34.052.649/0001-78", "created": "2022-02-16T17:23:53.980238+00:00", "flow": "in", "endToEndId": "E20018183202202161723Y4cqxlfLFcm", "amount": 1, "receiverAccountType": "checking", "reconciliationId": "", "receiverBankCode": "34052649"}',
        signature: 'MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk='
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'invalid signature was not detected')
    end
  end

  it 'parse with malformed signature' do
    begin
      StarkInfra::PixReversal.parse(
        content: '{"amount": "10", "external_id": "82635892395", "end_to_end_id": "E20018183202201201450u34sDGd19lz", "reason": "bankError", "tags": ["teste","sdk"], "senderAccountType": "payment", "fee": 0, "receiverName": "Cora", "cashierType": "", "externalId": "", "method": "manual", "status": "processing", "updated": "2022-02-16T17:23:53.980250+00:00", "description": "", "tags": [], "receiverKeyId": "", "cashAmount": 0, "senderBankCode": "20018183", "senderBranchCode": "0001", "bankCode": "34052649", "senderAccountNumber": "5647143184367616", "receiverAccountNumber": "5692908409716736", "initiatorTaxId": "", "receiverTaxId": "34.052.649/0001-78", "created": "2022-02-16T17:23:53.980238+00:00", "flow": "in", "endToEndId": "E20018183202202161723Y4cqxlfLFcm", "amount": 1, "receiverAccountType": "checking", "reconciliationId": "", "receiverBankCode": "34052649"}',
        signature: 'something is definitely wrong'
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'malformed signature was not detected')
    end
  end

  it 'denied response' do
    response = StarkInfra::PixReversal.response(status: "denied", reason: "taxIdMismatch")
    assert !response.nil?
  end

  it 'approved response' do
    response = StarkInfra::PixReversal.response(status: "approved")
    assert !response.nil?
  end
end
