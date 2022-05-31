# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')
require_relative('../user')

describe(StarkInfra::PixInfraction, '#pix-infraction#') do
  it 'query params' do
    infractions = StarkInfra::PixInfraction.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      type: 'fraud'
    ).to_a
    expect(infractions.length).must_equal(0)
  end

  it 'page params' do
    infractions, _ = StarkInfra::PixInfraction.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      type: 'fraud'
    ).to_a
    expect(infractions.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    infractions = nil
    (0..1).step(1) do
      infractions, cursor = StarkInfra::PixInfraction.page(limit: 5, cursor: cursor)
      infractions.each do |infraction|
        expect(ids).wont_include(infraction.id)
        ids << infraction.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    infractions = StarkInfra::PixInfraction.query(limit: 10).to_a
    expect(infractions.length).must_equal(10)
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

  it 'create and get' do
    pix_infraction1 = ExampleGenerator.pixinfraction_example
    pix_infraction2 = ExampleGenerator.pixinfraction_example
    infraction = StarkInfra::PixInfraction.create([pix_infraction1, pix_infraction2])[0]
    infraction_get = StarkInfra::PixInfraction.get(infraction.id)
    expect(infraction.id).must_equal(infraction_get.id)
  end

  it 'page and update' do
    infraction = StarkInfra::PixInfraction.get(get_infraction('reported'))
    infraction = StarkInfra::PixInfraction.update(infraction.id, result: 'agreed')
    expect(infraction.status).must_equal('closed')
  end

  it 'page and cancel' do
    infraction = StarkInfra::PixInfraction.get(get_infraction('reporter'))
    infraction = StarkInfra::PixInfraction.cancel(infraction.id)
    expect(infraction.status).must_equal('canceled')
  end

  def get_infraction(agent)
    cursor = nil
    infraction_id = nil
    while true
      infractions, cursor = StarkInfra::PixInfraction.page(limit: 5, status: 'delivered', cursor: cursor)
      infractions.each do |infraction|
        if infraction.agent == agent
          infraction_id = infraction.id
          break
        end
      end
      break if cursor.nil?
    end
    infraction_id
  end
end
