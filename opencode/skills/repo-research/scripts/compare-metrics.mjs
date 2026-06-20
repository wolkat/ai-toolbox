#!/usr/bin/env node

import { existsSync, readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';

const VERSION = '1.0.0';

function die(msg) {
  console.error(`Error: ${msg}`);
  process.exit(1);
}

function usage() {
  console.log(`compare-metrics v${VERSION}

Extract quantitative metrics from graphify-out/graph.json files
for multi-repo comparison.

Usage:
  compare-metrics.mjs extract --manifest <path>    Extract metrics from all repos
  compare-metrics.mjs compare --manifest <path>    Print comparison table
  compare-metrics.mjs markdown --manifest <path>   Print comparison table (markdown)
  compare-metrics.mjs -h | --help                   Show this help

Options:
  --manifest <path>   Path to .slim/repo-research/manifest.json
  --format <fmt>     Output format: json (default), markdown
  --output <path>     Write output to file instead of stdout

Manifest format:
  The manifest lists repos with their local paths. Each repo should
  have a graphify-out/graph.json at its path or at <path>/graphify-out/graph.json.

Examples:
  compare-metrics.mjs extract --manifest .slim/repo-research/manifest.json
  compare-metrics.mjs compare --manifest .slim/repo-research/manifest.json --format markdown
`);
}

function parseArgs(argv) {
  const args = { command: null, manifest: null, format: 'json', output: null };
  const positional = [];

  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i];
    if (arg === '-h' || arg === '--help') {
      usage();
      process.exit(0);
    } else if (arg === '--manifest') {
      args.manifest = argv[++i];
    } else if (arg === '--format') {
      args.format = argv[++i];
    } else if (arg === '--output') {
      args.output = argv[++i];
    } else if (!arg.startsWith('-')) {
      positional.push(arg);
    }
  }

  args.command = positional[0] || null;
  return args;
}

function loadManifest(manifestPath) {
  if (!manifestPath) die('Missing --manifest path');
  if (!existsSync(manifestPath)) die(`Manifest not found: ${manifestPath}`);

  try {
    return JSON.parse(readFileSync(manifestPath, 'utf8'));
  } catch (e) {
    die(`Failed to parse manifest: ${e.message}`);
  }
}

function findGraphJson(repoPath) {
  const candidates = [
    path.join(repoPath, 'graphify-out', 'graph.json'),
    path.join(repoPath, '.slim', 'repo-research', 'repos', repoPath, 'graphify-out', 'graph.json'),
  ];

  for (const candidate of candidates) {
    if (existsSync(candidate)) return candidate;
  }
  return null;
}

function extractMetrics(graphPath, repoName) {
  if (!existsSync(graphPath)) {
    return { repo: repoName, error: `graph.json not found at ${graphPath}` };
  }

  let graph;
  try {
    graph = JSON.parse(readFileSync(graphPath, 'utf8'));
  } catch (e) {
    return { repo: repoName, error: `Failed to parse graph.json: ${e.message}` };
  }

  const nodes = graph.nodes || [];
  const edges = graph.links || graph.edges || [];

  const nodeCount = nodes.length;
  const edgeCount = edges.length;

  const communities = new Set();
  for (const n of nodes) {
    if (n.community !== undefined && n.community !== null) {
      communities.add(n.community);
    }
  }
  const communityCount = communities.size;

  const fileTypes = {};
  for (const n of nodes) {
    const ft = n.file_type || 'unknown';
    fileTypes[ft] = (fileTypes[ft] || 0) + 1;
  }

  const degreeMap = {};
  for (const e of edges) {
    const src = e.source || e.source_id || '';
    const tgt = e.target || e.target_id || '';
    degreeMap[src] = (degreeMap[src] || 0) + 1;
    degreeMap[tgt] = (degreeMap[tgt] || 0) + 1;
  }

  const degreeEntries = Object.entries(degreeMap);
  degreeEntries.sort((a, b) => b[1] - a[1]);
  const godNodes = degreeEntries.slice(0, 10).map(([id, deg]) => ({
    id: String(id).slice(0, 60),
    degree: deg,
  }));

  const edgeTypes = {};
  for (const e of edges) {
    const et = e.relation || e.type || 'unknown';
    edgeTypes[et] = (edgeTypes[et] || 0) + 1;
  }

  const testFileCount = nodes.filter((n) => {
    const sf = (n.source_file || '').toLowerCase();
    return sf.includes('.test.') || sf.includes('.spec.') || sf.includes('_test.') || sf.includes('/test/') || sf.includes('/tests/') || sf.includes('/__tests__/');
  }).length;

  const configFileCount = nodes.filter((n) => {
    const sf = (n.source_file || '').toLowerCase();
    return sf.includes('.config.') || sf.includes('config/') || sf.endsWith('.yaml') || sf.endsWith('.yml') || sf.endsWith('.toml') || sf.endsWith('.env');
  }).length;

  const avgDegree = nodeCount > 0 ? (edgeCount * 2 / nodeCount).toFixed(2) : '0';
  const density = nodeCount > 1 ? (edgeCount / (nodeCount * (nodeCount - 1) / 2)).toFixed(6) : '0';

  return {
    repo: repoName,
    nodeCount,
    edgeCount,
    communityCount,
    avgDegree: parseFloat(avgDegree),
    density: parseFloat(density),
    testFileCount,
    configFileCount,
    testRatio: nodeCount > 0 ? (testFileCount / nodeCount).toFixed(4) : '0',
    fileTypes: Object.entries(fileTypes)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([t, c]) => ({ type: t, count: c })),
    edgeTypes: Object.entries(edgeTypes)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([t, c]) => ({ type: t, count: c })),
    godNodes,
  };
}

