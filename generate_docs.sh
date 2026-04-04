#!/usr/bin/env bash
# Generate HTML documentation from JSON Schema files using json-schema-for-humans.
# Output goes to docs/ which can be served via GitHub Pages.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEMAS_DIR="$SCRIPT_DIR/schemas"
DOCS_DIR="$SCRIPT_DIR/docs"

rm -rf "$DOCS_DIR"
mkdir -p "$DOCS_DIR"

echo "Generating documentation from JSON Schema files..."

# Generate HTML docs (one page per schema)
for schema in "$SCHEMAS_DIR"/*.schema.json; do
    basename="$(basename "$schema" .schema.json)"
    echo "  $basename"
    generate-schema-doc --config-file "$SCRIPT_DIR/jsfh-config.yaml" \
        "$schema" "$DOCS_DIR/${basename}.html"
done

# Generate a combined Markdown version for reference
mkdir -p "$DOCS_DIR/md"
for schema in "$SCHEMAS_DIR"/*.schema.json; do
    basename="$(basename "$schema" .schema.json)"
    generate-schema-doc --config-file "$SCRIPT_DIR/jsfh-config-md.yaml" \
        "$schema" "$DOCS_DIR/md/${basename}.md"
done

# Generate index page
cat > "$DOCS_DIR/index.html" << 'HEREDOC'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ResearchArtifacts Data Schemas</title>
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
</style>
</head>
<body>
<h1>ResearchArtifacts Data Schemas</h1>
<p>Auto-generated documentation for all JSON/YAML data structures in the
<a href="https://github.com/researchartifacts">researchartifacts</a> project.</p>

<h2>JSON Output Schemas</h2>
<ul class="schema-list">
HEREDOC

# Inject schema links into index
for schema in "$SCHEMAS_DIR"/*.schema.json; do
    basename="$(basename "$schema" .schema.json)"
    title=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['title'])" "$schema")
    desc=$(python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print(d.get('description','')[:120])" "$schema")
    cat >> "$DOCS_DIR/index.html" << EOF
  <li>
    <a href="${basename}.html">${title}</a>
    <div class="desc">${desc}</div>
    <div class="links">
      <a href="md/${basename}.md">Markdown</a>
      <a href="https://github.com/researchartifacts/data-schemas/blob/main/schemas/${basename}.schema.json">Schema source</a>
    </div>
  </li>
EOF
done

cat >> "$DOCS_DIR/index.html" << 'HEREDOC'
</ul>
</body>
</html>
HEREDOC

echo "Documentation generated in $DOCS_DIR/"
echo "Schemas: $(ls "$SCHEMAS_DIR"/*.schema.json | wc -l) files"
echo "HTML pages: $(ls "$DOCS_DIR"/*.html | wc -l) files"
