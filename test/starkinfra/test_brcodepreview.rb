# frozen_string_literal: false

require('date')
require_relative('../end_to_end_id')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::BrcodePreview, '#brcode-preview#') do
  it 'create' do
    static_brcodes = StarkInfra::StaticBrcode.query(limit: 2).to_a
    dynamic_brcodes = StarkInfra::DynamicBrcode.query(limit: 2).to_a

    brcodes = static_brcodes.concat(dynamic_brcodes)

    previews = StarkInfra::BrcodePreview.create(
      [StarkInfra::BrcodePreview.new(id: brcodes[0].id, payer_id: "20.018.183/0001-80"),
       StarkInfra::BrcodePreview.new(id: brcodes[1].id, payer_id: "20.018.183/0001-80"),
       StarkInfra::BrcodePreview.new(id: brcodes[2].id, payer_id: "20.018.183/0001-80"),
       StarkInfra::BrcodePreview.new(id: brcodes[3].id, payer_id: "20.018.183/0001-80")]
    )

    index = 0
    previews.each do |preview|
      assert !preview.nil?
      expect(preview.id).must_equal(brcodes[index].id)
      index += 1
    end
  end

  def deserialize_preview(payload)
    preview_maker = StarkInfra::BrcodePreview.resource[:resource_maker]
    StarkCore::Utils::API.from_api_json(preview_maker, payload)
  end

  it 'deserializes a populated subscription object with the correct type' do
    preview = deserialize_preview(ExampleGenerator.brcodepreview_payload(ExampleGenerator.brcodepreview_subscription_payload))

    expect(preview.subscription).wont_be_nil
    expect(preview.subscription).must_be_kind_of(StarkInfra::BrcodePreview::Subscription)
  end

  it 'preserves every populated subscription field through deserialization' do
    payload = ExampleGenerator.brcodepreview_subscription_payload
    preview = deserialize_preview(ExampleGenerator.brcodepreview_payload(payload))
    subscription = preview.subscription

    expect(subscription.amount).must_equal(payload['amount'])
    expect(subscription.amount_min_limit).must_equal(payload['amountMinLimit'])
    expect(subscription.bacen_id).must_equal(payload['bacenId'])
    expect(subscription.description).must_equal(payload['description'])
    expect(subscription.interval).must_equal(payload['interval'])
    expect(subscription.pull_retry_limit).must_equal(payload['pullRetryLimit'])
    expect(subscription.receiver_bank_code).must_equal(payload['receiverBankCode'])
    expect(subscription.receiver_name).must_equal(payload['receiverName'])
    expect(subscription.receiver_tax_id).must_equal(payload['receiverTaxId'])
    expect(subscription.reference_code).must_equal(payload['referenceCode'])
    expect(subscription.sender_final_name).must_equal(payload['senderFinalName'])
    expect(subscription.sender_final_tax_id).must_equal(payload['senderFinalTaxId'])
    expect(subscription.status).must_equal(payload['status'])
    expect(subscription.type).must_equal(payload['type'])

    iso_format = '%Y-%m-%dT%H:%M:%S+00:00'
    expect(subscription.created).must_be_kind_of(DateTime)
    expect(subscription.created.strftime(iso_format)).must_equal(payload['created'])
    expect(subscription.installment_start).must_be_kind_of(DateTime)
    expect(subscription.installment_start.strftime(iso_format)).must_equal(payload['installmentStart'])
    expect(subscription.installment_end).must_be_kind_of(DateTime)
    expect(subscription.installment_end.strftime(iso_format)).must_equal(payload['installmentEnd'])
    expect(subscription.updated).must_be_kind_of(DateTime)
    expect(subscription.updated.strftime(iso_format)).must_equal(payload['updated'])
  end

  it 'returns nil subscription when the JSON omits the field' do
    preview = deserialize_preview(ExampleGenerator.brcodepreview_payload(nil))
    expect(preview.subscription).must_be_nil
  end

  it 'returns nil subscription when the JSON delivers an empty object' do
    preview = deserialize_preview(ExampleGenerator.brcodepreview_payload({}))
    expect(preview.subscription).must_be_nil
  end

  it 'parses an empty-string installmentEnd as nil and a valid ISO-8601 string as a DateTime' do
    empty_payload = ExampleGenerator.brcodepreview_subscription_payload.merge('installmentEnd' => '')
    preview_empty = deserialize_preview(ExampleGenerator.brcodepreview_payload(empty_payload))
    expect(preview_empty.subscription.installment_end).must_be_nil

    valid_payload = ExampleGenerator.brcodepreview_subscription_payload.merge('installmentEnd' => '2022-06-15T08:45:00+00:00')
    preview_valid = deserialize_preview(ExampleGenerator.brcodepreview_payload(valid_payload))
    expect(preview_valid.subscription.installment_end).must_be_kind_of(DateTime)
    expect(preview_valid.subscription.installment_end.strftime('%Y-%m-%dT%H:%M:%S+00:00'))
      .must_equal('2022-06-15T08:45:00+00:00')
  end

  it 'invokes parse_subscription directly returning a Subscription for a populated hash' do
    parsed = StarkInfra::BrcodePreview::Subscription.parse_subscription(ExampleGenerator.brcodepreview_subscription_payload)
    expect(parsed).must_be_kind_of(StarkInfra::BrcodePreview::Subscription)
    expect(parsed.amount).must_equal(1000)
    expect(parsed.amount_min_limit).must_equal(500)
  end

  it 'returns nil from parse_subscription when given nil or an empty hash' do
    expect(StarkInfra::BrcodePreview::Subscription.parse_subscription(nil)).must_be_nil
    expect(StarkInfra::BrcodePreview::Subscription.parse_subscription({})).must_be_nil
  end
end
