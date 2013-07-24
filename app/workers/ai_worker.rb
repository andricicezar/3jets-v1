class AiWorker
  include Rails.application.routes.url_helpers
  Rails.application.routes.default_url_options[:host] = 'localhost:3000'

  include Sidekiq::Worker
  include ApplicationHelper
  include NotificationHelper
  include GameHelper
  include AiHelper

  def perform(user_id, ai_id, game_id)
    aiMove4(user_id, ai_id, Game.find(game_id))
  end
end
