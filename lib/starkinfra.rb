# frozen_string_literal: true

require_relative('brcode_preview/brcode_preview')
require_relative('business_attachment/business_attachment')
require_relative('business_attachment/log')
require_relative('business_identity/business_identity')
require_relative('business_identity/log')
require_relative('brcode_preview/subscription')
require_relative('card_method/card_method')
require_relative('credit_note/invoice/invoice')
require_relative('credit_note/invoice/description')
require_relative('credit_note/invoice/discount')
require_relative('credit_note/credit_note')
require_relative('credit_note/log')
require_relative('credit_note/transfer')
require_relative('credit_holmes/credit_holmes')
require_relative('credit_preview/credit_preview')
require_relative('credit_preview/credit_note_preview')
require_relative('credit_signer/credit_signer')
require_relative('dynamic_brcode/dynamic_brcode')
require_relative('individual_document/individual_document')
require_relative('individual_document/log')
require_relative('individual_identity/individual_identity')
require_relative('individual_identity/log')
require_relative('issuing_balance/issuing_balance')
require_relative('issuing_design/issuing_design')
require_relative('issuing_embossing_kit/issuing_embossing_kit')
require_relative('issuing_embossing_request/issuing_embossing_request')
require_relative('issuing_embossing_request/log')
require_relative('issuing_stock/issuing_stock')
require_relative('issuing_stock/log')
require_relative('issuing_stock_rule/issuing_stock_rule')
require_relative('issuing_restock/issuing_restock')
require_relative('issuing_restock/log')
require_relative('issuing_card/issuing_card')
require_relative('issuing_card/log')
require_relative('issuing_holder/issuing_holder')
require_relative('issuing_holder/log')
require_relative('issuing_invoice/issuing_invoice')
require_relative('issuing_invoice/log')
require_relative('issuing_product/issuing_product')
require_relative('issuing_purchase/issuing_purchase')
require_relative('issuing_purchase/log')
require_relative('issuing_rule/issuing_rule')
require_relative('issuing_transaction/issuing_transaction')
require_relative('issuing_withdrawal/issuing_withdrawal')
require_relative('merchant_category/merchant_category')
require_relative('merchant_country/merchant_country')
require_relative('pix_balance/pix_balance')
require_relative('pix_chargeback/pix_chargeback')
require_relative('pix_chargeback/log')
require_relative('pix_claim/pix_claim')
require_relative('pix_claim/log')
require_relative('pix_director/pix_director')
require_relative('pix_dispute/pix_dispute')
require_relative('pix_dispute/transaction')
require_relative('pix_dispute/log')
require_relative('pix_domain/pix_domain')
require_relative('pix_key_holmes/pix_key_holmes')
require_relative('pix_fraud/pix_fraud')
require_relative('pix_fraud/log')
require_relative('pix_infraction/pix_infraction')
require_relative('pix_infraction/log')
require_relative('pix_internal_transaction_report/pix_internal_transaction_report')
require_relative('pix_internal_transaction_report/log')
require_relative('pix_key/pix_key')
require_relative('pix_key/log')
require_relative('pix_pull_request/pix_pull_request')
require_relative('pix_pull_request/log')
require_relative('pix_pull_subscription/pix_pull_subscription')
require_relative('pix_pull_subscription/log')
require_relative('pix_request/pix_request')
require_relative('pix_request/log')
require_relative('pix_reversal/pix_reversal')
require_relative('pix_reversal/log')
require_relative('pix_statement/pix_statement')
require_relative('static_brcode/static_brcode')
require_relative('webhook/webhook')
require_relative('event/event')
require_relative('event/attempt')
require_relative('request/request')
require_relative('utils/return_id')

# SDK to facilitate Ruby integrations with Stark Infra
module StarkInfra

  API_VERSION = 'v2'
  SDK_VERSION = '0.5.1'
  HOST = "infra"
  public_constant :API_VERSION, :SDK_VERSION, :HOST;

  @user = nil
  @language = 'en-US'
  @timeout = 15
  class << self; attr_accessor :user, :language, :timeout; end

  Project = StarkCore::Project
  Organization = StarkCore::Organization
  Key = StarkCore::Key

end
