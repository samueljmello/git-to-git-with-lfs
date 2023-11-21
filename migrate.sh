#!/usr/bin/env bash -e

#-------------------------------#
# Git-to-Git Migration with LFS #
#-------------------------------#

# This tooling is provided free and with no support. Use at your own discretion.
# It's goal is to take a CSV of repositories, clone them, push them to new
# remotes, and then sync LFS objects. This alleviates the manual task of making
# sure LFS objects have been transferred

# Scripting assumes:
# - Git is installed
# - Git LFS is installed


#-------------------------------------#
# Functions used in parameter builder #
#-------------------------------------#

# generate an example file
Example() {
  EXAMPLE_FILE="example.csv";
  EXAMPLE_LINE="https://<your-git-server>/<repository>.git";
  EXAMPLE_LINE="${EXAMPLE_LINE},https://github.com/<owner>/<repository>.git"
  echo -e "${EXAMPLE_LINE}\n" > ${EXAMPLE_FILE};
  echo -e "\nExample file created at $(pwd)/${EXAMPLE_FILE}\n";
}

# print out usage
Usage()
{
  cat <<EOM
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

EOM
  exit 0
}

#------------------#
# Global Variables #
#------------------#

CLEAN=false;
FORCE=false;
INPUT_DATA="";
LOG=true;
PARAMS="";
REPOS_D="repos";
SOURCE_D="$(pwd)";
TIMESTAMP=$(date +%y%m%d%H%M%S);
TIMESTAMP_F="${SOURCE_D}/${TIMESTAMP}.log";
TOTAL_REPOS=0;

#---------------------------------------#
# Get parameters from script invocation #
#---------------------------------------#

while (( "$#" )); do
  case "$1" in
    -c|--clean)
      CLEAN=true;
      shift
      ;;
    -e|--example)
      Example;
      exit 0
      ;;
    -f|--force)
      FORCE=true;
      shift
      ;;
    -h|--help)
      Usage;
      ;;
    -i|--input)
      INPUT_CSV=$2
      shift 2
      ;;
    -n|--no-log)
      LOG=false;
      shift
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
  PARAMS="$PARAMS $1"
  shift
  ;;
  esac
done

#----------------------------------------#
# main processing functions of scripting #
#----------------------------------------#

# removes data after process completes
Cleanup() {
  if [ ${CLEAN} = true ]; then
    Output "Cleaning up repository data...";
    rm -rf ${SOURCE_D}/${REPOS_D};
  fi
}

# uses the INPUT_DATA global and runs through the process
CloneAndPush() {

  # validate data one more time
  if [ -z "${INPUT_DATA}" ]; then
    Output "Something went wrong. There's no repositories to process." 1;
  fi

  # loop repos in csv
  I=1;
  while IFS="," read -r SOURCE DESTINATION; do

    # skip potentially empty lines
    if [ ! -z "${SOURCE}" ]; then

      REPOS_D_ABS=${SOURCE_D}/${REPOS_D}

      cd ${REPOS_D_ABS}

      # make sure repo doesn't exist
      REPO_D="${REPOS_D_ABS}/${SOURCE##*/}";
      if [ -d ${REPO_D} ]; then
        Output "${I} of ${TOTAL_REPOS}: cleaning existing repo...";
        ExecAndLog "rm -rf ${REPO_D}";
      fi

      # clone the repo
      Output "${I} of ${TOTAL_REPOS}: cloning source repo...";
      ExecAndLog "git clone --bare ${SOURCE}";

      # change directory to repo
      cd ${REPOS_D_ABS}/${SOURCE##*/};

      # get LFS objects
      Output "${I} of ${TOTAL_REPOS}: getting any LFS objects...";
      ExecAndLog "git lfs fetch origin --all";

      # change origin remote url
      Output "${I} of ${TOTAL_REPOS}: adding new remote...";
      ExecAndLog "git remote add destination ${DESTINATION}";

      # determine if force is required
      FORCE_CMD="";
      if [ ${FORCE} = true ]; then
        FORCE_CMD="--force";
      fi

      # push
      Output "${I} of ${TOTAL_REPOS}: pushing to new remote...";
      ExecAndLog "git push --mirror destination ${FORCE_CMD}"

      # sync LFS objects
      Output "${I} of ${TOTAL_REPOS}: pushing LFS objects...";
      ExecAndLog "git lfs push destination --all";

      I=$((I+1));
    fi
  done <<< "${INPUT_DATA}"

}

# loads the contents of the CSV file
LoadCSV() {
  Output "Loading CSV file '${INPUT_CSV}'...";

  if [[ $(tail -c1 "${INPUT_CSV}" | wc -l) -le 0 ]]; then
    Output "Fixing missing new line at end of CSV file...";
    echo "" >> ${INPUT_CSV}
  fi

  # get CSV file into var
  INPUT_DATA=$(<${INPUT_CSV});

  # get total number of repos
  while IFS= read -r LINE; do
    if [[ ! -z "${LINE}" ]]; then
      TOTAL_REPOS=$((TOTAL_REPOS+1));
    fi
  done <<< "${INPUT_DATA}"

  if [ ${TOTAL_REPOS} -le 0 ]; then
    Output "Error: No repositories were provided in the CSV file." 1;
  fi
  Output "${TOTAL_REPOS} repositories to process.";
}

# helper to output to CLI and log
Output() {
  ERROR=false
  TYPE=""
  if [ ! -z "${2}" ] && [ ${2} -gt 0 ]; then
    TYPE="[ERROR]"
    ERROR=true
  fi
  Log "$(date '+%Y-%m-%d %H:%M:%S') ${TYPE} ${1}";
  if [ ${ERROR} = true ]; then echo ""; exit ${2}; fi
}

ExecAndLog() {
  if [ ${LOG} = true ]; then
    ${1} 2>&1 | tee -a ${TIMESTAMP_F};
  else
    ${1} 2>&1;
  fi
}

# log helper method
Log() {
  if [ ${LOG} = true ]; then
    echo "${1}" | tee -a ${TIMESTAMP_F};
  else
    echo "${1}";
  fi
}

# pre-process step for setting things up
PreProcess() {
  # create log if needed
  if [ ${LOG} = true ]; then
    echo -n "" > ${TIMESTAMP_F};
  fi
  # create repo folder
  mkdir -p ${REPOS_D}
}

# run through all processees for script
Process() {
  PreProcess;
  Validate;
  LoadCSV;
  CloneAndPush;
  Cleanup;
}

# validate all inputs and dependencies
Validate() {
  # check inputs
  if [ -z "${INPUT_CSV}" ]; then
    Output "Error: Please provide a CSV file containing a \
list of repositories with -i. Use -e to generate an example." 1;
  elif [ ! -f "${INPUT_CSV}" ]; then
    Output "Error: File at path '${INPUT_CSV}' does not exist." 1;
  fi
  # check dependencies
  if ! [ -x "$(command -v git)" ]; then
    Output 'Error: Git is not installed. Please see https://git-scm.com/downloads' 1;
  fi
  # check dependencies
  if ! [ -x "$(command -v git-lfs)" ]; then
    Output 'Error: Git LFS is not installed. Please see https://git-lfs.com' 1;
  fi
}

#-------------------#
# Script Invocation #
#-------------------#

echo "";
echo "#-------------------------------#";
echo "# Git-to-Git Migration with LFS #";
echo "#-------------------------------#";
echo "";
Process;
echo "";