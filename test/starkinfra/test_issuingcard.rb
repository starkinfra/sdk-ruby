# frozen_string_literal: false

require_relative('../user')
require_relative('../test_helper.rb')
require_relative('../example_generator.rb')


describe(StarkInfra::IssuingCard, '#issuing-card#') do
  it 'query' do
    cards = StarkInfra::IssuingCard.query(limit: 100, expand: ['rules'])

    cards.each do |card|
      expect(card.id).wont_be_nil
    end
  end

  it 'page' do
    ids = []
    cursor = nil
    (0..1).step(1) do
      cards, cursor = StarkInfra::IssuingCard.page(limit: 5, cursor: cursor)

      cards.each do |invoice|
        expect(ids).wont_include(invoice.id)
        ids << invoice.id
      end
      break if cursor.nil?
    end
    expect(ids.length).must_equal(10)
  end

  it 'query and get' do
    card = StarkInfra::IssuingCard.query(limit: 1).first

    card = StarkInfra::IssuingCard.get(card.id)
    expect(card.id).wont_be_nil
  end

  it 'create, update and delete' do
    holder = StarkInfra::IssuingHolder.query(limit: 1).first
    card_id = StarkInfra::IssuingCard.create(cards: [ExampleGenerator.issuingcard_example(holder: holder)], expand: ['securityCode']).first.id

    card = StarkInfra::IssuingCard.update(card_id, display_name: 'Updated name')
    expect(card.display_name).must_equal('Updated name')

    card = StarkInfra::IssuingCard.cancel(card_id)
    expect(card.status).must_equal('canceled')
  end
end
