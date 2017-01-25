class Poll::Answer < ActiveRecord::Base

  belongs_to :question, -> { with_hidden }
  belongs_to :author, ->   { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  validates :question, presence: true
  validates :author, presence: true
  validates :answer, presence: true
  validates :answer, inclusion: {in: ->(a) { a.question.valid_answers }}

  scope :by_author, -> (author_id) { where(author_id: author_id) }
  scope :by_question, -> (question_id) { where(question_id: question_id) }
end