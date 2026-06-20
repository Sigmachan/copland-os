#!/usr/bin/env bash

function custom-kernel() {
	[[ -n "$CUSTOM_KERNEL" ]] &&
		echo " $CUSTOM_KERNEL" >>/tmp/TO_BUILD &&
		echo "Using $CUSTOM_KERNEL as kernel." &&
		exit 0

	[[ "$CI_COMMIT_MESSAGE" == *"["*"-k"*"]"* ]] &&
		CUSTOM_KERNEL=$(echo "$CI_COMMIT_MESSAGE" | grep -Po "(?<=\[).*(?=\])" | awk -F ' ' '{ print $4 }') &&
		echo " $CUSTOM_KERNEL" >>/tmp/TO_BUILD &&
		echo "Using $CUSTOM_KERNEL as kernel." &&
		exit 0

	# if no custom kernel is specified, we still want to exit gracefully
	exit 0
}

# Read a list of flavours from the community and garuda directories
mapfile -t _FLAVOUR < <(find {community,garuda} -mindepth 1 -type d -prune | sed -e 's/community\///' -e 's/garuda\///')

# Check whether a manual build has been requested via GitLab web ui
if [[ -n "$MANUAL_BUILD" ]]; then
	[[ "$MANUAL_BUILD" == "all" ]] &&
		echo "buildall" >>/tmp/TO_BUILD &&
		echo "Requested a buildall run." &&
		custom-kernel

	for i in "${_FLAVOUR[@]}"; do
		# shellcheck disable=SC2076
		[[ "$MANUAL_BUILD" == "$i" ]] &&
			echo "$i" >>/tmp/TO_BUILD &&
			echo "Requested ISO build for $i." &&
			custom-kernel
	done

else
	# Only check for commit messages if no manual build has been requested
	[[ "$CI_COMMIT_MESSAGE" == *"[build all]"* ]] &&
		echo "buildall" >>/tmp/TO_BUILD &&
		echo "Requested a buildall run." &&
		custom-kernel

	for i in "${_FLAVOUR[@]}"; do
		# shellcheck disable=SC2076
		[[ "$CI_COMMIT_MESSAGE" == *"[build $i]"* ]] &&
			echo "$i" >>/tmp/TO_BUILD &&
			echo "Requested ISO build for $i." &&
			custom-kernel
	done
fi
echo "No valid flavour to build found in commit message, aborting." && exit 1
