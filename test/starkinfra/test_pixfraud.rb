# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixFraud, '#pix-fraud#') do
  # [M3] query/page filters: limit, after, before, status, ids, tags.
  # `flow` is NOT a valid PixFraud filter — the live API rejects it with
  # invalidQueryString (contract v4 [M3] + query-parameter note, verified
  # 2026-06-15). Only limit/after/before/status/ids/tags (+cursor on page)
  # are plumbed through; every one narrows to zero matches.
  it 'query params' do
    frauds = StarkInfra::PixFraud.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      tags: %w[travel food]
    ).to_a
    expect(frauds.length).must_equal(0)
  end

  # [M3] same filter set on page (+ cursor is exercised by the 'page' block
  # below). `flow` is intentionally absent — see 'query params' above.
  it 'page params' do
    frauds = StarkInfra::PixFraud.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      tags: %w[travel food]
    ).to_a
    expect(frauds.length).must_equal(2)
  end

  # [M3][M5] page uses an opaque cursor (not a numeric page index); two-page
  # walk asserts no duplicate ids across pages.
  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      frauds, cursor = StarkInfra::PixFraud.page(limit: 5, cursor: cursor)

      frauds.each do |fraud|
        expect(ids).wont_include(fraud.id)
        ids << fraud.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  # [M3] query happy path: ids round-trip (query then re-query by ids).
  it 'query' do
    frauds = StarkInfra::PixFraud.query(limit: 10).to_a
    expect(frauds.length).must_equal(10)
    frauds_ids_expected = []
    frauds.each do |fraud|
      frauds_ids_expected.push(fraud.id)
    end

    frauds_ids_result = []
    StarkInfra::PixFraud.query(limit: 10, ids: frauds_ids_expected).each do |fraud|
      frauds_ids_result.push(fraud.id)
    end

    frauds_ids_expected = frauds_ids_expected.sort
    frauds_ids_result = frauds_ids_result.sort
    expect(frauds_ids_expected).must_equal(frauds_ids_result)
  end

  # [M1][M2] create accepts a list of PixFraud and returns entities with a
  # server-assigned id; get retrieves a single PixFraud by id.
  # [M6][M8] the created entity exposes the output-only id/bacen_id/status and
  # the native-datetime created/updated (asserted in 'create attributes' below).
  it 'create and get' do
    pix_fraud = ExampleGenerator.pixfraud_example
    fraud = StarkInfra::PixFraud.create([pix_fraud])[0]

    fraud_get = StarkInfra::PixFraud.get(fraud.id)
    expect(fraud.id).must_equal(fraud_get.id)
  end

  # [M6] only the 5 input fields are accepted by create; the output-only fields
  # (id, bacen_id, status, created, updated) are populated by the server on the
  # returned entity. [M7] status carries created|failed|registered|canceled but
  # the API also emits transitional values, so we assert status is parsed and
  # non-empty rather than against a closed set (contract v4 [M7] note). [M8]
  # created/updated are parsed datetimes.
  it 'create attributes' do
    fraud = StarkInfra::PixFraud.create([ExampleGenerator.pixfraud_example])[0]

    expect(fraud.id).wont_be_nil
    expect(fraud.bacen_id).wont_be_nil
    expect(fraud.status).wont_be_nil
    expect(fraud.status).wont_be_empty
    # [M8] created/updated are parsed off the raw ISO string by
    # StarkCore::Utils::Checks.check_datetime
    # (starkcore-0.2.2/lib/utils/checks.rb:49-58). We assert parsed/non-empty
    # (wont_be_nil) — the canonical idiom in this suite (test-patterns.md:38;
    # test_pixbalance.rb single-get). Per contract v4 [M8] datetime note we do
    # NOT assert a specific native type, only that the value parsed.
    expect(fraud.created).wont_be_nil
    expect(fraud.updated).wont_be_nil
  end

  # [M4] cancel (DELETE /pix-fraud/{id}) IMPL is required but a happy-path cancel
  # TEST is intentionally OMITTED (contract v4 [M4], verified 2026-06-15): the
  # API only cancels frauds already in `registered` status; a freshly-created
  # fraud returns invalidCancellationStatus, and the sandbox cannot produce a
  # cancelable fraud on demand. The reference ports (pix_fraud.go, pixFraud.php)
  # ship no cancel test either. Phase 4 verifies the cancel method exists via the
  # surface, not via a happy-path round-trip.
end
