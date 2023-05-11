# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IssuingEmbossingRequest, '#issuing-request#') do
  it 'query' do
    requests = StarkInfra::IssuingEmbossingRequest.query(limit: 100)

    requests.each do |request|
      puts request
      expect(request.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      requests, cursor = StarkInfra::IssuingEmbossingRequest.page(limit: 5, cursor: cursor)

      requests.each do |request|
        puts request
        expect(ids).wont_include(request.id)
        ids << request.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    request = StarkInfra::IssuingEmbossingRequest.query(limit: 1).first
    request = StarkInfra::IssuingEmbossingRequest.get(request.id)
    puts request
    expect(request.id).wont_be_nil
  end

  it 'create, update and delete' do
    holder = StarkInfra::IssuingHolder.query(limit: 1).first
    requests = StarkInfra::IssuingEmbossingRequest.create(requests: [ExampleGenerator.issuing_embossingrequest_example(holder: holder)])
    requests.each do |request|
      expect(request.id).wont_be_nil
    end
  end
end
