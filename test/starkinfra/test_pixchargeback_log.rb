# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../user')

describe(StarkInfra::PixChargeback::Log, '#pix-chargeback/log#') do
  it 'query logs' do
    logs = StarkInfra::PixChargeback::Log.query(limit: 10, types: 'delivered').to_a
    expect(logs.length).must_equal(10)
    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.type).must_equal('delivered')
      expect(log.chargeback.status).must_equal('delivered')
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    logs = nil
    (0..1).step(1) do
      logs, cursor = StarkInfra::PixChargeback::Log.page(limit: 5, cursor: cursor)
      logs.each do |log|
        expect(ids).wont_include(log.id)
        ids << log.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    log = StarkInfra::PixChargeback::Log.query(limit: 1).to_a[0]
    get_log = StarkInfra::PixChargeback::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  it 'query params' do
    log = StarkInfra::PixChargeback::Log.query(
      ids: ['1'],
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      types: ['delivered'],
      chargeback_ids: ['1']
    ).to_a[0]
    expect(log.nil?)
  end

  it 'page params' do
    log = StarkInfra::PixChargeback::Log.page(
      ids: ['1'],
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      types: ['delivered'],
      chargeback_ids: ['1']
    ).to_a[0]
    expect(log.nil?)
  end
end
