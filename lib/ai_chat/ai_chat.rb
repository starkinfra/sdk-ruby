# frozen_string_literal: true

require('starkcore')
require_relative('../utils/ai_api')

module StarkInfra
  # # AiChat object
  #
  # An AiChat is one conversation thread with an AiAgent and holds the history. Each turn is an AiMessage.
  #
  # When you initialize an AiChat, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the object
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - agent_id [string]: id of the AiAgent that will answer in this chat. ex: '5656565656565656'
  #
  # ## Parameters (optional):
  # - title [string, default nil]: title of the conversation. Up to 100 characters. When omitted, the first message posted to the chat generates one.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the AiChat is created. ex: '5656565656565656'
  # - agent_name [string]: name of the agent. Only present when requested with expand: ['agent_name'].
  # - updated [DateTime]: latest update datetime for the AiChat. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiChat < StarkCore::Utils::Resource
    attr_reader :agent_id, :title, :id, :agent_name, :updated
    def initialize(agent_id:, title: nil, id: nil, agent_name: nil, updated: nil)
      super(id)
      @agent_id = agent_id
      @title = title
      @agent_name = agent_name
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create an AiChat
    #
    # Send an AiChat object for creation at the Stark Infra API
    #
    # ## Parameters (required):
    # - chat [AiChat object]: AiChat object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiChat object with updated attributes
    def self.create(chat, user: nil)
      StarkInfra::Utils::AiApi.create_one(
        path: PATH,
        key: 'chat',
        resource_maker: resource[:resource_maker],
        # the API answers 400 to any parameter it does not know, so only the creatable fields are sent
        payload: StarkInfra::Utils::AiApi.drop_nil(agentId: chat.agent_id, title: chat.title),
        user: user
      )
    end

    # # Retrieve a specific AiChat
    #
    # Receive a single AiChat object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - fields [list of strings, default nil]: attributes to keep in the response. ex: ['id', 'title']
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'agent_name'. When fields is also given, the expanded attribute must be listed there too.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiChat object with updated attributes
    def self.get(id, fields: nil, expand: nil, user: nil)
      StarkInfra::Utils::AiApi.get_one(
        path: PATH,
        key: 'chat',
        resource_maker: resource[:resource_maker],
        id: id,
        query: StarkInfra::Utils::AiApi.fields_and_expand(fields, expand),
        user: user
      )
    end

    # # Retrieve AiChats
    #
    # Receive a generator of AiChat objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - fields [list of strings, default nil]: attributes to keep in the response. ex: ['id', 'title']
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'agent_name'. When fields is also given, the expanded attribute must be listed there too.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiChat objects with updated attributes
    def self.query(fields: nil, expand: nil, user: nil)
      # this route is not paginated and rejects limit, cursor and every filter (invalidQueryString)
      StarkInfra::Utils::AiApi.list_all(
        path: PATH,
        key: 'chats',
        resource_maker: resource[:resource_maker],
        query: StarkInfra::Utils::AiApi.fields_and_expand(fields, expand),
        user: user
      )
    end

    # # Update AiChat entity
    #
    # Update an AiChat's parameters by passing its id. Only the parameters you give are changed.
    #
    # ## Parameters (required):
    # - id [string]: AiChat unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - title [string, default nil]: new title for the conversation. Up to 100 characters.
    # - agent_id [string, default nil]: id of the AiAgent that should answer from now on.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiChat with updated attributes
    def self.update(id, title: nil, agent_id: nil, user: nil)
      StarkInfra::Utils::AiApi.patch_one(
        path: PATH,
        key: 'chat',
        resource_maker: resource[:resource_maker],
        id: id,
        payload: StarkInfra::Utils::AiApi.drop_nil(title: title, agentId: agent_id),
        user: user
      )
    end

    # # Delete AiChats
    #
    # Delete up to 100 AiChats at once, with their messages.
    #
    # ## Parameters (required):
    # - ids [list of strings]: ids of the AiChats to be deleted. Up to 100 ids. ex: ['5656565656565656', '4545454545454545']
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of deleted AiChat objects
    def self.delete(ids:, user: nil)
      StarkInfra::Utils::AiApi.delete_many(
        path: PATH,
        key: 'chats',
        resource_maker: resource[:resource_maker],
        ids: ids,
        user: user
      )
    end

    # the path has no leading slash: the request code already joins it to the base url with one
    PATH = 'ai-chat'

    def self.resource
      {
        resource_name: 'AiChat',
        resource_maker: proc { |json|
          AiChat.new(
            id: json['id'],
            agent_id: json['agent_id'],
            title: json['title'],
            agent_name: json['agent_name'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
