# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

# One message per run: every create calls a model and takes seconds, so the whole file shares a single one.
module SharedMessages
  def self.chat
    AiFixtures.chat
  end

  def self.posted
    @posted ||= StarkInfra::AiMessage.create(
      StarkInfra::AiMessage.new(chat_id: chat.id, text: 'Say hello and mention order 123.'),
      expand: %w[chat_name]
    )
  end
end

describe(StarkInfra::AiMessage, '#ai-message#') do
  let(:chat) { SharedMessages.chat }
  let(:posted) { SharedMessages.posted }

  it 'create returns the user message and the answer' do
    expect(posted.map(&:sender)).must_equal(%w[user system])
    posted.each do |message|
      expect(message.chat_id).must_equal(chat.id)
      expect(message.created).must_be_kind_of(DateTime)
      expect(message.chat_name).wont_be_empty
    end
  end

  it 'the answer carries a metadata hash' do
    # whether the model fills a field is up to the model; the key spelling is checked at the http boundary
    expect(posted[1].metadata).must_be_kind_of(Hash)
  end

  it 'query returns the whole history' do
    found = StarkInfra::AiMessage.query(chat_id: chat.id).to_a
    expect(found.map(&:id).sort).must_equal(posted.map(&:id).sort)
  end

  it 'query with limit stops at the limit' do
    posted
    expect(StarkInfra::AiMessage.query(chat_id: chat.id, limit: 1).to_a.length).must_equal(1)
  end

  it 'page returns a cursor that leads to a different second page' do
    posted
    first, cursor = StarkInfra::AiMessage.page(chat_id: chat.id, limit: 1)
    expect(first.length).must_equal(1)
    expect(cursor).wont_be_nil
    second, = StarkInfra::AiMessage.page(chat_id: chat.id, cursor: cursor, limit: 1)
    expect(second.length).must_equal(1)
    expect(second[0].id).wont_equal(first[0].id)
  end

  it 'create in an unknown chat raises input errors' do
    message = StarkInfra::AiMessage.new(chat_id: '0000000000000000', text: 'hi')
    expect { StarkInfra::AiMessage.create(message) }.must_raise(StarkCore::Error::InputErrors)
  end
end

describe(StarkInfra::AiMessage, '#ai-message at the http boundary#') do
  let(:messages_json) do
    [
      { 'id' => '5642368648740864', 'chatId' => '5632499082330112', 'sender' => 'user', 'text' => 'Say hello.',
        'speech' => 'Say hello.', 'metadata' => {}, 'model' => 'bender-1.0', 'created' => '2026-10-01T14:28:02.652375+00:00' },
      { 'id' => '5079418695319552', 'chatId' => '5632499082330112', 'sender' => 'system', 'text' => 'Hello!',
        'speech' => 'Hello!', 'metadata' => { 'order_id' => '123', 'isUrgent' => false }, 'model' => 'bender-1.0',
        'created' => '2026-10-01T14:28:02.653375+00:00' }
    ]
  end

  it 'create sends expand in the query string and not in the body' do
    messages = nil
    with_http_answer('chatName' => 'Greeting', 'messages' => messages_json) do |requests|
      messages = StarkInfra::AiMessage.create(
        StarkInfra::AiMessage.new(chat_id: '5632499082330112', text: 'Say hello.', model: 'prime-1.0', id: 'x', sender: 'user'),
        expand: %w[chat_name]
      )
      expect(requests[0].method).must_equal('POST')
      expect(requests[0].path).must_equal('/v2/ai-message?expand=chatName')
      expect(JSON.parse(requests[0].body)).must_equal('chatId' => '5632499082330112', 'text' => 'Say hello.', 'model' => 'prime-1.0')
    end
    expect(messages.map(&:sender)).must_equal(%w[user system])
    expect(messages.map(&:chat_name).uniq).must_equal(%w[Greeting])
    expect(messages[1].metadata).must_equal('order_id' => '123', 'isUrgent' => false)
  end

  it 'create without expand has no chat name and no query string' do
    with_http_answer('messages' => messages_json) do |requests|
      messages = StarkInfra::AiMessage.create(StarkInfra::AiMessage.new(chat_id: '5632499082330112', text: 'Say hello.'))
      expect(requests[0].path).must_equal('/v2/ai-message')
      expect(messages.map(&:chat_name).compact).must_equal([])
    end
  end

  it 'query follows the cursor across two pages' do
    first_page = { 'cursor' => 'next-page', 'messages' => [messages_json[0]] }
    second_page = { 'cursor' => nil, 'messages' => [messages_json[1]] }
    with_http_answers(first_page, second_page) do |requests|
      found = StarkInfra::AiMessage.query(chat_id: '5632499082330112').to_a
      expect(found.map(&:id)).must_equal(%w[5642368648740864 5079418695319552])
      expect(requests[0].path).must_include('chatId=5632499082330112')
      expect(requests[1].path).must_include('cursor=next-page')
    end
  end

  it 'page returns the items and the cursor' do
    with_http_answer('cursor' => 'next-page', 'messages' => [messages_json[0]]) do |requests|
      items, cursor = StarkInfra::AiMessage.page(chat_id: '5632499082330112', limit: 1)
      expect(requests[0].path).must_include('limit=1')
      expect(items.map(&:id)).must_equal(%w[5642368648740864])
      expect(cursor).must_equal('next-page')
    end
  end
end
