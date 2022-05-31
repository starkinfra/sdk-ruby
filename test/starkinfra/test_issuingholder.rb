# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')
require_relative('../user')

describe(StarkInfra::IssuingHolder, '#issuing-holder#') do
  it 'query' do
    holders = StarkInfra::IssuingHolder.query(limit: 5, expand: ['rules'])
    holders.each do |holder|
      puts holder
      expect(holder.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    holders = nil
    (0..1).step(1) do
      holders, cursor = StarkInfra::IssuingHolder.page(limit: 5, cursor: cursor)
      holders.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
  end

  it 'query and get' do
    holder = StarkInfra::IssuingHolder.query(limit: 1).first
    holder = StarkInfra::IssuingHolder.get(holder.id)
    puts holder
    expect(holder.id).wont_be_nil
  end

  it 'create, update and delete' do
    holder_id = StarkInfra::IssuingHolder.create(holders: [ExampleGenerator.issuingholder_example]).first.id
    holder = StarkInfra::IssuingHolder.update(holder_id, name: 'Updated name')
    expect(holder.name).must_equal('Updated name')
    holder = StarkInfra::IssuingHolder.cancel(holder_id)
    expect(holder.status).must_equal('canceled')
  end

end
