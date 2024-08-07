# frozen_string_literal: false

require_relative('../test_helper.rb')

describe(StarkInfra::CardMethod, '#card-method#') do
  it 'query' do
    notes = StarkInfra::CardMethod.query(search: 'token').to_a

    notes.each do |note|
      expect(note).nil?
    end
  end
end
