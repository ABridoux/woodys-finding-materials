#!/bin/zsh
# installHelper v1.0.1
# (Alexis Bridoux) based on Marc Thielemann script:  https://github.com/autopkg/rtrouton-recipes/blob/master/Privileges/Scripts/postinstall

# ---- Colors ----
COLOR_FAILURE='\e[38;5;196m'
COLOR_SUCCESS='\e[38;5;70m'
COLOR_NC='\e[0m' # No Color

function print_error {
	>&2 echo -e  "${COLOR_FAILURE}$1${COLOR_NC}"
	exit 1
}

function print_success {
	echo -e  "${COLOR_SUCCESS}$1${COLOR_NC}"
}
# ---------

# ---- Constants ----
CURRENT_DIR=$(pwd)

HELPER="com.abridoux.Scriptex.helper"
HELPERS_FOLDER="/Library/PrivilegedHelperTools"
HELPER_PATH="$HELPERS_FOLDER/$HELPER"

DAEMON="com.abridoux.Scriptex.helper.plist"
DAEMONS_FOLDER="/Library/LaunchDaemons"
DAEMON_PATH="$DAEMONS_FOLDER/$DAEMON"
# --------

# ---- Main ----

# test if root
# https://scriptingosx.com/2018/04/demystifying-root-on-macos-part-3-root-and-scripting/
if [[ $EUID -ne 0 ]]; then
	 print_error "This script requires super user privileges, exiting..."
	exit 1
fi

# -- Helper --
echo "-- Helper -- "

if [[ ! -f "$HELPER_PATH" ]]; then
	# the Helper does not exist in the Helpers folder so copy it
	echo "Did not find the Helper at $HELPER_PATH. Copying it..."

	# create the Helper tools folder directory if needed
	if [[ ! -d $HELPERS_FOLDER ]]; then
		/bin/mkdir -p "$HELPERS_FOLDER"
		/bin/chmod 755 "$HELPERS_FOLDER"
		/usr/sbin/chown -R root:wheel "$HELPERS_FOLDER"
	fi

	# move the privileged helper into place
	/bin/cp -f "$CURRENT_DIR/$HELPER" "$HELPERS_FOLDER"
	
	if [[ -f "$HELPER_PATH" ]]; then
		print_success "Successfully copied $HELPER to $HELPERS_FOLDER"
	else
		print_error "Failed to copy $HELPER to $HELPERS_FOLDER"
		exit 1
	fi
	
	echo "Settings the correct rights to the Helper..."
	echo ""
	
	/usr/sbin/chown root:wheel "$HELPER_PATH"
	/bin/chmod 755 "$HELPER_PATH"
	# -- remove the quarantine if any
	/usr/bin/xattr -d com.apple.quarantine "$HELPER_PATH" 2>/dev/null
else
	# the Helper exists. Don't do anything
	print_success "$HELPERS_FOLDER already in place"
	echo ""
fi

# --- Daemon ---
echo "-- Daemon -- "
if [ ! -f  "$DAEMON_PATH" ]; then
	# the daemon does not exist in the daemons folder so copy it
	echo "Did not find the LaunchDaemon at $HELPER_PATH. Copying it..."
	
	# copy the daemon
	/bin/cp -f "$CURRENT_DIR/$DAEMON" "$DAEMONS_FOLDER"
	
	# ensure the daemon has beensuccessfully copied
	if [ -f  "$DAEMON_PATH" ]; then
		print_success  "Successfully copied $DAEMON to $DAEMONS_FOLDER"
	else
		print_error "Failed to copy $DAEMON to $DAEMONS_FOLDER"
		exit 1
	fi
else
	print_success "The daemon $DAEMON is already in place in $DAEMONS_FOLDER"
fi

# Set the rights to the daemon
echo "Settings the correct rights to the LaunchDaemon..."

/bin/chmod 644 "$DAEMON_PATH"
/usr/sbin/chown root:wheel "$DAEMON_PATH"
# -- remove the quarantine if any
/usr/bin/xattr -d com.apple.quarantine "$DAEMON_PATH" 2>/dev/null

# Load the daemon
loaded=`launchctl list | grep ${HELPER}`
if [ ! -n "$loaded" ]; then
	echo -e "Daemon not loaded. Loading it..."
	/bin/launchctl load -wF "$DAEMON_PATH"
else
	print_success "Daemon already loaded, exiting..."
	exit 0
fi

loaded=`launchctl list | grep ${HELPER}`

if [ -n "$loaded" ]; then
	print_success "Successfully loaded the Daemon at $DAEMON_PATH"
else
	print_error "Failed to load the Daemon at $DAEMON_PATH"
	exit 1
fi 