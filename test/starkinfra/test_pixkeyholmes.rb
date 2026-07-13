# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::PixKeyHolmes, '#pix-key-holmes#') do
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

  it 'create' do
    holmes = StarkInfra::PixKeyHolmes.create([ExampleGenerator.pix_key_holmes_example])

    holmes.each do |sherlock|
      expect(sherlock.id).wont_be_nil
    end
  end

  it 'create attributes' do
    sherlock = StarkInfra::PixKeyHolmes.create([ExampleGenerator.pix_key_holmes_example])[0]

    expect(sherlock.id).wont_be_nil
    expect(sherlock.status).wont_be_nil
    expect(sherlock.status).wont_be_empty
    expect(sherlock.created).wont_be_nil
    expect(sherlock.updated).wont_be_nil
  end
end
