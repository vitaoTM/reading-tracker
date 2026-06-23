module MapEntriesHelper
  # Inlines the world map SVG with injected CSS classes for responsive sizing.
  # html_safe is intentional — this is a static asset we control, not user input.
  def inline_world_map_svg(css_class: "w-full h-auto")
    File.read(Rails.root.join("app/assets/images/world_map.svg"))
        .gsub("<svg ", %(<svg class="#{css_class}" ))
        .html_safe
  end
end
