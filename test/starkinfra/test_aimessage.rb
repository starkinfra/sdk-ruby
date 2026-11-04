# frozen_string_literal: false

require_relative('../utils/ai_fixtures.rb')

module SharedMessages
  def self.chat
    AiFixtures.chat
  end

  def self.posted
    @posted ||= StarkInfra::AiMessage.create(
      StarkInfra::AiMessage.new(chat_id: chat.id, text: 'Say hello and mention order 123.'),
      expand: %w[chatName]
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
    expect(posted[1].metadata).must_be_kind_of(Hash)
  end

  it 'query returns the whole history' do
    found = AiFixtures.eventually do
      listed = StarkInfra::AiMessage.query(chat_id: chat.id).to_a
      listed if listed.length == posted.length
    end
    expect(found).wont_be_nil
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

  it 'query without chat id reads the workspace history' do
    posted
    found = AiFixtures.eventually { StarkInfra::AiMessage.query.find { |entity| entity.id == posted[0].id } }
    expect(found).wont_be_nil
  end

  it 'page without chat id returns messages and a cursor' do
    posted
    entities, cursor = StarkInfra::AiMessage.page(limit: 2)
    expect(entities.length).must_equal(2)
    expect(cursor.nil? || cursor.is_a?(String)).must_equal(true)
  end

  it 'limit above the maximum raises the API error' do
    expect { StarkInfra::AiMessage.page(chat_id: chat.id, limit: 101) }.must_raise(StarkCore::Error::InputErrors)
  end

  it 'create in an unknown chat raises input errors' do
    message = StarkInfra::AiMessage.new(chat_id: '0000000000000000', text: 'hi')
    expect { StarkInfra::AiMessage.create(message) }.must_raise(StarkCore::Error::InputErrors)
  end
end
