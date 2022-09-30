# frozen_string_literal: false

require_relative('../user')
require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

bank_code = BankCode.bank_code
describe(StarkInfra::PixRequest, '#pix-request#') do
  it 'query params' do
    requests = StarkInfra::PixRequest.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'success',
      tags: %w[1 2 3],
      ids: %w[1 2 3],
      end_to_end_ids: %w[1 2 3],
      external_ids: %w[1 2 3]
    ).to_a
    expect(requests.length).must_equal(0)
  end

  it 'page params' do
    requests = StarkInfra::PixRequest.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'success',
      tags: %w[1 2 3],
      ids: %w[1 2 3],
      end_to_end_ids: %w[1 2 3],
      external_ids: %w[1 2 3]
    ).to_a
    expect(requests.length).must_equal(2)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      requests, cursor = StarkInfra::PixRequest.page(limit: 5, cursor: cursor)

      requests.each do |request|
        expect(ids).wont_include(request.id)
        ids << request.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    requests = StarkInfra::PixRequest.query(limit: 10).to_a
    expect(requests.length).must_equal(10)
    requests_ids_expected = []
    requests.each do |request|
      requests_ids_expected.push(request.id)
    end

    requests_ids_result = []
    StarkInfra::PixRequest.query(limit: 10, ids: requests_ids_expected).each do |request|
      requests_ids_result.push(request.id)
    end

    requests_ids_expected = requests_ids_expected.sort
    requests_ids_result = requests_ids_result.sort
    expect(requests_ids_expected).must_equal(requests_ids_result)
  end

  it 'create and get' do
    pix_request = ExampleGenerator.pixrequest_example(bank_code)
    request = StarkInfra::PixRequest.create([pix_request])[0]

    request_get = StarkInfra::PixRequest.get(request.id)
    expect(request.id).must_equal(request_get.id)
  end

  it 'parse with right signature' do
    _no_cache_event = StarkInfra::PixRequest.parse(
      content: '{"receiverBranchCode": "0001", "cashierBankCode": "", "senderTaxId": "20.018.183/0001-80", "senderName": "Stark Bank S.A. - Instituicao de Pagamento", "id": "4508348862955520", "senderAccountType": "payment", "fee": 0, "receiverName": "Cora", "cashierType": "", "externalId": "", "method": "manual", "status": "processing", "updated": "2022-02-16T17:23:53.980250+00:00", "description": "", "tags": [], "receiverKeyId": "", "cashAmount": 0, "senderBankCode": "20018183", "senderBranchCode": "0001", "bankCode": "34052649", "senderAccountNumber": "5647143184367616", "receiverAccountNumber": "5692908409716736", "initiatorTaxId": "", "receiverTaxId": "34.052.649/0001-78", "created": "2022-02-16T17:23:53.980238+00:00", "flow": "in", "endToEndId": "E20018183202202161723Y4cqxlfLFcm", "amount": 1, "receiverAccountType": "checking", "reconciliationId": "", "receiverBankCode": "34052649"}',
      signature: 'MEUCIQC7FVhXdripx/aXg5yNLxmNoZlehpyvX3QYDXJ8o02X2QIgVwKfJKuIS5RDq50NC/+55h/7VccDkV1vm8Q/7jNu0VM='
    )
    event = StarkInfra::PixRequest.parse(
      content: '{"receiverBranchCode": "0001", "cashierBankCode": "", "senderTaxId": "20.018.183/0001-80", "senderName": "Stark Bank S.A. - Instituicao de Pagamento", "id": "4508348862955520", "senderAccountType": "payment", "fee": 0, "receiverName": "Cora", "cashierType": "", "externalId": "", "method": "manual", "status": "processing", "updated": "2022-02-16T17:23:53.980250+00:00", "description": "", "tags": [], "receiverKeyId": "", "cashAmount": 0, "senderBankCode": "20018183", "senderBranchCode": "0001", "bankCode": "34052649", "senderAccountNumber": "5647143184367616", "receiverAccountNumber": "5692908409716736", "initiatorTaxId": "", "receiverTaxId": "34.052.649/0001-78", "created": "2022-02-16T17:23:53.980238+00:00", "flow": "in", "endToEndId": "E20018183202202161723Y4cqxlfLFcm", "amount": 1, "receiverAccountType": "checking", "reconciliationId": "", "receiverBankCode": "34052649"}',
      signature: 'MEUCIQC7FVhXdripx/aXg5yNLxmNoZlehpyvX3QYDXJ8o02X2QIgVwKfJKuIS5RDq50NC/+55h/7VccDkV1vm8Q/7jNu0VM='
    )
    expect(event).wont_be_nil
  end

  it 'parse with wrong signature' do
    begin
      StarkInfra::PixRequest.parse(
        content: '{"receiverBranchCode": "0001", "cashierBankCode": "", "senderTaxId": "20.018.183/0001-80", "senderName": "Stark Bank S.A. - Instituicao de Pagamento", "id": "4508348862955520", "senderAccountType": "payment", "fee": 0, "receiverName": "Cora", "cashierType": "", "externalId": "", "method": "manual", "status": "processing", "updated": "2022-02-16T17:23:53.980250+00:00", "description": "", "tags": [], "receiverKeyId": "", "cashAmount": 0, "senderBankCode": "20018183", "senderBranchCode": "0001", "bankCode": "34052649", "senderAccountNumber": "5647143184367616", "receiverAccountNumber": "5692908409716736", "initiatorTaxId": "", "receiverTaxId": "34.052.649/0001-78", "created": "2022-02-16T17:23:53.980238+00:00", "flow": "in", "endToEndId": "E20018183202202161723Y4cqxlfLFcm", "amount": 1, "receiverAccountType": "checking", "reconciliationId": "", "receiverBankCode": "34052649"}',
        signature: 'MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk='
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'invalid signature was not detected')
    end
  end

  it 'parse with malformed signature' do
    begin
      StarkInfra::PixRequest.parse(
        content: '{"receiverBranchCode": "0001", "cashierBankCode": "", "senderTaxId": "20.018.183/0001-80", "senderName": "Stark Bank S.A. - Instituicao de Pagamento", "id": "4508348862955520", "senderAccountType": "payment", "fee": 0, "receiverName": "Cora", "cashierType": "", "externalId": "", "method": "manual", "status": "processing", "updated": "2022-02-16T17:23:53.980250+00:00", "description": "", "tags": [], "receiverKeyId": "", "cashAmount": 0, "senderBankCode": "20018183", "senderBranchCode": "0001", "bankCode": "34052649", "senderAccountNumber": "5647143184367616", "receiverAccountNumber": "5692908409716736", "initiatorTaxId": "", "receiverTaxId": "34.052.649/0001-78", "created": "2022-02-16T17:23:53.980238+00:00", "flow": "in", "endToEndId": "E20018183202202161723Y4cqxlfLFcm", "amount": 1, "receiverAccountType": "checking", "reconciliationId": "", "receiverBankCode": "34052649"}',
        signature: 'something is definitely wrong'
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'malformed signature was not detected')
    end
  end

  it 'denied response' do
    response = StarkInfra::PixRequest.response(status: "denied", reason: "taxIdMismatch")
    assert !response.nil?
  end

  it 'approved response' do
    response = StarkInfra::PixRequest.response(status: "approved")
    assert !response.nil?
  end
end
