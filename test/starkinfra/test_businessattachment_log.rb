# frozen_string_literal: false

require_relative('../test_helper.rb')

describe(StarkInfra::BusinessAttachment::Log, '#BusinessAttachment/log#') do
  it 'query logs' do
    logs = StarkInfra::BusinessAttachment::Log.query(limit: 10, types: 'created').to_a

    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.type).must_equal('created')
    end
  end

  it 'query and get' do
    log = StarkInfra::BusinessAttachment::Log.query(limit: 1).to_a[0]

    get_log = StarkInfra::BusinessAttachment::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  it 'query params' do
    log = StarkInfra::BusinessAttachment::Log.query(
      limit: 1,
      after: '2023-01-01',
      before: '2023-01-02',
      types: ['canceled'],
      attachment_ids: ['1']
    ).to_a[0]
    expect(log.nil?)
  end

  it 'page params' do
    log = StarkInfra::BusinessAttachment::Log.page(
      limit: 1,
      after: '2023-01-01',
      before: '2023-01-02',
      types: ['canceled'],
      attachment_ids: ['1']
    ).to_a[0]
    expect(log.nil?)
  end
end
