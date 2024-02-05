[10:47 AM] Nguyen (WORK), Nghia
#!/usr/bin/env bash
 
# Output from this script looks a bit messy code-wise due to

# colorizing it.  There are inline comments to annotate.
 
export PS4='line $LINENO: '

USER=$1

main () #{{{

{

  setup

  check_user

  create_dir

  create_link

} #}}}
 
create_dir () #{{{

{

  # check for the existance of the data directory

  # check the permissions (do not change in case the permissions are different for a reason)

  # if needed, create it and set permissions

  # show the directory as output

  if [ -d /data/$USER ]; then

    printf "\n%s[%s/data/%s$USER%s]%s data directory already exists%s\n" \

      ${cyan} ${green} ${magenta} ${cyan} ${yellow} ${reset}

    check_permissions=$(stat -c %a /data/$USER)

    if [ $check_permissions -ne 755 ]; then

      printf "%scheck permissions; they are %s[%s$check_permissions%s]%s instead of %s[%s755%s]%s\n\n" \

        ${yellow} ${cyan} ${red} ${cyan} ${yellow} ${cyan} ${green} ${cyan} ${reset}

    fi

  else

    printf "\n%s[%s/data/%s$USER%s]%s creating data directory%s\n" \

      ${cyan} ${green} ${magenta} ${cyan} ${magenta} ${reset}

    mkdir /data/$USER

    chown $USER:$USER /data/$USER

    chmod 755 /data/$USER

  fi

  print_dir=$(ls -ld /data/$USER)

  printf "%s$print_dir%s\n" \

    ${blue} ${reset}
 
  # also check for and create as needed a .conda directory

  if [ -d /data/$USER/.conda ]; then

    printf "\n%s[%s/data/%s$USER%s/.conda%s]%s .conda directory already exists%s\n" \

      ${cyan} ${green} ${magenta} ${green} ${cyan} ${yellow} ${reset}

  else

    printf "\n%s[%s/data/%s$USER%s/.conda%s]%s creating .conda directory%s\n" \

      ${cyan} ${green} ${magenta} ${green} ${cyan} ${magenta} ${reset}

    mkdir /data/$USER/.conda

    chown $USER:$USER /data/$USER/.conda

  fi

  print_dir=$(ls -ld /data/$USER/.conda)

  printf "%s$print_dir%s\n\n" \

    ${blue} ${reset}

} #}}}
 
create_link () #{{{

{

  # check for the existance of the link in the user's home directory

  # make sure it is to the "right" one

  # if needed, create the link and change ownership

  # show the link as output

  if [ ! -L /home/$USER/data_${USER} ]; then

    printf "%s[%s/home/%s$USER%s/data%s]%s creating link%s\n" \

      ${cyan} ${green} ${magenta} ${green} ${cyan} ${magenta} ${reset}

    cd /home/$USER

    ln -s /data/$USER data_${USER}

    chown -h $USER:$USER /home/$USER/data_${USER}

  else

    #linked_dir=$(readlink -n /home/$USER/data_${USER})

    #echo "($linked_dir) ($print_dir)"

    if [ "$(readlink -n /home/$USER/data_${USER})" -ef "$(ls -d /data/$USER)" ]; then

      #echo "they match"

      printf "%s[%s/home/%s$USER%s/data%s]%s link already exists%s\n" \

        ${cyan} ${green} ${magenta} ${green} ${cyan} ${yellow} ${reset}

    else

      printf "%s[%s/home/%s$USER%s/data%s]%s link already exists but to something else\n" \

        ${cyan} ${green} ${magenta} ${green} ${cyan} ${red}

    fi

    #chown -h $USER:$USER /home/$USER/data_${USER}

  fi

  print_link=$(ls -ld /home/$USER/data_${USER})

  printf "%s$print_link%s\n\n" \

    ${blue} ${reset}
 
  # also check for and create as needed a .conda link

  if [ ! -L /home/$USER/.conda ]; then

    printf "%s[%s/home/%s$USER%s/.conda%s]%s creating .conda link%s\n" \

      ${cyan} ${green} ${magenta} ${green} ${cyan} ${magenta} ${red}

    cd /home/$USER

    ln -s /data/$USER/.conda /home/$USER

    chown -h $USER:$USER /home/$USER/.conda

  else

    if [ "$(readlink -n /home/$USER/.conda)" -ef "$(ls -d /data/$USER/.conda)" ]; then

      printf "%s[%s/home/%s$USER%s/.conda%s]%s .conda link already exists%s\n" \

        ${cyan} ${green} ${magenta} ${green} ${cyan} ${yellow} ${reset}

    else

      printf "%s[%s/home/%s$USER%s/.conda%s]%s .conda link already exists but to something else\n" \

        ${cyan} ${green} ${magenta} ${green} ${cyan} ${red}

    fi

  fi

  print_link=$(ls -ld /home/$USER/.conda)

  printf "%s$print_link%s\n\n" \

    ${blue} ${reset}

} #}}}
 
check_user () #{{{

{

  # make sure this user exists at the system level

  check=$(id $USER 2>&1)

  if [[ "$check" =~ "no such user" ]]; then

    printf "\n%sno such user %s[%s$USER%s]%s\n\n" \

      ${yellow} ${cyan} ${magenta} ${cyan} ${reset}

    exit 1

  fi

} #}}}
 
setup () #{{{

{

  # define colors to be used for printf output

     cyan=`tput setab 0; tput setaf 6; tput bold`

  magenta=`tput setab 0; tput setaf 5; tput bold`

     blue=`tput setab 0; tput setaf 4; tput bold`

   yellow=`tput setab 0; tput setaf 3; tput bold`

    green=`tput setab 0; tput setaf 2; tput bold`

      red=`tput setab 0; tput setaf 1; tput bold`

    reset=`tput sgr0`

  # because of permissions needed, this needs to be run as root

  ( [ $UID -ne 0  ] || [ $EUID -ne 0  ] ) \

    && printf "\n%sThis must be run as %sroot%s.\n\n" \

        ${yellow} ${red} ${reset} \

    && exit

  # check for the user parameter

  ( [ -z "$USER" ] ) \

    && printf "\n%sPlease supply a user %s(%s$0 %suser%s)%s\n\n" \

        ${yellow} ${cyan} ${green} ${magenta} ${cyan} ${reset} \

    && exit

} #}}}
 
main