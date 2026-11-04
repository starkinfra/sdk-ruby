# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

module StarkInfra
  # # AiVoice object
  #
  # An AiVoice is a voice cloned from a recording you upload. Once cloned, it can read any text out loud through
  # an AiSpeech, and it can be attached to an AiAgent so every reply carries a speech ready to be synthesized.
  # Cloning is asynchronous: the voice is created in 'processing' status and moves to 'success' when it is ready
  # to speak, or to 'failed' when the recording could not be cloned.
  #
  # When you initialize an AiVoice, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the object
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - audio [string]: base64-encoded recording of the speaker. MP3, WAV, OGG, FLAC and WebM are accepted. Up to 10000000 characters. The API never returns it, so a voice read back has none.
  #
  # ## Parameters (optional):
  # - name [string, default nil]: name of the voice. Up to 100 characters. Defaults to the voice's own id. ex: 'Helena'
  # - description [string, default nil]: free-text description of the voice. Up to 1000 characters.
  # - language [string, default nil]: language the voice speaks. Options: 'portuguese', 'english'. The API defaults to 'portuguese'.
  # - gender [string, default nil]: gender of the voice. Options: 'male', 'female', 'neutral'
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the AiVoice is created. This is the voice_id you send to other AI resources. ex: '5656565656565656'
  # - status [string]: current status of the voice. Options: 'processing', 'success', 'failed'. Only a voice in 'success' can speak.
  # - errors [list of strings]: reasons the cloning failed. Empty while the voice is healthy.
  # - created [DateTime]: creation datetime for the AiVoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the AiVoice. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiVoice < StarkCore::Utils::Resource
    attr_reader :audio, :name, :description, :language, :gender, :id, :status, :errors, :created, :updated
    def initialize(
      audio: nil, name: nil, description: nil, language: nil, gender: nil, id: nil, status: nil, errors: nil,
      created: nil, updated: nil
    )
      super(id)
      @audio = audio
      @name = name
      @description = description
      @language = language
      @gender = gender
      @status = status
      @errors = errors
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create an AiVoice
    #
    # Send an AiVoice object for creation at the Stark Infra API and start cloning it.
    # The call returns immediately with the voice in 'processing' status.
    #
    # ## Parameters (required):
    # - voice [AiVoice object]: AiVoice object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiVoice object with updated attributes
    def self.create(voice, user: nil)
      StarkInfra::Utils::Rest.post_single(entity: voice, user: user, **resource)
    end

    # # Retrieve AiVoices
    #
    # Receive a generator of AiVoice objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiVoice objects with updated attributes
    def self.query(limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(limit: limit, user: user, **resource)
    end

    # # Retrieve paged AiVoices
    #
    # Receive a list of up to 100 AiVoice objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default nil]: maximum number of objects to be retrieved. The API accepts up to 100 and answers with an error above it. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of AiVoice objects with updated attributes
    # - cursor to retrieve the next page of AiVoice objects, nil on the last page
    def self.page(cursor: nil, limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(cursor: cursor, limit: limit, user: user, **resource)
    end

    # # Delete AiVoices
    #
    # Delete up to 100 AiVoices at once.
    #
    # ## Parameters (required):
    # - ids [list of strings]: ids of the AiVoices to be deleted. Up to 100 ids. ex: ['5656565656565656', '4545454545454545']
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of deleted AiVoice objects
    def self.delete(ids:, user: nil)
      path = StarkCore::Utils::API.endpoint(resource[:resource_name])
      response = StarkInfra::Utils::Rest.delete_raw(path: path, query: { ids: ids }, raiseException: true, user: user)
      response.json[StarkCore::Utils::API.last_name_plural(resource[:resource_name])].map do |entity|
        StarkCore::Utils::API.from_api_json(resource[:resource_maker], entity)
      end
    end

    def self.resource
      {
        resource_name: 'AiVoice',
        resource_maker: proc { |json|
          AiVoice.new(
            id: json['id'],
            name: json['name'],
            description: json['description'],
            language: json['language'],
            gender: json['gender'],
            status: json['status'],
            errors: json['errors'],
            created: json['created'],
            updated: json['updated']
          )
        }
      }
    end
  end
end
