# frozen_string_literal: true

require_relative('../test_helper.rb')


describe(StarkInfra::PixInternalTransactionReport::Log, '#pix-internal-transaction-report/log#') do
  it 'query logs' do
    logs = StarkInfra::PixInternalTransactionReport::Log.query(limit: 10, types: 'success').to_a
    expect(logs.length).must_equal(10)
    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.type).must_equal('success')
      expect(log.report.status).must_equal('success')
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      logs, cursor = StarkInfra::PixInternalTransactionReport::Log.page(limit: 5, cursor: cursor)
      logs.each do |log|
        expect(ids).wont_include(log.id)
        ids << log.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    log = StarkInfra::PixInternalTransactionReport::Log.query(limit: 1).to_a[0]

    get_log = StarkInfra::PixInternalTransactionReport::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  it 'query params' do
    logs = StarkInfra::PixInternalTransactionReport::Log.query(
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      types: %w[success],
      report_ids: %w[1]
    ).to_a
    expect(logs.length).must_equal(0)
  end
end
