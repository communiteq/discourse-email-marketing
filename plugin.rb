# name: discourse-email-marketing
# version: 1.0
# author: michael@communiteq.com

PLUGIN_NAME = 'discourse-email-marketing'.freeze

enabled_site_setting :discourse_email_marketing_enabled

after_initialize do
  require_relative 'app/jobs/regular/email_marketing_api_job'
  require_relative 'lib/discourse_email_marketing'

  on(:user_created) do |user|
    return unless SiteSetting.discourse_email_marketing_enabled
    Jobs.enqueue(:email_marketing_api_job, user_id: user.id, action: 'subscribe')
  end

  on(:user_updated) do |user|
    return unless SiteSetting.discourse_email_marketing_enabled
    Jobs.enqueue(:email_marketing_api_job, user_id: user.id, action: 'update')
  end

  on(:user_destroyed) do |user|
    return unless SiteSetting.discourse_email_marketing_enabled
    Jobs.enqueue(:email_marketing_api_job, user_id: user.id, action: 'unsubscribe')
  end
end
