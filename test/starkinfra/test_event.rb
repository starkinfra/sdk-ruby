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

  it 'parse a pix-pull-subscription event with the right signature' do
    event = StarkInfra::Event.parse(
      content: '{"event": {"created": "2026-03-17T20:24:02.006080+00:00", "id": "5739991880695808", "log": {"created": "2026-03-17T20:23:58.050406+00:00", "errors": [], "id": "5340798381981696", "reason": "", "subscription": {"amount": 52064, "amountMinLimit": 0, "bacenId": "RR321606372026170317231564231", "created": "2026-03-17T20:23:57.255567+00:00", "description": "A Lannister always pays his debts", "due": "2026-04-17T02:59:59.999000+00:00", "externalId": "606512134", "flow": "out", "id": "5656970050666496", "installmentEnd": "", "installmentStart": "2026-03-18T02:59:59.999999+00:00", "interval": "month", "pullRetryLimit": 3, "receiverBankCode": "32160637", "receiverName": "Stark Bank", "receiverTaxId": "39.908.427/0001-28", "referenceCode": "36135971", "senderAccountNumber": "55213", "senderBankCode": null, "senderBranchCode": "356", "senderCityCode": "", "senderFinalName": "STARK SCD S.A.", "senderFinalTaxId": "39.908.427/0001-28", "senderTaxId": "99.999.919/9999-79", "status": "created", "tags": [], "type": "push", "updated": "2026-03-17T20:23:58.050421+00:00"}, "type": "delivering"}, "subscription": "pix-pull-subscription", "workspaceId": "4828094443552768"}}',
      signature: 'MEUCIQCCZWR4+JYoDNENLnRbSCGGZf+atOaG4q8jWB3ADgc+DQIgIZ1LuXLZ06pke2qzaMNTlDLwcriuH+S3ve1aTQeqNK0='
    )
    expect(event.subscription).must_equal('pix-pull-subscription')
    expect(event.log).must_be_kind_of(StarkInfra::PixPullSubscription::Log)
    expect(event.log.subscription).must_be_kind_of(StarkInfra::PixPullSubscription)
    expect(event.log.type).must_equal('delivering')
  end

  it 'parse a pix-pull-request event with the right signature' do
    event = StarkInfra::Event.parse(
      content: '{"event": {"created": "2026-03-17T22:17:48.687366+00:00", "id": "5980132964564992", "log": {"created": "2026-03-17T22:17:44.741312+00:00", "description": "The Pix Pull Request was created in Stark Infra.", "errors": [], "id": "4777799707525120", "reason": "", "request": {"amount": 79562, "attemptType": "default", "created": "2026-03-17T22:17:44.727124+00:00", "description": "Monthly fare", "due": "2026-03-18T19:17:44.382949+00:00", "endToEndId": "E32160637202617031917FXbuEOeqxTE", "flow": "out", "id": "5859939668983808", "receiverAccountNumber": "00000000", "receiverAccountType": "payment", "receiverBankCode": "32160637", "receiverBranchCode": "", "receiverName": "Stark Bank", "receiverTaxId": "39.908.427/0001-28", "reconciliationId": "20260317191744.382994-03001917VKqeyyGMWvK", "senderBankCode": null, "senderFinalName": "STARK SCD S.A.", "senderFinalTaxId": "39.908.427/0001-28", "senderTaxId": "99.999.919/9999-79", "status": "created", "subscriptionBacenId": "RR321606372026170319175775651", "subscriptionId": "6366699370577920", "tags": [], "updated": "2026-03-17T22:17:45.560279+00:00"}, "type": "created"}, "subscription": "pix-pull-request", "workspaceId": "4828094443552768"}}',
      signature: 'MEUCIQDPci6mVcRQUqQazbol04cYvz8Ffuhh0birk4+8jSUH4AIgKlLhIH5zKzu+4jQlyabvSJin+8+5kJKiJpoqSQPCITg='
    )
    expect(event.subscription).must_equal('pix-pull-request')
    expect(event.log).must_be_kind_of(StarkInfra::PixPullRequest::Log)
    expect(event.log.request).must_be_kind_of(StarkInfra::PixPullRequest)
    expect(event.log.type).must_equal('created')
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
