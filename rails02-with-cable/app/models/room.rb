class Room < ApplicationRecord
  validates :name, uniqueness: true
end
