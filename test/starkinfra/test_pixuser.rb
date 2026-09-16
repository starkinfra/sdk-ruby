# frozen_string_literal: false

require_relative('../test_helper.rb')

describe(StarkInfra::PixUser, '#pix-user#') do
  it 'get' do
    user = StarkInfra::PixUser.get('01234567890')
    expect(user.id).must_equal('01234567890')
    user.statistics.each do |statistic|
      expect(statistic.type).wont_be_nil
    end
  end
end
