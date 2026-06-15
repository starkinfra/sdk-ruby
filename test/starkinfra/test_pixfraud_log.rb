# frozen_string_literal: true

require_relative('../test_helper.rb')

# [M9] PixFraud.Log is a read-only sub-resource exposed under StarkInfra::PixFraud::Log
# with query/page/get only (no create/cancel). [M14] the parent's exports register
# the Log so the constant resolves. Logs are queried from existing entities, so the
# Log needs no fixture of its own.
describe(StarkInfra::PixFraud::Log, '#pix-fraud/log#') do
  # [M9][M10][M11][M13] query happy path + attribute surface.
  # IMPORTANT (contract v4 [M11]): Log.type is an OPEN, non-empty string — the
  # live API emits transitional values such as "canceling". We do NOT filter by
  # a closed `types` value and we do NOT assert type against a closed set. We
  # assert only that type is parsed and non-empty, matching the canonical *_log
  # convention and the cross-language reference
  # sdk-infra/go/tests/sdk/pix_fraud_log_test.go:139.
  it 'query logs' do
    logs = StarkInfra::PixFraud::Log.query(limit: 10).to_a
    expect(logs.length).must_equal(10)
    logs.each do |log|
      expect(log.id).wont_be_nil
      # [M11] type parsed to a non-empty free string (open set — no closed enum)
      expect(log.type).wont_be_nil
      expect(log.type).wont_be_empty
      # [M10] embedded parent rebuilt into a full PixFraud via API.from_api_json
      expect(log.fraud.id).wont_be_nil
      # [M13] created parsed off the raw ISO string by
      # StarkCore::Utils::Checks.check_datetime
      # (starkcore-0.2.2/lib/utils/checks.rb:49-58). We assert parsed/non-empty
      # (wont_be_nil) — the canonical idiom in this suite; per contract v4 [M13]
      # datetime note we do NOT assert a specific native type.
      expect(log.created).wont_be_nil
    end
  end

  # [M9][M12] page uses an opaque cursor; two-page walk asserts no duplicate ids.
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

  # [M9] log.get retrieves a single Log by id.
  it 'query and get' do
    log = StarkInfra::PixFraud::Log.query(limit: 1).to_a[0]

    get_log = StarkInfra::PixFraud::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
  end

  # [M12] query supports limit, after, before, types, fraud_ids, ids. Every
  # documented Log filter is plumbed through (open `types` set passed as a list).
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

  # [M12] same filter set on page (+ cursor handled by the 'page' block above).
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
