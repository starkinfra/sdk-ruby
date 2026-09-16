# frozen_string_literal: true

require_relative('../test_helper.rb')


describe(StarkInfra::IssuingTokenActivation, '#issuing-token-activation#') do
  it 'parse with right signature' do
    activation = StarkInfra::IssuingTokenActivation.parse(
      content: '{"activationMethod": {"type": "text", "value": "** *****-5678"}, "tokenId": "5585821789122165", "tags": ["token", "user/1234"], "cardId": "5189831499972623"}',
      signature: 'MEUCIAxn0FmsPWI4r3Y7Nq8xFNQHYZgo0QAGDQ4/7CajKoVuAiEA09kXWrPMhsw4JbgC3pmNccCWr+hidfop/KsSNqza0yE='
    )
    expect(activation.card_id).wont_be_nil
    expect(activation.token_id).wont_be_nil
  end

  it 'parse with wrong signature' do
    begin
      StarkInfra::IssuingTokenActivation.parse(
        content: '{"activationMethod": {"type": "text", "value": "** *****-5678"}, "tokenId": "5585821789122165", "tags": ["token", "user/1234"], "cardId": "5189831499972623"}',
        signature: 'MEUCIQDOpo1j+V40DNZK2URL2786UQK/8mDXon9ayEd8U0/l7AIgYXtIZJBTs8zCRR3vmted6Ehz/qfw1GRut/eYyvf1yOk='
      )
    rescue StarkInfra::Error::InvalidSignatureError
    else
      raise(StandardError, 'invalid signature was not detected')
    end
  end
end
