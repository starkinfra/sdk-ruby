# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::Ledger::Log, '#ledger/log#') do
  it 'query logs' do
    logs = StarkInfra::Ledger::Log.query(limit: 10).to_a

    logs.each do |log|
      expect(log.id).wont_be_nil
    end
  end

  it 'query and get' do
    log = StarkInfra::Ledger::Log.query(limit: 1).to_a[0]

    get_log = StarkInfra::Ledger::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  it 'query params' do
    log = StarkInfra::Ledger::Log.query(
      limit: 1,
      after: '2023-01-01',
      before: '2023-01-02',
      ledger_id: '1'
    ).to_a[0]
    expect(log.nil?)
  end

  it 'page params' do
    log = StarkInfra::Ledger::Log.page(
      limit: 1,
      after: '2023-01-01',
      before: '2023-01-02',
      ledger_id: '1'
    ).to_a[0]
    expect(log.nil?)
  end
end
