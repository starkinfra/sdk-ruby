# frozen_string_literal: true

require('minitest/spec')
require('minitest/autorun')
require('date')
require('./lib/starkinfra')

describe('bacen id generators') do
  let(:ispb) { '20018183' }

  it 'creates a pix subscription bacen id' do
    bacen_id = StarkInfra::PixSubscriptionBacenId.create(ispb, 'RR')
    expect(bacen_id.length).must_equal(29)
    expect(bacen_id).must_match(/\ARR#{ispb}\d{8}[a-zA-Z0-9]{11}\z/)
    expect(bacen_id[10, 8]).must_equal(Time.now.strftime('%Y%m%d'))
  end

  it 'creates different pix subscription bacen ids' do
    first = StarkInfra::PixSubscriptionBacenId.create(ispb, 'RR')
    second = StarkInfra::PixSubscriptionBacenId.create(ispb, 'RR')
    expect(first).wont_equal(second)
  end

  it 'creates an end to end id with minute precision' do
    end_to_end_id = StarkInfra::EndToEndId.create(ispb)
    expect(end_to_end_id.length).must_equal(32)
    expect(end_to_end_id).must_match(/\AE#{ispb}\d{12}[a-zA-Z0-9]{11}\z/)
  end

  it 'creates a return id with minute precision' do
    return_id = StarkInfra::ReturnId.create(ispb)
    expect(return_id.length).must_equal(32)
    expect(return_id).must_match(/\AD#{ispb}\d{12}[a-zA-Z0-9]{11}\z/)
  end
end
