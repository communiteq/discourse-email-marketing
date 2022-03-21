# frozen_string_literal: true

module Jobs
  class EmailMarketingApiJob < ::Jobs::Base
    def execute(args)
      DiscourseEmailMarketing.process(args)
    end
  end
end


