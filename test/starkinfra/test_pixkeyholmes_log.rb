# frozen_string_literal: true

require_relative('../test_helper.rb')

describe(StarkInfra::PixKeyHolmes::Log, '#pix-key-holmes/log#') do
  it 'query logs' do
    logs = StarkInfra::PixKeyHolmes::Log.query(limit: 10).to_a
    expect(logs.length).must_be(:>, 0)

    logs.each do |log|
      expect(log.id).wont_be_nil
      expect(log.type).wont_be_nil
      expect(log.holmes.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      logs, cursor = StarkInfra::PixKeyHolmes::Log.page(limit: 2, cursor: cursor)

      logs.each do |log|
        expect(ids).wont_include(log.id)
        ids << log.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(4)
  end

  it 'query and get' do
    log = StarkInfra::PixKeyHolmes::Log.query(limit: 1).to_a[0]

    get_log = StarkInfra::PixKeyHolmes::Log.get(log.id)
    expect(log.id).must_equal(get_log.id)
    expect(get_log.holmes.id).wont_be_nil
  end
end
