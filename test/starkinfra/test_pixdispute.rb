# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

SANDBOX_SCARCITY_CODES = %w[
  repeatedReferenceId invalidReferenceId invalidDispute
].freeze

describe(StarkInfra::PixDispute, '#pix-dispute#') do
  eligible_refs = nil

  it 'query params' do
    disputes = StarkInfra::PixDispute.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      tags: %w[travel food]
    ).to_a
    expect(disputes.length).must_equal(0)
  end

  it 'page params' do
    disputes = StarkInfra::PixDispute.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      tags: %w[travel food]
    ).to_a
    expect(disputes.length).must_equal(2)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      disputes, cursor = StarkInfra::PixDispute.page(limit: 5, cursor: cursor)

      disputes.each do |dispute|
        expect(ids).wont_include(dispute.id)
        ids << dispute.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_be(:<=, 10)
  end

  it 'query' do
    disputes = StarkInfra::PixDispute.query(limit: 10).to_a
    expect(disputes.length).must_be(:<=, 10)
    disputes_ids_expected = []
    disputes.each do |dispute|
      expect(dispute.id).wont_be_nil
      disputes_ids_expected.push(dispute.id)
    end

    disputes_ids_result = []
    StarkInfra::PixDispute.query(limit: 10, ids: disputes_ids_expected).each do |dispute|
      disputes_ids_result.push(dispute.id)
    end

    disputes_ids_expected = disputes_ids_expected.sort
    disputes_ids_result = disputes_ids_result.sort
    expect(disputes_ids_expected).must_equal(disputes_ids_result)
  end

  it 'create and get' do
    eligible_refs ||= eligible_reference_ids(2)
    reference_id = eligible_refs[0]
    next if reference_id.nil?

    pix_dispute = StarkInfra::PixDispute.new(
      reference_id: reference_id,
      method: 'scam',
      operator_email: 'ruby-sdk@starkinfra.com',
      operator_phone: '+5511999999999'
    )
    dispute = create_or_skip([pix_dispute])
    next if dispute.nil?

    dispute_get = StarkInfra::PixDispute.get(dispute.id)
    expect(dispute.id).must_equal(dispute_get.id)
    expect(dispute_get.id).wont_be_nil
    expect(dispute_get.status).wont_be_nil
  end

  it 'create with method other requires description' do
    eligible_refs ||= eligible_reference_ids(2)
    reference_id = eligible_refs[1]
    next if reference_id.nil?

    dispute = StarkInfra::PixDispute.new(
      reference_id: reference_id,
      method: 'other',
      operator_email: 'ruby-sdk@starkinfra.com',
      operator_phone: '+5511999999999',
      description: 'investigation details required because method is other'
    )
    created = create_or_skip([dispute])
    next if created.nil?

    expect(created.id).wont_be_nil
  end

  it 'get parses transactions sub-objects' do
    dispute = StarkInfra::PixDispute.query(limit: 1).to_a[0]
    next if dispute.nil?

    dispute.transactions.each do |transaction|
      expect(transaction).must_be_instance_of(StarkInfra::PixDispute::Transaction)
      expect(transaction.end_to_end_id).wont_be_nil
    end
  end

  it 'cancel' do
    dispute_id = get_dispute('out')
    next if dispute_id.nil?

    dispute = StarkInfra::PixDispute.cancel(dispute_id)
    expect(dispute.id).must_equal(dispute_id)
  end

  def create_or_skip(disputes)
    StarkInfra::PixDispute.create(disputes)[0]
  rescue StarkInfra::Error::InputErrors => e
    raise unless e.errors.any? { |error| SANDBOX_SCARCITY_CODES.include?(error.code) }

    nil
  end

  def eligible_reference_ids(count)
    cursor = nil
    reference_ids = []
    while true
      requests, cursor = StarkInfra::PixRequest.page(limit: 30, status: 'success', cursor: cursor)
      requests.each do |request|
        next unless request.flow == 'out'

        reference_ids << request.end_to_end_id unless reference_ids.include?(request.end_to_end_id)
        break if reference_ids.length >= count
      end
      break if cursor.nil? || reference_ids.length >= count
    end
    reference_ids
  end

  def get_dispute(flow)
    cursor = nil
    dispute_id = nil
    while true
      disputes, cursor = StarkInfra::PixDispute.page(limit: 5, status: 'delivered', cursor: cursor)
      disputes.each do |dispute|
        if dispute.flow == flow
          dispute_id = dispute.id
          break
        end
      end
      break if cursor.nil? || !dispute_id.nil?
    end
    dispute_id
  end
end
