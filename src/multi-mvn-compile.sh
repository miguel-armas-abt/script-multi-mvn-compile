#!/bin/bash
set -e

source ./commons.sh
source ./../variables.env

compile_component() {
  local project_name=$1
  local absolute_path=$2

  project_path="$absolute_path\\$project_name"
  local original_dir
  original_dir="$(pwd)"

  export JAVA_HOME=$JAVA_HOME
  export MAVEN_HOME=$MAVEN_HOME
  export MAVEN_REPOSITORY=$MAVEN_REPOSITORY

  cd "$project_path"
  command="mvn clean install -Dmaven.repo.local=\"$MAVEN_REPOSITORY\" -Dstyle.color=always"

  print_title "$project_name"
  print_log "$project_path"
  print_log "$command"

  eval "$command"
  cd "$original_dir"
}

iterate_csv_records() {
  firstline=true
  while IFS=',' read -r project_name absolute_path || [ -n "$project_name" ]; do
    # Ignore headers
    if $firstline; then
        firstline=false
        continue
    fi

    # Ignore comments
    if [[ $project_name != "#"* ]]; then
      compile_component "$project_name" "$absolute_path"
    fi

  done < <(sed 's/\r//g' "$PROJECTS_CSV")
}

iterate_csv_records