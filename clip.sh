# !/usr/bin/env zsh -e

if [[ $MISE_CONFIG_ROOT == $MISE_ORIGINAL_CWD ]]; then
	bin="$CURRENT_CONTEST-$1"
else
	name=$(basename $MISE_ORIGINAL_CWD)
	bin="$name-$1"
fi

src=$(cargo equip --exclude-atcoder-crates --exclude internals --minify libs --no-check --bin $bin)

from="#[helpers::main]"
to="#[argio::argio(input = proconio::input)]\n#[proconio::fastout]"
src=${src/$from/$to}

echo $src | pbcopy
