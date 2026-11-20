# frozen_string_literal: false

require_relative('../test_helper.rb')

FakeReply = Struct.new(:code, :body) unless defined?(FakeReply)

# The *payload tests are offline: only the outgoing HTTP call (Net::HTTP.start) is replaced, so payload building and signing
# run for real. The sandbox tests run against the real API and cancel every card they create.
describe(StarkInfra::IssuingCard, '#issuing-card-without-holder#') do
  def with_fake_api(reply_body)
    sent = []
    http = Object.new
    http.define_singleton_method(:request) { |req| sent << req; FakeReply.new('200', reply_body) }
    original_start = Net::HTTP.method(:start)
    Net::HTTP.define_singleton_method(:start) { |*_args, **_kwargs, &block| block.call(http) }
    begin
      yield(sent)
    ensure
      Net::HTTP.define_singleton_method(:start, original_start)
    end
  end

  def sent_json(sent)
    JSON.parse(sent[0].body)
  end

  describe 'payload' do
    it 'omits the holder fields when they are not informed' do
      with_fake_api('{"cards": [{"id": "1", "status": "pending", "holder_id": "", "holder_name": ""}]}') do |sent|
        cards = StarkInfra::IssuingCard.create(cards: [StarkInfra::IssuingCard.new(product_id: '123', type: 'physical')])

        expect(sent_json(sent)).must_equal({ 'cards' => [{ 'productId' => '123', 'type' => 'physical' }] })
        expect(cards.first.holder_id).must_equal('')
        expect(cards.first.holder_name).must_equal('')
      end
    end

    it 'sends the holder fields when they are informed' do
      with_fake_api('{"cards": [{"id": "1"}]}') do |sent|
        StarkInfra::IssuingCard.create(cards: [StarkInfra::IssuingCard.new(
          holder_name: 'Tony Stark', holder_tax_id: '012.345.678-90', holder_external_id: 'my-entity/123', product_id: '123'
        )])

        expect(sent_json(sent)).must_equal({ 'cards' => [{
          'holderName' => 'Tony Stark', 'holderTaxId' => '012.345.678-90', 'holderExternalId' => 'my-entity/123', 'productId' => '123'
        }] })
      end
    end

    it 'keeps update payloads free of holder fields when they are omitted' do
      with_fake_api('{"card": {"id": "5656565656565656", "status": "pending"}}') do |sent|
        StarkInfra::IssuingCard.update('5656565656565656', display_name: 'ANTHONY STARK')

        expect(sent[0].method).must_equal('PATCH')
        expect(sent_json(sent)).must_equal({ 'displayName' => 'ANTHONY STARK' })
      end
    end

    it 'sends the holder fields alone in update' do
      with_fake_api('{"card": {"id": "5656565656565656"}}') do |sent|
        StarkInfra::IssuingCard.update('5656565656565656', holder_name: 'Tony Stark', holder_tax_id: '012.345.678-90', holder_external_id: 'my-entity/123')

        expect(sent_json(sent)).must_equal({ 'holderName' => 'Tony Stark', 'holderTaxId' => '012.345.678-90', 'holderExternalId' => 'my-entity/123' })
      end
    end

    it 'sends the holder fields with status and pin in update' do
      with_fake_api('{"card": {"id": "5656565656565656"}}') do |sent|
        StarkInfra::IssuingCard.update(
          '5656565656565656', status: 'active', pin: '1234',
          holder_name: 'Tony Stark', holder_tax_id: '012.345.678-90', holder_external_id: 'my-entity/123'
        )

        expect(sent_json(sent)).must_equal({
          'status' => 'active', 'pin' => '1234',
          'holderName' => 'Tony Stark', 'holderTaxId' => '012.345.678-90', 'holderExternalId' => 'my-entity/123'
        })
      end
    end

    it 'sends update_multi items in the cards list with only the informed fields' do
      with_fake_api('{"cards": [{"id": "1", "status": "pending"}, {"id": "2", "status": "pending"}]}') do |sent|
        cards = StarkInfra::IssuingCard.update_multi(cards: [
          StarkInfra::IssuingCard.new(id: '1', holder_name: 'Tony Stark', holder_tax_id: '012.345.678-90', holder_external_id: 'my-entity/123'),
          { id: '2', tags: ['batch'] }
        ])

        expect(sent[0].method).must_equal('PATCH')
        expect(sent[0].path).must_equal('/v2/issuing-card')
        expect(sent_json(sent)).must_equal({ 'cards' => [
          { 'id' => '1', 'holderName' => 'Tony Stark', 'holderTaxId' => '012.345.678-90', 'holderExternalId' => 'my-entity/123' },
          { 'id' => '2', 'tags' => ['batch'] }
        ] })
        expect(cards.map(&:id)).must_equal(%w[1 2])
        expect(cards.all? { |card| card.is_a?(StarkInfra::IssuingCard) }).must_equal(true)
      end
    end
  end

  describe 'sandbox' do
    def first_product
      StarkInfra::IssuingProduct.query(limit: 1).first || raise('no issuing product in the sandbox Project')
    end

    # A holder can only be linked to a product of its own type: business holders have a CNPJ (14 digits) and individual
    # holders a CPF (11 digits). Existing holders are used so no personal data is created by the test.
    def holder_for(product)
      digits = { 'business' => 14, 'individual' => 11 }.fetch(product.holder_type)
      StarkInfra::IssuingHolder.query(status: 'active', limit: 100).find { |holder| holder.tax_id.gsub(/\D/, '').length == digits }
    end

    def cards_without_holder(count, type, product_id)
      Array.new(count) { StarkInfra::IssuingCard.new(product_id: product_id, type: type, tags: ['sdk-test']) }
    end

    # A failed cancel must not hide the failure of the test (a leftover card is also reported by the sandbox-test plan).
    def cancel_all(cards)
      cards.each do |card|
        StarkInfra::IssuingCard.cancel(card.id)
      rescue StandardError => e
        puts("could not cancel card #{card.id} (#{e.class})")
      end
    end

    def holder_fields(holder)
      { holder_name: holder.name, holder_tax_id: holder.tax_id, holder_external_id: holder.external_id }
    end

    # The API rejection reaches the caller untouched, with the error code of the API.
    def assert_rejected(code)
      yield
    rescue StarkInfra::Error::InputErrors => e
      expect(e.errors.map(&:code)).must_include(code)
    else
      flunk('expected the API to reject the call')
    end

    # Creates pending physical cards without holder, yields them with an existing holder and always cancels them.
    def with_pending_cards(count)
      product = first_product
      holder = holder_for(product)
      expect(holder).wont_be_nil('the sandbox needs an existing active holder compatible with the product')
      cards = StarkInfra::IssuingCard.create(cards: cards_without_holder(count, 'physical', product.id))
      begin
        yield(cards, holder)
      ensure
        cancel_all(cards)
      end
    end

    it 'creates a physical card without holder as pending' do
      cards = StarkInfra::IssuingCard.create(cards: cards_without_holder(1, 'physical', first_product.id))
      begin
        expect(cards.length).must_equal(1)
        expect(cards.first.status).must_equal('pending')
        expect(cards.first.type).must_equal('physical')
        expect(cards.first.holder_id).must_equal('')
        expect(cards.first.holder_name).must_equal('')
      ensure
        cancel_all(cards)
      end
    end

    # If the API ever accepted these requests, the created cards are cancelled before the failure is reported.
    def assert_rejected_create(code, cards)
      created = []
      assert_rejected(code) { created = StarkInfra::IssuingCard.create(cards: cards) }
    ensure
      cancel_all(created)
    end

    it 'has the API reject a virtual card without holder' do
      assert_rejected_create('invalidHolder', cards_without_holder(1, 'virtual', first_product.id))
    end

    it 'has the API reject incomplete holder fields on create' do
      card = StarkInfra::IssuingCard.new(product_id: first_product.id, type: 'physical', holder_name: 'Tony Stark')
      assert_rejected_create('invalidHolder', [card])
    end

    it 'assigns the holder to a pending card' do
      with_pending_cards(1) do |cards, holder|
        card = StarkInfra::IssuingCard.update(cards.first.id, **holder_fields(holder))

        expect(card.status).must_equal('pending')
        expect(card.holder_id).must_equal(holder.id)
      end
    end

    it 'assigns the holder and activates the card in the same call' do
      with_pending_cards(1) do |cards, holder|
        card = StarkInfra::IssuingCard.update(cards.first.id, status: 'active', pin: '1234', **holder_fields(holder))

        expect(card.status).must_equal('active')
        expect(card.holder_id).must_equal(holder.id)
      end
    end

    it 'has the API reject incomplete holder fields on update' do
      with_pending_cards(1) do |cards, holder|
        assert_rejected('invalidHolder') { StarkInfra::IssuingCard.update(cards.first.id, holder_name: holder.name) }
      end
    end

    it 'has the API reject activation without holder' do
      with_pending_cards(1) do |cards, _holder|
        assert_rejected('invalidHolder') { StarkInfra::IssuingCard.update(cards.first.id, status: 'active', pin: '1234') }
      end
    end

    it 'assigns the holder to several cards' do
      with_pending_cards(2) do |cards, holder|
        updated = StarkInfra::IssuingCard.update_multi(cards: cards.map { |card| { id: card.id, **holder_fields(holder) } })

        expect(updated.map(&:id).sort).must_equal(cards.map(&:id).sort)
        expect(updated.map(&:holder_id).uniq).must_equal([holder.id])
      end
    end

    it 'has the API reject the whole list when one item is invalid' do
      with_pending_cards(2) do |cards, holder|
        items = [{ id: cards.first.id, **holder_fields(holder) }, { id: '0000000000000001', **holder_fields(holder) }]

        assert_rejected('invalidCard') { StarkInfra::IssuingCard.update_multi(cards: items) }
        expect(StarkInfra::IssuingCard.get(cards.first.id).holder_id).must_equal('')
      end
    end

    it 'has the API reject incomplete holder fields on update_multi' do
      with_pending_cards(1) do |cards, holder|
        assert_rejected('invalidHolder') do
          StarkInfra::IssuingCard.update_multi(cards: [{ id: cards.first.id, holder_name: holder.name }])
        end
      end
    end
  end
end
