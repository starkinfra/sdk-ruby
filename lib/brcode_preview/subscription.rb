# frozen_string_literal: true

require('starkcore')
require_relative('brcode_preview')
require_relative('../utils/rest')

module StarkInfra
  class BrcodePreview
    # # BrcodePreview::Subscription object
    #
    # A read-only snapshot of a Pix recurring-debit subscription, embedded inside a
    # BrcodePreview response when the previewed BR Code carries subscription metadata.
    # This sub-resource has no endpoints and is constructed only when deserializing a
    # BrcodePreview returned by the API.
    #
    # ## Attributes (return-only):
    # - amount [integer]: amount in cents charged per cycle. nil for variable-amount subscriptions. ex: 1000 (= R$ 10.00)
    # - amount_min_limit [integer]: floor value for the maximum amount the sender can set when approving a variable-amount subscription. nil for fixed-amount subscriptions. ex: 500 (= R$ 5.00)
    # - bacen_id [string]: Central Bank's unique recurrency id for the subscription.
    # - created [DateTime]: creation datetime of the subscription. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - description [string]: additional information delivered to the sender.
    # - installment_end [DateTime]: end datetime of settlements allowed for this subscription. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - installment_start [DateTime]: start datetime of settlements allowed for this subscription. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    # - interval [string]: cycle definition exposed verbatim from the server. ex: 'monthly'
    # - pull_retry_limit [integer]: max number of retries the receiver may issue for a single failed pull cycle.
    # - receiver_bank_code [string]: receiver's bank institution code.
    # - receiver_name [string]: receiver's full name.
    # - receiver_tax_id [string]: receiver's tax id (CPF or CNPJ).
    # - reference_code [string]: commercial-relation identifier (contract number, order id, or client code).
    # - sender_final_name [string]: final sender name when the sender differs from the originating institution.
    # - sender_final_tax_id [string]: final sender tax id when distinct from the originating sender.
    # - status [string]: current lifecycle state of the subscription snapshot, verbatim from the server. ex: 'created', 'pending', 'failed', 'denied', 'approved', 'active', 'expired', 'canceled'
    # - type [string]: subscription journey type, verbatim from the server. ex: 'push', 'qrcode', 'qrcodeAndPayment', 'paymentAndOrQrcode'
    # - updated [DateTime]: latest update datetime of the subscription. ex: DateTime.new(2020, 3, 10, 10, 30, 0, 0)
    class Subscription < StarkCore::Utils::SubResource
      attr_reader :amount, :amount_min_limit, :bacen_id, :created, :description, :installment_end,
                  :installment_start, :interval, :pull_retry_limit, :receiver_bank_code, :receiver_name,
                  :receiver_tax_id, :reference_code, :sender_final_name, :sender_final_tax_id, :status,
                  :type, :updated
      def initialize(
        amount: nil, amount_min_limit: nil, bacen_id: nil, created: nil, description: nil,
        installment_end: nil, installment_start: nil, interval: nil, pull_retry_limit: nil,
        receiver_bank_code: nil, receiver_name: nil, receiver_tax_id: nil, reference_code: nil,
        sender_final_name: nil, sender_final_tax_id: nil, status: nil, type: nil, updated: nil
      )
        @amount = amount
        @amount_min_limit = amount_min_limit
        @bacen_id = bacen_id
        @created = StarkCore::Utils::Checks.check_datetime(created)
        @description = description
        @installment_end = StarkCore::Utils::Checks.check_datetime(installment_end == '' ? nil : installment_end)
        @installment_start = StarkCore::Utils::Checks.check_datetime(installment_start == '' ? nil : installment_start)
        @interval = interval
        @pull_retry_limit = pull_retry_limit
        @receiver_bank_code = receiver_bank_code
        @receiver_name = receiver_name
        @receiver_tax_id = receiver_tax_id
        @reference_code = reference_code
        @sender_final_name = sender_final_name
        @sender_final_tax_id = sender_final_tax_id
        @status = status
        @type = type
        @updated = StarkCore::Utils::Checks.check_datetime(updated)
      end

      def self.parse_subscription(json)
        return nil if json.nil? || (json.respond_to?(:empty?) && json.empty?)

        subscription_maker = Subscription.resource[:resource_maker]
        StarkCore::Utils::API.from_api_json(subscription_maker, json)
      end

      def self.resource
        {
          resource_name: 'Subscription',
          resource_maker: proc { |json|
            Subscription.new(
              amount: json['amount'],
              amount_min_limit: json['amount_min_limit'],
              bacen_id: json['bacen_id'],
              created: json['created'],
              description: json['description'],
              installment_end: json['installment_end'],
              installment_start: json['installment_start'],
              interval: json['interval'],
              pull_retry_limit: json['pull_retry_limit'],
              receiver_bank_code: json['receiver_bank_code'],
              receiver_name: json['receiver_name'],
              receiver_tax_id: json['receiver_tax_id'],
              reference_code: json['reference_code'],
              sender_final_name: json['sender_final_name'],
              sender_final_tax_id: json['sender_final_tax_id'],
              status: json['status'],
              type: json['type'],
              updated: json['updated']
            )
          }
        }
      end
    end
  end
end
