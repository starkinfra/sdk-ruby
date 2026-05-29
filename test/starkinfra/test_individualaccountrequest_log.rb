# frozen_string_literal: true

require_relative('../test_helper.rb')


describe(StarkInfra::IndividualAccountRequest::Log, '#individual-account-request/log#') do
  # M8: Log is read-only under <resource>.log with get/query/page; the `request`
  # field is the parent type, not a string id.
  it 'query logs' do
    logs = StarkInfra::IndividualAccountRequest::Log.query(limit: 10, types: 'created').to_a
    expect(logs.length).must_equal(10)
    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.type).must_equal('created')
      # exercises the recursive parent rebuild via API.from_api_json:
      expect(log.request.status).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      logs, cursor = StarkInfra::IndividualAccountRequest::Log.page(limit: 5, cursor: cursor)
      logs.each do |log|
        expect(ids).wont_include(log.id)
        ids << log.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    log = StarkInfra::IndividualAccountRequest::Log.query(limit: 1).to_a[0]
    next if log.nil?

    get_log = StarkInfra::IndividualAccountRequest::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  # M9: Log.query and Log.page accept limit, after, before, types, accountRequestIds.
  it 'query params' do
    logs = StarkInfra::IndividualAccountRequest::Log.query(
      limit: 1,
      after: '2023-01-01',
      before: '2023-01-02',
      types: ['created'],
      account_request_ids: ['1']
    ).to_a
    expect(logs.length).must_equal(0)
  end

  it 'page params' do
    logs = StarkInfra::IndividualAccountRequest::Log.page(
      limit: 1,
      after: '2023-01-01',
      before: '2023-01-02',
      types: ['created'],
      account_request_ids: ['1']
    ).to_a
    expect(logs.length).must_equal(2)
  end
end
