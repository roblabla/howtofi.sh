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

def my_pull(git, remote, branch, options = {})
  branch = "refs/heads/#{branch}" unless branch =~ /^refs\/heads\//
  r = git.repo.remotes[remote]
  r.fetch([branch], **options)

  branch_name = branch.match(/^refs\/heads\/(.*)/)[1]
  remote_name = remote.match(/^(refs\/heads\/)?(.*)/)[2]
  remote_ref = git.repo.branches["#{remote_name}/#{branch_name}"].target
  local_ref = git.repo.branches[branch].target

  # If local_ref is a descendant of remote_ref, do nothing!
  if repo.descendant_of?(local_ref, remote_ref) then
    return
  end

  # Otherwise, merge. Note that we _may_ want to rebase instead for linear
  # history, but that seems to be a fair bit more complicated.
  index = git.repo.merge_commits(local_ref, remote_ref)
  options = { author: Actor.default_actor.to_h,
    committer:  Actor.default_actor.to_h,
    message:    "Merged branch #{branch} of #{remote}.",
    parents: [local_ref, remote_ref],
    tree: index.write_tree(@repo),
    update_ref: branch
  }
  Rugged::Commit.create @repo, options
  @repo.checkout(@repo.head.name, :strategy => :force) if !@repo.bare? && branch == @repo.head.name
end

credentials = Rugged::Credentials::SshKey.new(username: 'git', privatekey: '/ssh_key')
Gollum::Hook.register(:post_commit, :hook_id) do |committer, sha1|
  my_pull(committer.wiki.repo.git, 'gh', committer.wiki.ref, credentials: credentials)
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
