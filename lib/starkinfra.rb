# frozen_string_literal: true

require_relative('brcodepreview/brcodepreview')
require_relative('cardmethod/cardmethod')
require_relative('creditnote/invoice/invoice')
require_relative('creditnote/invoice/description')
require_relative('creditnote/invoice/discount')
require_relative('creditnote/creditnote')
require_relative('creditnote/log')
require_relative('creditnote/transfer')
require_relative('creditholmes/creditholmes')
require_relative('creditpreview/creditpreview')
require_relative('creditpreview/creditnotepreview')
require_relative('creditsigner/creditsigner')
require_relative('dynamicbrcode/dynamicbrcode')
require_relative('individualdocument/individualdocument')
require_relative('individualdocument/log')
require_relative('individualidentity/individualidentity')
require_relative('individualidentity/log')
require_relative('issuingbalance/issuingbalance')
require_relative('issuingdesign/issuingdesign')
require_relative('issuingembossingkit/issuingembossingkit')
require_relative('issuingembossingrequest/issuingembossingrequest')
require_relative('issuingembossingrequest/log')
require_relative('issuingstock/issuingstock')
require_relative('issuingstock/log')
require_relative('issuingrestock/issuingrestock')
require_relative('issuingrestock/log')
require_relative('issuingcard/issuingcard')
require_relative('issuingcard/log')
require_relative('issuingholder/issuingholder')
require_relative('issuingholder/log')
require_relative('issuinginvoice/issuinginvoice')
require_relative('issuinginvoice/log')
require_relative('issuingproduct/issuingproduct')
require_relative('issuingpurchase/issuingpurchase')
require_relative('issuingpurchase/log')
require_relative('issuingrule/issuingrule')
require_relative('issuingtransaction/issuingtransaction')
require_relative('issuingwithdrawal/issuingwithdrawal')
require_relative('merchantcategory/merchantcategory')
require_relative('merchantcountry/merchantcountry')
require_relative('pixbalance/pixbalance')
require_relative('pixchargeback/pixchargeback')
require_relative('pixchargeback/log')
require_relative('pixclaim/pixclaim')
require_relative('pixclaim/log')
require_relative('pixdirector/pixdirector')
require_relative('pixdomain/pixdomain')
require_relative('pixinfraction/pixinfraction')
require_relative('pixinfraction/log')
require_relative('pixkey/pixkey')
require_relative('pixkey/log')
require_relative('pixrequest/pixrequest')
require_relative('pixrequest/log')
require_relative('pixreversal/pixreversal')
require_relative('pixreversal/log')
require_relative('pixstatement/pixstatement')
require_relative('staticbrcode/staticbrcode')
require_relative('webhook/webhook')
require_relative('event/event')
require_relative('event/attempt')
require_relative('request/request')

# SDK to facilitate Ruby integrations with Stark Infra
module StarkInfra

  API_VERSION = 'v2'
  SDK_VERSION = '2.10.0'
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
