# Release preparation

The addon publishes under its dedicated GitHub identity, casualg1t. The previous repository remains a private backup. Uploading a CurseForge file and publishing a GitHub release are separate actions. No marketplace API credentials are stored here. The first marketplace upload is manual.

## Before the first public download

1. Install the candidate ZIP in Forever and confirm both tabs, minimap launcher, tooltips, scrollbars and filters. Test TSM; only claim Auctionator compatibility after testing that build.
2. Capture one screenshot per tab. Crop away chat, character/account names and unrelated UI. Save reviewed screenshots in `assets/` before uploading; do not substitute HTML mockups for in-game screenshots.
3. Run `python3 tools/check.py`. Use the ZIP in `outputs/`, not GitHub's source archive.
4. Review `docs/CURSEFORGE.md`, choose the tested Forever client version and use the supplied original PNG logo. A failed/unverified integration should remain documented.

## CurseForge

Create the project at https://authors.curseforge.com/#/projects/create/choose-game using the prepared listing. Upload the candidate ZIP, assign Forever and the tested game version, add the matching CHANGELOG entry and submit for moderation. Use Beta for a test candidate; CurseForge's normal app distribution requires a Release file. Publish a Release only after field validation.

Add source/issues links to this repository. A price provider is needed for estimates, but either TSM or Auctionator can satisfy that need; do not mark both as mandatory dependencies or require OneForAll.

Official guidance: https://support.curseforge.com/support/solutions/articles/9000197241-creating-and-submitting-a-project and https://support.curseforge.com/support/solutions/articles/9000199552-overview-of-the-project-submission-page

## GitHub

A draft release can hold the candidate ZIP and notes without making a public download release. After field validation, publish the draft. For subsequent versions, update the TOC/changelog, run checks, commit/tag the exact source and attach the newly generated ZIP. CI runs checks on pushes and pull requests, but does not publish to marketplaces.

## Other hosts

Wago is an optional additional listing. Reuse the same tested ZIP, branding and explicit limitations; select a supported Forever client flavor. Avoid claiming support for Retail or Classic Era.

## Privacy

Publish only repository files and the generated install ZIP. Internal working notes, old exports, local paths, raw account data and SavedVariables are excluded. Git commits use a project identity and a non-personal noreply address. Public repository ownership still identifies the GitHub account hosting it.


## Dedicated publishing identity

Prepare a fresh repository under the chosen identity, rather than transferring the old repository: GitHub transfers redirect old repository URLs to the new owner. Use a clean source snapshot so earlier documentation links do not become public through Git history. Keep the existing private repository as a backup.

Git commits already use a project name and non-personal noreply address. A separate login requires its own signup/verified email and authentication. An organization supports a separate project namespace and private membership, but public actions by the managing account may still identify that account. Neither option can undo any copies made while an earlier repository was public.
