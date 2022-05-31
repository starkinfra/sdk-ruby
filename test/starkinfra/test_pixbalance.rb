# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../user')

describe(StarkInfra::PixBalance, '#pix-balance#') do
  it 'get success' do
    balance = StarkInfra::PixBalance.get
    expect(balance.id).wont_be_nil
    expect(balance.amount).wont_be_nil
    expect(balance.currency).wont_be_nil
    expect(balance.updated).wont_be_nil
  end
end

