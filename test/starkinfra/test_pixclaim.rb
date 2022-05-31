# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')
require_relative('../user')

describe(StarkInfra::PixClaim, '#pix-claim#') do
  it 'query params' do
    claims = StarkInfra::PixClaim.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[+55999999999],
      type: 'cpf',
      agent: 'claimed',
      key_id: '+55119' + rand(10_000_000...99_999_999).to_s,
      key_type: 'cpf'
    ).to_a
    expect(claims.length).must_equal(0)
  end

  it 'page params' do
    claims, _ = StarkInfra::PixClaim.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: %w[created],
      ids: %w[+55999999999],
      type: 'cpf',
      agent: 'claimed',
      key_id: '+55119' + rand(10_000_000...99_999_999).to_s,
      key_type: 'cpf'
    ).to_a
    expect(claims.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    claims = nil
    (0..1).step(1) do
      claims, cursor = StarkInfra::PixClaim.page(limit: 5, cursor: cursor)
      claims.each do |claim|
        expect(ids).wont_include(claim.id)
        ids << claim.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query' do
    claims = StarkInfra::PixClaim.query(limit: 10).to_a
    expect(claims.length).must_equal(10)
    claims_ids_expected = []
    claims.each do |claim|
      claims_ids_expected.push(claim.id)
    end

    claims_ids_result = []
    StarkInfra::PixClaim.query(limit: 10, ids: claims_ids_expected).each do |claim|
      claims_ids_result.push(claim.id)
    end

    claims_ids_expected = claims_ids_expected.sort
    claims_ids_result = claims_ids_result.sort
    expect(claims_ids_expected).must_equal(claims_ids_result)
  end

  it 'create and get' do
    pix_claim = ExampleGenerator.pixclaim_example
    claim = StarkInfra::PixClaim.create(pix_claim)
    expect(claim.name).wont_be_nil
    expect(claim.status).must_equal('created')
  end

  it 'page, get and update' do
    claim = StarkInfra::PixClaim.query(limit: 1, agent: 'claimer', status: 'delivered').to_a[0]
    claim_get = StarkInfra::PixClaim.get(claim.id)
    expect(claim.id).must_equal(claim_get.id)
    claim = StarkInfra::PixClaim.update(
      claim_get.id,
      status: 'canceled',
      reason: 'userRequested'
    )
    expect(claim.id).must_equal(claim_get.id)
  end
end
