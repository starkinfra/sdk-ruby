# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::PixKey, '#pix-key#') do
  it 'query params' do
    keys = StarkInfra::PixKey.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      tags: %w[bank],
      ids: %w[+55999999999],
      type: 'cpf'
    ).to_a
    expect(keys.length).must_equal(0)
  end

  it 'page params' do
    keys = StarkInfra::PixKey.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      tags: %w[bank],
      ids: %w[+55999999999],
      type: 'cpf'
    ).to_a
    expect(keys.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      keys, cursor = StarkInfra::PixKey.page(limit: 5, cursor: cursor)

      keys.each do |key|
        expect(ids).wont_include(key.id)
        ids << key.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    keys = StarkInfra::PixKey.query(limit: 10).to_a
    expect(keys.length).must_equal(10)
    keys_ids_expected = []
    keys.each do |key|
      keys_ids_expected.push(key.id)
    end

    keys_ids_result = []
    StarkInfra::PixKey.query(limit: 10, ids: keys_ids_expected).each do |key|
      keys_ids_result.push(key.id)
    end

    keys_ids_expected = keys_ids_expected.sort
    keys_ids_result = keys_ids_result.sort
    expect(keys_ids_expected).must_equal(keys_ids_result)
  end

  it 'create and get' do
    pix_key = ExampleGenerator.pixkey_example
    key = StarkInfra::PixKey.create(pix_key)
    expect(key.name).wont_be_nil
    expect(key.status).must_equal('created')
  end

  it 'page, get and update' do
    key = StarkInfra::PixKey.query(limit: 1, status: 'registered').to_a[0]

    key_get = StarkInfra::PixKey.get(key.id, payer_id: '012.345.678-90')
    expect(key.id).must_equal(key_get.id)

    key = StarkInfra::PixKey.update(
      key.id,
      reason: 'branchTransfer',
      account_created: '2022-01-01',
      account_number: '32432423',
      account_type: 'checking',
      branch_code: '0001',
      name: 'Arya Stark'
    )
    expect(key.name).must_equal('Arya Stark')
  end

  it 'page and cancel' do
    key = StarkInfra::PixKey.query(limit: 1, status: 'registered').to_a[0]

    key_cancel = StarkInfra::PixKey.cancel(key.id)
    expect(key.id).must_equal(key_cancel.id)
  end
end
