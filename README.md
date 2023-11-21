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

## Usage

## Notes
- Make sure to have a newline at the end of your CSV File. Without, the last line won't be read correctly.