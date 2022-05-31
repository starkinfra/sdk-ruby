# frozen_string_literal: true

require_relative('../test_helper.rb')

describe(StarkInfra::Key, '#key#') do
  it 'generates new random ECDSA key pair' do
    private_key, public_key = StarkInfra::Key.create
    expect(private_key).wont_be_empty
    expect(public_key).wont_be_empty
  end

  it 'generates new random ECDSA key pair and saves to folder keys' do
    private_key, public_key = StarkInfra::Key.create('keys')
    expect(private_key).wont_be_empty
    expect(public_key).wont_be_empty
  end
end
