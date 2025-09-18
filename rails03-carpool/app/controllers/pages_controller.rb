class PagesController < ApplicationController
  def root
    @pictures = Dir.entries(Rails.root.join("public/pictures")).sort.reverse.select do |file|
      file.match?(/\.(jpg|jpeg)$/i) && !file.start_with?('.')
    end
    if @pictures.first
      # Pick up the number of cars from file name. yyyymmddhhmmss-nn.jpg
      @car_count = @pictures.first.match(/^\d+-(\d+).jpg$/)[1].to_i
    end
  end

  def update
    #Update carpool information
    ActionCable.server.broadcast "notification_channel", {type: "carpool"}
    head :ok
  end
end
