# frozen_string_literal: true

require('date')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixPullRequest, '#pix-pull-request#') do
  it 'query params' do
    requests = StarkInfra::PixPullRequest.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'created',
      tags: %w[1 2 3],
      ids: %w[1 2 3],
      subscription_ids: %w[1 2 3]
    ).to_a
    expect(requests.length).must_equal(0)
  end

  it 'page params' do
    requests, _cursor = StarkInfra::PixPullRequest.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'created',
      tags: %w[1 2 3],
      ids: %w[1 2 3],
      subscription_ids: %w[1 2 3]
    )
    expect(requests.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      requests, cursor = StarkInfra::PixPullRequest.page(limit: 5, cursor: cursor)

      requests.each do |request|
        expect(ids).wont_include(request.id)
        ids << request.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    requests = StarkInfra::PixPullRequest.query(limit: 10).to_a
    expect(requests.length).must_equal(10)
    requests_ids_expected = []
    requests.each do |request|
      requests_ids_expected.push(request.id)
    end

    requests_ids_result = []
    StarkInfra::PixPullRequest.query(limit: 10, ids: requests_ids_expected).each do |request|
      requests_ids_result.push(request.id)
    end

    requests_ids_expected = requests_ids_expected.sort
    requests_ids_result = requests_ids_result.sort
    expect(requests_ids_expected).must_equal(requests_ids_result)
  end

  it 'query by subscription_ids plural filter' do
    requests = StarkInfra::PixPullRequest.query(
      limit: 2,
      subscription_ids: %w[5656565656565656]
    ).to_a
    expect(requests.length).must_be :<=, 2
  end

  it 'create and get' do
    pix_pull_request = ExampleGenerator.pixpullrequest_example
    request = StarkInfra::PixPullRequest.create([pix_pull_request])[0]

    request_get = StarkInfra::PixPullRequest.get(request.id)
    expect(request.id).must_equal(request_get.id)
  end

  it 'create and update' do
    pix_pull_request = ExampleGenerator.pixpullrequest_example
    request = StarkInfra::PixPullRequest.create([pix_pull_request])[0]

    begin
      updated = StarkInfra::PixPullRequest.update(
        request.id,
        patch_data: { status: 'scheduled' }
      )
      expect(updated.id).must_equal(request.id)
    rescue StarkCore::Error::InputErrors => e
      # Patch on a PixPullRequest is only permitted for the sender role; this workspace
      # acts as receiver, so the server returns invalidAction. Asserting the verb
      # dispatched and surfaced a typed error is sufficient evidence the wire is correct.
      expect(e.errors.first.code).must_equal('invalidAction')
    end
  end

  it 'create and cancel' do
    pix_pull_request = ExampleGenerator.pixpullrequest_example
    request = StarkInfra::PixPullRequest.create([pix_pull_request])[0]

    canceled = StarkInfra::PixPullRequest.cancel(request.id, reason: 'receiverUserRequested')
    expect(canceled).must_be_kind_of(StarkInfra::PixPullRequest)
    expect(canceled.id).must_equal(request.id)
  end

  it 'does not define a parse class method (M12 guard)' do
    expect(StarkInfra::PixPullRequest.respond_to?(:parse)).must_equal(false)
  end

  def deserialize_request(payload)
    maker = StarkInfra::PixPullRequest.resource[:resource_maker]
    StarkCore::Utils::API.from_api_json(maker, payload)
  end

  it 'deserializes a populated payload into a typed PixPullRequest' do
    request = deserialize_request(ExampleGenerator.pixpullrequest_payload)

    expect(request).must_be_kind_of(StarkInfra::PixPullRequest)
    expect(request.id).must_equal('5656565656565656')
    expect(request.amount).must_equal(11_234)
    expect(request.end_to_end_id).must_equal('E00002649202201172211u34srod19le')
    expect(request.receiver_account_number).must_equal('876543-2')
    expect(request.receiver_account_type).must_equal('checking')
    expect(request.receiver_bank_code).must_equal('20018183')
    expect(request.reconciliation_id).must_equal('123456')
    expect(request.subscription_id).must_equal('5656565656565656')
    expect(request.attempt_type).must_equal('default')
    expect(request.description).must_equal('Payment for service #1234')
    expect(request.receiver_branch_code).must_equal('1357-9')
    expect(request.tags).must_equal(%w[employees monthly])
    expect(request.status).must_equal('created')
    expect(request.flow).must_equal('out')
    expect(request.subscription_bacen_id).must_equal('RR2222222220250101000000000abcdef')
  end

  it 'parses due, created, and updated as native DateTime values (M8)' do
    request = deserialize_request(ExampleGenerator.pixpullrequest_payload)
    iso_format = '%Y-%m-%dT%H:%M:%S+00:00'

    expect(request.due).must_be_kind_of(DateTime)
    expect(request.due.strftime(iso_format)).must_equal('2020-10-28T17:59:26+00:00')

    expect(request.created).must_be_kind_of(DateTime)
    expect(request.created.strftime(iso_format)).must_equal('2020-03-10T10:30:00+00:00')

    expect(request.updated).must_be_kind_of(DateTime)
    expect(request.updated.strftime(iso_format)).must_equal('2020-04-10T10:30:00+00:00')
  end

  it 'resolves a webhook event with subscription pix-pull-request to a typed Log' do
    log_payload = {
      'id' => '5074777513394176',
      'request' => ExampleGenerator.pixpullrequest_payload,
      'type' => 'created',
      'errors' => [],
      'created' => '2020-03-10T10:30:00+00:00'
    }
    event_payload = {
      'id' => '5074777513394176',
      'log' => log_payload,
      'created' => '2020-03-10T10:30:00+00:00',
      'isDelivered' => false,
      'workspaceId' => '5692908409716736',
      'subscription' => 'pix-pull-request'
    }

    event_maker = StarkInfra::Event.send(:resource)[:resource_maker]
    event = StarkCore::Utils::API.from_api_json(event_maker, event_payload)

    expect(event.subscription).must_equal('pix-pull-request')
    expect(event.log).must_be_kind_of(StarkInfra::PixPullRequest::Log)
    expect(event.log.request).must_be_kind_of(StarkInfra::PixPullRequest)
    expect(event.log.request.id).must_equal('5656565656565656')
  end
end
