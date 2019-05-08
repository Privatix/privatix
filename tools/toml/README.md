# Introduction

`toml.sh` is intended to adopt the `dep` tool for the `git-flow` environment. 

# How it works

`toml.sh` replaces a `%BRANCH_NAME%` occurences in a template file 
with the current branch name, by using the following rules:

```
#   develop         ->  develop
#   master          ->  master
#   feature/name    ->  develop
#   release/name    ->  release/name
#   hotfix/name     ->  master
```

# Using

```
./toml.sh ./Gopkg.toml.template > ./Gopkg.toml
```