# frozen_string_literal: true

require_relative('../test_helper.rb')


describe(StarkInfra::IssuingToken, '#issuing-token#') do
  it 'query' do
    tokens = StarkInfra::IssuingToken.query(limit: 5).to_a
    tokens.each do |token|
      expect(token.id).wont_be_nil
    end
  end

  it 'query params' do
    tokens = StarkInfra::IssuingToken.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[active],
      card_ids: %w[1 2 3],
      tags: %w[1 2 3],
      ids: %w[1 2 3],
      external_ids: %w[1 2 3]
    ).to_a
    expect(tokens.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      tokens, cursor = StarkInfra::IssuingToken.page(limit: 5, cursor: cursor)

      tokens.each do |token|
        expect(ids).wont_include(token.id)
        ids << token.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'page params' do
    tokens = StarkInfra::IssuingToken.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[active],
      card_ids: %w[1 2 3],
      tags: %w[1 2 3],
      ids: %w[1 2 3],
      external_ids: %w[1 2 3]
    ).to_a
    expect(tokens.length).must_equal(2)
  end

  it 'query and get' do
    token = StarkInfra::IssuingToken.query(limit: 1).to_a[0]

    get_token = StarkInfra::IssuingToken.get(token.id)
    expect(token.id).must_equal(get_token.id)
  end

  it 'query and update' do
    token = StarkInfra::IssuingToken.query(limit: 1).to_a[0]

    updated = StarkInfra::IssuingToken.update(token.id, status: 'blocked')
    expect(updated.id).must_equal(token.id)
  end

  it 'query and cancel' do
    token = StarkInfra::IssuingToken.query(limit: 1, status: 'active').to_a[0]

    canceled = StarkInfra::IssuingToken.cancel(token.id)
    expect(canceled.id).must_equal(token.id)
  end

  it 'parse with right signature' do
    _no_cache_event = StarkInfra::IssuingToken.parse(
      content: '{"acquirerId": "236090", "amount": 100, "cardId": "5671893688385536", "cardTags": [], "endToEndId": "2fa7ef9f-b889-4bae-ac02-16749c04a3b6", "holderId": "5917814565109760", "holderTags": [], "isPartialAllowed": false, "issuerAmount": 100, "issuerCurrencyCode": "986", "merchantAmount": 100, "merchantCurrencyCode": "986", "methodCode": "token", "merchantCategoryCode": "bookStores", "merchantCountryCode": "BRA", "merchantName": "COMPANY 123", "metadata": {}, "purpose": "purchase", "score": null, "tax": 0, "walletId": ""}',
      signature: 'MEUCIQC7FVhXdripx/aXg5yNLxmNoZlehpyvX3QYDXJ8o02X2QIgVwKfJKuIS5RDq50NC/+55h/7VccDkV1vm8Q/7jNu0VM='
    )
    event = StarkInfra::IssuingToken.parse(
      content: '{"acquirerId": "236090", "amount": 100, "cardId": "5671893688385536", "cardTags": [], "endToEndId": "2fa7ef9f-b889-4bae-ac02-16749c04a3b6", "holderId": "5917814565109760", "holderTags": [], "isPartialAllowed": false, "issuerAmount": 100, "issuerCurrencyCode": "986", "merchantAmount": 100, "merchantCurrencyCode": "986", "methodCode": "token", "merchantCategoryCode": "bookStores", "merchantCountryCode": "BRA", "merchantName": "COMPANY 123", "metadata": {}, "purpose": "purchase", "score": null, "tax": 0, "walletId": ""}',
      signature: 'MEUCIQC7FVhXdripx/aXg5yNLxmNoZlehpyvX3QYDXJ8o02X2QIgVwKfJKuIS5RDq50NC/+55h/7VccDkV1vm8Q/7jNu0VM='
    )
    expect(event).wont_be_nil
  end

  it 'parse with wrong signature' do
    begin
      StarkInfra::IssuingToken.parse(
        content: '{"acquirerId": "236090", "amount": 100, "cardId": "5671893688385536", "cardTags": [], "endToEndId": "2fa7ef9f-b889-4bae-ac02-16749c04a3b6", "holderId": "5917814565109760", "holderTags": [], "isPartialAllowed": false, "issuerAmount": 100, "issuerCurrencyCode": "986", "merchantAmount": 100, "merchantCurrencyCode": "986", "methodCode": "token", "merchantCategoryCode": "bookStores", "merchantCountryCode": "BRA", "merchantName": "COMPANY 123", "metadata": {}, "purpose": "purchase", "score": null, "tax": 0, "walletId": ""}',
        signature: 'MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk='
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'invalid signature was not detected')
    end
  end

  it 'parse with malformed signature' do
    begin
      StarkInfra::IssuingToken.parse(
        content: '{"acquirerId": "236090", "amount": 100, "cardId": "5671893688385536", "cardTags": [], "endToEndId": "2fa7ef9f-b889-4bae-ac02-16749c04a3b6", "holderId": "5917814565109760", "holderTags": [], "isPartialAllowed": false, "issuerAmount": 100, "issuerCurrencyCode": "986", "merchantAmount": 100, "merchantCurrencyCode": "986", "methodCode": "token", "merchantCategoryCode": "bookStores", "merchantCountryCode": "BRA", "merchantName": "COMPANY 123", "metadata": {}, "purpose": "purchase", "score": null, "tax": 0, "walletId": ""}',
        signature: 'something is definitely wrong'
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'malformed signature was not detected')
    end
  end

  it 'response authorization approved' do
    response = StarkInfra::IssuingToken.response_authorization(
      status: 'approved',
      activation_methods: [
        { type: 'app', value: 'com.example.app' },
        { type: 'text', value: '** *****-5678' }
      ],
      design_id: '5314278287671296'
    )
    assert !response.nil?
  end

  it 'response authorization denied' do
    response = StarkInfra::IssuingToken.response_authorization(status: 'denied', reason: 'other')
    assert !response.nil?
  end

  it 'response activation approved' do
    response = StarkInfra::IssuingToken.response_activation(status: 'approved')
    assert !response.nil?
  end

  it 'response activation denied' do
    response = StarkInfra::IssuingToken.response_activation(status: 'denied', reason: 'other')
    assert !response.nil?
  end
end
