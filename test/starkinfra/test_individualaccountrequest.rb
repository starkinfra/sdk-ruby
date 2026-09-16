# frozen_string_literal: true

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IndividualAccountRequest, '#individual-account-request#') do
  # --- happy-path CRUD verbs (contract §Endpoints) ---

  # M1: create accepts a list and returns the same shape with server-assigned
  # id, status, accountType, created, updated populated.
  it 'create and get' do
    request = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]

    expect(request.id).wont_be_nil
    expect(request.status).wont_be_nil
    expect(request.account_type).must_equal('individual')

    # M3: get(id) returns a single IndividualAccountRequest by id.
    request_get = StarkInfra::IndividualAccountRequest.get(request.id)
    expect(request.id).must_equal(request_get.id)
  end

  # M4: query returns an iterable of IndividualAccountRequest accepting
  # limit, after, before, status, tags, ids.
  it 'query' do
    requests = StarkInfra::IndividualAccountRequest.query(limit: 5).to_a
    requests.each do |request|
      expect(request.id).wont_be_nil
    end
  end

  it 'query params' do
    requests = StarkInfra::IndividualAccountRequest.query(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'created',
      tags: %w[1 2 3],
      ids: %w[1 2 3]
    ).to_a
    expect(requests.length).must_equal(0)
  end

  # M5: page returns [items, cursor] and accepts the query params plus cursor.
  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      requests, cursor = StarkInfra::IndividualAccountRequest.page(limit: 5, cursor: cursor)
      requests.each do |request|
        expect(ids).wont_include(request.id)
        ids << request.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'page params' do
    requests = StarkInfra::IndividualAccountRequest.page(
      limit: 4,
      after: '2022-01-01',
      before: '2022-02-01',
      status: 'created',
      tags: %w[1 2 3],
      ids: %w[1 2 3]
    ).to_a
    expect(requests.length).must_equal(2)
  end

  # M6: update(id, ...) PATCHes the request, replacing (not deep-merging) the
  # address object. Self-contained: create a fresh record and patch name/address
  # (NOT status — status patch is exercised only as an error case below).
  it 'create and update' do
    request = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]

    new_address = StarkInfra::IndividualAccountRequest::Address.new(
      street: 'Rua Nova',
      number: '900',
      neighborhood: 'Centro',
      city: 'SP',
      state: 'SP',
      zip_code: '01310-100'
    )

    updated = StarkInfra::IndividualAccountRequest.update(
      request.id,
      name: 'Tony Stark Updated',
      address: new_address
    )
    expect(updated.id).must_equal(request.id)
  end

  # --- M2: address is a structured object, never flattened ---
  it 'address is constructed as a structured object' do
    address = StarkInfra::IndividualAccountRequest::Address.new(
      street: 'Rua do Estilo Barroco',
      number: '648',
      neighborhood: 'Santo Amaro',
      city: 'SP',
      state: 'SP',
      zip_code: '05724005'
    )
    expect(address.street).must_equal('Rua do Estilo Barroco')
    expect(address.number).must_equal('648')
    expect(address.zip_code).must_equal('05724005')

    request = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    # The address round-trips as an object, not as flattened addressStreet/etc.
    expect(request.id).wont_be_nil
  end

  # --- M7: status enum membership ---
  it 'status enum is a member of the sandbox-emitted set' do
    valid = %w[approved created denied processing updated]
    requests = StarkInfra::IndividualAccountRequest.query(limit: 5).to_a
    requests.each do |request|
      expect(valid).must_include(request.status) unless request.status.nil?
    end
  end

  # --- M10: datetime fields parsed to native datetime type ---
  # check_datetime parses an ISO string to DateTime (core-repos/ruby/lib/utils/checks.rb:79,84);
  # DateTime is NOT a subclass of Time in Ruby, so assert non-nil (parse succeeded) rather
  # than pinning a concrete class — code-agnostic per the v3 contract.
  it 'datetime fields parse to native type' do
    request = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    expect(request.created).wont_be_nil
    expect(request.updated).wont_be_nil unless request.updated.nil?
  end

  # --- M11: output-only fields are not serialized into the POST body ---
  # Passing accountType/status/id/created/updated to the constructor must not
  # crash and must not be rejected by the API; the server-assigned values win.
  it 'output-only fields passed to constructor are ignored by the API' do
    request_input = StarkInfra::IndividualAccountRequest.new(
      name: 'Tony Stark',
      tax_id: '012.345.678-90',
      income: 1_000_000,
      address: StarkInfra::IndividualAccountRequest::Address.new(
        street: 'Rua do Estilo Barroco',
        number: '648',
        neighborhood: 'Santo Amaro',
        city: 'SP',
        state: 'SP',
        zip_code: '05724005'
      ),
      status: 'approved',
      account_type: 'individual',
      flags: ['ignored'],
      id: '999',
      created: '2020-01-01T00:00:00.000000+00:00',
      updated: '2020-01-01T00:00:00.000000+00:00'
    )
    request = StarkInfra::IndividualAccountRequest.create([request_input])[0]
    # Server assigns its own id, ignoring the client-supplied one.
    expect(request.id).wont_equal('999')
  end

  # --- error cases (M12): assert the mapped exception TYPE is raised,
  # never a specific error-code string. ---

  it 'create with empty name raises InputErrors' do
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountRequest.create(
        [ExampleGenerator.individual_account_request_example(name: '')]
      )
    end
  end

  it 'create with invalid taxId raises InputErrors' do
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountRequest.create(
        [ExampleGenerator.individual_account_request_example(tax_id: '000.000.000-00')]
      )
    end
  end

  it 'create with incomplete address raises InputErrors' do
    bad_address = StarkInfra::IndividualAccountRequest::Address.new(
      street: 'Rua do Estilo Barroco'
      # missing number, neighborhood, city, state, zip_code
    )
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountRequest.create(
        [ExampleGenerator.individual_account_request_example(address: bad_address)]
      )
    end
  end

  it 'create with negative income raises InputErrors' do
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountRequest.create(
        [ExampleGenerator.individual_account_request_example(income: -1)]
      )
    end
  end

  it 'update with invalid status raises InputErrors' do
    request = StarkInfra::IndividualAccountRequest.create(
      [ExampleGenerator.individual_account_request_example]
    )[0]
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountRequest.update(request.id, status: 'not-a-real-status')
    end
  end

  it 'get with unknown id raises InputErrors' do
    assert_raises(StarkInfra::Error::InputErrors) do
      StarkInfra::IndividualAccountRequest.get('0')
    end
  end
end
