class ProjectObserver < BaseObserver
  def after_create(project)
    log_info("#{project.owner.name} created a new project \"#{project.name_with_namespace}\"")
    unless project.vapor.path == Gitlab.config.gitlab_shell.repos_path
      # Create a links in the main path
      Vapors::MoveService.new(Vapor.find_by_path(Gitlab.config.gitlab_shell.repos_path)).symlinks(project)
    end
  end

  def after_update(project)
    project.send_move_instructions if project.namespace_id_changed?
    if project.vapor_id_changed?
      Vapors::MoveService.new(project.vapor).move(project)
    end
    if project.path_changed?
      # Plain rename
      project.rename_repo
      # Move the actual repo
      Vapors::MoveService.new(project.vapor).relink(project)
    end
  end

  def before_destroy(project)
    project.repository.expire_cache unless project.empty_repo?
  end

  def after_destroy(project)
    GitlabShellWorker.perform_async(
      :remove_repository,
      project.path_with_namespace
    )

    GitlabShellWorker.perform_async(
      :remove_repository,
      project.path_with_namespace + ".wiki"
    )

    project.satellite.destroy

    log_info("Project \"#{project.name}\" was removed")
  end
end
