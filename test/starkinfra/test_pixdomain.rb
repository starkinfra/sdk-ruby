# frozen_string_literal: false

require_relative('../user')
require_relative('../test_helper.rb')

describe(StarkInfra::PixDomain, '#pix-domain#') do
  it 'query' do
    domains = StarkInfra::PixDomain.query.to_a
    domains.each do |domain|
      expect(domain.certificates[0].class).must_equal(StarkInfra::Certificate)
      expect(domain.class).must_equal(StarkInfra::PixDomain)
      expect(domain.certificates[0].content).wont_be_nil
    end
  end
end
