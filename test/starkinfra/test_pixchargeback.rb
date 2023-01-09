# frozen_string_literal: false

require_relative('../user')
require_relative('../test_helper.rb')
require('starkcore')
require_relative('../example_generator.rb')

bank_code = BankCode.bank_code

describe(StarkInfra::PixChargeback, '#pix-chargeback#') do
  it 'query params' do
    chargebacks = StarkInfra::PixChargeback.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      flow: 'in',
      tags: %w[travel food]
    ).to_a
    expect(chargebacks.length).must_equal(0)
  end

  it 'page params' do
    chargebacks = StarkInfra::PixChargeback.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[1 2 3],
      flow: 'in',
      tags: %w[travel food]
    ).to_a
    expect(chargebacks.length).must_equal(2)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      chargebacks, cursor = StarkInfra::PixChargeback.page(limit: 5, cursor: cursor)

      chargebacks.each do |chargeback|
        expect(ids).wont_include(chargeback.id)
        ids << chargeback.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    chargebacks = StarkInfra::PixChargeback.query(limit: 10).to_a
    expect(chargebacks.length).must_equal(10)
    chargebacks_ids_expected = []
    chargebacks.each do |chargeback|
      chargebacks_ids_expected.push(chargeback.id)
    end

    chargebacks_ids_result = []
    StarkInfra::PixChargeback.query(limit: 10, ids: chargebacks_ids_expected).each do |chargeback|
      chargebacks_ids_result.push(chargeback.id)
    end

    chargebacks_ids_expected = chargebacks_ids_expected.sort
    chargebacks_ids_result = chargebacks_ids_result.sort
    expect(chargebacks_ids_expected).must_equal(chargebacks_ids_result)
  end

  it 'create and get' do
    pix_chargeback1 = ExampleGenerator.pixchargeback_example
    pix_chargeback2 = ExampleGenerator.pixchargeback_example
    chargeback = StarkInfra::PixChargeback.create([pix_chargeback1, pix_chargeback2])[0]

    chargeback_get = StarkInfra::PixChargeback.get(chargeback.id)
    expect(chargeback.id).must_equal(chargeback_get.id)
  end

  it 'page and update' do
    chargeback = StarkInfra::PixChargeback.get(get_chargeback('out'))

    chargeback = StarkInfra::PixChargeback.update(
      chargeback.id, result: 'accepted', reversal_reference_id: StarkInfra::ReturnId.create(bank_code))
    expect(chargeback.status).must_equal('closed')
  end

  it 'page and cancel' do
    chargeback = StarkInfra::PixChargeback.get(get_chargeback('out'))

    chargeback = StarkInfra::PixChargeback.cancel(chargeback.id)
    expect(chargeback.status).must_equal('canceled')
  end

  def get_chargeback(flow)
    cursor = nil
    chargeback_id = nil
    while true
      chargebacks, cursor = StarkInfra::PixChargeback.page(limit: 5, status: 'delivered', cursor: cursor)

      chargebacks.each do |chargeback|
        if chargeback.flow != flow
          chargeback_id = chargeback.id
          break
        end
      end
      break if cursor.nil?
    end
    chargeback_id
  end
end
