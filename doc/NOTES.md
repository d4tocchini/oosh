https://superuser.com/questions/91881/invoke-zsh-having-it-run-a-command-and-then-enter-interactive-mode-instead-of

    if [[ $1 == eval ]]
    then
        "$@"
    set --
    fi
to .zshrc, then call zsh with
    zsh -is eval 'your shell command here'

#- https://www.systutorials.com/docs/linux/man/1-zsh-lovers/
#- https://www.systutorials.com/docs/linux/man/1-zshmodules/



# foreach in one line of shell
  $ for f (*) print -r -- $f


# keep specified number of child processes running until entire task finished
  $ zsh -c 'sleep 1 & sleep 3 & sleep 2& print -rl -- $jobtexts'

# Synonymic to ``ps ax | awk '{print $1}''' (under Linux)
  $ print -l /proc/*/cwd(:h:t:s/self//)
# Get the PID of a process (without ``ps'', ``sed'', ``pgrep'', ..
# (under Linux)
  $ pid2 () {
  >   local i
  >   for i in /proc/<->/stat
  > do
  >   [[ "$(< $i)" = *\((${(j:|:)~@})\)* ]] && echo $i:h:t
  > done
  > }

# global
    alias -g ...='../..'
    alias EG='|& egrep'

# functions with any char !

# test if a parameter is numeric
  $ if [[ $1 == <-> ]] ; then
         echo numeric
    else
         echo non-numeric
    fi

# brace expansion - example
  $ X=(A B C)
  $ Y=(+ -)
  $ print -r -- $^X.$^Y
  A.+ A.- B.+ B.- C.+ C.-

# random numbers
  $ echo $[${RANDOM}%1000]     # random between 0-999
  $ echo $[${RANDOM}%11+10]    # random between 10-20
  $ echo ${(l:3::0:)${RANDOM}} # N digits long (3 digits)
# random array element
  $ FILES=( .../files/* )
  $ feh $FILES[$RANDOM%$#FILES+1]

#FS
## Show newest directory
  $ ls -ld *(/om[1])
## Show me all the .c files for which there doesn't exist a .o file.
  $ print *.c(e_'[[ ! -e $REPLY:r.o ]]'_)
# All files in /var/ that are not owned by root
  $ ls -ld /var/*(^u:root)
# All files for which the owner hat read and execute permissions
  $ echo *(f:u+rx:)
# The same, but also others dont have execute permissions
  $ echo *(f:u+rx,o-x:)
# Fetch the newest file containing the string 'fgractg*.log' in the
# filename and contains the string 'ORA-' in it
  $ file=(fgractg*.log(Nm0om[1]))
  $ (($#file)) && grep -l ORA- $file
  # without Zsh
  $ files=$( find . -name . -o -prune -name 'fgractg*>log' -mtime 0 -print )
  > if [ -n "$files" ]; then
  >    IFS='
  > '
  > set -f
  > file=$(ls -td $files | head -1)
  > grep -l ORA- "$file"
  > fi
# Remove zero length and .bak files in a directory
  $ rm -i *(.L0) *.bak(.)
# Finding files which does not contain a specific string
  $ print -rl file* | comm -2 -3 - <(grep -l string file*)'
  $ for f (file*(N)) grep -q string $f || print -r $f'
# Matching all files which do not have a dot in filename
  $ ls *~*.*(.)
# load all available modules at startup
  $ typeset -U m
  $ m=()
  $ for md ($module_path) m=($m $md/**/*(*e:'REPLY=${REPLY#$md/}'::r))
  $ zmodload -i $m
# Rename all files within a directory such that their names get a numeral
# prefix in the default sort order.
  $ i=1; for j in *; do mv $j $i.$j; ((i++)); done
  $ i=1; for f in *; do mv $f $(echo $i | \
    awk '{ printf("%03d", $0)}').$f; ((i++)); done
  $ integer i=0; for f in *; do mv $f $[i+=1].$f; done

# Find (and print) all symbolic links without a target within the current
# dirtree.
  $ $ file **/*(D@) | fgrep broken
  $ for i in **/*(D@); [[ -f $i || -d $i ]] || echo $i
  $ echo **/*(@-^./=%p)
  $ print -l **/*(-@)

# Match file names containing only digits and ending with .xml (require
# *setopt kshglob*)
  $ ls -l [0-9]##.xml
  $ ls -l <0->.xml

