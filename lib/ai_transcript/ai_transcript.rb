# frozen_string_literal: true

require('starkcore')
require_relative('../utils/rest')

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
  # - audio [string]: base64-encoded audio to transcribe. Up to 10000000 characters. The format is read from the file's own header. The API never returns it, so a transcript read back has none.
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
      StarkInfra::Utils::Rest.post_single(entity: transcript, user: user, **resource)
    end

    # # Retrieve AiTranscripts
    #
    # Receive a generator of AiTranscript objects previously created in the Stark Infra API
    #
    # ## Parameters (optional):
    # - limit [integer, default nil]: maximum number of objects to be retrieved. Unlimited if nil. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - generator of AiTranscript objects with updated attributes
    def self.query(limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_stream(limit: limit, user: user, **resource)
    end

    # # Retrieve paged AiTranscripts
    #
    # Receive a list of up to 100 AiTranscript objects previously created in the Stark Infra API and the cursor to the next page.
    # Use this function instead of query if you want to manually page your requests.
    #
    # ## Parameters (optional):
    # - cursor [string, default nil]: cursor returned on the previous page function call
    # - limit [integer, default nil]: maximum number of objects to be retrieved. The API accepts up to 100 and answers with an error above it. ex: 35
    # - user [Organization/Project object, default nil]: Organization or Project object. Not necessary if StarkInfra.user was set before function call
    #
    # ## Return:
    # - list of AiTranscript objects with updated attributes
    # - cursor to retrieve the next page of AiTranscript objects, nil on the last page
    def self.page(cursor: nil, limit: nil, user: nil)
      StarkInfra::Utils::Rest.get_page(cursor: cursor, limit: limit, user: user, **resource)
    end

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
