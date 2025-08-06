# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  renders_one :header
  renders_one :footer

  def initialize(class: nil, **options)
    @custom_class = binding.local_variable_get(:class)
    @options = options
    @options[:class] = card_classes(@custom_class)
  end

  def call
    content_tag :div, **@options do
      safe_join([
        header_content,
        body_content,
        footer_content
      ].compact)
    end
  end

  private

  def card_classes(custom_classes = nil)
    base_classes = %w[
      rounded-lg border bg-white text-gray-900 shadow-sm
    ]

    classes = base_classes
    classes << custom_classes if custom_classes.present?
    classes.join(" ")
  end

  def header_content
    return unless header?

    content_tag :div, class: "flex flex-col space-y-1.5 p-6" do
      header
    end
  end

  def body_content
    content_tag :div, class: "p-6 pt-0" do
      content
    end
  end

  def footer_content
    return unless footer?

    content_tag :div, class: "flex items-center p-6 pt-0" do
      footer
    end
  end
end
