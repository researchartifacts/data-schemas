# ReproDB Data Schemas

[JSON Schema](https://json-schema.org/) definitions for all data structures produced by the [reprodb-pipeline](https://github.com/ReproDB/reprodb-pipeline) and consumed by the [reprodb.github.io](https://reprodb.github.io) website.

**Browse the documentation:** [reprodb.github.io/data-schemas](https://reprodb.github.io/data-schemas/)

## Schema → Output File Mapping

Each schema validates one or more output files produced by the pipeline. Output files land in two locations within the website repo:
- `_data/` — YAML/JSON consumed by Jekyll templates
- `assets/data/` — JSON served directly to the browser (charts, search, client-side tables)
- `_build/` — Intermediate files (not published, used by downstream generators)

### Schemas with definitions (✓ documented)

| Schema | Output file(s) | Generator | Description |
|--------|---------------|-----------|-------------|
| [artifacts](https://reprodb.github.io/data-schemas/artifacts.html) | `assets/data/artifacts.json` | `generate_statistics.py` | Core artifact records with badges and URLs |
| [artifacts_by_conference](https://reprodb.github.io/data-schemas/artifacts_by_conference.html) | `_data/artifacts_by_conference.yml` | `generate_statistics.py` | Badge breakdown by conference and year |
| [artifacts_by_year](https://reprodb.github.io/data-schemas/artifacts_by_year.html) | `_data/artifacts_by_year.yml` | `generate_statistics.py` | Year-over-year artifact counts |
| [ae_members](https://reprodb.github.io/data-schemas/ae_members.html) | `assets/data/ae_members.json`, `assets/data/{area}_ae_members.json` | `committee_stats/` | AE committee member lists |
| [artifact_availability](https://reprodb.github.io/data-schemas/artifact_availability.html) | `assets/data/artifact_availability.json` | `generate_artifact_availability.py` | URL liveness checks for artifacts |
| [artifact_citations](https://reprodb.github.io/data-schemas/artifact_citations.html) | `assets/data/artifact_citations.json` | `generate_artifact_citations.py` | Citation data for artifacts |
| [author_index](https://reprodb.github.io/data-schemas/author_index.html) | `assets/data/author_index.json` | `generate_author_stats.py` | Lightweight author lookup index |
| [author_profiles](https://reprodb.github.io/data-schemas/author_profiles.html) | `assets/data/author_profiles.json` | `generate_author_profiles.py` | Detailed per-author profile data |
| [author_stats](https://reprodb.github.io/data-schemas/author_stats.html) | `assets/data/authors.json`, `assets/data/{area}_authors.json` | `generate_author_stats.py` | Per-author statistics and paper lists |
| [combined_rankings](https://reprodb.github.io/data-schemas/combined_rankings.html) | `assets/data/combined_rankings.json`, `assets/data/{conf}_combined_rankings.json` | `generate_combined_rankings.py` | Author rankings combining artifacts + AE service |
| [committee_stats](https://reprodb.github.io/data-schemas/committee_stats.html) | `assets/data/committee_stats.json` | `committee_stats/` | AE committee participation statistics |
| [institution_ranking_history](https://reprodb.github.io/data-schemas/institution_ranking_history.html) | `assets/data/institution_ranking_history.json` | `generate_ranking_history.py` | Historical institution ranking changes |
| [institution_rankings](https://reprodb.github.io/data-schemas/institution_rankings.html) | `assets/data/institution_rankings.json`, `assets/data/{conf}_institution_rankings.json` | `generate_institution_rankings.py` | Institution-level rankings and metrics |
| [paper_citations](https://reprodb.github.io/data-schemas/paper_citations.html) | `assets/data/paper_citations.json` | `generate_paper_citations_doi.py` | Paper citation counts from OpenAlex/Crossref |
| [paper_index](https://reprodb.github.io/data-schemas/paper_index.html) | `assets/data/papers.json`, `_data/papers.json` | `generate_author_stats.py` | Paper metadata index |
| [participation_stats](https://reprodb.github.io/data-schemas/participation_stats.html) | `assets/data/participation_stats.json`, `_data/participation_stats.yml` | `generate_participation_stats.py` | Conference participation trends |
| [ranking_history](https://reprodb.github.io/data-schemas/ranking_history.html) | `assets/data/ranking_history.json` | `generate_ranking_history.py` | Historical author ranking changes |
| [repo_stats](https://reprodb.github.io/data-schemas/repo_stats.html) | `assets/data/repo_stats_detail.json` | `generate_repo_stats.py` | Per-artifact repository metrics (stars, forks) |
| [repo_stats_summary](https://reprodb.github.io/data-schemas/repo_stats_summary.html) | `_data/repo_stats.yml` | `generate_repo_stats.py` | Aggregated repository metrics (overall, by-conference, by-year, by-area) |
| [repo_stats_yearly](https://reprodb.github.io/data-schemas/repo_stats_yearly.html) | `assets/data/repo_stats_yearly.json` | `generate_repo_stats.py` | Per-conference yearly star/fork trends for charts |
| [search_data](https://reprodb.github.io/data-schemas/search_data.html) | `assets/data/search_data.json` | `generate_search_data.py` | Merged data for website full-text search |
| [summary](https://reprodb.github.io/data-schemas/summary.html) | `_data/summary.yml`, `assets/data/summary.json` | `generate_statistics.py` | High-level site summary statistics |
| [top_repos](https://reprodb.github.io/data-schemas/top_repos.html) | `assets/data/top_repos.json`, `assets/data/{area}_top_repos.json` | `generate_repo_stats.py` | Top repositories by stars |

### Output files without schemas (not yet documented)

| Output file | Generator | Description | Priority |
|-------------|-----------|-------------|----------|
| `assets/data/artifact_citations_summary.json` | `generate_artifact_citations.py` | Summary stats for citation data | Low |
| `assets/data/citation_verification_summary.json` | `generate_artifact_citations.py` | Citation verification report | Low |
| `assets/data/cited_artifacts_by_author.json` | `generate_cited_artifacts_list.py` | Authors mapped to their cited artifacts | Medium |
| `assets/data/cited_artifacts_by_institution.json` | `generate_cited_artifacts_list.py` | Institutions mapped to cited artifacts | Medium |
| `assets/data/cited_artifacts_list.json` | `generate_cited_artifacts_list.py` | Flat list of all cited artifacts | Medium |
| `assets/data/geographic_statistics.json` | `generate_institution_rankings.py` | Country/region breakdown | Medium |
| `assets/data/paper_citations_summary.json` | `generate_paper_citations_doi.py` | Summary stats for paper citations | Low |
| `_build/institution_timeline.json` | `committee_stats/` | Institution participation over time | Low |
| `_build/paper_authors_map.json` | `generate_author_stats.py` | Intermediate: paper→author mapping | Low |
| `_build/repo_stats_history.json` | `generate_repo_stats.py` | Historical star/fork snapshots per repo | Medium |
| `_data/author_summary.yml` | `generate_author_stats.py` | Author summary for Jekyll | Low |
| `_data/combined_summary.yml` | `generate_combined_rankings.py` | Combined ranking summary for Jekyll | Low |
| `_data/coverage.yml` | `generate_statistics.py` | Conference/year coverage table | Low |
| `_data/navigation.yml` | `generate_statistics.py` | Site navigation structure | Low |
| `_data/pipeline_metadata.yml` | Pipeline runner | Run timestamp and version info | Low |
| `_data/all_results_cache.yml` | `generate_statistics.py` | Full results cache for Jekyll | Low |
| `assets/data/{conf}_conf_authors.json` | `generate_author_stats.py` | Per-conference author details | Medium |
