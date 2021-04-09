import re
from typing import List

from gitlint.git import GitCommit
from gitlint.options import BoolOption, ListOption
from gitlint.rules import CommitMessageTitle, LineRule, RuleViolation

import json

defaultTypes =  [
    "fix",
    "feat",
    "refactor",
    "revert",
    "ci",
    "style",
    "build",
    "perf",
    "dbg",
    "test",
    "version",
    "hack",
    "chore",
    "config",
    "docs",
    "license",
    "WIP",
]

defaultIgnoreScope = False
defaultScopes = []

# format: type(optional-scope)!: description
commitMessageTitleRe = re.compile(r"^(\w+?)(\([^)]+?\))?!?: .+")

class ConventionaliCommitsMessageTitle(LineRule):
    """This rule enforces the spec at https://www.conventionalcommits.org/."""
    name = "ubnt-conventional-commits-message-title"
    id = "ULCC1"
    target = CommitMessageTitle

    # can be configured in '.gitlint'
    options_spec = [
            ListOption("types", defaultTypes, "Comma separated list of allowed commit types."),
            BoolOption("ignore-scope", defaultIgnoreScope,"Ignore the scope validation"),
            ListOption("scopes", defaultScopes, "Comma separated list of allowed commit scopes."),
    ]

    def validate(self, line: str, commit: GitCommit) -> List[RuleViolation]:
        violations = []

        # validate format
        match = commitMessageTitleRe.match(line)
        if not match:
            violations.append(RuleViolation(self.id,
                f"Title does not follow ConventionalCommits.org format: '{line}'"
                f"\nFormat could be like:"
                f"\n    'type(scope1,scope2): description'"
                f"\n    'type: description'",
                ))

        # validate type tag
        if match:
            configTypes = self.options['types'].value
            commitType = match.group(1)
            if configTypes.count(commitType) == 0:
                violations.append(RuleViolation(self.id,
                    f"Title does not start with one of [{', '.join(configTypes)}]: '{line}'",))

        # validate scopes
        if not self.options['ignore-scope'].value and match and match.group(2):
            configScopes = self.options['scopes'].value
            commitScopes = match.group(2)[1:-1]
            if configScopes and commitScopes:
                commitScopes = re.split("[|,/]", commitScopes)
                configScopesRe = re.compile('|'.join(configScopes))
                badScopes = []
                for scope in commitScopes:
                    if not configScopesRe.match(scope):
                        badScopes.append(scope)

                if badScopes:
                    violations.append(RuleViolation(self.id,
                        f"Title scopes:[{', '.join(badScopes)}] are not listed in allowed scopes:[{', '.join(configScopes)}]: '{line}'"
                        f"\nThe missed scopes can be added to .gitlint config file",))

        return violations
