# frozen_string_literal: true

require_relative('key')
require_relative('user/project')
require_relative('user/organization')
require_relative('pixrequest/pixrequest')
require_relative('pixrequest/log')
require_relative('pixreversal/pixreversal')
require_relative('pixreversal/log')
require_relative('pixbalance/pixbalance')
require_relative('pixstatement/pixstatement')
require_relative('pixinfraction/pixinfraction')
require_relative('pixinfraction/log')
require_relative('pixchargeback/pixchargeback')
require_relative('pixchargeback/log')
require_relative('pixkey/pixkey')
require_relative('pixkey/log')
require_relative('pixclaim/pixclaim')
require_relative('pixclaim/log')
require_relative('pixdomain/pixdomain')
require_relative('pixdirector/pixdirector')
require_relative('webhook/webhook')
require_relative('event/event')
require_relative('event/attempt')
require_relative('utils/endtoendid')
require_relative('utils/returnid')
require_relative('creditnote/creditnote')
require_relative('creditnote/log')

# SDK to facilitate Ruby integrations with Stark Infra
module StarkInfra
  @user = nil
  @language = 'en-US'
  class << self; attr_accessor :user, :language; end
end
