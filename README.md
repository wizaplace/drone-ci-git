# Drone CI Git plugin

Git plugin for Drone CI, using a single bare repo and [`git archive`](https://git-scm.com/docs/git-archive) to speed up setup.

## Usage

In your `.drone.yml`:

```yml
pipeline:
    clone:
        image: wizaplace/drone-ci-git
        volumes:
            - /data/gitBareRepo:/bareRepo
```

The volume is here to cache the bare repo. The worktree will be created in the Drone workspace.
