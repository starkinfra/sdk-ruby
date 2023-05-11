# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IssuingEmbossingKit, '#issuing-kit#') do
  it 'query' do
    kits = StarkInfra::IssuingEmbossingKit.query(limit: 100)

    kits.each do |kit|
      puts kit
      expect(kit.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      kits, cursor = StarkInfra::IssuingEmbossingKit.page(limit: 3, cursor: cursor)

      kits.each do |kit|
        puts kit
        expect(ids).wont_include(kit.id)
        ids << kit.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(3)
  end

  it 'query and get' do
    kit = StarkInfra::IssuingEmbossingKit.query(limit: 1).first
    kit = StarkInfra::IssuingEmbossingKit.get(kit.id)
    puts kit
    expect(kit.id).wont_be_nil
  end
end
