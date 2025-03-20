# frozen_string_literal: true

class Dataset < ApplicationRecord
  self.implicit_order_column = :created_at

  belongs_to :user, inverse_of: :datasets
  has_many :experiments, inverse_of: :dataset, dependent: :destroy
  has_one_attached :evaluation

  validates :name, presence: true
  validates :column_separator, presence: true, length: {is: 1}
  validates :evaluation, presence: true
  validate :evaluation_content_type

  private def evaluation_content_type
    return unless evaluation.attached?
    return if evaluation.content_type == "text/csv"

    errors.add(:evaluation, "must be CSV")
  end
end
