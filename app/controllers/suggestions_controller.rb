class SuggestionsController < ApplicationController
  before_action :require_login

  def create
    @suggestion = current_user.suggestions.build(suggestion_params)

    if @suggestion.save
      render json: { message: "건의사항이 성공적으로 접수되었습니다." }, status: :created
    else
      render json: @suggestion.errors.full_messages, status: :unprocessable_entity
    end
  end

  private

  def suggestion_params
    params.require(:suggestion).permit(:title, :content)
  end
end
