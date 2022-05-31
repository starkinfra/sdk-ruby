# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::Webhook, '#webhook#') do
  it 'query' do
    webhooks = StarkInfra::Webhook.query.to_a
    webhooks.each do |webhook|
      expect(webhook.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    webhooks = nil
    (0..1).step(1) do
      webhooks, cursor = StarkInfra::Webhook.page(limit: 2, cursor: cursor)
      webhooks.each do |webhook|
        expect(ids).wont_include(webhook.id)
        ids << webhook.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_be :<=, 4
  end

  it 'create, get and delete' do
    webhook = ExampleGenerator.webhook_example
    webhook = StarkInfra::Webhook.create(
      StarkInfra::Webhook.new(
        url: webhook.url,
        subscriptions: webhook.subscriptions
      )
    )
    get_webhook = StarkInfra::Webhook.get(webhook.id)
    expect(webhook.id).must_equal(get_webhook.id)
    delete_webhook = StarkInfra::Webhook.delete(webhook.id)
    expect(webhook.id).must_equal(delete_webhook.id)
  end
end
