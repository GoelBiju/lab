# Git - Cheat Sheet

## Install Git

[Download](http://git-scm.com) Git distributions for Linux and POSIX systems.


## Configure Tooling

Configure user information for all local repositories

```bash
$ git config --global user.name "[name]"
```
Sets the name you want attached to your commit transactions

```bash
$ git config --global user.email "[email.address]"
```
Sets the email you want attached to your commit transactions

```bash
$ git config --global color.ui auto
```
Enables helpful colorisation of command line output

## Create repositories

Start a new repository or obtain one from an existing URL
```bash
$ git init [project-name]
```
Creates a new local repository with the specified name

```bash
$ git clone [url]
```
Downloads a project and its entire version history

## Make changes
Review edits and craft a commit transaction

```bash
$ git status
```
Lists all new or modified files to be committed
```bash
$ git diff
```
Shows file differences not yet staged
```bash
$ git add [file]
```
Snapshots the file in preparation for versioning
```bash
$ git diff --staged
```
Show file differences between staging and the last file version
```bash
$ git reset [file]
```
Unstages the file, but preserves its contents
```bash
$ git commit -m "[descriptive message]"
```
Records file snapshots permanently in version history

## Group changes
Name a series of commits and combine completed efforts

```bash
$ git branch
```
LIsts all local branches in the current repository
```bash
$ git branch [branch-name]
```
Creates a new branch
```bash
$ git checkout [branch-name]
```
Switches to the specified branch and updates the working directory
```bash
$ git merge [branch]
```
Combines the specified branch's history into the current branch
```bash
$ git branch -d [branch-name]
```
Deletes the specified branch

## Refactor filenames
Relocate and remove versioned files

```bash
$ git rm [file]
```
Deletes the file from the working directory and stages the deletion
```bash
$ git rm --cached [file]
```
Removes the file from verison control but preserves the file locally
```bash
$ git mv [file-original] [file-renamed]
```

## Supress tracking
Exclude temporary files and paths

```
*log
build/
temp-*
```
A text file named `.gitignore`suppresses accidental versioning of files and paths matching the specified patterns

```bash
$ git ls-files --other --ignored --exclude-standard
```
Lists all ignored files in this project

## Save fragments
Shelve and restore incomplete changes

```bash
$ git stash 
```
Temporarily stores all modified tracked files
```bash
$ git stash pop
```
Restores the most recently stashed files
```bash
$ git stash list
```
Lists all stashed changesets
```bash
$ git stash drop
```
Discards the most recently stashed changeset

## Review history
Browse and inspect the evolution of project files

```bash
$ git log
```
Lists version history for the current branch
```bash
$ git log --follow [file]
```
Lists version history for a file, including renames
```bash
$ git diff [first-branch]...[second-branch]
```
Shows content differences between two branches
```bash
$ git show [commit]
```
Outputs metadata and content changes of the specified commit

## Redo commits
Erase mistakes and craft replacement history

```bash
$ git reset [commit]
```
Undoes all commits after [commit], preserving changes locally
```bash
$ git reset --hard [commit]
```
Discards all history and changes back to the specified commit


## Synchronise changes
Register a repository bookmark and exchange version history

```bash
$ git fetch [bookmark]
```
Downloads all history from the repository bookmark
```bash
$ git merge [bookmark]/[branch]
```
Combines bookmark's branch into current local branch
```bash
$ git push [alias] [branch]
```
Uploads all local branch commits to GitHub
```bash
$ git pull
```
Downloads bookmark history and incorporates changes