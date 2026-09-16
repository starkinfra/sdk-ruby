# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::CreditSigner, '#credit-signer#') do
  it 'resend token' do
    credit_note = ExampleGenerator.creditnote_example
    note = StarkInfra::CreditNote.create([credit_note])[0]

    signer = note.signers.find { |candidate| !candidate.name.to_s.strip.downcase.start_with?('stark') }
    refute_nil(signer, 'no signer created by the test was found')

    resent_signer = StarkInfra::CreditSigner.resend_token(signer.id)
    expect(resent_signer.id).must_equal(signer.id)
  end

  it 'resend token signer not found' do
    assert_raises(StarkCore::Error::InputErrors) do
      StarkInfra::CreditSigner.resend_token('000')
    end
  end
end
