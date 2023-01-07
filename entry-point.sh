#!/bin/sh

cd "${GITHUB_WORKSPACE}/${WORKDIR}" || exit 1

TEMP_PATH="$(mktemp -d)"
PREV_PATH=$PATH
PATH="${TEMP_PATH}:$PATH"
export REVIEWDOG_GITHUB_API_TOKEN="${GITHUB_TOKEN}"

echo '::group:: Installing reviewdog 🐶... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "latest" 2>&1
echo '::endgroup::'

echo '::group:: stylelint'
echo "Using version: $(./node_modules/.bin/stylelint --version)"
echo '::endgroup::'

echo '::group:: Running stylelint with reviewdog 🐶...'
if [ "${REVIEWDOG_REPORTER}" = 'github-pr-review' ]; then
  npm run --silent "$LINTER_COMMAND" \
    | jq -r '.[] | {source: .source, warnings:.warnings[]} | "\(.source):\(.warnings.line):\(.warnings.column):\(.warnings.severity): \(.warnings.text) [\(.warnings.rule)](https://stylelint.io/user-guide/rules/\(.warnings.rule))"' \
    | reviewdog -efm="%f:%l:%c:%t%*[^:]: %m" -name="eslint" -reporter="${REVIEWDOG_REPORTER}" -level="${REVIEWDOG_LEVEL}" -filter-mode="${REVIEWDOG_FILTER_MODE}" -fail-on-error="${REVIEWDOG_FAIL_ON_ERROR}"
else
  npm run --silent "$LINTER_COMMAND" \
    | reviewdog -f="stylelint" -name="eslint" -reporter="${REVIEWDOG_REPORTER}" -level="${REVIEWDOG_LEVEL}" -filter-mode="${REVIEWDOG_FILTER_MODE}" -fail-on-error="${REVIEWDOG_FAIL_ON_ERROR}"
fi

output=$?
echo '::endgroup::'

echo '::group:: Removing rewiewdog 🐶 files...'
PATH="$PREV_PATH"
rm -rf "$TEMP_PATH"
echo '::endgroup::'

exit $output