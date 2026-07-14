# frozen_string_literal: true

require_relative('../test_helper.rb')


describe(StarkInfra::IssuingTokenRequest, '#issuing-token-request#') do
  it 'create' do
    card = StarkInfra::IssuingCard.query(status: 'active', limit: 1).to_a[0]

    request = StarkInfra::IssuingTokenRequest.create(
      StarkInfra::IssuingTokenRequest.new(
        card_id: card.id,
        wallet_id: 'google',
        method_code: 'app'
      )
    )

    expect(request.card_id).must_equal(card.id)
    expect(request.wallet_id).must_equal('google')
    expect(request.method_code).must_equal('app')
    expect(request.content).wont_be_nil
    expect(request.content.length).must_be(:>, 1000)
  end

  it 'create returns signature and metadata' do
    card = StarkInfra::IssuingCard.query(status: 'active', limit: 1).to_a[0]

    request = StarkInfra::IssuingTokenRequest.create(
      StarkInfra::IssuingTokenRequest.new(
        card_id: card.id,
        wallet_id: 'google',
        method_code: 'app'
      )
    )

    expect(request.signature).wont_be_nil
    expect(request.metadata).wont_be_nil
  end
end
