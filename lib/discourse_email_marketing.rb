# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class DiscourseEmailMarketing
  def self.process(args)
    return unless SiteSetting.discourse_email_marketing_enabled

    user = User.find(args[:user_id])

    unless SiteSetting.discourse_email_marketing_mailerlite_apikey.empty?
      case args[:action]
      when "subscribe"
        uri = URI.parse("https://api.mailerlite.com/api/v2/subscribers")
        request = Net::HTTP::Post.new(uri)
        request.body = JSON.dump({
          "email" => user.email,
          "name"  => user.name
        })
      when "update"
        uri = URI.parse("https://api.mailerlite.com/api/v2/subscribers")
        request = Net::HTTP::Post.new(uri)
        request.body = JSON.dump({
          "email" => user.email,
          "name"  => user.name
        })
      else
        return
      end

      request["Accept"] = 'application/json'
      request["Content-Type"] = 'application/json'
      request["X-Mailerlite-Apikey"] = SiteSetting.discourse_email_marketing_mailerlite_apikey
      response = Net::HTTP.start(uri.hostname, uri.port, {use_ssl: true}) do |http|
          http.request(request)
      end
      if response.code.to_i == 200
        response_obj = JSON.parse(response.body)
        user.custom_fields['mailerlite_id'] = response_obj["id"]
        user.save!
      end
    end
  end
end

