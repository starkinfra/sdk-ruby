# frozen_string_literal: false

require_relative('../test_helper.rb')
require_relative('../example_generator.rb')

describe(StarkInfra::IssuingWithdrawal, '#issuing-withdrawak#') do
  it 'query' do
    withdrawals = StarkInfra::IssuingWithdrawal.query(limit: 5)
    withdrawals.each do |withdrawal|
      expect(withdrawal.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      withdrawals, cursor = StarkInfra::IssuingWithdrawal.page(limit: 5, cursor: cursor)

      withdrawals.each do |withdrawal|
        expect(ids).wont_include(withdrawal.id)
        ids << withdrawal.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    withdrawal = StarkInfra::IssuingWithdrawal.query(limit: 1).first

    withdrawal = StarkInfra::IssuingWithdrawal.get(withdrawal.id)
    expect(withdrawal.id).wont_be_nil
  end

  it 'create, update and delete' do
    withdrawal_id = StarkInfra::IssuingWithdrawal.create(ExampleGenerator.issuingwithdrawal_example).id
    expect(withdrawal_id).wont_be_nil
  end
end
