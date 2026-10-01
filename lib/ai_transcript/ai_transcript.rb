# frozen_string_literal: true

require('starkcore')
require_relative('../utils/ai_api')

module StarkInfra
  # # AiTranscript object
  #
  # An AiTranscript is the text of an audio file you upload, from any speaker, cloned or not.
  # The transcription happens during the create call, so the transcript comes back already in 'success' status.
  #
  # When you initialize an AiTranscript, the entity will not be automatically
  # created in the Stark Infra API. The 'create' function sends the object
  # to the Stark Infra API and returns the created object.
  #
  # ## Parameters (required):
  # - audio [string]: base64-encoded audio to transcribe. Up to 10000000 characters. The format is read from the file's own header.
  #
  # ## Attributes (return-only):
  # - id [string]: unique id returned when the AiTranscript is created. ex: '5656565656565656'
  # - text [string]: transcribed text.
  # - status [string]: current status of the transcript. Options: 'processing', 'success', 'failed'
  # - errors [list of strings]: reasons the transcription failed. Empty when it worked.
  # - created [DateTime]: creation datetime for the AiTranscript. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  # - updated [DateTime]: latest update datetime for the AiTranscript. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
  class AiTranscript < StarkCore::Utils::Resource
    attr_reader :audio, :id, :text, :status, :errors, :created, :updated
    # audio defaults to nil because the API never returns it, so a transcript read back has none
    def initialize(audio: nil, id: nil, text: nil, status: nil, errors: nil, created: nil, updated: nil)
      super(id)
      @audio = audio
      @text = text
      @status = status
      @errors = errors
      @created = StarkCore::Utils::Checks.check_datetime(created)
      @updated = StarkCore::Utils::Checks.check_datetime(updated)
    end

    # # Create an AiTranscript
    #
    # Send an AiTranscript object for creation at the Stark Infra API. The audio is transcribed during the call.
    #
    # ## Parameters (required):
    # - transcript [AiTranscript object]: AiTranscript object to be created in the API.
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - AiTranscript object with updated attributes
    def self.create(transcript, user: nil)
      StarkInfra::Utils::AiApi.create_one(
        path: PATH,
        key: 'transcript',
        resource_maker: resource[:resource_maker],
        payload: { audio: transcript.audio },
        user: user
      )
    end

    # # Retrieve AiTranscripts
    #
    # Receive a generator of AiTranscript objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiTranscript objects with updated attributes
    def self.query(user: nil)
      # this route is not paginated and takes no filters
      StarkInfra::Utils::AiApi.list_all(path: PATH, key: 'transcripts', resource_maker: resource[:resource_maker], user: user)
    end

    # the path has no leading slash: the request code already joins it to the base url with one
    PATH = 'ai-transcript'

    def self.resource
      {
        resource_name: 'AiTranscript',
        resource_maker: proc { |json|
          AiTranscript.new(
            id: json['id'],
            text: json['text'],
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
