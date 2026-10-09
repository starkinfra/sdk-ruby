# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')
require_relative('../ai_knowledge_base/ai_knowledge_base')

module StarkInfra
  # # AiAgent object
  #
  # An AiAgent is the configuration of an assistant: the model, the instructions, the knowledge it may consult and
  # the voice it speaks with. The agent never changes during a conversation; the conversation lives in an AiChat
  # and each turn is an AiMessage.
  #
  # When you initialize an AiAgent, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the object
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - name [string]: name of the agent. Between 1 and 100 characters. ex: 'Support assistant'
  # - model [string]: AI model the agent runs on. Options: 'bender-1.0' for everyday conversations, 'prime-1.0' for harder reasoning.
  #
  # ## Parameters (optional):
  # - system_prompt [string, default nil]: instructions that define the agent's persona, tone and domain behavior. Up to 100000 characters. The API falls back to its default assistant prompt when omitted.
  # - voice_id [string, default nil]: id of the AiVoice the agent speaks with. When set, every reply also carries a speech string ready to be sent to AiSpeech. The API does not check that the voice exists.
  # - knowledge_base_ids [list of strings, default nil]: ids of up to 100 AiKnowledgeBases the agent retrieves from before answering. The API does not check that they exist.
  # - metadata_schema [hash, default nil]: flat hash whose keys are the fields the agent must extract on every reply. Each field takes a 'type' (string, integer, number, boolean or array), an optional 'description' of up to 2000 characters, an optional 'enum' of up to 20 strings for string fields. The keys are yours and are sent exactly as written. ex: { 'order_id' => { 'type' => 'string', 'description' => 'Order the customer mentions' } }
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the AiAgent is created. ex: '5656565656565656'
  # - knowledge_bases [list of AiKnowledgeBase objects]: the knowledge bases themselves. Only present when requested with expand: ['knowledge_bases'].
  # - created [DateTime]: creation datetime for the AiAgent. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the AiAgent. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiAgent < StarkCore::Utils::Resource
    attr_reader :name, :model, :system_prompt, :voice_id, :knowledge_base_ids, :metadata_schema, :id,
                :knowledge_bases, :created, :updated
    def initialize(
      name:, model:, system_prompt: nil, voice_id: nil, knowledge_base_ids: nil, metadata_schema: nil, id: nil,
      knowledge_bases: nil, created: nil, updated: nil
    )
      super(id)
      @name = name
      @model = model
      @system_prompt = system_prompt
      @voice_id = voice_id
      @knowledge_base_ids = knowledge_base_ids
      @metadata_schema = metadata_schema
      @knowledge_bases = knowledge_bases&.map { |entity| _parse_knowledge_base(entity) }
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create an AiAgent
    #
    # Send an AiAgent object for creation at the Stark Infra API. Attributes that are nil are sent as null.
    # The keys of metadata_schema are sent exactly as written, so this function does not go through the case conversion of the core.
    #
    # ## Parameters (required):
    # - agent [AiAgent object]: AiAgent object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiAgent object with updated attributes
    def self.create(agent, user: nil)
      response = StarkInfra::Utils::Rest.post_raw(
        path: StarkCore::Utils::API.endpoint(resource[:resource_name]),
        payload: {
          name: agent.name,
          model: agent.model,
          systemPrompt: agent.system_prompt,
          voiceId: agent.voice_id,
          knowledgeBaseIds: agent.knowledge_base_ids,
          metadataSchema: agent.metadata_schema
        },
        raiseException: true,
        user: user
      )
      StarkCore::Utils::API.from_api_json(resource[:resource_maker], response.json[StarkCore::Utils::API.last_name(resource[:resource_name])])
    end

    # # Retrieve a specific AiAgent
    #
    # Receive a single AiAgent object previously created in the Stark Infra API by its id
    #
    # ## Parameters (required):
    # - id [string]: object unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'knowledge_bases'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiAgent object with updated attributes
    def self.get(id, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_id(id: id, expand: _expand_names(expand), user: user, **resource)
    end

    # # Retrieve AiAgents
    #
    # Receive a generator of AiAgent objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'knowledge_bases'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiAgent objects with updated attributes
    def self.query(limit: nil, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(limit: limit, expand: _expand_names(expand), user: user, **resource)
    end

    # # Retrieve paged AiAgents
    #
    # Receive a list of up to 100 AiAgent objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default nil]: maximum number of objects to be retrieved. The API accepts up to 100 and answers with an error above it. ex: 35
    # - expand [list of strings, default nil]: extra attributes to compute. Options: 'knowledge_bases'.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of AiAgent objects with updated attributes
    # - cursor to retrieve the next page of AiAgent objects, nil on the last page
    def self.page(cursor: nil, limit: nil, expand: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(cursor: cursor, limit: limit, expand: _expand_names(expand), user: user, **resource)
    end

    # # Update AiAgent entity
    #
    # Update an AiAgent's parameters by passing its id. The API keeps every parameter you do not give.
    # To clear a parameter, send an empty value: '' for system_prompt and voice_id, [] for knowledge_base_ids, {} for metadata_schema.
    # The keys of metadata_schema are sent exactly as written, so this function does not go through the case conversion of the core.
    #
    # ## Parameters (required):
    # - id [string]: AiAgent unique id. ex: '5656565656565656'
    #
    # ## Parameters (optional):
    # - name [string, default nil]: new name for the agent. Between 1 and 100 characters.
    # - model [string, default nil]: new AI model. Options: 'bender-1.0', 'prime-1.0'
    # - system_prompt [string, default nil]: new instructions for the agent. Up to 100000 characters.
    # - voice_id [string, default nil]: new AiVoice id.
    # - knowledge_base_ids [list of strings, default nil]: the AiKnowledgeBase ids the agent should end up with. Replaces the current list.
    # - metadata_schema [hash, default nil]: new schema of the structured data the agent must extract.
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiAgent with updated attributes
    def self.update(
      id, name: nil, model: nil, system_prompt: nil, voice_id: nil, knowledge_base_ids: nil, metadata_schema: nil,
      user: nil
    )
      response = StarkInfra::Utils::Rest.patch_raw(
        path: "#{StarkCore::Utils::API.endpoint(resource[:resource_name])}/#{id}",
        payload: {
          name: name,
          model: model,
          systemPrompt: system_prompt,
          voiceId: voice_id,
          knowledgeBaseIds: knowledge_base_ids,
          metadataSchema: metadata_schema
        },
        raiseException: true,
        user: user
      )
      StarkCore::Utils::API.from_api_json(resource[:resource_maker], response.json[StarkCore::Utils::API.last_name(resource[:resource_name])])
    end

    # # Delete AiAgents
    #
    # Delete up to 100 AiAgents at once.
    #
    # ## Parameters (required):
    # - ids [list of strings]: ids of the AiAgents to be deleted. Up to 100 ids. ex: ['5656565656565656', '4545454545454545']
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of deleted AiAgent objects
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
        resource_name: 'AiAgent',
        resource_maker: proc { |json|
          AiAgent.new(
            id: json['id'],
            name: json['name'],
            model: json['model'],
            system_prompt: json['system_prompt'],
            voice_id: json['voice_id'],
            knowledge_base_ids: json['knowledge_base_ids'],
            metadata_schema: json['metadata_schema'],
            knowledge_bases: json['knowledge_bases'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end

    private

    def _parse_knowledge_base(entity)
      return entity unless entity.is_a?(Hash)

      StarkCore::Utils::API.from_api_json(AiKnowledgeBase.resource[:resource_maker], entity)
    end
  end
end
