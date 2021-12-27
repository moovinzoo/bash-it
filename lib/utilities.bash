# shellcheck shell=bash
#
# A collection of reusable functions.

###########################################################################
# Generic utilies
###########################################################################

function _bash-it-get-component-name-from-path() {
	local filename
	# filename without path
	filename="${1##*/}"
	# filename without path or priority
	filename="${filename##*"${BASH_IT_LOAD_PRIORITY_SEPARATOR?}"}"
	# filename without path, priority or extension
	echo "${filename%.*.bash}"
}

function _bash-it-get-component-type-from-path() {
	local filename
	# filename without path
	filename="${1##*/}"
	# filename without extension
	filename="${filename%.bash}"
	# extension without priority or name
	filename="${filename##*.}"
	echo "${filename}"
}

# This function searches an array for an exact match against the term passed
# as the first argument to the function. This function exits as soon as
# a match is found.
#
# Returns:
#   0 when a match is found, otherwise 1.
#
# Examples:
#   $ declare -a fruits=(apple orange pear mandarin)
#
#   $ _bash-it-array-contains-element apple "@{fruits[@]}" && echo 'contains apple'
#   contains apple
#
#   $ if _bash-it-array-contains-element pear "${fruits[@]}"; then
#       echo "contains pear!"
#     fi
#   contains pear!
#
#
function _bash-it-array-contains-element() {
	local e element="${1?}"
	shift
	for e in "$@"; do
		[[ "$e" == "${element}" ]] && return 0
	done
	return 1
}

# Dedupe an array (without embedded newlines).
function _bash-it-array-dedup() {
	printf '%s\n' "$@" | sort -u
}

# Outputs a full path of the grep found on the filesystem
function _bash-it-grep() {
	: "${BASH_IT_GREP:=$(type -p egrep || type -p grep)}"
	printf "%s" "${BASH_IT_GREP:-'/usr/bin/grep'}"
}

# Runs `grep` with extended regular expressions
function _bash-it-egrep() {
	: "${BASH_IT_GREP:=$(type -p egrep || type -p grep)}"
	"${BASH_IT_GREP:-/usr/bin/grep}" -E "$@"
}

###########################################################################
# Component-specific functions (component is either an alias, a plugin, or a
# completion).
###########################################################################

function _bash-it-component-help() {
	local component file func
	_bash-it-component-pluralize "${1}"
	component="${_bash_it_component_pluralized_name?}"
	_bash-it-component-cache-file "${component}"
	file="${_bash_it_component_cache_filename?}"
	if [[ ! -s "${file}" || -z "$(find "${file}" -mmin -300)" ]]; then
		func="_bash-it-${component}"
		"${func}" | _bash-it-egrep '\[[x ]\]' >| "${file}"
	fi
	cat "${file}"
}

function _bash-it-component-cache-file() {
	local component file
	_bash-it-component-pluralize "${1?${FUNCNAME[0]}: component name required}"
	component="${_bash_it_component_pluralized_name?}"
	file="${XDG_CACHE_HOME:-${BASH_IT?}/tmp/cache}${XDG_CACHE_HOME:+/bash_it}/${component}"
	[[ -f "${file}" ]] || mkdir -p "${file%/*}"
	printf -v _bash_it_component_cache_filename '%s' "${file}"
}

function _bash-it-component-singularize() {
	[[ -n "${2:-}" ]] && local -n _bash_it_component_singularized_name="${2?}"
	local component="${1?${FUNCNAME[0]}: component name required}"
	local -i len="$((${#component} - 2))"
	if [[ "${component:${len}:2}" == 'ns' ]]; then
		component="${component%s}"
	elif [[ "${component}" == "aliases" ]]; then
		component="${component%es}"
	fi
	printf -v _bash_it_component_singularized_name '%s' "${component}"
}

function _bash-it-component-pluralize() {
	[[ -n "${2:-}" ]] && local -n _bash_it_component_pluralized_name="${2?}"
	local component="${1?${FUNCNAME[0]}: component name required}"
	local -i len="$((${#component} - 1))"
	# pluralize component name for consistency
	if [[ "${component:${len}:1}" != 's' ]]; then
		component="${component}s"
	elif [[ "${component}" == "alias" ]]; then
		component="${component}es"
	fi
	printf -v _bash_it_component_pluralized_name '%s' "${component}"
}

function _bash-it-clean-component-cache() {
	local component="$1"
	local cache
	local -a BASH_IT_COMPONENTS=(aliases plugins completions)
	if [[ -z "${component}" ]]; then
		for component in "${BASH_IT_COMPONENTS[@]}"; do
			_bash-it-clean-component-cache "${component}"
		done
	else
		_bash-it-component-cache-file "${component}"
		cache="${_bash_it_component_cache_filename?}"
		if [[ -f "${cache}" ]]; then
			rm -f "${cache}"
		fi
	fi
}

# Returns an array of items within each compoenent.
function _bash-it-component-list() {
	local IFS=$'\n' component="$1"
	_bash-it-component-help "${component}" | awk '{print $1}' | sort -u
}

function _bash-it-component-list-matching() {
	local component="$1"
	shift
	local term="$1"
	_bash-it-component-help "${component}" | _bash-it-egrep -- "${term}" | awk '{print $1}' | sort -u
}

function _bash-it-component-list-enabled() {
	local IFS=$'\n' component="$1"
	_bash-it-component-help "${component}" | _bash-it-egrep '\[x\]' | awk '{print $1}' | sort -u
}

function _bash-it-component-list-disabled() {
	local IFS=$'\n' component="$1"
	_bash-it-component-help "${component}" | _bash-it-egrep -v '\[x\]' | awk '{print $1}' | sort -u
}

# Checks if a given item is enabled for a particular component/file-type.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _bash-it-component-item-is-enabled alias git && echo "git alias is enabled"
function _bash-it-component-item-is-enabled() {
	local component="$1" item="$2"
	local each_file

	for each_file in "${BASH_IT}/enabled"/*"${BASH_IT_LOAD_PRIORITY_SEPARATOR?}${item}.${component}"*."bash" \
		"${BASH_IT}/${component}"*/"enabled/${item}.${component}"*."bash" \
		"${BASH_IT}/${component}"*/"enabled"/*"${BASH_IT_LOAD_PRIORITY_SEPARATOR?}${item}.${component}"*."bash"; do
		[[ -f "${each_file}" ]] && return
	done
}

# Checks if a given item is disabled for a particular component/file-type.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _bash-it-component-item-is-disabled alias git && echo "git aliases are disabled"
function _bash-it-component-item-is-disabled() {
	! _bash-it-component-item-is-enabled "$@"
}
