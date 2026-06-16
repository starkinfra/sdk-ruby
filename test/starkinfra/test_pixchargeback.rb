# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

bank_code = BankCode.bank_code

CHARGEBACK_SCARCITY_CODES = %w[
  repeatedReferenceId invalidReferenceId
].freeze

describe(StarkInfra::PixChargeback, '#pix-chargeback#') do
  it 'query params' do
    chargebacks = StarkInfra::PixChargeback.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      flow: 'in',
      tags: %w[travel food]
    ).to_a
    expect(chargebacks.length).must_equal(0)
  end

  it 'page params' do
    chargebacks = StarkInfra::PixChargeback.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      flow: 'in',
      tags: %w[travel food]
    ).to_a
    expect(chargebacks.length).must_equal(2)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      chargebacks, cursor = StarkInfra::PixChargeback.page(limit: 5, cursor: cursor)

      chargebacks.each do |chargeback|
        expect(ids).wont_include(chargeback.id)
        ids << chargeback.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_be(:<=, 10)
  end

  it 'query' do
    chargebacks = StarkInfra::PixChargeback.query(limit: 10).to_a
    expect(chargebacks.length).must_be(:<=, 10)
    chargebacks_ids_expected = []
    chargebacks.each do |chargeback|
      chargebacks_ids_expected.push(chargeback.id)
    end

    chargebacks_ids_result = []
    StarkInfra::PixChargeback.query(limit: 10, ids: chargebacks_ids_expected).each do |chargeback|
      chargebacks_ids_result.push(chargeback.id)
    end

    chargebacks_ids_expected = chargebacks_ids_expected.sort
    chargebacks_ids_result = chargebacks_ids_result.sort
    expect(chargebacks_ids_expected).must_equal(chargebacks_ids_result)
  end

  it 'create and get' do
    examples = [
      ExampleGenerator.pixchargeback_example(0),
      ExampleGenerator.pixchargeback_example(1)
    ].compact
    next if examples.empty?

    chargeback = create_or_skip(examples)
    next if chargeback.nil?

    chargeback_get = StarkInfra::PixChargeback.get(chargeback.id)
    expect(chargeback.id).must_equal(chargeback_get.id)
  end

  it 'page and update' do
    chargeback_id = get_chargeback('out')
    next if chargeback_id.nil?

    chargeback = StarkInfra::PixChargeback.get(chargeback_id)
    chargeback = StarkInfra::PixChargeback.update(
      chargeback.id, result: 'accepted', reversal_reference_id: StarkInfra::ReturnId.create(bank_code))
    expect(chargeback.status).must_equal('closed')
  end

  it 'page and cancel' do
    chargeback_id = get_chargeback('out')
    next if chargeback_id.nil?

    chargeback = StarkInfra::PixChargeback.get(chargeback_id)
    chargeback = StarkInfra::PixChargeback.cancel(chargeback.id)
    expect(chargeback.status).must_equal('canceled')
  end

  it 'exposes new return-only fields' do
    chargeback = StarkInfra::PixChargeback.query(limit: 1).to_a[0]
    next if chargeback.nil?

    expect(chargeback.respond_to?(:dispute_id)).must_equal(true)
    expect(chargeback.respond_to?(:is_monitoring_required)).must_equal(true)
    expect(chargeback.respond_to?(:reversal_account_number)).must_equal(true)
    expect(chargeback.respond_to?(:reversal_account_type)).must_equal(true)
    expect(chargeback.respond_to?(:reversal_bank_code)).must_equal(true)
    expect(chargeback.respond_to?(:reversal_branch_code)).must_equal(true)
    expect(chargeback.respond_to?(:reversal_tax_id)).must_equal(true)

    unless chargeback.is_monitoring_required.nil?
      expect([true, false]).must_include(chargeback.is_monitoring_required)
    end
  end

  def create_or_skip(chargebacks)
    StarkInfra::PixChargeback.create(chargebacks)[0]
  rescue StarkInfra::Error::InputErrors => e
    raise unless e.errors.any? { |error| CHARGEBACK_SCARCITY_CODES.include?(error.code) }

    nil
  end

  def get_chargeback(flow)
    cursor = nil
    chargeback_id = nil
    while true
      chargebacks, cursor = StarkInfra::PixChargeback.page(limit: 5, status: 'delivered', cursor: cursor)

      chargebacks.each do |chargeback|
        if chargeback.flow == flow
          chargeback_id = chargeback.id
          break
        end
      end
      break if cursor.nil? || !chargeback_id.nil?
    end
    chargeback_id
  end
end
