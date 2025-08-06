class TournamentBudget < ApplicationRecord
  belongs_to :tournament

  CATEGORIES = %w[
    income
    court_fee
    prize
    refreshment
    platform_fee
    equipment
    staff
    marketing
    other
  ].freeze

  validates :category, inclusion: { in: CATEGORIES }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true

  scope :income, -> { where(is_income: true) }
  scope :expenses, -> { where(is_income: false) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(transaction_date: :desc) }

  def self.total_income
    income.sum(:amount)
  end

  def self.total_expenses
    expenses.sum(:amount)
  end

  def self.balance
    total_income - total_expenses
  end

  def self.expenses_by_category
    expenses.group(:category).sum(:amount)
  end

  def expense?
    !is_income?
  end
end
