vapor = Vapor.create(
    path: Gitlab.config.gitlab_shell.repos_path,
    default: true,
    tier: 1
)
vapor.save!