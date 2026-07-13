# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixFraud, '#pix-fraud#') do
  it 'query params' do
    frauds = StarkInfra::PixFraud.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      tags: %w[travel food]
    ).to_a
    expect(frauds.length).must_equal(0)
  end

  it 'page params' do
    frauds = StarkInfra::PixFraud.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      tags: %w[travel food]
    ).to_a
    expect(frauds.length).must_equal(2)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      frauds, cursor = StarkInfra::PixFraud.page(limit: 5, cursor: cursor)

      frauds.each do |fraud|
        expect(ids).wont_include(fraud.id)
        ids << fraud.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    frauds = StarkInfra::PixFraud.query(limit: 10).to_a
    expect(frauds.length).must_equal(10)
    frauds_ids_expected = []
    frauds.each do |fraud|
      frauds_ids_expected.push(fraud.id)
    end

    frauds_ids_result = []
    StarkInfra::PixFraud.query(limit: 10, ids: frauds_ids_expected).each do |fraud|
      frauds_ids_result.push(fraud.id)
    end

    frauds_ids_expected = frauds_ids_expected.sort
    frauds_ids_result = frauds_ids_result.sort
    expect(frauds_ids_expected).must_equal(frauds_ids_result)
  end

  it 'create and get' do
    pix_fraud = ExampleGenerator.pixfraud_example
    fraud = StarkInfra::PixFraud.create([pix_fraud])[0]

    fraud_get = StarkInfra::PixFraud.get(fraud.id)
    expect(fraud.id).must_equal(fraud_get.id)
  end

  it 'create attributes' do
    fraud = StarkInfra::PixFraud.create([ExampleGenerator.pixfraud_example])[0]

    expect(fraud.id).wont_be_nil
    expect(fraud.bacen_id).wont_be_nil
    expect(fraud.status).wont_be_nil
    expect(fraud.status).wont_be_empty
    expect(fraud.created).wont_be_nil
    expect(fraud.updated).wont_be_nil
  end

  it 'query cancelable and cancel' do
    frauds = StarkInfra::PixFraud.query(status: ['registered'], limit: 1).to_a
    frauds.each do |fraud|
      canceled = StarkInfra::PixFraud.cancel(fraud.id)
      expect(canceled.id).must_equal(fraud.id)
    end
  end
end
