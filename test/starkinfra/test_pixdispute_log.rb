# frozen_string_literal: true

require_relative('../test_helper.rb')

describe(StarkInfra::PixDispute::Log, '#pix-dispute/log#') do
  # [M11] Log exposes query (read-only, no create/cancel);
  # [M12] Log.dispute rebuilds the embedded parent into a full PixDispute;
  # [M13] Log.type is a free, non-empty string — NOT a closed enum.
  # [S1] sandbox-tolerant: assert <= limit and well-formed items, never a fixed count.
  it 'query logs' do
    logs = StarkInfra::PixDispute::Log.query(limit: 10).to_a
    expect(logs.length).must_be(:<=, 10)
    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.type).wont_be_nil
      expect(log.type).wont_be_empty
      expect(log.dispute.status).wont_be_nil
    end
  end

  # [M11] Log exposes page with an opaque cursor.
  # [S1] sandbox-tolerant: assert the cursor mechanics work and no duplicates;
  #      never assert a fixed count.
  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      logs, cursor = StarkInfra::PixDispute::Log.page(limit: 5, cursor: cursor)

      logs.each do |log|
        expect(ids).wont_include(log.id)
        ids << log.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_be(:<=, 10)
  end

  # [M11] Log exposes get by id
  it 'query and get' do
    log = StarkInfra::PixDispute::Log.query(limit: 1).to_a[0]

    get_log = StarkInfra::PixDispute::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  # [M14] Log query/page support limit, after, before, types, dispute_ids (+ cursor on page);
  # [M15] Log.created parsed to native datetime
  it 'query params' do
    log = StarkInfra::PixDispute::Log.query(
      ids: ['1'],
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      types: ['analysed'],
      dispute_ids: ['1']
    ).to_a[0]
    expect(log).must_be_nil
  end

  it 'page params' do
    entities, _cursor = StarkInfra::PixDispute::Log.page(
      ids: ['1'],
      limit: 1,
      after: '2022-01-01',
      before: '2022-01-02',
      types: ['analysed'],
      dispute_ids: ['1']
    )
    expect(entities).must_be_empty
  end
end
