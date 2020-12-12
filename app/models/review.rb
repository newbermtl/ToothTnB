class Review < ApplicationRecord
  belongs_to :user
  belongs_to :toothbrush
  validates :toothbrush, presence: true
  validates :content, :rating, presence: true
  validates :rating, inclusion: { in: 1..5, message: "%{value} is not a valid rating" }
  validates :rating, numericality: true
end
