wiki_options = {
  page_file_dir: "page",
  allow_uploads: true,
  per_page_uploads: true,
  template_dir: 'templates'
}

::Loofah::HTML5::SafeList::ALLOWED_ATTRIBUTES.add('camera-controls')
::Loofah::HTML5::SafeList::ALLOWED_ATTRIBUTES.add('touch-action')
::Loofah::HTML5::SafeList::ALLOWED_ELEMENTS_WITH_LIBXML2.add('model-viewer')

module Gollum
  class Macro
    class ModelViewer < Gollum::Macro
      def render(model_name, alt="")
        "<model-viewer alt=\"#{CGI::escapeHTML(alt)}\" src=\"#{CGI::escapeHTML(model_name)}\" camera-controls=\"true\" touch-action=\"pan-y\"></model-viewer>"
      end
    end
  end
end

Precious::App.set(:wiki_options, wiki_options)
