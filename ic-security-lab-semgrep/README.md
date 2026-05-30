# Security Analysis Research Pipeline

> Building a security analysis research pipeline to benchmark 5 tools (SAST, DAST, AI-based and custom agent) across 50 code samples. Currently operational with Semgrep SAST via Docker. Evaluating detection rates, false positive rates and coverage across different analysis approaches.
> Most security tool comparisons lack reproducible environments. This pipeline standardizes analysis conditions across tools using Docker, enabling fair comparison of detection rates and false positive rates.

![Docker](https://img.shields.io/badge/Docker-blue) ![Semgrep](https://img.shields.io/badge/Semgrep-blue) ![Research](https://img.shields.io/badge/Research_Project-green) ![Status](https://img.shields.io/badge/Status-In_Progress-yellow)

## About the research

This pipeline was built to support an undergraduate research project comparing the effectiveness of 5 security analysis tools across 50 code samples. The goal is to evaluate detection rates, false positive rates, and coverage across different analysis approaches:

- 2 SAST tools (static analysis)
- 1 DAST tool (dynamic analysis)
- 1 AI-based analysis tool
- 1 custom-built agent

## What it does

- Runs SAST analysis automatically on any repository
- Identifies potential security vulnerabilities
- Generates structured JSON output for research analysis
- Designed to scale. Same pipeline will run DAST and AI-based tools

## Pipeline architecture

```
Repo URL
  └─→ Docker Container
        └─→ Semgrep SAST Analysis
                └─→ Raw Json Report (results)
                       └─→ Structured JSON Report (treated_results)
```

## Tech stack

- **Docker** — isolated, reproducible analysis environment
- **Semgrep** — static application security testing (SAST)
- **Shell Script** — pipeline orchestration

## How to use

### 1. Build the image

```bash
docker build -t ic-security-lab:v1 .
```

### 2. Run analysis

```bash
docker run --rm -v $(pwd):/workspace ic-security-lab-semgrep:v1  
```

### Output example

```json
"version": "1.162.0",
    "results": [
        {
            "check_id": "javascript.browser.security.eval-detected.eval-detected",
            "path": "10. WhatsApp Chatlist (LRU Cache)/ChatHandler.js",
            "start": {
                "line": 54,
                "col": 41,
                "offset": 1764
            },
            "end": {
                "line": 54,
                "col": 69,
                "offset": 1792
            },
            "extra": {
                "message": "Detected the use of eval(). eval() can be dangerous if used to evaluate dynamic content. If this content can be input from outside the program, this may be a code injection vulnerability. Ensure evaluated content is not definable by external sources.",
                "metadata": {
                    "cwe": [
                        "CWE-95: Improper Neutralization of Directives in Dynamically Evaluated Code ('Eval Injection')"
                    ],
                    "owasp": [
                        "A03:2021 - Injection",
                        "A05:2025 - Injection"
                    ],
```

Full example at `treated_results/Data-Structure-in-Real-Life-Projects.json`

## Research progress

- [x] Docker pipeline configured
- [x] SAST analysis with Semgrep
- [ ] Integration with second SAST tool
- [ ] DAST analysis
- [ ] AI-based analysis tool
- [ ] Custom agent
- [ ] AWS deployment for large-scale runs
- [ ] Comparative analysis across all 50 samples

## Notes

- This repository does not include the final research dataset
- Available results are execution examples only
- Main focus is pipeline infrastructure and reproducibility


