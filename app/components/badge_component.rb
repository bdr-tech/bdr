# frozen_string_literal: true

class BadgeComponent < ViewComponent::Base
  def initialize(variant: :default, **options)
    @variant = variant.to_sym
    @options = options
    @options[:class] = badge_classes(@options[:class])
  end

  def call
    content_tag :span, content, **@options
  end

  private

  def badge_classes(custom_classes = nil)
    base_classes = %w[
      inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold
      transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2
    ]

    variant_classes = case @variant
    when :default
      %w[border-transparent bg-gray-900 text-gray-50]
    when :secondary
      %w[border-transparent bg-gray-100 text-gray-900]
    when :destructive
      %w[border-transparent bg-red-500 text-white]
    when :outline
      %w[text-gray-900 border border-gray-200]
    when :success
      %w[border-transparent bg-green-500 text-white]
    when :warning
      %w[border-transparent bg-yellow-500 text-white]
    when :info
      %w[border-transparent bg-blue-500 text-white]
    else
      %w[border-transparent bg-gray-900 text-gray-50]
    end

    classes = base_classes + variant_classes
    classes << custom_classes if custom_classes.present?
    classes.join(" ")
  end
end
