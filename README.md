# Git to Git Migration with LFS Support
Tooling to support copying a repository from one git source to another, including LFS objects.

## Dependencies
- [Git](https://git-scm.com/downloads)
- [Git LFS](https://git-lfs.com)
- Bash Compatible Terminal
- SSH credentials configured
- ...

## Functionality
This script is a very simple bash script that:

- Takes a list of repositories in CSV format
- For each repository:
   - Performs a mirror clone of the source
   - Adds the destination as a remote
   - Pushes the repository to the destination
   - Syncs LFS objects (if they exist)
   - Cleans up data (if requested)

## Assumptions
- Authentication to repositories is handled via SSH or credentials manager (based on your OS).

## Usage
```sh
Usage: migrate.sh [options]

Options:
     -c, --clean   : Whether to clean up git repositories or not
     -e, --example : Generate example inputer CSV file
     -f, --force   : Whether to force push in Git
     -h, --help    : Show script help
     -i, --input   : CSV file containing repository URL list
     -n, --no-log  : Do not create log file

Description:
  Tooling to support cloning a repository from one git source to another with 
  LFS objects.

Example:
  migrate.sh -i repositories.csv
```

## Notes
- Make sure to have a newline at the end of your CSV File. Without, the last line won't be read correctly.