[10:48 AM] Nguyen (WORK), Nghia
#!/usr/bin/env bash

export PS4='line $LINENO: '

#set -x
 
[[ $# -lt 3 ]] && \

  cmsh -c "user ; ls" | awk '{print $2, $1}' | sort -n | grep --color=never ^2 && \

  echo \

  echo "$0 ULID UID PASSWORD" && \

  echo "e.g." && \

  echo "$0 shagberg 28940 password@123" && \

  exit
 
setup () #{{{

{

     cyan=`tput setab 0; tput setaf 6; tput bold`

  magenta=`tput setab 0; tput setaf 5; tput bold`

     blue=`tput setab 0; tput setaf 4; tput bold`

   yellow=`tput setab 0; tput setaf 3; tput bold`

    green=`tput setab 0; tput setaf 2; tput bold`

      red=`tput setab 0; tput setaf 1; tput bold`

  ( [ $UID -ne 0  ] || [ $EUID -ne 0  ] ) \

    && printf "\n%sThis must be run as %sroot%s.\n\n" \

        "${yellow}" "${red}" "${reset}" \

    && exit

  ( [ -z "$USER" ] ) \

    && printf "\n%sPlease supply a user %s(%s$0 %suser%s)%s\n\n" \

        "${yellow}" "${cyan}" "${green}" "${magenta}" "${cyan}" "${reset}" \

    && exit

} #}}}
 
reminder () #{{{

{

  printf "\n\n%sRemember to run the %s[%screate_data_dir.sh%s]%s script on the %slogin node%s.\n\n" \

    "${yellow}" "${cyan}" "${green}" "${cyan}" "${yellow}" "${red}" "${reset}"

} #}}}
 
make_user () #{{{

{

  cmsh -c " user; add $USER ; commit $USER "

  cmsh -c " user use $USER ; set id $ID ; commit $USER "

  cmsh -c " group use $USER ; set id $ID ; commit $USER "

  cmsh -c " user use $USER ; set groupid $ID ; commit $USER"

  cmsh -c " user use $USER ; set password $PASSWORD ; commit $USER"

} #}}}
 
fix_home_dir () #{{{

{

  check=$(stat -c %u "/home/$USER")

  if [[ "$check" -ne "$ID" ]]; then

    sudo chown -R $ID:$ID /home/$USER

    sudo chmod 700 /home/$USER

  fi

} #}}}
 
make_home_dir () #{{{

{

  if [[ ! -d "/home/$USER" ]]; then

    echo "the home directory does not exist; do not create manually; must use cmsh"

    exit

  fi

} #}}}
 
main () #{{{

{

  setup

  USER=$1

  ID=$2

  PASSWORD=$3

  cmsh -c "user show $USER" > /dev/null

  check=$?

  if [[ ! $check -eq 0 ]]; then

    get_id=$(cmsh -c "user list" | grep $ID | awk '{print $1}')

    if [[ "$get_id" == "" ]]; then

      echo "making user ($USER) with ID ($ID)"

      make_user "${@}"

      make_home_dir "${@}"

      fix_home_dir "${@}"

    else

      echo "user ($get_id) is already using ($ID)"

      make_home_dir "${@}"

      fix_home_dir "${@}"

    fi

  else

    get_id=$(cmsh -c "user get $USER id")

    if [[ $get_id == $ID ]]; then

      echo "user ($USER) already exists with ID ($ID)"

      make_home_dir "${@}"

      fix_home_dir "${@}"

      exit

    else

      echo "user ($USER) already exists but ID is ($get_id)... you supplied ($ID)"

      exit

    fi

  fi

  reminder

} #}}}
 
main "$@"