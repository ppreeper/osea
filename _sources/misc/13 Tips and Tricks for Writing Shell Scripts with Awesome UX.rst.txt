====== 13 Tips and Tricks for Writing Shell Scripts with Awesome UX ======

Let’s make .sh great again

How many times have you ran some ./script.sh, it runs, some output appears, but you have no idea what it just did? That’s bad scripting UX at play and is what I will be covering in this short piece — how to write shell scripts with a more pleasant developer UX.

There’s a certain irony when writing scripts. Unlike code destined for products where your end-user is usually non-technical (sweep it under the bed! they won’t know!), code in scripts are a different monster, they’re for developers, by developers.

This results in some problems:

  - **Really, really messy scripts** — I get it, we’re all engineers, we can read code, but spare a thought for us who aren’t that proficient at shell scripts (we’ll spare you too when we write our code).
  - **Wall-of-text logs and error dumps** — just because we’re engineers too doesn’t mean we know what you’ve done/or are doing.
  - **Screwing up without cleaning up** — yes, we can go through your script and undo the changes manually, but are you really making people who trusted your script, do that?

So, without further ado, let’s get into some ways we can write better shell scripts for ourselves and others. All examples herein have been considered with a POSIX compliant basic dash shell (''#!/bin/sh'') in mind since it’s the most commonly available.

===== The TL;DR =====

  - Provide a --help flag
  - Sanity check for availability of all commands
  - Work independently of current working directory
  - Design how input is read: environment vs flags
  - Print everything you’re doing to the system…
  - …But provide a--silent option if necessary…
  - And turn the display back on after silencing
  - Indicate progress with animations
  - Colour code your output
  - Do not prolong the life of your script unnecessarily
  - Clean up after yourself
  - Exit with different error codes
  - Print a new line to bid farewell

===== Provide a --help flag =====

With binaries that are installed onto your system, we have the handy man page. The same is not true for scripts, hence it is usually always useful to include a ''-h'' or ''--help'' flag that will dump usage information about the script. This also helps to have inline documentation of the script should other engineers have to modify your script:

<code bash>
#!/bin/sh
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- '...help...\n';
  exit 0;
fi;
</code>

What that does is count the length of the arguments (''${#@} -ne 0'') and proceed with checking for the ''--help'' flag only if it equals 0. The next condition checks if the string "''--help''" is present. The first condition is required so that help doesn’t print on a no arguments condition.

===== Sanity check for availability of all commands =====

Scripts usually call other scripts or binaries. When dealing with commands that may not be present on all systems, check for them first before proceeding. You can use the command, ''command -v binary-name'', to do this and check for a non-zero exit code. If a command is not available, it is also useful to indicate how the end-user might acquire the binary:

<code bash>
#!/bin/sh
_=$(command -v docker);
if [ "$?" != "0" ]; then
  printf -- 'You don\'t seem to have Docker installed.\n';
  printf -- 'Get it: https://www.docker.com/community-edition\n';
  printf -- 'Exiting with code 127...\n';
  exit 127;
fi;
= ...
</code>

===== Work independently of current working directory =====

No one likes a script which breaks just because it is triggered from a different directory. To solve this problem, use only absolute paths (''/path/to/something'') and paths relative to the script (demonstrated below).

You can reference the current path of the script using dirname $0:

<code bash>
#!/bin/sh
CURR_DIR="$(dirname $0);"
printf -- 'moving application to /opt/app.jar';
mv "${CURR_DIR}/application.jar" /opt/app.jar;
</code>

===== Design how input is read: environment vs flags =====

There are two ways of getting input into a script: via environment variables, and via option flags/parameters. As a rule of thumb, use environment variables for values which do not affect the behaviour of your script, and use script parameters for values which will trigger different flows in your script.

Variables which don’t affect the behaviour of your script are things like access tokens and IDs:

<code bash>
#!/bin/sh
= do this
export AWS_ACCESS_TOKEN='xxxxxxxxxxxx';
./provision-everything
= and not
./provisiong-everything --token 'xxxxxxxxxxx';
</code>

Variables which may affect your script are parameters affecting things like number of instances we should run, asynchronous/synchronous, background/foreground //et cetera//:

<code bash>
#!/bin/sh
= do this
./provision-everything --async --instance-count 400
= and not
INSTANCE_COUNT=400 ASYNC=true ./provision-everything
</code>

===== Print everything you’re doing to the system… (cont’d) =====

Scripts generally perform stateful changes to a system. However since we do not know when a user may send a ''SIGINT'' to us or when an error may cause the script to terminate unexpectedly, it is useful to print whatever you are doing to the terminal so that the user can retrace the steps without having to open the script:

<code bash>
#!/bin/sh
printf -- 'Downloading required document to ./downloaded... ';
wget -o ./downloaded https://some.site.com/downloaded;
printf -- 'Moving ./downloaded to /opt/downloaded...';
mv ./downloaded /opt/;
printf -- 'Creating symlink to /opt/downloaded...';
ln -s /opt/downloaded /usr/bin/downloaded;
</code>

===== (cont’d)… But provide a --silent option if necessary… (cont’d) =====

Some scripts are meant to have their outputs piped to other scripts. While all scripts should be able to run alone, it is occasionally useful to have them be able to just print a result that can be piped to another script. Implementing a silent flag using ''stty -echo'' helps with this:

<code bash>
#!/bin/sh
if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
  stty -echo;
fi;
= ...
= before point of intended output:
stty +echo && printf -- 'intended output\n';
= silence it again till end of script
stty -echo;
= ...
stty +echo;
exit 0;
</code>

===== (cont’d)… And turn the display back on after silencing =====

If you’ve silenced your script using ''stty -echo'', should a fatal error happen, your script will terminate without restoring the terminal output. Leaving the user with a useless terminal. Prevent this from happening by using ''trap''s which allow you to capture ''SIGINT'' and other operating level signals, and do a ''stty echo'':

<code bash>
#!/bin/sh
error_handle() {
  stty echo;
}
if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
  stty -echo;
  trap error_handle INT;
  trap error_handle TERM;
  trap error_handle KILL;
  trap error_handle EXIT;
fi;
= ...
</code>

===== Indicate progress with animations =====

Some commands take time to run to completion, and not all scripts are kind enough to proffer a progress bar. When making users wait for an asynchronous task to complete, provide a way for your end-use tr to observe that the script is still running. You can do this by printing a period after every iteration of your while loop:

<code bash>
#!/bin/sh
printf -- 'Performing asynchronous action..';
./trigger-action;
DONE=0;
while [ $DONE -eq 0 ]; do
  ./async-checker;
  if [ "$?" = "0" ]; then DONE=1; fi;
  printf -- '.';
  sleep 1;
done;
printf -- ' DONE!\n';
</code>

Alternatively, you could do [[http://mywiki.wooledge.org/BashFAQ/034|something more fancy like a spinner]].

===== Colour code your output =====

When calling other binaries or scripts from your script, colour code them to provide contrast between which output is from where. This lets us avoid having to slowly decipher the output we are looking for through the black and white.

Ideally, your script should output white/default (it’s the foreground process), child processes should output grey (usually not needed unless things screw up), success should be denoted with green, failure, red, and warnings in yellow.

<code bash>
#!/bin/sh
printf -- 'doing something... \n';
printf -- '\033[37m someone else's output \033[0m\n';
printf -- '\033[32m SUCCESS: yay \033[0m\n';
printf -- '\033[33m WARNING: hmm \033[0m\n';
printf -- '\033[31m ERROR: fubar \033[0m\n';
</code>

Use ''\033[Xm'' where ''X'' is the colour code. You may see other examples using ''\e'' instead of ''\033'', but be warned that ''\e'' doesn’t work on all UNIX systems.

{{https://cdn-images-1.medium.com/max/800/1*u3_gKCiRXHLV_y7fL_wmZw.png|An example of what it looks like when properly done.}}

Check out a [[https://misc.flogisoft.com/bash/tip_colors_and_formatting|full list of all the colors/modifiers you can use in .sh]].

===== Do not prolong the life of your script unncessarily =====

There exists a ''set -e'' directive command which indicates that from that point forward, all errors will trigger an ''EXIT'' signal. The converse is ''set +e'' which configures the script to push on regardless of any errors.

If your script is statefully procedural (each subsequent steps relies on the previous step to complete), do us a favour and do a ''set -e'' so that the script exits on the first error. If all commands should be run (rarely happens), then let it be ''set +e''.

<code bash>
#!/bin/sh
set +e;
./script-1;
./script-2; # does not depend on ./script-1
./script-3; # does not depend on ./script-2
set -e;
./script-4;
./script-5; # depends on success of ./script-4
= ...
</code>

===== Clean up after yourself =====

Most scripts don’t do clean-ups to the point we hardly expect scripts to clean up after screwing up. Proper error handling in shell scripts is a rarity but would be super helpful and time-saving. As demonstrated above to return the ''stty'' to normal, the ''trap'' command can also help us by cleaning up:

<code bash>
#!/bin/sh
handle_exit_code() {
  ERROR_CODE="$?";
  printf -- "an error occurred. cleaning up now... ";
  # ... cleanup code ...
  printf -- "DONE.\nExiting with error code ${ERROR_CODE}.\n";
  exit ${ERROR_CODE};
}
trap "handle_exit_code" EXIT;
</code>

===== Exit with different error codes =====

In the large majority of shell scripts, exit 0 means it successfully executed, exit 1 means an error happened. Make your scripts easier to debug by exiting with numbers that are a 1–1 mapping to possible errors.

<code bash>
#!/bin/sh
= ...
if [ "$?" != "0" ]; then
  printf -- 'X happened. Exiting with status code 1.\n';
  exit 1;
fi;
= ...
if [ "$?" != "0" ]; then
  printf -- 'Y happened. Exiting with status code 2.\n';
  exit 2;
fi;
</code>

As an added benefit, your script will now be usable by other scripts who can decipher errors based on the exit code of your script.

===== Print a new line to bid farewell =====

If you’re following decent shell scripting practices, you’ll be using ''printf'' instead of ''echo'' (which has behavioural differences across different systems). A downside in doing this is that ''printf'' does not automatically add a new line for you after each command. This results in my terminal ending up like this:

{{https://cdn-images-1.medium.com/max/800/1*TLN6Vr3NC6dJApqOc_VVTw.png|That’s just plain… Urgh.}}

Not cool. Give your users a new line with a simple:

<code bash>
#!/bin/sh
= ... your awesome script ...
printf -- '\n';
exit 0;
</code>

So that we now get:

{{https://cdn-images-1.medium.com/max/800/1*Lkg7b2YTMDejeKDCQVUyMg.png|Much better}}

They’ll thank you for it.

So that roughly sums up some quick and easy tips to make your shell scripts easier to work with, debug, and use.


