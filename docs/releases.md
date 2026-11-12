# Releases and release preparation

Saaster's first versioned public release is being prepared. No Git tags or GitHub Releases have been published yet. PAWECO is responsible for selecting the release scope, approving the release candidate, and authorizing publication.

This guide records the intended release process and the checks that must be completed before the first release. The first version number, compatibility commitments, security-reporting route, and support policy still need PAWECO approval.

## Current version labels

The public documentation at [docs.saaster.io](https://docs.saaster.io) uses the label "Version 1.1". Its relationship to a software release has not been established. Confirm its meaning before choosing the first release number or updating the public documentation.

The version in `www/tests/box.json` identifies the test workspace. Its TestBox dependency has a separate version. Generated frontend asset timestamps are cache-invalidation identifiers. None of these identifies a Saaster software release.

## Branches and release identity

| Reference | Purpose |
| --- | --- |
| `development` | Ongoing development and the target for external contributions; currently the default branch. |
| `staging` | PAWECO's acceptance environment for the next deployment or release candidate. |
| `production` | PAWECO's approved deployment state. |
| Release tag and GitHub Release | A fixed published software version, created after verification and approval. |

Keep the current branch structure during preparation. Review whether `production` should become the default branch after the first verified release.

Pushes to `staging` and `production` trigger the existing deployment workflows and database migrations. Treat each promotion as an operational change requiring PAWECO authorization. A branch promotion and a GitHub Release are separate actions.

## Versioning direction

The intended scheme is `MAJOR.MINOR.PATCH`, with tags in the form `vMAJOR.MINOR.PATCH`. The first numeric version remains undecided.

Following [Semantic Versioning](https://semver.org/spec/v2.0.0.html), the proposed rules are:

| Change | Version increment |
| --- | --- |
| An incompatible change to the documented compatibility contract | MAJOR |
| A backward-compatible feature | MINOR |
| A backward-compatible bug fix | PATCH |

Before applying these rules, PAWECO must define the compatibility contract. Review documented APIs, application and module hooks, permission manifests, configuration keys, runtime requirements, and the upgrade path. Record tested combinations separately from any promised support. Internal implementation details must not accidentally become compatibility promises.

Once published, release tags and their contents remain unchanged. Corrections require a new release. Preserve migration files that have already been released or applied to existing installations; document additional migration work in a subsequent change.

## Release checklist

- [ ] PAWECO selects the scope and exact candidate commit, reviews feature-specific release prerequisites, and records known limitations. Include the prerequisites described in [invoice retention](invoice-retention.md#remaining-integration-before-production-release) and the requirements of installed extensions.
- [ ] Record the tested runtime and tool versions, relevant Lucee extensions, and image references. Reproduce the setup from public inputs without relying on a maintainer's private Lucee image or saved administrator settings.
- [ ] Verify a fresh installation with empty volumes and databases, core and project migrations, application configuration, the setup wizard, first registration, login, and local mail delivery.
- [ ] Run the existing TestBox suites against a dedicated test database with local mocks and Inbucket. Report results and intentional skips. Establish isolated pull request checks that work without deployment secrets.
- [ ] Verify migration validation and a second migration run on the same test database. Preserve existing Flyway histories and migration checksums.
- [ ] Complete the repository's installation, production, upgrade, and recovery instructions, and align the public documentation with the same version.
- [ ] Explain extension locations and update conflicts, including shipped files under `www/backend/myapp/`, `www/backend/modules/`, and `www/frontend/custom_theme/`. Verify deployment-specific permission and lifecycle hooks.
- [ ] Back up and restore application code, configuration, database with Flyway histories, and user data as a consistent installation. Demonstrate restoration in an isolated environment; a code-only rollback does not prove database recovery.
- [ ] Review deployment exclusions and preservation of local configuration and project-owned files. Exclude `www/tests` from deployed installations.
- [ ] Starting with the second release, verify the full upgrade path from the previous release, including representative application and theme customizations.
- [ ] Confirm the decisions below, prepare release notes and a changelog entry, and obtain PAWECO approval for the release commit and publication.

The first release requires a verified fresh installation. There is no previous published release for a release-to-release upgrade test. Existing installations still need their own migration and configuration review.

## Release notes

Each GitHub Release should contain:

- The version, release date, and exact tag.
- User-visible changes, fixes, and breaking changes.
- Tested prerequisites and changes to runtime or configuration requirements.
- Included migrations, their impact, and any operator actions.
- Installation and upgrade instructions for that version, with backup and recovery requirements.
- Extension or theme compatibility implications and known limitations.

Keep version-specific instructions with the code in the repository. The public documentation should provide an introduction and link to the matching tagged instructions. Until it is aligned, the [repository setup instructions](../readme.md#development-setup) describe the current development stack.

## Approval and publication

1. Complete the checklist and prepare the release notes for review.
2. Obtain PAWECO approval for the candidate and each required branch promotion. Account for the automatic deployments and migrations before promoting to `staging` or `production`.
3. Confirm validation of the exact `production` commit selected for publication, then obtain authorization to create its fixed version tag and GitHub Release.
4. Publish the approved release notes and update installation links to the released version. Keep the published tag and migration files unchanged.

Preparing documentation, running checks, or opening a pull request does not itself authorize a deployment or publication. No release cadence or support duration is established by this guide.

## Pending PAWECO decisions

| Decision | Required before |
| --- | --- |
| Meaning of the public documentation's "Version 1.1" label and the first software release number | Selecting the first release tag. |
| The documented compatibility contract and supported runtime combinations | Publishing compatibility claims. |
| Supported release lines and the scope of community help and PAWECO services | Publishing support commitments. |
| A confidential security-reporting route | Publishing a security policy or directing confidential reports to a contact. |
| Named release approvers and any administrative exceptions to repository protection | Configuring release permissions and approving publication. |

These decisions do not block documentation corrections or local test preparation. Dependent policies and publication wait for their confirmation.
