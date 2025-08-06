class TournamentWizard < ApplicationRecord
  belongs_to :user
  belongs_to :tournament, optional: true

  STEPS = %w[template_selection basic_info settings review].freeze

  validates :step, inclusion: { in: STEPS }

  def current_step_index
    STEPS.index(step) || 0
  end

  def next_step!
    return if completed?

    current_index = current_step_index
    if current_index < STEPS.length - 1
      update!(step: STEPS[current_index + 1])
    else
      update!(completed: true)
    end
  end

  def previous_step!
    current_index = current_step_index
    return if current_index == 0

    update!(step: STEPS[current_index - 1])
  end

  def progress_percentage
    ((current_step_index + 1).to_f / STEPS.length * 100).round
  end
end
