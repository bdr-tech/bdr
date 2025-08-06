# frozen_string_literal: true

class SkeletonComponent < ViewComponent::Base
  def initialize(type: :text, lines: 1, width: "w-full", height: "h-4", **options)
    @type = type.to_sym
    @lines = lines
    @width = width
    @height = height
    @options = options
    @options[:class] = skeleton_classes(@options[:class])
  end

  def call
    case @type
    when :text
      render_text_skeleton
    when :avatar
      render_avatar_skeleton
    when :card
      render_card_skeleton
    when :custom
      content_tag :div, "", **@options
    else
      render_text_skeleton
    end
  end

  private

  def skeleton_classes(custom_classes = nil)
    base_classes = %w[animate-pulse bg-gray-200 rounded]
    classes = base_classes
    classes << custom_classes if custom_classes.present?
    classes.join(" ")
  end

  def render_text_skeleton
    content_tag :div, class: "space-y-2" do
      safe_join(
        @lines.times.map do |i|
          # 마지막 줄은 더 짧게
          width = (i == @lines - 1 && @lines > 1) ? "w-3/4" : @width
          content_tag :div, "", class: "#{skeleton_classes} #{@height} #{width}"
        end
      )
    end
  end

  def render_avatar_skeleton
    content_tag :div, "", class: "#{skeleton_classes} rounded-full w-12 h-12"
  end

  def render_card_skeleton
    content_tag :div, class: "rounded-lg border bg-white p-6 shadow-sm" do
      safe_join([
        # 헤더
        content_tag(:div, class: "space-y-2 mb-4") do
          safe_join([
            content_tag(:div, "", class: "#{skeleton_classes} h-6 w-1/3"),
            content_tag(:div, "", class: "#{skeleton_classes} h-4 w-1/2")
          ])
        end,
        # 본문
        content_tag(:div, class: "space-y-2") do
          safe_join([
            content_tag(:div, "", class: "#{skeleton_classes} h-4 w-full"),
            content_tag(:div, "", class: "#{skeleton_classes} h-4 w-full"),
            content_tag(:div, "", class: "#{skeleton_classes} h-4 w-3/4")
          ])
        end
      ])
    end
  end
end
