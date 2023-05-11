# frozen_string_literal: false

require_relative('../user')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IssuingDesign, '#issuing-design#') do
  it 'query' do
    designs = StarkInfra::IssuingDesign.query(limit: 100)

    designs.each do |design|
      expect(design.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      designs, cursor = StarkInfra::IssuingDesign.page(limit: 1, cursor: cursor)

      designs.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(2)
  end

  it 'query and get' do
    design = StarkInfra::IssuingDesign.query(limit: 1).first

    design = StarkInfra::IssuingDesign.get(design.id)
    expect(design.id).wont_be_nil
  end
end
