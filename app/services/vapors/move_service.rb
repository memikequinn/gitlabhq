require 'pathname'
module Vapors
  class MoveService < BaseVaporService
    class TooSmallError < StandardError;
    end

    def move_all
      new_vapor = vapor.big_enough
      vapor.projects.each do |project|
        Vapors::MoveService.new(new_vapor).move(project)
      end
    end

    # To move this service and move a project from another vapor, initialize with the
    # Vapor that you are wanting to move TO
    # Example,
    # b = BaseVaporService.new(vapor_to_move_to)
    # b.move(project_i_want_to_move)
    def move(project)
      raise TooSmallError.new("#{vapor.path} is not large enough") unless vapor.free_space > project.repository.size
      Project.transaction do
        orig_real_path = project.repository.real_path
        orig_path = project.repository.path
        new_path = "#{File.join(vapor.path, project.path_with_namespace)}.git"
        if File.symlink?(new_path)
          FileUtils.rm new_path
        end
        FileUtils.mkdir_p(File.dirname(new_path))
        FileUtils.mv(orig_real_path, File.dirname(new_path)) unless File.exists?(new_path)
        # Clean up if we're moving back to the path from settings
        if File.symlink?(orig_path)
          FileUtils.rm orig_path
        end
        # Create the symlinks when moving off of default
        if !File.symlink?(orig_path) && !vapor.default?
          File.symlink new_path, orig_path
        end
        project.update_attribute :vapor_id, vapor.id unless project.vapor.id == vapor.id
      end
    end

    # Assumed use: create symlinks when project is not on the
    # Gitlab.config.gitlab_shell.repos_path path
    def symlinks(project)
      # Not needed
      return true if project.vapor.path == Gitlab.config.gitlab_shell.repos_path
      File.symlink File.join(project.vapor.path, project.path_with_namespace).to_s + '.git', File.join(vapor.path, project.path_with_namespace) + '.git'
    end

    def relink(project)
      return true if project.vapor.path == Gitlab.config.gitlab_shell.repos_path
      return true unless File.symlink?(project.repository.path_to_repo)
      project.reload
      real_path = File.readlink(project.repository.path_to_repo)
      linked_path = project.repository.path_to_repo # save for after symlink update
      FileUtils.mv(real_path, File.join(project.vapor.path, "#{project.path_with_namespace}.git"))
      # remove the old link
      system("rm #{linked_path}")
      # create the new symlink
      File.symlink File.join(project.vapor.path, "#{project.path_with_namespace}.git"), linked_path
    end

  end
end