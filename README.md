# Git to Git Migration with LFS Support
Tooling to support copying a repository from one git source to another, including LFS objects.

## Dependencies
- [Git](https://git-scm.com/downloads)
- [Git LFS](https://git-lfs.com)
- Bash Compatible Terminal
- Git credentials configured

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

- Print usage help: `./migrate.sh -h`

- Generate example CSV: `./migrate.sh -e`

- Normal operation: `./migrate.sh -i example.csv`

- Cleanup after normal operation: `./migrate.sh -i example.csv -c`

Print usage help for all options.