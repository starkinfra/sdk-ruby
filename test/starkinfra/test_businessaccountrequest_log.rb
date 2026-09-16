# frozen_string_literal: false

require_relative('../test_helper.rb')


describe(StarkInfra::BusinessAccountRequest::Log, '#BusinessAccountRequest/log#') do
  it 'query logs' do
    logs = StarkInfra::BusinessAccountRequest::Log.query(limit: 10).to_a

    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.request).must_be_instance_of(StarkInfra::BusinessAccountRequest)
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      logs, cursor = StarkInfra::BusinessAccountRequest::Log.page(limit: 2, cursor: cursor)

      logs.each do |log|
        expect(ids).wont_include(log.id)
        ids << log.id
      end
      break if cursor.nil?
    end
  end

  it 'query and get' do
    log = StarkInfra::BusinessAccountRequest::Log.query(limit: 1).to_a[0]

    get_log = StarkInfra::BusinessAccountRequest::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  it 'query params' do
    log = StarkInfra::BusinessAccountRequest::Log.query(
      limit: 1,
      after: '2020-04-01',
      before: '2020-04-30',
      types: ['created'],
      account_request_ids: ['1', '2', '3']
    ).to_a[0]
    expect(log.nil?)
  end

  it 'page params' do
    log = StarkInfra::BusinessAccountRequest::Log.page(
      limit: 1,
      after: '2020-04-01',
      before: '2020-04-30',
      types: ['created'],
      account_request_ids: ['1', '2', '3']
    ).to_a[0]
    expect(log.nil?)
  end
end
