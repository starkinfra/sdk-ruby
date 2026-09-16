# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::BusinessAccountRequest, '#business-account-request#') do
  it 'create' do
    request = StarkInfra::BusinessAccountRequest.create([ExampleGenerator.business_account_request_example]).first
    expect(request.id).wont_be_nil
    expect(request.account_type).must_equal('business')
    expect(request.address).must_be_instance_of(StarkInfra::BusinessAccountRequest::Address)
    request.owners.each do |owner|
      expect(owner).must_be_instance_of(StarkInfra::BusinessAccountRequest::Owner)
    end
  end

  it 'query' do
    requests = StarkInfra::BusinessAccountRequest.query(limit: 1)

    requests.each do |request|
      expect(request.id).wont_be_nil
    end
  end

  it 'query params' do
    requests = StarkInfra::BusinessAccountRequest.query(
      limit: 10,
      after: '2020-04-01',
      before: '2020-04-30',
      status: 'created',
      tags: ['employees', 'monthly'],
      ids: ['1', '2', '3']
    ).to_a
    expect(requests.length).must_equal(0)
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      requests, cursor = StarkInfra::BusinessAccountRequest.page(limit: 2, cursor: cursor)

      requests.each do |request|
        expect(ids).wont_include(request.id)
        ids << request.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_be(:>=, 1)
  end

  it 'query and get' do
    request = StarkInfra::BusinessAccountRequest.query(limit: 1).first

    get_request = StarkInfra::BusinessAccountRequest.get(request.id)
    expect(request.id).must_equal(get_request.id)
    get_request.owners.each do |owner|
      expect(owner).must_be_instance_of(StarkInfra::BusinessAccountRequest::Owner)
    end
  end

  it 'status enum' do
    allowed = ['created', 'processing', 'approved', 'denied', 'failed']

    requests = StarkInfra::BusinessAccountRequest.query(limit: 10)
    requests.each do |request|
      expect(allowed).must_include(request.status) unless request.status.nil?
    end
  end

  it 'owners from hashes are parsed' do
    request = StarkInfra::BusinessAccountRequest.new(
      name: 'Stark Bank S.A.',
      tax_id: '20.018.183/0001-80',
      address: {
        'street' => 'Av. Faria Lima',
        'number' => '2000',
        'neighborhood' => 'Itaim Bibi',
        'city' => 'Sao Paulo',
        'state' => 'SP',
        'zip_code' => '04538-132'
      },
      revenue: 100_000_000,
      owners: [
        {
          'tax_id' => '012.345.678-90',
          'name' => 'Jamie Lannister',
          'role' => 'partner'
        },
        {
          'tax_id' => '812.531.960-36',
          'name' => 'Cersei Lannister',
          'role' => 'representative'
        }
      ]
    )

    expect(request.address).must_be_instance_of(StarkInfra::BusinessAccountRequest::Address)
    expect(request.address.zip_code).must_equal('04538-132')
    expect(request.owners.length).must_equal(2)
    request.owners.each do |owner|
      expect(owner).must_be_instance_of(StarkInfra::BusinessAccountRequest::Owner)
      expect(owner.validator_link).must_be_nil
    end
  end

  it 'error not found' do
    begin
      StarkInfra::BusinessAccountRequest.get('0')
    rescue StarkInfra::Error::InputErrors
    else
      raise(StandardError, 'nonexistent id did not raise InputErrors')
    end
  end
end
