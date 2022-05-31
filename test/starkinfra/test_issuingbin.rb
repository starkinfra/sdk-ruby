# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../user')

describe(StarkInfra::IssuingBin, '#issuing-bin#') do
  it 'query' do
    bins = StarkInfra::IssuingBin.query
    bins.each do |bin|
      expect(bin.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    bins = nil
    (0..1).step(1) do
      bins, cursor = StarkInfra::IssuingBin.page(limit: 5, cursor: cursor)
      bins.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
  end
end
