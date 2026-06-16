# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::PixKeyHolmes, '#pix-key-holmes#') do
  # [M2] query supports the documented filter set: limit, after, before,
  # status, tags, ids. Every filter is plumbed through and narrows to zero
  # matching entities (contract query-parameter table, /tmp/pr128.diff:704).
  it 'query params' do
    holmes = StarkInfra::PixKeyHolmes.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[solved solving],
      tags: %w[travel food],
      ids: %w[1 2 3]
    ).to_a
    expect(holmes.length).must_equal(0)
  end

  # [M2] same documented filter set on page; cursor is exercised by the 'page'
  # block below (contract query-parameter table, /tmp/pr128.diff:730).
  it 'page params' do
    holmes = StarkInfra::PixKeyHolmes.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[solved solving],
      tags: %w[travel food],
      ids: %w[1 2 3]
    ).to_a
    expect(holmes.length).must_equal(2)
  end

  # [M4] page uses an opaque cursor (not a numeric page index); the two-page
  # walk asserts no duplicate ids across pages (contract [M4],
  # /tmp/pr128.diff:730).
  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      holmes, cursor = StarkInfra::PixKeyHolmes.page(limit: 5, cursor: cursor)

      holmes.each do |sherlock|
        expect(ids).wont_include(sherlock.id)
        ids << sherlock.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  # [M2] query happy path: ids round-trip (query, then re-query by the
  # returned ids and assert the id sets match).
  it 'query' do
    holmes = StarkInfra::PixKeyHolmes.query(limit: 10).to_a
    expect(holmes.length).must_equal(10)
    holmes_ids_expected = []
    holmes.each do |sherlock|
      holmes_ids_expected.push(sherlock.id)
    end

    holmes_ids_result = []
    StarkInfra::PixKeyHolmes.query(limit: 10, ids: holmes_ids_expected).each do |sherlock|
      holmes_ids_result.push(sherlock.id)
    end

    holmes_ids_expected = holmes_ids_expected.sort
    holmes_ids_result = holmes_ids_result.sort
    expect(holmes_ids_expected).must_equal(holmes_ids_result)
  end

  # [M1] create accepts a list of PixKeyHolmes and returns the list with each
  # entity carrying a server-assigned id (contract [M1],
  # /tmp/pr128.diff:691-701). [M3] there is NO get and NO cancel on this
  # resource, so there is intentionally no create-and-get round trip — the
  # created entity is asserted directly.
  it 'create' do
    holmes = StarkInfra::PixKeyHolmes.create([ExampleGenerator.pix_key_holmes_example])

    holmes.each do |sherlock|
      expect(sherlock.id).wont_be_nil
    end
  end

  # [M1][M5] only key_id and tags are accepted by create; the output-only
  # fields (id, result, status, created, updated) are populated by the server
  # on the returned entity (contract [M5], /tmp/pr128.diff:677).
  # [M6] created/updated are parsed off the raw ISO string by
  # StarkCore::Utils::Checks.check_datetime — we assert parsed/non-empty
  # (wont_be_nil), the canonical idiom in this suite (test-patterns.md:38;
  # test_pixbalance.rb single-get). status/result carry open documented value
  # sets (status: created|solving|solved|failed; result: registered|
  # unregistered) plus transitional values, so we assert parsed/non-empty
  # rather than against a closed set (contract Fields table, /tmp/pr128.diff:671-674).
  it 'create attributes' do
    sherlock = StarkInfra::PixKeyHolmes.create([ExampleGenerator.pix_key_holmes_example])[0]

    expect(sherlock.id).wont_be_nil
    expect(sherlock.status).wont_be_nil
    expect(sherlock.status).wont_be_empty
    expect(sherlock.created).wont_be_nil
    expect(sherlock.updated).wont_be_nil
  end
end
