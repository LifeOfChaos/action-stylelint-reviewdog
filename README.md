# GitHub Action: Run stylelint with reviewdog

This action runs [stylelint](https://github.com/stylelint/stylelint) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests.

## Inputs

### `github_token`

**Required**. Your Github token. 
Default is `${{ github.token }}`.

### `level`

Optional. Report level for reviewdog.
Default: `error`.
Values: `info`, `warning`, `error`.

### `reporter`
Optional. Reporter of reviewdog command. 
Default is `github-pr-review`.
Values: `github-check`, `github-pr-review`.

### `filter_mode`

Optional. Filtering mode for the reviewdog command. 
Default is `added`.
Values: `added`, `diff_context`, `file`, `nofilter`

### `fail_on_error`

Optional. Exit code for reviewdog when errors are found. 
Default is `false`.
Valies: `true`, `false`.

### `linter_command`

Optional. Your package script name. `npm run "$linter_command"` will be executed. 
Default is `stylelint`.

### `workdir`

Optional. Working directory. Default '.'

## Example usage

```yml
name: Style Linter

on:
  pull_request:
jobs:
  stylelint:
    name: Style Linter (SCSS)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js 16
        uses: actions/setup-node@v3
        with:
          node-version: 16
          cache: 'npm'
          cache-dependency-path: '**/package-lock.json'
      - name: Install Node JS Dependencies
        run: |
          npm install
        env:
          CI: true
      - uses: LifeOfChaos/action-stylelint-reviewdog@v.0.0.1
        name: Running stylelint with Reviewdog 🐶
        with:
          reporter: github-pr-review
          github_token: ${{ secrets.GITHUB_TOKEN }}
          level: 'error'
          linter_command: 'lint:scss:ci'
```
