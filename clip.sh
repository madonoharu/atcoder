# !/usr/bin/env zsh -e

if [[ $MISE_CONFIG_ROOT == $MISE_ORIGINAL_CWD ]]; then
	bin="$CURRENT_CONTEST-$1"
else
	name=$(basename $MISE_ORIGINAL_CWD)
	bin="$name-$1"
fi

cargo metadata --no-deps --format-version=1 |
	jq -r --arg bin $bin '.packages[] | .targets[] | select(.name == $bin) | .src_path' |
	read src_path

if [[ ! -s $src_path ]]; then
	echo "Error!" >&2
	exit 1
fi

src=$(cat $src_path)
from="#[helpers::main]"
to="#[argio::argio(input = proconio::input)]\n#[proconio::fastout]"
src=${src/$from/$to}

lib=$(cat 'helpers/src/lib.rs')
lib=${lib##'pub use internals::*;'}
lib=${lib#"${lib%%[!"$IFS"]*}"}
lib="mod helpers {$lib}"

printf "$src\n\n$lib" | rustfmt | pbcopy
