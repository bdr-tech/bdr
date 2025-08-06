# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(variant: :default, size: :default, type: "button", **options)
    @variant = variant.to_sym
    @size = size.to_sym
    @type = type
    @options = options
    @options[:class] = button_classes(@options[:class])
    @options[:type] ||= @type
  end

  def call
    content_tag :button, content, **@options
  end

  private

  def button_classes(custom_classes = nil)
    base_classes = %w[
      inline-flex items-center justify-center rounded-md text-sm font-medium
      ring-offset-background transition-colors focus-visible:outline-none
      focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2
      disabled:pointer-events-none disabled:opacity-50
    ]

    variant_classes = case @variant
    when :default
      %w[bg-orange-500 text-white hover:bg-orange-600]
    when :destructive
      %w[bg-red-500 text-white hover:bg-red-600]
    when :outline
      %w[border border-gray-300 bg-background hover:bg-gray-100 hover:text-gray-900]
    when :secondary
      %w[bg-blue-500 text-white hover:bg-blue-600]
    when :ghost
      %w[hover:bg-gray-100 hover:text-gray-900]
    when :link
      %w[text-orange-500 underline-offset-4 hover:underline]
    else
      %w[bg-orange-500 text-white hover:bg-orange-600]
    end

    size_classes = case @size
    when :default
      %w[h-10 px-4 py-2]
    when :sm
      %w[h-9 rounded-md px-3]
    when :lg
      %w[h-11 rounded-md px-8]
    when :icon
      %w[h-10 w-10]
    else
      %w[h-10 px-4 py-2]
    end

    classes = base_classes + variant_classes + size_classes
    classes << custom_classes if custom_classes.present?
    classes.join(" ")
  end
end
