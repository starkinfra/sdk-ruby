# frozen_string_literal: true

require_relative('../test_helper.rb')

describe(StarkInfra::PixFraud::Log, '#pix-fraud/log#') do
  it 'query logs' do
    logs = StarkInfra::PixFraud::Log.query(limit: 10).to_a
    expect(logs.length).must_equal(10)
    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.type).wont_be_nil
      expect(log.type).wont_be_empty
      expect(log.fraud.id).wont_be_nil
      expect(log.created).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      logs, cursor = StarkInfra::PixFraud::Log.page(limit: 5, cursor: cursor)

      logs.each do |log|
        expect(ids).wont_include(log.id)
        ids << log.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    log = StarkInfra::PixFraud::Log.query(limit: 1).to_a[0]

    get_log = StarkInfra::PixFraud::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  it 'query params' do
    log = StarkInfra::PixFraud::Log.query(
      ids: ['1'],
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      types: ['registered'],
      fraud_ids: ['1']
    ).to_a[0]
    expect(log.nil?)
  end

  it 'page params' do
    log = StarkInfra::PixFraud::Log.page(
      ids: ['1'],
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      types: ['registered'],
      fraud_ids: ['1']
    ).to_a[0]
    expect(log.nil?)
  end
end
