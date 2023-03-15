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

credentials = Rugged::Credentials::SshKey.new(username: 'git', privatekey: '/ssh_key')
Gollum::Hook.register(:post_commit, :hook_id) do |committer, sha1|
  committer.wiki.repo.git.pull('gh', committer.wiki.ref, credentials: credentials)
  committer.wiki.repo.git.push('gh', committer.wiki.ref, credentials: credentials)
end

Precious::App.set(:wiki_options, wiki_options)

class Precious::App
  before do
    if request.has_header?("HTTP_X_TOKEN_SUBJECT") then
      name = request.get_header("HTTP_X_TOKEN_SUBJECT").split("/").last
      session["gollum.author"] = {name: name}
    end
  end
end
