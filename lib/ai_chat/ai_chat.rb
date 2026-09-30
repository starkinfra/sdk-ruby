# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

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
  # - tags [list of strings, default nil]: list of strings for reference when searching for AiChats. ex: ['vip', 'gold']
  # - context [hash, default nil]: free-form object with the data the agent should know about the conversation. The keys are yours and are sent exactly as written. ex: { 'customerId' => '42' }
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the AiChat is created. ex: '5656565656565656'
  # - agent_name [string]: name of the agent. Only present when requested with expand: ['agent_name'].
  # - updated [DateTime]: latest update datetime for the AiChat. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiChat < StarkCore::Utils::Resource
    attr_reader :agent_id, :title, :tags, :context, :id, :agent_name, :updated
    def initialize(agent_id:, title: nil, tags: nil, context: nil, id: nil, agent_name: nil, updated: nil)
      super(id)
      @agent_id = agent_id
      @title = title
      @tags = tags
      @context = context
      @agent_name = agent_name
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create an AiChat
    #
    # Send an AiChat object for creation at the Stark Infra API. Attributes that are nil are sent as null.
    # The keys of context are sent exactly as written, so this function does not go through the case conversion of the core.
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
      response = StarkInfra::Utils::Rest.post_raw(
        path: StarkCore::Utils::API.endpoint(resource[:resource_name]),
        payload: { agentId: chat.agent_id, title: chat.title, tags: chat.tags, context: chat.context },
        raiseException: true,
        user: user
      )
      StarkCore::Utils::API.from_api_json(resource[:resource_maker], response.json[StarkCore::Utils::API.last_name(resource[:resource_name])])
    end

    # # Retrieve a specific AiChat
    #
    # Receive a single AiChat object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'agent_name'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiChat object with updated attributes
    def self.get(id, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, expand: _expand_names(expand), user: user, **resource)
    end

    # # Retrieve AiChats
    #
    # Receive a generator of AiChat objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'agent_name'.
    # - tags [list of strings, default nil]: list of strings to filter retrieved objects. ex: ['vip', 'gold']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiChat objects with updated attributes
    def self.query(limit: nil, expand: nil, tags: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(limit: limit, expand: _expand_names(expand), tags: tags, user: user, **resource)
    end

    # # Retrieve paged AiChats
    #
    # Receive a list of up to 100 AiChat objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default nil]: maximum number of objects to be retrieved. The API accepts up to 100 and answers with an error above it. ex: 35
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'agent_name'.
    # - tags [list of strings, default nil]: list of strings to filter retrieved objects. ex: ['vip', 'gold']
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of AiChat objects with updated attributes
    # - cursor to retrieve the next page of AiChat objects, nil on the last page
    def self.page(cursor: nil, limit: nil, expand: nil, tags: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(
        cursor: cursor,
        limit: limit,
        expand: _expand_names(expand),
        tags: tags,
        user: user,
        **resource
      )
    end

    # # Update AiChat entity
    #
    # Update an AiChat's parameters by passing its id. The API keeps every parameter you do not give.
    # To clear a parameter, send an empty value: [] for tags, {} for context.
    # The keys of context are sent exactly as written, so this function does not go through the case conversion of the core.
    #
    # ## Parameters (required):
    # - id [string]: AiChat unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - title [string, default nil]: new title for the conversation. Up to 100 characters.
    # - agent_id [string, default nil]: id of the AiAgent that should answer from now on.
    # - tags [list of strings, default nil]: new list of tags. Replaces the current list.
    # - context [hash, default nil]: new free-form object with the data the agent should know about the conversation.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiChat with updated attributes
    def self.update(id, title: nil, agent_id: nil, tags: nil, context: nil, user: nil)
      response = StarkInfra::Utils::Rest.patch_raw(
        path: "#{StarkCore::Utils::API.endpoint(resource[:resource_name])}/#{id}",
        payload: { title: title, agentId: agent_id, tags: tags, context: context },
        raiseException: true,
        user: user
      )
      StarkCore::Utils::API.from_api_json(resource[:resource_maker], response.json[StarkCore::Utils::API.last_name(resource[:resource_name])])
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
      path = StarkCore::Utils::API.endpoint(resource[:resource_name])
      response = StarkInfra::Utils::Rest.delete_raw(path: path, query: { ids: ids }, raiseException: true, user: user)
      response.json[StarkCore::Utils::API.last_name_plural(resource[:resource_name])].map do |entity|
        StarkCore::Utils::API.from_api_json(resource[:resource_maker], entity)
      end
    end

    def self._expand_names(expand)
      expand&.map { |name| StarkCore::Utils::Case.snake_to_camel(name) }
    end

    def self.resource
      {
        resource_name: 'AiChat',
        resource_maker: proc { |json|
          AiChat.new(
            id: json['id'],
            agent_id: json['agent_id'],
            title: json['title'],
            tags: json['tags'],
            context: json['context'],
            agent_name: json['agent_name'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
