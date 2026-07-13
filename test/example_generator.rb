# frozen_string_literal: true

require('securerandom')
require_relative('./end_to_end_id')
require_relative('./utils/bacen_id')
require_relative('./bacen_id')
require_relative('./test_helper.rb')

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

  def self.pixfraud_example
    StarkInfra::PixFraud.new(
      external_id: SecureRandom.base64,
      type: 'scam',
      tax_id: '01234567890'
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
    invoice1 = StarkInfra::Invoice.new(
      amount: 50_000,
      due: (Time.now + 60 * 24 * 3600).to_date,
      descriptions: [
        StarkInfra::Description.new(
          key: 'key',
          value: 'value'
        )
      ]
    )

    invoice2 = StarkInfra::Invoice.new(
      amount: 50_000,
      due: (Time.now + 30 * 24 * 3600).to_date
    )
    invoices = [invoice1, invoice2]

    payment = StarkInfra::Transfer.new(
      bank_code: '00000000',
      branch_code: '0122',
      account_number: '129340-1',
      tax_id: '012.345.678-90',
      name: 'Jamie Lannister'
    )

    signers = [
      StarkInfra::CreditSigner.new(
        name: 'Jamie Lannister',
        contact: rand(10_000_000...99_999_999).to_s + '@invaliddomain.com',
        method: 'link'
      ),
      StarkInfra::CreditSigner.new(
        name: 'Jamie Lannister 2',
        contact: rand(10_000_000...99_999_999).to_s + '@invaliddomain.com',
        method: 'link'
      )
    ]
    StarkInfra::CreditNote.new(
      template_id: '5707012469948416',
      name: 'Jamie Lannister',
      tax_id: '012.345.678-90',
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
      city: 'São Paulo',
      state_code: 'SP',
      zip_code: '01234-567',
      tags: ['iron'],
      rebate_amount: 0
    )
  end

  def self.creditnote_hash_example
    {
      'template_id' => '5707012469948416',
      'name' => 'Jamie Lannister',
      'tax_id' => '012.345.678-90',
      'nominal_amount' => 100_000,
      'scheduled' => (Time.now + 3 * 24 * 3600).to_date,
      'invoices' => [
        {
          'amount' => 50_000,
          'due' => (Time.now + 60 * 24 * 3600).to_date
        }
      ],
      'payment' => {
        'bank_code' => '00000000',
        'branch_code' => '0122',
        'account_number' => '129340-1',
        'tax_id' => '012.345.678-90',
        'name' => 'Jamie Lannister'
      },
      'payment_type' => 'transfer',
      'signers' => [
        {
          'name' => 'Jamie Lannister',
          'contact' => rand(10_000_000...99_999_999).to_s + '@invaliddomain.com',
          'method' => 'link'
        },
        {
          'name' => 'Jamie Lannister 2',
          'contact' => rand(10_000_000...99_999_999).to_s + '@invaliddomain.com',
          'method' => 'link'
        }
      ],
      'external_id' => SecureRandom.base64,
      'street_line_1' => 'Rua ABC',
      'street_line_2' => 'Ap 123',
      'district' => 'Jardim Paulista',
      'city' => 'São Paulo',
      'state_code' => 'SP',
      'zip_code' => '01234-567',
      'tags' => ['iron'],
      'rebate_amount' => 0
    }
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
      tax_id: '34.511.067/0001-02',
      tags: [
        'Traveler Employee'
      ],
      rules: [issuingrule_example]
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
      interval: %w[day week month instant].sample,
      amount: rand(1_000..100_000),
      currency_code: %w[BRL USD].sample
    )
  end

  def self.brcodepreview_example
    brcode = StarkInfra::StaticBrcode.query(limit: 1).to_a[0]
    StarkInfra::BrcodePreview.new(
      id: brcode.id,
      payer_id: "20.018.183/0001-80"
    )
  end

  def self.dynamicbrcode_example
    StarkInfra::DynamicBrcode.new(
      name: 'Jamie Lannister',
      city: 'Rio de Janeiro',
      external_id: SecureRandom.base64,
      type: 'instant'
    )
  end

  def self.staticbrcode_example
    StarkInfra::StaticBrcode.new(
      name: 'Jamie Lannister',
      key_id: '+5511988887777',
      amount: 0,
      reconciliation_id: '123',
      cashier_bank_code: '20018183',
      description: 'A StaticBrcode',
      city: 'São Paulo'
    )
  end

  def self.webhook_example
    StarkInfra::Webhook.new(
      url: "https://webhook.site/#{SecureRandom.uuid}",
      subscriptions: %w[pix-request.in pix-claim]
    )
  end

  def self.webhook_hash_example
    {
      'url' => "https://webhook.site/#{SecureRandom.uuid}",
      'subscriptions' => %w[pix-request.in pix-claim]
    }
  end

  def self.preview_sac_example
    StarkInfra::CreditNotePreview.new(
      type: 'sac',
      nominal_amount: rand(1..100_000),
      scheduled: (Time.now + 3 * 24 * 3600).to_date,
      tax_id: '012.345.678-90',
      initial_due: (Time.now + 3 * 24 * 3600).to_date,
      nominal_interest: 10,
      count: 3,
      interval: %w[month year].sample
    )
  end

  def self.preview_price_example
    StarkInfra::CreditNotePreview.new(
      type: 'price',
      nominal_amount: rand(1..100_000),
      scheduled: (Time.now + 3 * 24 * 3600).to_date,
      tax_id: '012.345.678-90',
      initial_due: (Time.now + 3 * 24 * 3600).to_date,
      nominal_interest: 10,
      count: 3,
      interval: %w[month year].sample
    )
  end

  def self.preview_american_example
    StarkInfra::CreditNotePreview.new(
      type: 'american',
      nominal_amount: rand(1..100_000),
      scheduled: (Time.now + 3 * 24 * 3600).to_date,
      tax_id: '012.345.678-90',
      initial_due: (Time.now + 3 * 24 * 3600).to_date,
      nominal_interest: rand(1..4.99),
      count: 3,
      interval: %w[month year].sample
    )
  end

  def self.preview_bullet_example
    StarkInfra::CreditNotePreview.new(
      type: 'bullet',
      nominal_amount: 100000,
      scheduled: '2023-07-10',
      tax_id: '012.345.678-90',
      initial_due: '2023-07-20',
      nominal_interest: 10
    )
  end

  def self.hash_sac_example
    {
      'tax_id' => '012.345.678-90',
      'type' => 'sac',
      'nominal_amount' => rand(100..100_000),
      'rebate_amount' => rand(100..1000),
      'nominal_interest' => rand(1..4.99),
      'scheduled' => (Time.now + 3 * 24 * 3600).to_date,
      'initial_due' => (Time.now + 3 * 24 * 3600).to_date,
      'initial_amount' => rand(1..9999),
      'interval' => %w[month year].sample
    }
  end

  def self.dynamic_brcode_discount_example

    discount1 = StarkInfra::DynamicBrcode::Discount.new(
      percentage: 3,
      due: (Time.now + 3 * 24 * 3600).to_date
    )

    discount2 = StarkInfra::DynamicBrcode::Discount.new(
      percentage: 5,
      due: (Time.now + 3 * 24 * 3600).to_date
    )

    discounts = [discount1, discount2]
    discounts
  end

  def self.individual_identity_example
    StarkInfra::IndividualIdentity.new(
      name: "Jamie Lannister",
      tax_id: "012.345.678-90",
      tags: ["test", "testing"]
    )
  end

  def self.business_identity_example
    StarkInfra::BusinessIdentity.new(
      tax_id: "20.018.183/0001-80",
      tags: ["test", "testing"]
    )
  end

  def self.individual_document_image(image)
    rg_images = {
      "front" => "test/utils/identity/identity-front-face.png",
      "back" => "test/utils/identity/identity-back-face.png",
      "selfie" => "test/utils/identity/walter-white.png"
    }
    
    file = open(rg_images[image], 'rb')
    return picture = file.read
  end

  def self.issuing_embossingrequest_example(holder:)

    card = StarkInfra::IssuingCard.create(
      cards: [StarkInfra::IssuingCard.new(
        holder_name: holder.name,
        holder_tax_id: holder.tax_id,
        holder_external_id: holder.external_id,
        product_id: "52233227", 
        type: "physical"
      )]
    ).to_a[0]

    kit = StarkInfra::IssuingEmbossingKit.query(limit: 1).to_a[0]

    request = StarkInfra::IssuingEmbossingRequest.new(
      card_id: card.id,
      kit_id: kit.id, 
      display_name_1: "teste", 
      shipping_city: "Sao Paulo", 
      shipping_country_code: "BRA", 
      shipping_district: "Bela Vista", 
      shipping_service: "loggi", 
      shipping_state_code: "SP", 
      shipping_street_line_1: "teste", 
      shipping_street_line_2: "teste", 
      shipping_tracking_number: "teste", 
      shipping_zip_code: "12345-678",
      embosser_id: "5746980898734080"
    )

    return request
  end

  def self.issuing_restock_example

    stock = StarkInfra::IssuingStock.query(limit: 1).to_a[0]

    restock = StarkInfra::IssuingRestock.new(
      count: 100,
      stock_id: stock.id
    )

    return restock
  end

  def self.credit_holmes_example
    StarkInfra::CreditHolmes.new(
      tax_id: '012.345.678-90',
      competence: "2021-01",
      tags: ["SDK Ruby Test"]
    )
  end

  def self.pix_key_holmes_example
    StarkInfra::PixKeyHolmes.new(
      key_id: 'valid@sandbox.com',
      tags: ["SDK Ruby Test"]
    )
  end

  def self.pixinternaltransactionreport_example(bank_code)
    StarkInfra::PixInternalTransactionReport.new(
      amount: 1,
      created: '2022-02-16T17:23:53.980238+00:00',
      end_to_end_id: BacenId.create('E', bank_code),
      method: 'manual',
      reference_type: 'request',
      sender_account_number: '00000-0',
      sender_branch_code: '0000',
      sender_account_type: 'checking',
      sender_bank_code: bank_code,
      sender_tax_id: '09.346.601/0001-25',
      receiver_account_number: '00000-1',
      receiver_branch_code: '0001',
      receiver_account_type: 'checking',
      receiver_bank_code: '18236120',
      receiver_tax_id: '45.987.245/0001-92'
    )
  end

  def self.pixinternaltransactionreport_reversal_example(bank_code)
    StarkInfra::PixInternalTransactionReport.new(
      amount: 1,
      created: '2022-02-16T17:23:53.980238+00:00',
      end_to_end_id: BacenId.create('E', bank_code),
      method: 'dict',
      reference_type: 'reversal',
      sender_account_number: '00000-0',
      sender_branch_code: '0000',
      sender_account_type: 'checking',
      sender_bank_code: bank_code,
      sender_tax_id: '09.346.601/0001-25',
      receiver_account_number: '00000-1',
      receiver_branch_code: '0001',
      receiver_account_type: 'checking',
      receiver_bank_code: '18236120',
      receiver_tax_id: '45.987.245/0001-92',
      receiver_key_id: '+5511989898989',
      return_id: BacenId.create('D', bank_code)
    )
  end

  def self.pixpullsubscription_example
    bank_code = BankCode.bank_code
    StarkInfra::PixPullSubscription.new(
      bacen_id: BacenId.pixpullsubscription_bacen_id(bank_code),
      external_id: SecureRandom.base64,
      installment_start: Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S+00:00'),
      interval: 'month',
      receiver_bank_code: bank_code,
      receiver_name: 'Stark Bank',
      receiver_tax_id: '39.908.427/0001-28',
      sender_account_number: '55213',
      sender_bank_code: '20018183',
      sender_branch_code: '356',
      sender_tax_id: '99.999.919/9999-79',
      sender_final_name: 'STARK SCD S.A.',
      sender_final_tax_id: '39908427000128',
      type: 'push',
      amount: 52064,
      pull_retry_limit: 3,
      description: 'A Lannister always pays his debts',
      reference_code: '36135971',
      tags: ['ruby', 'sdk', 'test']
    )
  end

  def self.pixpullrequest_example
    ispb = BankCode.bank_code
    subscription = StarkInfra::PixPullSubscription.query(limit: 1, status: 'active').to_a[0]
    StarkInfra::PixPullRequest.new(
      amount: 1234,
      due: (Time.now + 3 * 24 * 3600).utc.strftime('%Y-%m-%dT%H:%M:%S+00:00'),
      end_to_end_id: StarkInfra::EndToEndIdTest.pixpullrequest_end_to_end_id(ispb),
      receiver_account_number: '876543-2',
      receiver_account_type: 'checking',
      receiver_bank_code: ispb,
      reconciliation_id: SecureRandom.hex(12),
      subscription_id: subscription.nil? ? '5656565656565656' : subscription.id,
      attempt_type: 'default',
      description: 'Ruby SDK PixPullRequest test',
      receiver_branch_code: '1357-9',
      tags: ['ruby', 'sdk', 'test']
    )
  end

  def self.brcodepreview_subscription_payload
    {
      'amount' => 1000,
      'amountMinLimit' => 500,
      'bacenId' => 'RR2222222220250101000000000abcdef',
      'created' => '2020-03-10T10:30:00+00:00',
      'description' => 'Monthly subscription for premium plan',
      'installmentEnd' => '2021-03-10T10:30:00+00:00',
      'installmentStart' => '2020-03-10T10:30:00+00:00',
      'interval' => 'monthly',
      'pullRetryLimit' => 3,
      'receiverBankCode' => '20018183',
      'receiverName' => 'Anthony Edward Stark',
      'receiverTaxId' => '012.345.678-90',
      'referenceCode' => 'contract-2020-0001',
      'senderFinalName' => 'Jamie Lannister',
      'senderFinalTaxId' => '20.018.183/0001-80',
      'status' => 'active',
      'type' => 'paymentAndOrQrcode',
      'updated' => '2020-04-10T10:30:00+00:00'
    }
  end

  def self.brcodepreview_payload(subscription_value)
    {
      'id' => '00020126580014br.gov.bcb.pix0136a629532e-7693-4846-852d-1bbff817b5a85204000053039865802BR5908Tony6009Sao Paulo62090505123456304B14A',
      'payerId' => '20.018.183/0001-80',
      'endToEndId' => 'E20018183202003101030000000abcdef',
      'accountNumber' => '1234567',
      'accountType' => 'checking',
      'amount' => 1000,
      'amountType' => 'fixed',
      'bankCode' => '20018183',
      'branchCode' => '0001',
      'cashAmount' => 0,
      'cashierBankCode' => nil,
      'cashierType' => nil,
      'discountAmount' => 0,
      'fineAmount' => 0,
      'keyId' => '+5511989898989',
      'interestAmount' => 0,
      'name' => 'Anthony Edward Stark',
      'nominalAmount' => 1000,
      'reconciliationId' => 'cd65c78aeb6543eaaa0170f68bd741ee',
      'reductionAmount' => 0,
      'scheduled' => '2020-03-10T10:30:00+00:00',
      'status' => 'active',
      'subscription' => subscription_value,
      'taxId' => '012.345.678-90'
    }
  end

  def self.pixpullrequest_payload
    {
      'id' => '5656565656565656',
      'amount' => 11_234,
      'due' => '2020-10-28T17:59:26+00:00',
      'endToEndId' => 'E00002649202201172211u34srod19le',
      'receiverAccountNumber' => '876543-2',
      'receiverAccountType' => 'checking',
      'receiverBankCode' => '20018183',
      'reconciliationId' => '123456',
      'subscriptionId' => '5656565656565656',
      'attemptType' => 'default',
      'description' => 'Payment for service #1234',
      'receiverBranchCode' => '1357-9',
      'tags' => %w[employees monthly],
      'status' => 'created',
      'flow' => 'out',
      'receiverName' => 'Edward Stark',
      'receiverTaxId' => '01234567890',
      'senderBankCode' => '20018183',
      'senderFinalName' => 'Edward Stark',
      'senderTaxId' => '20.018.183/0001-80',
      'subscriptionBacenId' => 'RR2222222220250101000000000abcdef',
      'created' => '2020-03-10T10:30:00+00:00',
      'updated' => '2020-04-10T10:30:00+00:00'
    }
  end

  def self.pixpullrequest_log_request_payload
    {
      'id' => '5656565656565656',
      'amount' => 11_234,
      'due' => '2020-10-28T17:59:26+00:00',
      'endToEndId' => 'E00002649202201172211u34srod19le',
      'receiverAccountNumber' => '876543-2',
      'receiverAccountType' => 'checking',
      'receiverBankCode' => '20018183',
      'reconciliationId' => '123456',
      'subscriptionId' => '5656565656565656',
      'status' => 'created',
      'flow' => 'out',
      'created' => '2020-03-10T10:30:00+00:00',
      'updated' => '2020-04-10T10:30:00+00:00'
    }
  end

  def self.pixpullsubscription_payload
    {
      'id' => '5656565656565656',
      'bacenId' => 'RR2222222220250101000000000abcdef',
      'externalId' => 'my-internal-id-123456',
      'installmentStart' => '2020-03-10T10:30:00+00:00',
      'installmentEnd' => '2021-03-10T10:30:00+00:00',
      'interval' => 'month',
      'receiverName' => 'Anthony Edward Stark',
      'receiverTaxId' => '012.345.678-90',
      'senderAccountNumber' => '876543-2',
      'senderBankCode' => '20018183',
      'senderBranchCode' => '1357-9',
      'senderTaxId' => '20.018.183/0001-80',
      'type' => 'paymentAndOrQrcode',
      'amount' => 1234,
      'amountMinLimit' => 500,
      'description' => 'Payment for service #1234',
      'due' => '2020-10-28T17:59:26+00:00',
      'receiverBankCode' => '20018183',
      'referenceCode' => 'contract-123',
      'pullRetryLimit' => 3,
      'senderCityCode' => '1234567',
      'senderFinalName' => 'Edward Stark',
      'senderFinalTaxId' => '01234567890',
      'tags' => %w[employees monthly],
      'status' => 'active',
      'flow' => 'out',
      'created' => '2020-03-10T10:30:00+00:00',
      'updated' => '2020-04-10T10:30:00+00:00'
    }
  end
  
  def self.issuing_stock_rule_example
    stock = StarkInfra::IssuingStock.query(limit: 1).to_a[0]

    rule = StarkInfra::IssuingStockRule.new(
      minimum_balance: 10_000,
      stock_id: stock.id,
      tags: %w[card corporate],
      emails: ['john.doe@enterprise.com'],
      phones: ['+5511912345678']
    )

    return rule
  end
end
