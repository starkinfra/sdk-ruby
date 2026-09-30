# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # AiMessage object
  #
  # An AiMessage is a single turn of an AiChat. You post what the user said and the same call returns the user's
  # message and the agent's answer.
  #
  # When you initialize an AiMessage, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the object
  # to the Stark Infra API and returns the user's message and the agent's answer.
  #
  # ## Parameters (required):
  # - chat_id [string]: id of the AiChat to post to. ex: '5656565656565656'
  # - text [string]: content of the user's message. Between 1 and 50000 characters. ex: 'What is the status of my order?'
  #
  # ## Parameters (optional):
  # - model [string, default nil]: AI model to use for this turn only. Options: 'bender-1.0', 'prime-1.0'. The API defaults to the agent's own model.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id of the AiMessage. ex: '5656565656565656'
  # - sender [string]: who wrote the message. Options: 'user', 'system'. The agent's answers are sent by 'system'.
  # - speech [string]: version of the text written to be heard rather than read, ready to be sent to AiSpeech. Only filled when the agent has a voice.
  # - metadata [hash]: structured data the agent extracted, shaped by the agent's metadata_schema. The keys are the agent's, exactly as it declared them.
  # - chat_name [string]: title of the chat. Only present when create is called with expand: ['chat_name'].
  # - created [DateTime]: creation datetime for the AiMessage. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiMessage < StarkCore::Utils::Resource
    attr_reader :chat_id, :text, :model, :id, :sender, :speech, :metadata, :chat_name, :created
    def initialize(
      chat_id:, text:, model: nil, id: nil, sender: nil, speech: nil, metadata: nil, chat_name: nil, created: nil
    )
      super(id)
      @chat_id = chat_id
      @text = text
      @model = model
      @sender = sender
      @speech = speech
      @metadata = metadata
      @chat_name = chat_name
      @created = StarkCore::Utils::Checks.check_datetime(created)
    end

    # # Create an AiMessage
    #
    # Post the user's message to an AiChat. The call waits for the agent, which takes a few seconds, and returns both messages.
    # The API answers with a list and takes expand in the query string, so this function does not go through the standard create of the core.
    #
    # ## Parameters (required):
    # - message [AiMessage object]: AiMessage object with chat_id and text, to be created in the API.
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'chat_name', which returns the chat title on every message, useful on the first turn, when the title is generated.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list with the user's AiMessage and the agent's AiMessage
    def self.create(message, expand: nil, user: nil)
      response = StarkInfra::Utils::Rest.post_raw(
        path: StarkCore::Utils::API.endpoint(resource[:resource_name]),
        payload: { chatId: message.chat_id, text: message.text, model: message.model },
        query: { expand: _expand_names(expand) },
        raiseException: true,
        user: user
      )
      content = response.json
      content['messages'].map do |entity|
        StarkCore::Utils::API.from_api_json(resource[:resource_maker], entity.merge('chatName' => content['chatName']))
      end
    end

    # # Retrieve AiMessages
    #
    # Receive a generator of AiMessage objects previously created in the Stark Infra API, following the cursor until the history ends.
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - chat_id [string, default nil]: id of the AiChat whose messages you want. When omitted, the messages of the whole workspace are returned. ex: '5656565656565656'
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiMessage objects with updated attributes
    def self.query(limit: nil, chat_id: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(limit: limit, chat_id: chat_id, user: user, **resource)
    end

    # # Retrieve paged AiMessages
    #
    # Receive a list of up to 100 AiMessage objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default nil]: maximum number of objects to be retrieved. The API accepts up to 100 and answers with an error above it. ex: 35
    # - chat_id [string, default nil]: id of the AiChat whose messages you want. When omitted, the messages of the whole workspace are returned. ex: '5656565656565656'
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of AiMessage objects with updated attributes
    # - cursor to retrieve the next page of AiMessage objects, nil on the last page
    def self.page(cursor: nil, limit: nil, chat_id: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(cursor: cursor, limit: limit, chat_id: chat_id, user: user, **resource)
    end

    def self._expand_names(expand)
      expand&.map { |name| StarkCore::Utils::Case.snake_to_camel(name) }
    end

    def self.resource
      {
        resource_name: 'AiMessage',
        resource_maker: proc { |json|
          AiMessage.new(
            id: json['id'],
            chat_id: json['chat_id'],
            sender: json['sender'],
            text: json['text'],
            speech: json['speech'],
            metadata: json['metadata'],
            model: json['model'],
            chat_name: json['chat_name'],
            created: json['created']
          )
        }
      }
    end
  end
end
