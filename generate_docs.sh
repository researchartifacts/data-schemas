#!/usr/bin/env bash
# Generate HTML documentation from JSON Schema files using json-schema-for-humans.
# Output goes to docs/ which can be served via GitHub Pages.
#
# When git tags matching v* exist, documentation is generated for every tagged
# version plus HEAD.  The directory layout under docs/ becomes:
#
#   docs/index.html          – landing page with version picker
#   docs/v1.0.0/index.html   – per-schema pages for tag v1.0.0
#   docs/v1.1.0/index.html   – per-schema pages for tag v1.1.0
#   docs/latest/              – symlink → newest version dir
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMAS_DIR="$SCRIPT_DIR/schemas"
DOCS_DIR="$SCRIPT_DIR/docs"

rm -rf "$DOCS_DIR"
mkdir -p "$DOCS_DIR"

# ---------------------------------------------------------------------------
# Helper: generate docs for a single schemas directory into a target dir.
# Usage: _generate_version_docs <schemas_dir> <out_dir> <version_label>
# ---------------------------------------------------------------------------
_generate_version_docs() {
    local src_dir="$1" out_dir="$2" ver="$3"
    mkdir -p "$out_dir" "$out_dir/md"

    for schema in "$src_dir"/*.schema.json; do
        [[ -f "$schema" ]] || continue
        local base
        base="$(basename "$schema" .schema.json)"
        generate-schema-doc --config-file "$SCRIPT_DIR/jsfh-config.yaml" \
            "$schema" "$out_dir/${base}.html"
        generate-schema-doc --config-file "$SCRIPT_DIR/jsfh-config-md.yaml" \
            "$schema" "$out_dir/md/${base}.md"
    done

    # Per-version index
    cat > "$out_dir/index.html" << VHEREDOC
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>ReproDB Data Schemas – ${ver}</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1rem; color: #24292f; }
  h1 { border-bottom: 1px solid #d0d7de; padding-bottom: 0.5rem; }
  .schema-list { list-style: none; padding: 0; }
  .schema-list li { padding: 0.75rem 0; border-bottom: 1px solid #d0d7de; }
  .schema-list a { font-size: 1.1rem; font-weight: 600; text-decoration: none; color: #0969da; }
  .schema-list a:hover { text-decoration: underline; }
  .desc { color: #57606a; margin-top: 0.25rem; font-size: 0.9rem; }
  .links { margin-top: 0.25rem; font-size: 0.85rem; }
  .links a { color: #57606a; margin-right: 1rem; }
  .back { margin-bottom: 1rem; font-size: 0.9rem; }
</style>
</head>
<body>
<div class="back"><a href="../">← All versions</a></div>
<h1>ReproDB Data Schemas – ${ver}</h1>
<ul class="schema-list">
VHEREDOC

    for schema in "$src_dir"/*.schema.json; do
        [[ -f "$schema" ]] || continue
        local base title desc
        base="$(basename "$schema" .schema.json)"
        title=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['title'])" "$schema")
        desc=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('description','')[:120])" "$schema")
        cat >> "$out_dir/index.html" << EOF
  <li>
    <a href="${base}.html">${title}</a>
    <div class="desc">${desc}</div>
    <div class="links">
      <a href="md/${base}.md">Markdown</a>
      <a href="https://github.com/ReproDB/data-schemas/blob/${ver}/schemas/${base}.schema.json">Schema source</a>
    </div>
  </li>
EOF
    done

    cat >> "$out_dir/index.html" << 'VHEREDOC'
</ul>
</body>
</html>
VHEREDOC
}

# ---------------------------------------------------------------------------
# Collect version tags (sorted by semver).
# ---------------------------------------------------------------------------
VERSION_TAGS=()
if git tag -l 'v*' | grep -q '^v'; then
    while IFS= read -r t; do
        VERSION_TAGS+=("$t")
    done < <(git tag -l 'v*' | sort -V)
fi

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
STASH_NEEDED=false
if ! git diff --quiet 2>/dev/null; then
    STASH_NEEDED=true
fi

echo "Generating documentation from JSON Schema files..."
echo "  Found ${#VERSION_TAGS[@]} version tag(s): ${VERSION_TAGS[*]:-none}"

# ---------------------------------------------------------------------------
# Build docs for each tagged version by checking out the tag's schemas.
# ---------------------------------------------------------------------------
for tag in "${VERSION_TAGS[@]}"; do
    echo "── $tag ──"
    # Extract schemas from tagged commit into a temp dir
    TMPSCHEMAS="$(mktemp -d)"
    git archive "$tag" -- schemas/ | tar -x -C "$TMPSCHEMAS"
    _generate_version_docs "$TMPSCHEMAS/schemas" "$DOCS_DIR/$tag" "$tag"
    rm -rf "$TMPSCHEMAS"
done

# ---------------------------------------------------------------------------
# Build docs for HEAD (current schemas on disk).
# ---------------------------------------------------------------------------
# Determine the version label from the first schema file.
HEAD_VERSION=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('version','latest'))" \
    "$SCHEMAS_DIR"/summary.schema.json 2>/dev/null || echo "latest")
HEAD_TAG="v${HEAD_VERSION}"

echo "── HEAD ($HEAD_TAG) ──"
# If HEAD version already matches a tag, overwrite with current on-disk schemas
_generate_version_docs "$SCHEMAS_DIR" "$DOCS_DIR/$HEAD_TAG" "$HEAD_TAG"

# Symlink latest
ln -sfn "$HEAD_TAG" "$DOCS_DIR/latest"

# ---------------------------------------------------------------------------
# Build top-level version-picker index.
# ---------------------------------------------------------------------------
ALL_VERSIONS=()
for d in "$DOCS_DIR"/v*/; do
    [[ -d "$d" ]] && ALL_VERSIONS+=("$(basename "$d")")
done
# Sort by semver (strip v prefix, sort, re-add)
IFS=$'\n' ALL_VERSIONS=($(printf '%s\n' "${ALL_VERSIONS[@]}" | sort -t. -k1,1n -k2,2n -k3,3n)); unset IFS

cat > "$DOCS_DIR/index.html" << 'HEREDOC'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>ReproDB Data Schemas</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1rem; color: #24292f; }
  h1 { border-bottom: 1px solid #d0d7de; padding-bottom: 0.5rem; }
  .ver-list { list-style: none; padding: 0; }
  .ver-list li { padding: 0.6rem 0; border-bottom: 1px solid #d0d7de; display: flex; align-items: center; gap: 0.75rem; }
  .ver-list a { font-size: 1.1rem; font-weight: 600; text-decoration: none; color: #0969da; }
  .ver-list a:hover { text-decoration: underline; }
  .badge { font-size: 0.75rem; padding: 2px 8px; border-radius: 12px; font-weight: 600; }
  .badge-latest { background: #dafbe1; color: #1a7f37; }
  .meta { color: #57606a; font-size: 0.9rem; }
</style>
</head>
<body>
<h1>ReproDB Data Schemas</h1>
<p>Auto-generated documentation for all JSON/YAML data structures in the
<a href="https://github.com/ReproDB">ReproDB</a> project.
Select a schema version below.</p>
<h2>Versions</h2>
<ul class="ver-list">
HEREDOC

LATEST_VER="${ALL_VERSIONS[${#ALL_VERSIONS[@]}-1]}"
# List versions newest-first
for (( i=${#ALL_VERSIONS[@]}-1; i>=0; i-- )); do
    v="${ALL_VERSIONS[$i]}"
    badge=""
    if [[ "$v" == "$LATEST_VER" ]]; then
        badge='<span class="badge badge-latest">latest</span>'
    fi
    # Count schemas in that version dir
    nschemas=$(ls "$DOCS_DIR/$v"/*.html 2>/dev/null | grep -cv index || echo 0)
    cat >> "$DOCS_DIR/index.html" << EOF
  <li>
    <a href="${v}/">${v}</a>${badge}
    <span class="meta">${nschemas} schemas</span>
  </li>
EOF
done

cat >> "$DOCS_DIR/index.html" << 'HEREDOC'
</ul>
</body>
</html>
HEREDOC

echo "Documentation generated in $DOCS_DIR/"
echo "Versions: ${ALL_VERSIONS[*]}"
