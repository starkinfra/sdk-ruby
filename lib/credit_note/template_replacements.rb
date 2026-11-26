require_relative('../utils/rest')

module StarkInfra
  class CreditNote
    # # CreditNote::TemplateReplacements object
    #
    # The CreditNote::TemplateReplacements object carries the values that fill the placeholders of the
    # contract template of a CreditNote. Its attributes are free: they depend on the template.
    #
    # ## Parameters (optional):
    # - **kwargs [string]: placeholder name and its value. Write the names in snake_case, as the core sends
    # them in camelCase (ex: guarantor_name: 'Jon Snow' is sent as guarantorName). Names already in camelCase
    # are corrupted by the core. Values that are nil are not sent.
    class TemplateReplacements < StarkCore::Utils::SubResource
      def initialize(**kwargs)
        @entries = {}
        kwargs.each { |key, value| @entries[key.to_s] = value }
      end

      # # Read a value
      #
      # ## Parameters (required):
      # - key [string or symbol]: placeholder name exactly as it was given to the object or returned by the API.
      #   The name is not converted to camelCase here, that only happens when the request is sent. ex: 'guarantorName'
      #
      # ## Return:
      # - value of the placeholder, or nil when it is absent
      def [](key)
        @entries[key.to_s]
      end

      # # Hash with every placeholder
      #
      # ## Return:
      # - Hash with the placeholder names as string keys, exactly as given or returned (no camelCase conversion, nil values kept)
      def to_h
        @entries.dup
      end

      # The core serializes an entity by walking instance_variables/instance_variable_get. Exposing the entries through
      # them lets any placeholder name travel, including names that are not valid Ruby identifiers (ex: "guarantor-name"),
      # which instance_variable_set would reject.
      def instance_variables
        @entries.keys.map { |key| :"@#{key}" }
      end

      def instance_variable_get(name)
        @entries[name.to_s[1..]]
      end

      # pp reads the names from instance_variables but the values through instance_eval, which would show nil (or raise
      # for names that are not valid Ruby identifiers), so it prints the entries directly.
      def pretty_print(printer)
        printer.group(1, "#<#{self.class.name}", '>') do
          printer.breakable
          printer.pp(@entries)
        end
      end

      # # Parse CreditNote::TemplateReplacements
      #
      # Converts a hash received from the API (or given by the user) into a CreditNote::TemplateReplacements object.
      #
      # ## Parameters (required):
      # - template_replacements [hash or CreditNote::TemplateReplacements object, nil]: value to be parsed.
      #
      # ## Return:
      # - parsed CreditNote::TemplateReplacements object, or nil
      def self.parse_template_replacements(template_replacements)
        return template_replacements if template_replacements.nil?
        return template_replacements if template_replacements.is_a? TemplateReplacements
        return new(**template_replacements) if template_replacements.is_a? Hash

        raise "template_replacements must be a Hash or a CreditNote::TemplateReplacements, but not a #{template_replacements.class}"
      end
    end
  end
end