# If `foo=23'', then print with 10 digit with leading '0'.
  $ foo=23
  $ print ${(r:10::0:)foo}

# find the name of all the files in their home directory that have
# more than 20 characters in their file names
  print -rl $HOME/${(l:20::?:)~:-}*

# Save arrays
  $ print -r -- ${(qq)m} > $nameoffile      # save it
  $ eval "m=($(cat -- $nameoffile)"            # or use
  $ m=("${(@Q)${(z)"$(cat -- $nameoffile)"}}") # to restore it

# get a "ls -l" on all the files in the tree that are younger than a
# specified age (e.g "ls -l" all the files in the tree that where
# modified in the last 2 days)
  $ ls -tld **/*(m-2)
# This will give you a listing 1 file perl line (not à la ls -R).
# Think of an easy way to have a "ls -R" style output with
# only files newer than 2 day old.
  $ for d (. ./**/*(/)) {
  >   print -r -- $'\n'${d}:
  >   cd $d && {
  >       l=(*(Nm-2))
  >       (($#l)) && ls -ltd -- $l
  >       cd ~-
  >   }
  > }
# If you also want directories to be included even if their mtime
# is more than 2 days old:
  $ for d (. ./**/*(/)) {
  >   print -r -- $'\n'${d}:
  >   cd $d && {
  >      l=(*(N/,m-2))
  >      (($#l)) && ls -ltd -- $l
  >      cd ~-
  >   }
  > }
# And if you want only the directories with mtime < 2 days to be listed:
  $ for d (. ./**/*(N/m-2)) {
  >   print -r -- $'\n'${d}:
  >   cd $d && {
  >      l=(*(Nm-2))
  >      (($#l)) && ls -ltd -- $l
  >      cd ~-
  >   }
  > }


# copy a directory recursively without data/files
  $ dirs=(**/*(/))
  $ cd -- $dest_root
  $ mkdir -p -- $dirs
# or without zsh
  $ find . -type d -exec env d="$dest_root" \
    sh -c ' exec mkdir -p -- "$d/$1"' '{}' '{}' \;

# List all plain files that do not have extensions listed in `fignore'
  $ ls **/*~*(${~${(j/|/)fignore}})(.)
  # see above, but now omit executables
  $ ls **/*~*(${~${(j/|/)fignore}})(.^*)

# Print out files that dont have extensions (require *setopt extendedglob*
# and *setopt dotglob*)
  $ printf '%s\n' ^?*.*

# List files in reverse order sorted by name
  $ print -rl -- *(On)
  or
  $ print -rl -- *(^on)

# Show/Check whether a option is set or not. It works both with $options as
# with $builtins
  $ echo $options[correct]
  off
  $ $options[zle]
  on

# zsh/zpty

# zsh/net/socket

        # ``-l'': open a socket listening on filename
        # ``-d'': argument will be taken as the target file descriptor for the
        #         connection
        # ``3'' : file descriptor. See ``A User's Guide to the Z-Shell''
        #         (3.7.2: File descriptors)
        $ zmodload zsh/net/socket
        $ zsocket -l -d 3
        # ``-a'': accept an incoming connection to the socket
        $ zsocket -a -d 4 3
        $ zsocket -a -d 5 3 # accept a connection
        $ echo foobar >&4
        $ echo barfoo >&5
        $ 4>&- 5>&- 3>&
# Ping all the IP addresses in a couple of class C's or all hosts
# into /etc/hosts
  $ for i in {1..254}; do ping -c 1 192.168.13.$i; done
  or
  $ I=1
  $ while ( [[ $I -le 255 ]] ) ; do ping -1 2 150.150.150.$I; let I++; done
  or
  $ for i in $(sed 's/#.*//' > /etc/hosts | awk '{print $2}')
  : do
  :    echo "Trying $i ... "
  :    ping -c 1 $i ;
  :    echo '============================='
  : done


# Redirect STDERR to a command like xless without redirecting STDOUT as well.
  $ foo 2>>(xless)
# but this executes the command asynchronously. To do it synchronously:
  $ { { foo 1>&3 } 2>&1 | xless } 3>&1


# Download with LaTeX2HTML  created Files (for example the ZSH-Guide):
  $ for f in http://zsh.sunsite.dk/Guide/zshguide{,{01..08}}.html; do
  >     lynx -source $f >${f:t}
  > done