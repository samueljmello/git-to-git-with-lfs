# Git to Git Migration with LFS Support
Tooling to support copying a repository from one git source to another, including LFS objects.

## Dependencies
- [Git](https://git-scm.com/downloads)
- [Git LFS](https://git-lfs.com)
- Bash Compatible Terminal
- Git credentials configured for respository sources
- JQ

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

## Caveats
Depending on how many repositories and their respective size, this script could take significant time to complete. The processing is accomplished in series, not parallel, which means only one repository is processed at a time. You will want to run this on a dedicated machine that has time to complete without interuption or system down time.

Additionally, the script assumes your destination repositories exist already. Future work may include repository detection, but would require additional input from the executor increasing the amount of work up-front.

## Usage
First, export your Github PAT (`export GH_PAT="<your-pat>"`) and then follow the syntax described below.

If you want to pass the PAT via CLI, use the `-p` or `--pat` flags.

- Print usage help: `./migrate.sh -h`

- Generate example CSV: `./migrate.sh -e`

- Normal operation: `./migrate.sh -i example.csv`

- Cleanup after normal operation: `./migrate.sh -i example.csv -c`

Print usage help for all options.