function cmdExtract(args) {
  const manifest = loadManifest(args.manifest);
  const repos = manifest.repos || [];
  const results = [];

  for (const repo of repos) {
    const repoPath = repo.path || repo.url;
    const graphPath = findGraphJson(repoPath) || path.join(repoPath, 'graphify-out', 'graph.json');
    const metrics = extractMetrics(graphPath, repo.name || repo.url);
    results.push(metrics);
  }

  const output = { version: VERSION, extractedAt: new Date().toISOString(), theme: manifest.theme, repos: results };

  writeOutput(output, args);
  return 0;
}

function cmdCompare(args) {
  const manifest = loadManifest(args.manifest);
  const repos = manifest.repos || [];
  const metrics = [];

  for (const repo of repos) {
    const repoPath = repo.path || repo.url;
    const graphPath = findGraphJson(repoPath) || path.join(repoPath, 'graphify-out', 'graph.json');
    metrics.push(extractMetrics(graphPath, repo.name || repo.url));
  }

  if (args.format === 'markdown') {
    const md = formatMarkdown(metrics);
    writeOutput(md, args, true);
  } else {
    writeOutput({ version: VERSION, comparedAt: new Date().toISOString(), metrics }, args);
  }

  return 0;
}

function formatMarkdown(metrics) {
  const errors = metrics.filter((m) => m.error);
  const valid = metrics.filter((m) => !m.error);

  let md = '# Comparative Metrics\n\n';
  md += `Generated: ${new Date().toISOString()}\n\n`;

  if (errors.length) {
    md += '## Errors\n\n';
    for (const e of errors) {
      md += `- **${e.repo}**: ${e.error}\n`;
    }
    md += '\n';
  }

  md += '## Quantitative Overview\n\n';
  md += '| Metric |' + valid.map((m) => ` ${m.repo.slice(0, 30)} |`).join('') + '\n';
  md += '|--------|' + valid.map(() => '--------|').join('') + '\n';

  const rows = [
    ['Nodes', 'nodeCount'],
    ['Edges', 'edgeCount'],
    ['Communities', 'communityCount'],
    ['Avg Degree', 'avgDegree'],
    ['Density', 'density'],
    ['Test Files', 'testFileCount'],
    ['Config Files', 'configFileCount'],
    ['Test Ratio', 'testRatio'],
  ];

  for (const [label, key] of rows) {
    md += `| ${label} |` + valid.map((m) => ` ${m[key]} |`).join('') + '\n';
  }

  md += '\n## File Type Distribution\n\n';
  md += '| Type |' + valid.map((m) => ` ${m.repo.slice(0, 30)} |`).join('') + '\n';
  md += '|------|' + valid.map(() => '------|').join('') + '\n';

  const allTypes = new Set();
  for (const m of valid) {
    for (const ft of (m.fileTypes || [])) {
      allTypes.add(ft.type);
    }
  }

  for (const ft of [...allTypes].sort()) {
    md += `| ${ft} |`;
    for (const m of valid) {
      const entry = (m.fileTypes || []).find((f) => f.type === ft);
      md += ` ${(entry ? entry.count : 0)} |`;
    }
    md += '\n';
  }

  md += '\n## God Nodes (Top 10 by Degree)\n\n';
  for (const m of valid) {
    md += `### ${m.repo.slice(0, 40)}\n\n`;
    md += '| Node | Degree |\n|------|--------|\n';
    for (const g of (m.godNodes || []).slice(0, 5)) {
      md += `| ${g.id} | ${g.degree} |\n`;
    }
    md += '\n';
  }

  return md;
}

function writeOutput(data, args, isString = false) {
  const content = isString ? data : JSON.stringify(data, null, 2);

  if (args.output) {
    const dir = path.dirname(path.resolve(args.output));
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
    writeFileSync(args.output, content + '\n');
    console.log(`Written to ${args.output}`);
  } else {
    console.log(content);
  }
}

function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);

  switch (args.command) {
    case 'extract':
      return cmdExtract(args);
    case 'compare':
      return cmdCompare(args);
    default:
      usage();
      return 1;
  }
}

const currentFilePath = path.resolve(process.argv[1] || '');
const scriptPath = path.resolve(new URL(import.meta.url).pathname);
if (currentFilePath === scriptPath || process.argv[1]?.endsWith('compare-metrics.mjs')) {
  process.exit(main());
}