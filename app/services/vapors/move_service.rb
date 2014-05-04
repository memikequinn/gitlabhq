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
        unless Dir.exists?(File.dirname(new_path))
          # No -p here because the vapor should already exist
          Dir.mkdir(File.dirname(new_path))
        end
        FileUtils.mv orig_real_path, new_path
        # Clean up if we're moving back to default
        if File.symlink?(orig_path)
          FileUtils.rm orig_path
        end
        # Create the symlinks when moving off of default
        if !File.symlink?(orig_path) && !vapor.default?
          File.symlink new_path, orig_path
        end
        project.update_attribute :vapor_id, vapor.id
      end
    end

    # Assumed use: create symlinks when project is not on the
    # Gitlab.config.gitlab_shell.repos_path path
    def symlinks(project)
      # Not needed
      return true if project.vapor.path == Gitlab.config.gitlab_shell.repos_path
      File.symlink File.join(project.vapor.path, project.path_with_namespace).to_s + '.git', File.join(vapor.path, project.path_with_namespace) + '.git'
    end

  end
end