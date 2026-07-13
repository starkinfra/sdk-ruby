# frozen_string_literal: true

require('date')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixPullRequest::Log, '#pix-pull-request/log#') do
  it 'query logs' do
    logs = StarkInfra::PixPullRequest::Log.query(limit: 10).to_a
    expect(logs.length).must_be :<=, 10
    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.type).wont_be_nil
      expect(log.request.status).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      logs, cursor = StarkInfra::PixPullRequest::Log.page(limit: 5, cursor: cursor)

      logs.each do |log|
        expect(ids).wont_include(log.id)
        ids << log.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    log = StarkInfra::PixPullRequest::Log.query(limit: 1).to_a[0]
    skip 'no PixPullRequest log exists in this workspace yet' if log.nil?

    get_log = StarkInfra::PixPullRequest::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  it 'query params with request_ids plural filter' do
    log = StarkInfra::PixPullRequest::Log.query(
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      request_ids: ['1']
    ).to_a[0]
    expect(log.nil?)
  end

  it 'page params with request_ids plural filter' do
    log = StarkInfra::PixPullRequest::Log.page(
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      request_ids: ['1']
    ).to_a[0]
    expect(log.nil?)
  end

  def deserialize_log(payload)
    maker = StarkInfra::PixPullRequest::Log.resource[:resource_maker]
    StarkCore::Utils::API.from_api_json(maker, payload)
  end

  it 'deserializes a populated log payload into a typed Log with nested request' do
    payload = {
      'id' => '5074777513394176',
      'request' => ExampleGenerator.pixpullrequest_log_request_payload,
      'type' => 'created',
      'errors' => ['some-error-code'],
      'created' => '2020-03-10T10:30:00+00:00'
    }
    log = deserialize_log(payload)

    expect(log).must_be_kind_of(StarkInfra::PixPullRequest::Log)
    expect(log.id).must_equal('5074777513394176')
    expect(log.type).must_equal('created')
    expect(log.errors).must_equal(['some-error-code'])
    expect(log.request).must_be_kind_of(StarkInfra::PixPullRequest)
    expect(log.request.id).must_equal('5656565656565656')
  end

  it 'defaults errors to [] when the JSON payload has no errors field (M11)' do
    payload = {
      'id' => '5074777513394176',
      'request' => ExampleGenerator.pixpullrequest_log_request_payload,
      'type' => 'created',
      'created' => '2020-03-10T10:30:00+00:00'
    }
    log = deserialize_log(payload)

    expect(log.errors).must_equal([])
  end

  it 'parses created as a native DateTime value (M8)' do
    payload = {
      'id' => '5074777513394176',
      'request' => ExampleGenerator.pixpullrequest_log_request_payload,
      'type' => 'created',
      'errors' => [],
      'created' => '2020-03-10T10:30:00+00:00'
    }
    log = deserialize_log(payload)
    iso_format = '%Y-%m-%dT%H:%M:%S+00:00'

    expect(log.created).must_be_kind_of(DateTime)
    expect(log.created.strftime(iso_format)).must_equal('2020-03-10T10:30:00+00:00')
  end
end
