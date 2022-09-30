# frozen_string_literal: true

require_relative('../test_helper.rb')

describe(StarkInfra::Event, '#event#') do
  it 'query' do
    events = StarkInfra::Event.query(limit: 101).to_a

    expect(events.length).must_equal(101)
    events.each do |event|
      expect(event.id).wont_be_nil
      expect(event.log).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      events, cursor = StarkInfra::Event.page(limit: 5, cursor: cursor)

      events.each do |event|
        expect(ids).wont_include(event.id)
        ids << event.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and attempt' do
    events = StarkInfra::Event.query(limit: 2, is_delivered: false).to_a

    expect(events.length).must_equal(2)
    events.each do |event|
      expect(event.id).wont_be_nil
      expect(event.log).wont_be_nil
      attempts = StarkInfra::Event::Attempt.query(event_ids: [event.id], limit: 1).to_a

      attempts.each do |attempt|
        attempt_get = StarkInfra::Event::Attempt.get(attempt.id)
        expect(attempt_get.id).must_equal(attempt.id)
      end
    end
  end

  it 'query, get, update and delete' do
    event = StarkInfra::Event.query(limit: 100, is_delivered: false).to_a.sample

    expect(event.is_delivered).must_equal(false)
    get_event = StarkInfra::Event.get(event.id)

    expect(event.id).must_equal(get_event.id)
    update_event = StarkInfra::Event.update(event.id, is_delivered: true)

    expect(update_event.id).must_equal(event.id)
    expect(update_event.is_delivered).must_equal(true)

    delete_event = StarkInfra::Event.delete(event.id)
    expect(delete_event.id).must_equal(event.id)
  end

  it 'parse with right signature' do
    _no_cache_event = StarkInfra::Event.parse(
      content: '{"event": {"created": "2022-05-27T15:19:05.840123+00:00", "id": "5074777513394176", "log": {"created": "2022-05-27T15:19:03.620939+00:00", "errors": [], "id": "4971315165396992", "request": {"amount": 10000, "cashAmount": 0, "cashierBankCode": "", "cashierType": "", "created": "2022-05-27T15:19:03.474039+00:00", "description": "", "endToEndId": "E34052649202205271219dKrmVefNEZy", "externalId": "FrgxSTRg29VTazE0sJ2zMg==", "fee": 0, "flow": "out", "id": "6378690048950272", "initiatorTaxId": "", "method": "manual", "receiverAccountNumber": "000001", "receiverAccountType": "checking", "receiverBankCode": "00000000", "receiverBranchCode": "0001", "receiverKeyId": "", "receiverName": "maria", "receiverTaxId": "45.987.245/0001-92", "reconciliationId": "", "senderAccountNumber": "000000", "senderAccountType": "checking", "senderBankCode": "34052649", "senderBranchCode": "0000", "senderName": "joao", "senderTaxId": "09.346.601/0001-25", "status": "created", "tags": [], "updated": "2022-05-27T15:19:03.620979+00:00"}, "type": "created"}, "subscription": "pix-request.out", "workspaceId": "5692908409716736"}}',
      signature: 'MEQCIFU7GBVL45lUXJ3LqUH5nDkFN67WMWq2jMeNxZuqJyUdAiAKbxvHpAZ5oFgga63hlQHmVsT88tu6gJKVyUDB8LZyvQ=='
    )
    event = StarkInfra::Event.parse(
      content: '{"event": {"created": "2022-05-27T15:19:05.840123+00:00", "id": "5074777513394176", "log": {"created": "2022-05-27T15:19:03.620939+00:00", "errors": [], "id": "4971315165396992", "request": {"amount": 10000, "cashAmount": 0, "cashierBankCode": "", "cashierType": "", "created": "2022-05-27T15:19:03.474039+00:00", "description": "", "endToEndId": "E34052649202205271219dKrmVefNEZy", "externalId": "FrgxSTRg29VTazE0sJ2zMg==", "fee": 0, "flow": "out", "id": "6378690048950272", "initiatorTaxId": "", "method": "manual", "receiverAccountNumber": "000001", "receiverAccountType": "checking", "receiverBankCode": "00000000", "receiverBranchCode": "0001", "receiverKeyId": "", "receiverName": "maria", "receiverTaxId": "45.987.245/0001-92", "reconciliationId": "", "senderAccountNumber": "000000", "senderAccountType": "checking", "senderBankCode": "34052649", "senderBranchCode": "0000", "senderName": "joao", "senderTaxId": "09.346.601/0001-25", "status": "created", "tags": [], "updated": "2022-05-27T15:19:03.620979+00:00"}, "type": "created"}, "subscription": "pix-request.out", "workspaceId": "5692908409716736"}}',
      signature: 'MEQCIFU7GBVL45lUXJ3LqUH5nDkFN67WMWq2jMeNxZuqJyUdAiAKbxvHpAZ5oFgga63hlQHmVsT88tu6gJKVyUDB8LZyvQ=='
    )
    expect(event.log).wont_be_nil
  end

  it 'parse with wrong signature' do
    begin
      StarkInfra::Event.parse(
        content: '{"event": {"created": "2022-05-27T15:19:05.840123+00:00", "id": "5074777513394176", "log": {"created": "2022-05-27T15:19:03.620939+00:00", "errors": [], "id": "4971315165396992", "request": {"amount": 10000, "cashAmount": 0, "cashierBankCode": "", "cashierType": "", "created": "2022-05-27T15:19:03.474039+00:00", "description": "", "endToEndId": "E34052649202205271219dKrmVefNEZy", "externalId": "FrgxSTRg29VTazE0sJ2zMg==", "fee": 0, "flow": "out", "id": "6378690048950272", "initiatorTaxId": "", "method": "manual", "receiverAccountNumber": "000001", "receiverAccountType": "checking", "receiverBankCode": "00000000", "receiverBranchCode": "0001", "receiverKeyId": "", "receiverName": "maria", "receiverTaxId": "45.987.245/0001-92", "reconciliationId": "", "senderAccountNumber": "000000", "senderAccountType": "checking", "senderBankCode": "34052649", "senderBranchCode": "0000", "senderName": "joao", "senderTaxId": "09.346.601/0001-25", "status": "created", "tags": [], "updated": "2022-05-27T15:19:03.620979+00:00"}, "type": "created"}, "subscription": "pix-request.out", "workspaceId": "5692908409716736"}}',
        signature: 'MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk='
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'invalid signature was not detected')
    end
  end

  it 'parse with malformed signature' do
    begin
      StarkInfra::Event.parse(
        content: '{"event": {"created": "2022-05-27T15:19:05.840123+00:00", "id": "5074777513394176", "log": {"created": "2022-05-27T15:19:03.620939+00:00", "errors": [], "id": "4971315165396992", "request": {"amount": 10000, "cashAmount": 0, "cashierBankCode": "", "cashierType": "", "created": "2022-05-27T15:19:03.474039+00:00", "description": "", "endToEndId": "E34052649202205271219dKrmVefNEZy", "externalId": "FrgxSTRg29VTazE0sJ2zMg==", "fee": 0, "flow": "out", "id": "6378690048950272", "initiatorTaxId": "", "method": "manual", "receiverAccountNumber": "000001", "receiverAccountType": "checking", "receiverBankCode": "00000000", "receiverBranchCode": "0001", "receiverKeyId": "", "receiverName": "maria", "receiverTaxId": "45.987.245/0001-92", "reconciliationId": "", "senderAccountNumber": "000000", "senderAccountType": "checking", "senderBankCode": "34052649", "senderBranchCode": "0000", "senderName": "joao", "senderTaxId": "09.346.601/0001-25", "status": "created", "tags": [], "updated": "2022-05-27T15:19:03.620979+00:00"}, "type": "created"}, "subscription": "pix-request.out", "workspaceId": "5692908409716736"}}',
        signature: 'something is definitely wrong'
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'malformed signature was not detected')
    end
  end
end
