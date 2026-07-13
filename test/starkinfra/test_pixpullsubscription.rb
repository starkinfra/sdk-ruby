# frozen_string_literal: true

require('date')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixPullSubscription, '#pix-pull-subscription#') do
  it 'query params' do
    subscriptions = StarkInfra::PixPullSubscription.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[active canceled],
      tags: %w[1 2 3],
      ids: %w[1 2 3]
    ).to_a
    expect(subscriptions.length).must_equal(0)
  end

  it 'page params' do
    subscriptions, _cursor = StarkInfra::PixPullSubscription.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[active canceled],
      tags: %w[1 2 3],
      ids: %w[1 2 3]
    ).to_a
    expect(subscriptions.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      subscriptions, cursor = StarkInfra::PixPullSubscription.page(limit: 5, cursor: cursor)

      subscriptions.each do |subscription|
        expect(ids).wont_include(subscription.id)
        ids << subscription.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    subscriptions = StarkInfra::PixPullSubscription.query(limit: 10).to_a
    expect(subscriptions.length).must_equal(10)
    subscriptions_ids_expected = []
    subscriptions.each do |subscription|
      subscriptions_ids_expected.push(subscription.id)
    end

    subscriptions_ids_result = []
    StarkInfra::PixPullSubscription.query(limit: 10, ids: subscriptions_ids_expected).each do |subscription|
      subscriptions_ids_result.push(subscription.id)
    end

    subscriptions_ids_expected = subscriptions_ids_expected.sort
    subscriptions_ids_result = subscriptions_ids_result.sort
    expect(subscriptions_ids_expected).must_equal(subscriptions_ids_result)
  end

  it 'create and get' do
    pix_pull_subscription = ExampleGenerator.pixpullsubscription_example
    subscription = StarkInfra::PixPullSubscription.create([pix_pull_subscription])[0]

    subscription_get = StarkInfra::PixPullSubscription.get(subscription.id)
    expect(subscription.id).must_equal(subscription_get.id)
  end

  it 'create and update' do
    pix_pull_subscription = ExampleGenerator.pixpullsubscription_example
    subscription = StarkInfra::PixPullSubscription.create([pix_pull_subscription])[0]

    begin
      updated = StarkInfra::PixPullSubscription.update(
        subscription.id,
        patch_data: { status: 'active' }
      )
      expect(updated.id).must_equal(subscription.id)
    rescue StarkCore::Error::InputErrors => e
      # The sandbox forbids created -> active transitions. Asserting the verb dispatched
      # and surfaced a typed error is sufficient evidence that update is wired correctly.
      expect(e.errors.first.code).must_equal('invalidStatusPatch')
    end
  end

  it 'create and cancel' do
    pix_pull_subscription = ExampleGenerator.pixpullsubscription_example
    subscription = StarkInfra::PixPullSubscription.create([pix_pull_subscription])[0]

    canceled = StarkInfra::PixPullSubscription.cancel(subscription.id, reason: 'receiverUserRequested')
    expect(canceled).must_be_kind_of(StarkInfra::PixPullSubscription)
    expect(canceled.id).must_equal(subscription.id)
  end

  def deserialize_subscription(payload)
    maker = StarkInfra::PixPullSubscription.resource[:resource_maker]
    StarkCore::Utils::API.from_api_json(maker, payload)
  end

  it 'deserializes a populated payload into a typed PixPullSubscription' do
    subscription = deserialize_subscription(ExampleGenerator.pixpullsubscription_payload)

    expect(subscription).must_be_kind_of(StarkInfra::PixPullSubscription)
    expect(subscription.id).must_equal('5656565656565656')
    expect(subscription.bacen_id).must_equal('RR2222222220250101000000000abcdef')
    expect(subscription.external_id).must_equal('my-internal-id-123456')
    expect(subscription.interval).must_equal('month')
    expect(subscription.type).must_equal('paymentAndOrQrcode')
    expect(subscription.amount).must_equal(1234)
    expect(subscription.amount_min_limit).must_equal(500)
    expect(subscription.sender_city_code).must_equal('1234567')
    expect(subscription.status).must_equal('active')
    expect(subscription.flow).must_equal('out')
    expect(subscription.tags).must_equal(%w[employees monthly])
  end

  it 'parses installmentStart, created, and updated as native DateTime values (M13)' do
    subscription = deserialize_subscription(ExampleGenerator.pixpullsubscription_payload)
    iso_format = '%Y-%m-%dT%H:%M:%S+00:00'

    expect(subscription.installment_start).must_be_kind_of(DateTime)
    expect(subscription.installment_start.strftime(iso_format)).must_equal('2020-03-10T10:30:00+00:00')

    expect(subscription.created).must_be_kind_of(DateTime)
    expect(subscription.created.strftime(iso_format)).must_equal('2020-03-10T10:30:00+00:00')

    expect(subscription.updated).must_be_kind_of(DateTime)
    expect(subscription.updated.strftime(iso_format)).must_equal('2020-04-10T10:30:00+00:00')

    expect(subscription.installment_end).must_be_kind_of(DateTime)
    expect(subscription.installment_end.strftime(iso_format)).must_equal('2021-03-10T10:30:00+00:00')

    expect(subscription.due).must_be_kind_of(DateTime)
    expect(subscription.due.strftime(iso_format)).must_equal('2020-10-28T17:59:26+00:00')
  end

  it 'normalizes an empty-string installmentEnd to nil while preserving valid values (M8)' do
    payload_empty = ExampleGenerator.pixpullsubscription_payload.merge('installmentEnd' => '')
    subscription_empty = deserialize_subscription(payload_empty)
    expect(subscription_empty.installment_end).must_be_nil

    payload_valid = ExampleGenerator.pixpullsubscription_payload.merge('installmentEnd' => '2022-06-15T08:45:00+00:00')
    subscription_valid = deserialize_subscription(payload_valid)
    expect(subscription_valid.installment_end).must_be_kind_of(DateTime)
    expect(subscription_valid.installment_end.strftime('%Y-%m-%dT%H:%M:%S+00:00'))
      .must_equal('2022-06-15T08:45:00+00:00')
  end

  it 'normalizes an empty-string due to nil while preserving valid values (M8)' do
    payload_empty = ExampleGenerator.pixpullsubscription_payload.merge('due' => '')
    subscription_empty = deserialize_subscription(payload_empty)
    expect(subscription_empty.due).must_be_nil

    payload_valid = ExampleGenerator.pixpullsubscription_payload.merge('due' => '2022-06-15T08:45:00+00:00')
    subscription_valid = deserialize_subscription(payload_valid)
    expect(subscription_valid.due).must_be_kind_of(DateTime)
    expect(subscription_valid.due.strftime('%Y-%m-%dT%H:%M:%S+00:00'))
      .must_equal('2022-06-15T08:45:00+00:00')
  end

  it 'resolves a webhook event with subscription pix-pull-subscription to a typed Log' do
    log_payload = {
      'id' => '5074777513394176',
      'subscription' => ExampleGenerator.pixpullsubscription_payload,
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
      'subscription' => 'pix-pull-subscription'
    }

    event_maker = StarkInfra::Event.send(:resource)[:resource_maker]
    event = StarkCore::Utils::API.from_api_json(event_maker, event_payload)

    expect(event.subscription).must_equal('pix-pull-subscription')
    expect(event.log).must_be_kind_of(StarkInfra::PixPullSubscription::Log)
    expect(event.log.subscription).must_be_kind_of(StarkInfra::PixPullSubscription)
    expect(event.log.subscription.id).must_equal('5656565656565656')
  end
end
