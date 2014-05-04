Vapor.seed(:id, [
    {
        id:      1,
        path:    Gitlab.config.gitlab_shell.repos_path,
        default: true,
        tier:    1
    }
])
