# Data Schemas — Copilot Instructions

## Repository Purpose

This repo contains JSON Schema (Draft 2020-12) definitions for all data structures
produced by the [artifact_analysis](https://github.com/researchartifacts/artifact_analysis)
pipeline and consumed by [researchartifacts.github.io](https://github.com/researchartifacts/researchartifacts.github.io).

## Schema Editing Rules

- Schemas must validate with `jsonschema.Draft202012Validator.check_schema()`.
- Use `additionalProperties: false` to enforce strict field sets.
- Nullable fields use `type: ["number", "null"]` (not `nullable: true`).
- Badge values are NOT enum-restricted — the data has non-normalized variants.
- Conference names ARE enum-restricted in `artifacts.schema.json`.

## Cross-Repo Impact

Changes here affect validation in the `artifact_analysis` CI pipeline
(`update-stats.yml`), which validates generated JSON against these schemas.

If a schema change makes it more restrictive (removing fields, tightening types),
verify that the corresponding generator in `../artifact_analysis/src/generators/`
still produces conforming output.

## Generator ↔ Schema Mapping

| Schema | Generator(s) in artifact_analysis |
|--------|----------------------------------|
| `artifacts.schema.json` | `generate_statistics.py` (+ scrapers) |
| `institution_rankings.schema.json` | `generate_institution_rankings.py` |
| `combined_rankings.schema.json` | `generate_combined_rankings.py` |
| `author_stats.schema.json` | `generate_author_stats.py` |
| `search_data.schema.json` | `generate_search_data.py` |
| `repo_stats.schema.json` | `generate_repo_stats.py` |
| `repo_stats_summary.schema.json` | `generate_repo_stats.py` |
| `summary.schema.json` | `generate_statistics.py` |
| `artifacts_by_conference.schema.json` | `generate_statistics.py` |
| `artifacts_by_year.schema.json` | `generate_statistics.py` |
