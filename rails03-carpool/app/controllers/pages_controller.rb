class PagesController < ApplicationController
  def root
    @pictures = Dir.entries(Rails.root.join("public/pictures")).sort.reverse.select do |file|
      file.match?(/\.(jpg|jpeg)$/i) && !file.start_with?('.')
    end
  end

  def update
    ActionCable.server.broadcast "notification_channel"
    # This action is used to check if the application is running properly.
    # It should return a 200 status code if everything is fine. => who is using this?
    head :ok
  end
end
