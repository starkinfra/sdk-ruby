# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixInfraction, '#pix-infraction#') do
  it 'query params' do
    infractions = StarkInfra::PixInfraction.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      type: 'reversal',
      flow: 'in',
      tags: %w[travel food]
    ).to_a
    expect(infractions.length).must_equal(0)
  end

  it 'page params' do
    infractions = StarkInfra::PixInfraction.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      type: 'reversal',
      flow: 'in',
      tags: %w[travel food]
    ).to_a
    expect(infractions.length).must_equal(2)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      infractions, cursor = StarkInfra::PixInfraction.page(limit: 5, cursor: cursor)

      infractions.each do |infraction|
        expect(ids).wont_include(infraction.id)
        ids << infraction.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_be(:<=, 10)
  end

  it 'query' do
    infractions = StarkInfra::PixInfraction.query(limit: 10).to_a
    expect(infractions.length).must_be(:<=, 10)
    infractions_ids_expected = []
    infractions.each do |infraction|
      infractions_ids_expected.push(infraction.id)
    end

    infractions_ids_result = []
    StarkInfra::PixInfraction.query(limit: 10, ids: infractions_ids_expected).each do |infraction|
      infractions_ids_result.push(infraction.id)
    end

    infractions_ids_expected = infractions_ids_expected.sort
    infractions_ids_result = infractions_ids_result.sort
    expect(infractions_ids_expected).must_equal(infractions_ids_result)
  end

  it 'create is deprecated' do
    pix_infraction = ExampleGenerator.pixinfraction_example
    begin
      StarkInfra::PixInfraction.create([pix_infraction])
    rescue StarkInfra::Error::StarkInfraError
    else
      raise(StandardError, 'deprecated create did not raise an API error')
    end
  end

  it 'page and update' do
    infraction_id = get_infraction('out')
    next if infraction_id.nil?

    infraction = StarkInfra::PixInfraction.get(infraction_id)
    infraction = StarkInfra::PixInfraction.update(infraction.id, result: 'agreed')
    expect(infraction.status).must_equal('closed')
  end

  it 'page and cancel' do
    infraction_id = get_infraction('out')
    next if infraction_id.nil?

    infraction = StarkInfra::PixInfraction.get(infraction_id)
    infraction = StarkInfra::PixInfraction.cancel(infraction.id)
    expect(infraction.status).must_equal('canceled')
  end

  it 'operator fields are required inputs' do
    pix_request = StarkInfra::PixRequest.query(limit: 1).to_a[0]
    infraction = StarkInfra::PixInfraction.new(
      reference_id: pix_request.end_to_end_id,
      type: 'fraud',
      operator_email: 'ruby-sdk@starkinfra.com',
      operator_phone: '+5511999999999'
    )
    expect(infraction.operator_email).must_equal('ruby-sdk@starkinfra.com')
    expect(infraction.operator_phone).must_equal('+5511999999999')
  end

  it 'exposes new return-only fields' do
    infraction = StarkInfra::PixInfraction.query(limit: 1).to_a[0]
    next if infraction.nil?

    expect(infraction.respond_to?(:amount)).must_equal(true)
    expect(infraction.respond_to?(:dispute_id)).must_equal(true)
    expect(infraction.amount).must_be_kind_of(Integer) unless infraction.amount.nil?
  end

  def get_infraction(flow)
    cursor = nil
    infraction_id = nil
    while true
      infractions, cursor = StarkInfra::PixInfraction.page(limit: 5, status: 'delivered', cursor: cursor)
      infractions.each do |infraction|
        assert !infraction.nil?
        if infraction.flow == flow
          infraction_id = infraction.id
          assert !infraction_id.nil?
          break
        end
      end
      break if cursor.nil?
    end
    infraction_id
  end
end
