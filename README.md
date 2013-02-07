**Request code review:**
test

```
hs request [-b,--branch] [-m,--message]
```
```sh
~/dev/my-project $ git branch
* master
  new-feature

~/dev/my-project $ hs request -b new-feature -m "I'm looking for a more concise way to do foobar."
Hacker School code review requested for my-project:new-feature. Please remember to push recent changes to Github.

## review request then added to /private
## links to https://github.com/username/my-project/compare/new-feature...master
```

**Review code:**

```
hs review gh-username/repo[:branch] [-b,--branch] [folder]
hs submit [-m,--message]
```
```sh
~/dev $ hs review username/my-project:new-feature new-feature-review && cd new-feature-review
## forks username/my-project on GitHub
## clones it locally to new-feature-review
## sets origin correctly
## branches from my-project:new-feature

~/dev/new-feature-review $ git branch
  master
  new-feature
* new-feature-hs-review-1

## review code and make changes

~/dev/new-feature-review $ hs submit -m "I made granular commits with descriptions of each change. Let me know if you have any questions!"
## pushes to GH and issues a pull request
```

