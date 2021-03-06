# frozen_string_literal: true

require_relative('./test_helper.rb')
require_relative('./end_to_end_id')
require('securerandom')


class ExampleGenerator
  def self.pixrequest_example(bank_code)
    StarkInfra::PixRequest.new(
      amount: 10_000,
      external_id: SecureRandom.base64,
      sender_account_number: '00000-0',
      sender_branch_code: '0000',
      sender_account_type: 'checking',
      sender_name: 'joao',
      sender_tax_id: '09.346.601/0001-25',
      receiver_bank_code: '00000000',
      receiver_account_number: '00000-1',
      receiver_branch_code: '0001',
      receiver_account_type: 'checking',
      receiver_name: 'maria',
      receiver_tax_id: '45.987.245/0001-92',
      end_to_end_id: StarkInfra::EndToEndId.create(bank_code)
    )
  end

  def self.pixreversal_example()
    StarkInfra::PixReversal.new(
      amount: 1,
      external_id: SecureRandom.base64,
      end_to_end_id: StarkInfra::EndToEndIdTest.get_to_reverse,
      reason: 'fraud'
    )
  end

  def self.pixstatement_example
    StarkInfra::PixStatement.new(
      after: '2022-01-10',
      before: '2022-01-10',
      type: 'transaction'
    )
  end

  def self.pixinfraction_example
    pix_request = StarkInfra::PixRequest.query(limit: 1).to_a[0]
    StarkInfra::PixInfraction.new(
      reference_id: pix_request.end_to_end_id,
      type: 'fraud',
      description: 'ruby tests'
    )
  end

  def self.pixchargeback_example
    pix_request = StarkInfra::PixRequest.query(limit: 1).to_a[0]
    StarkInfra::PixChargeback.new(
      amount: 1,
      reference_id: pix_request.end_to_end_id,
      reason: 'flaw'
    )
  end

  def self.pixkey_example
    StarkInfra::PixKey.new(
      account_created: '2022-03-01',
      account_number: '0000',
      account_type: 'savings',
      branch_code: '0000',
      name: 'Jamie Lannister',
      tax_id: '012.345.678-90',
      id: '+5541989898989'
    )
  end

  def self.pixclaim_example
    StarkInfra::PixClaim.new(
      key_id: '+55119' + rand(10_000_000...99_999_999).to_s,
      account_created: '2022-03-01',
      account_number: '0000' + rand(1_000...9_999).to_s,
      account_type: 'savings',
      branch_code: '000' + rand(1...9).to_s,
      name: 'Jamie Lannister',
      tax_id: '012.345.678-90'
    )
  end

  def self.pixdirector_example
    StarkInfra::PixDirector.new(
      name: 'John Snow',
      tax_id: '012.345.678-90',
      phone: '+551141164616',
      email: 'bacen@starkbank.com',
      password: '12345678',
      team_email: 'bacen@starkbank.com',
      team_phones: ['+551141164616']
    )
  end

  def self.creditnote_example
    invoice1 = StarkInfra::CreditNote::Invoice.new(
      amount: 50_000,
      fine: 10,
      interest: 2,
      due: (Time.now + 60 * 24 * 3600).to_date,
      descriptions: [
        StarkInfra::CreditNote::Invoice::Description.new(
          key: 'key',
          value: 'value'
        )
      ]
    )

    invoice2 = StarkInfra::CreditNote::Invoice.new(
      amount: 50_000,
      fine: 10,
      interest: 2,
      due: (Time.now + 30 * 24 * 3600).to_date
    )
    invoices = [invoice1, invoice2]

    payment = StarkInfra::CreditNote::Transfer.new(
      bank_code: '00000000',
      branch_code: '0122',
      account_number: '129340-1',
      tax_id: '012.345.678-90',
      name: 'Jamie Lannister'
    )

    signers = [
      StarkInfra::CreditNote::Signer.new(
        name: 'Jamie Lannister',
        contact: rand(10_000_000...99_999_999).to_s + '@invaliddomain.com',
        method: 'link'
      ),
      StarkInfra::CreditNote::Signer.new(
        name: 'Jamie Lannister 2',
        contact: rand(10_000_000...99_999_999).to_s + '@invaliddomain.com',
        method: 'link'
      )
    ]
    StarkInfra::CreditNote.new(
      template_id: '5707012469948416',
      name: 'Jamie Lannister',
      tax_id: '20.018.183/0001-80',
      nominal_amount: 100_000,
      scheduled: (Time.now + 3 * 24 * 3600).to_date,
      invoices: invoices,
      payment: payment,
      payment_type: 'transfer',
      signers: signers,
      external_id: SecureRandom.base64,
      street_line_1: 'Rua ABC',
      street_line_2: 'Ap 123',
      district: 'Jardim Paulista',
      city: 'S??o Paulo',
      state_code: 'SP',
      zip_code: '01234-567',
      tags: ['iron'],
      rebate_amount: 0
    )
  end

  def self.issuingcard_example(holder:)
    StarkInfra::IssuingCard.new(
      holder_name: holder.name,
      holder_tax_id: holder.tax_id,
      holder_external_id: holder.external_id,
      rules: [issuingrule_example, issuingrule_example, issuingrule_example]
    )
  end

  def self.issuingholder_example
    StarkInfra::IssuingHolder.new(
      name: 'Iron Bank S.A.',
      external_id: SecureRandom.base64,
      tax_id: '012.345.678-90',
      tags: [
        'Traveler Employee'
      ],
      rules: [issuingrule_example],
    )
  end

  def self.issuinginvoice_example
    StarkInfra::IssuingInvoice.new(
      amount: rand(1..1_000)
    )
  end

  def self.issuingwithdrawal_example
    StarkInfra::IssuingWithdrawal.new(
      amount: rand(1..1_000),
      external_id: SecureRandom.base64,
      description: 'Issuing Withdrawal test'
    )
  end

  def self.issuingrule_example
    StarkInfra::IssuingRule.new(
      name: 'Example Rule',
      interval: ['day', 'week', 'month', 'instant'].sample,
      amount: rand(1_000..100_000),
      currency_code: ['BRL', 'USD'].sample
    )
  end

  def self.webhook_example
    StarkInfra::Webhook.new(
      url: 'https://webhook.site/#{SecureRandom.uuid}',
      subscriptions: %w[pix-request.in pix-claim]
    )
  end
end
