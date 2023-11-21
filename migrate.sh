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
  EXAMPLE_LINE="https://<your-git-server>/<repository-path>";
  EXAMPLE_LINE="${EXAMPLE_LINE},https://github.com/<owner>/<repository-name>"
  echo -e "${EXAMPLE_LINE}\n" >> ${EXAMPLE_FILE};
  echo -e "\nExample file created at $(pwd)/${EXAMPLE_FILE}\n";
}

# print out usage
Usage()
{
  cat <<EOM
Usage: migrate.sh [options]

Options:
     -h, --help    : Show script help
     -e, --example : Generate example inputer CSV file
     -i, --input   : CSV file containing repository URL list
     -f, --force   : Whether to force push in Git

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

TIMESTAMP_F="$(date +%y%m%d%H%M%S).log"
PARAMS=""
INPUT_DATA=""

#---------------------------------------#
# Get parameters from script invocation #
#---------------------------------------#

while (( "$#" )); do
  case "$1" in
    -h|--help)
      Usage;
      ;;
    -i|--input)
      INPUT_CSV=$2
      shift 2
      ;;
    -e|--example)
      Example;
      exit 0
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
  TOTAL_REPOS=0;
  while IFS= read -r LINE; do
    if [[ ! -z "${LINE}" ]]; then
      TOTAL_REPOS=$((TOTAL_REPOS+1));
    fi
  done <<< "${INPUT_DATA}"

  if [ ${TOTAL_REPOS} -le 0 ]; then
    Output "Error: No repositories were provided in the CSV file.";
    exit 1;
  fi
  Output "${TOTAL_REPOS} repositories to process.";
}

# helper to output to CLI and log
Output() {
  echo "${1}" | tee -a ${TIMESTAMP_F}; 
}

# pre-process step for setting things up
PreProcess() {
  echo -n "" > ${TIMESTAMP_F};
}

# run through all processees for script
Process() {
  PreProcess;
  ValidateInput;
  LoadCSV;
}

# validate all inputs and dependencies
ValidateInput() {
  # check inputs
  if [[ -z "${INPUT_CSV}" ]]; then
    Output "Error: Please provide a CSV file containing a \
list of repositories with -i. Use -e to generate an example."
    exit 1;
  elif [[ ! -f "${INPUT_CSV}" ]]; then
    Output "Error: File at path '${INPUT_CSV}' does not exist.";
    exit 1;
  fi
}

#-------------------#
# Script Invocation #
#-------------------#

Process;