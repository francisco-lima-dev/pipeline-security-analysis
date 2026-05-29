# Security Analysis Research Pipeline

> Building a security analysis research pipeline to benchmark 5 tools (SAST, DAST, AI-based and custom agent) across 50 code samples. Evaluating detection rates, false positive rates and coverage across different analysis approaches.
> Most security tool comparisons lack reproducible environments. This pipeline standardizes analysis conditions across tools using Docker, enabling fair comparison of detection rates and false positive rates.

![Docker](https://img.shields.io/badge/Docker-blue) ![Semgrep](https://img.shields.io/badge/Semgrep-blue) ![CodeQL](https://img.shields.io/badge/CodeQL-blue) ![Snyk](https://img.shields.io/badge/Snyk_Code-blue) ![Research](https://img.shields.io/badge/Research_Project-green) ![Status](https://img.shields.io/badge/Status-In_Progress-yellow)

## About the research

This pipeline was built to support an undergraduate research project comparing the effectiveness of 5 security analysis tools across 50 code samples. The goal is to evaluate detection rates, false positive rates, and coverage across different analysis approaches:

- 2 SAST tools (static analysis)
- 1 DAST tool (dynamic analysis)
- 1 AI-based analysis tool
- 1 custom-built agent

## What it does

- Runs security analysis automatically on any repository via Docker
- Supports Semgrep, CodeQL and Snyk Code — each in an isolated container
- Identifies potential security vulnerabilities
- Generates structured JSON output for research analysis
- Designed to scale. Same pipeline will run DAST and AI-based tools

## Pipeline architecture

Each tool runs in its own independent Docker container. The flow per repository:

```
Repo URL
  └─→ Docker Container
        ├─→ Semgrep
        │       └─→ Raw JSON → Structured JSON
        │
        ├─→ CodeQL
        │       └─→ SARIF → JSON → Structured JSON
        │
        └─→ Snyk Code
                └─→ SARIF + JSON → Structured JSON
```

## Folder structure

```
pipeline-security-analysis/
├── ic-security-lab-codeql/
│   ├── Dockerfile
│   ├── scripts/
│   │   ├── run_codeql.sh
│   │   └── convert_sarif.py
│   ├── results_json/
│   ├── results_sarif/
│   └── treated_results/
│
├── ic-security-lab-semgrep/
│   ├── Dockerfile
│   ├── scripts/
│   │   └── run_semgrep.sh
│   ├── results_json/
│   └── treated_results/
│
└── ic-security-lab-snyk-code/
    ├── Dockerfile
    ├── scripts/
    │   └── run_snyk.sh
    ├── results_json/
    ├── results_sarif/
    └── treated_results/
```

## Tech stack

- **Docker** — isolated, reproducible analysis environment per tool
- **Shell Script** — pipeline orchestration
- **Python** — SARIF to JSON conversion (CodeQL)
- **Semgrep** — SAST tool
- **CodeQL** — SAST tool (GitHub)
- **Snyk Code** — AI-assisted SAST tool

## How to use

Each tool lives in its own folder with its own Dockerfile. The workflow is the same for all: build the image, add your repo list to `repos.txt`, then run.

Before running, create a `repos.txt` file inside the tool's folder with one GitHub URL per line:

```
https://github.com/owner/repo-name
```

### Semgrep

```bash
cd ic-security-lab-semgrep

docker build -t ic-security-lab-semgrep:v1 .

docker run --rm -v $(pwd):/workspace ic-security-lab-semgrep:v1
```

### CodeQL

```bash
cd ic-security-lab-codeql

docker build -t ic-security-lab-codeql:v1 .

docker run --rm -v $(pwd):/workspace ic-security-lab-codeql:v1
```

### Snyk Code

Snyk requires an API token. Get yours at [snyk.io](https://snyk.io) and pass it via environment variable:

```bash
cd ic-security-lab-snyk-code

docker build -t ic-security-lab-snyk:v1 .

docker run --rm -v $(pwd):/workspace -e SNYK_TOKEN=your_token_here ic-security-lab-snyk:v1
```

## Output example

Results are written to `results_json/` and `treated_results/` inside each tool's folder. The format varies per tool.

### Semgrep

```json
{
    "version": "1.162.0",
    "results": [
        {
            "check_id": "javascript.browser.security.eval-detected.eval-detected",
            "path": "ChatHandler.js",
            "start": { "line": 54, "col": 41 },
            "end": { "line": 54, "col": 69 },
            "extra": {
                "message": "Detected the use of eval(). eval() can be dangerous if used to evaluate dynamic content.",
                "metadata": {
                    "cwe": ["CWE-95: Improper Neutralization of Directives in Dynamically Evaluated Code ('Eval Injection')"],
                    "owasp": ["A03:2021 - Injection"]
                },
                "severity": "WARNING"
            }
        }
    ]
}
```

### CodeQL

CodeQL outputs SARIF, which is converted to JSON by `scripts/convert_sarif.py`. The `treated_results/` folder contains the formatted version:

```json
{
    "version": "2.1.0",
    "runs": [
        {
            "results": [
                {
                    "ruleId": "js/xss-through-exception",
                    "message": {
                        "text": "Exception text is reinterpreted as HTML without escaping meta-characters."
                    },
                    "locations": [
                        {
                            "physicalLocation": {
                                "artifactLocation": { "uri": "lambda/local/index.ts" },
                                "region": { "startLine": 13, "startColumn": 45 }
                            }
                        }
                    ]
                }
            ]
        }
    ]
}
```

### Snyk Code

Snyk outputs both SARIF (`results_sarif/`) and JSON (`results_json/`). Example coming after first run.

## Research progress

- [x] Docker pipeline configured
- [x] SAST analysis with Semgrep
- [x] SAST analysis with CodeQL
- [x] Snyk Code pipeline (Dockerfile + script ready)
- [ ] DAST analysis
- [ ] AI-based analysis tool
- [ ] Custom agent
- [ ] AWS deployment for large-scale runs
- [ ] Comparative analysis across all 50 samples

## Notes

- This repository does not include the research dataset or analysis results
- Results are generated locally at runtime and are not committed to the repository
- Main focus is pipeline infrastructure and reproducibility
