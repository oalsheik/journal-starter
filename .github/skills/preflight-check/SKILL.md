# Preflight Check Skill

You are a submission-readiness validator for a LearnToCloud journal capstone project.
When asked to run the preflight check, execute each step below using bash commands, report the result (PASS/FAIL), and fix any issues you find.

## Instructions

Run the following checks in order. For each check, print a clear PASS ✅ or FAIL ❌ with a short reason.

---

### 1. Required Files Check

Run this exact bash block to verify all required files exist:

```bash
REQUIRED=(
  "Dockerfile"
  ".dockerignore"
  "README.md"
  ".github/workflows/ci.yml"
  "infra/main.tf"
  "infra/variables.tf"
  "infra/outputs.tf"
  "infra/providers.tf"
  "k8s/deployment.yaml"
  "k8s/service.yaml"
  "k8s/secrets.yaml.example"
  "api"
  "uv.lock"
)

MISSING=()
for f in "${REQUIRED[@]}"; do
  [ -f "$f" ] || MISSING+=("$f")
done

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "✅ PASS: All required files present"
else
  echo "❌ FAIL: Missing files:"
  printf '  - %s\n' "${MISSING[@]}"
fi
```

---

### 2. Dockerfile Correctness Check

```bash
echo "=== Dockerfile checks ==="

# Base image must be python:3.12-slim
if grep -q "FROM python:3.12-slim" Dockerfile; then
  echo "✅ PASS: Base image is python:3.12-slim"
else
  echo "❌ FAIL: Base image is not python:3.12-slim (found: $(grep '^FROM' Dockerfile))"
fi

# Must use uv, not pip install
if grep -q "uv sync\|uv pip" Dockerfile; then
  echo "✅ PASS: Uses uv for dependency installation"
else
  echo "❌ FAIL: Does not use uv for dependency installation"
fi

# Must expose port 8000
if grep -q "EXPOSE 8000" Dockerfile; then
  echo "✅ PASS: Exposes port 8000"
else
  echo "❌ FAIL: Does not expose port 8000"
fi

# Must use uvicorn entrypoint
if grep -q "uvicorn api.main:app" Dockerfile; then
  echo "✅ PASS: Uses uvicorn api.main:app entrypoint"
else
  echo "❌ FAIL: Entrypoint does not use uvicorn api.main:app"
fi
```

---

### 3. .dockerignore Check

```bash
echo "=== .dockerignore checks ==="
for pattern in ".git" "tests/" ".devcontainer"; do
  if grep -q "$pattern" .dockerignore 2>/dev/null; then
    echo "✅ PASS: .dockerignore excludes $pattern"
  else
    echo "❌ FAIL: .dockerignore missing exclusion for $pattern"
  fi
done
```

---

### 4. /health Endpoint Check

```bash
echo "=== /health endpoint check ==="
if grep -q '"/health"\|"/health"' api/main.py; then
  echo "✅ PASS: /health endpoint found in api/main.py"
else
  echo "❌ FAIL: No /health endpoint in api/main.py"
fi
```

---

### 5. Kubernetes Manifests YAML Validation

```bash
echo "=== Kubernetes YAML validation ==="
if command -v python3 &>/dev/null; then
  for f in k8s/*.yaml k8s/*.yml; do
    [ -f "$f" ] || continue
    python3 -c "import yaml; list(yaml.safe_load_all(open('$f')))" 2>&1 && echo "✅ PASS: $f is valid YAML" || echo "❌ FAIL: $f has invalid YAML"
  done
else
  echo "⚠️  SKIP: python3 not available for YAML validation"
fi

# Check IMAGE_PLACEHOLDER in deployment.yaml
if grep -q "IMAGE_PLACEHOLDER" k8s/deployment.yaml 2>/dev/null; then
  echo "✅ PASS: k8s/deployment.yaml uses IMAGE_PLACEHOLDER"
else
  echo "❌ FAIL: k8s/deployment.yaml must use IMAGE_PLACEHOLDER as image reference"
fi

# Check /health probes
if grep -q "/health" k8s/deployment.yaml 2>/dev/null; then
  echo "✅ PASS: Health probes reference /health"
else
  echo "❌ FAIL: No /health probe found in k8s/deployment.yaml"
fi
```

---

### 6. Terraform Validate

```bash
echo "=== Terraform validation ==="
if command -v terraform &>/dev/null; then
  cd infra && terraform init -backend=false -input=false > /dev/null 2>&1 && terraform validate && echo "✅ PASS: Terraform config is valid" || echo "❌ FAIL: Terraform validation failed"
  cd ..
else
  echo "⚠️  SKIP: terraform not installed — validating file structure instead"
  for f in infra/main.tf infra/variables.tf infra/outputs.tf infra/providers.tf; do
    [ -f "$f" ] && echo "✅ PASS: $f exists" || echo "❌ FAIL: $f missing"
  done
fi
```

---

### 7. CI Workflow Jobs Check

```bash
echo "=== CI workflow check ==="
CI_FILE=".github/workflows/ci.yml"
if [ ! -f "$CI_FILE" ]; then
  echo "❌ FAIL: $CI_FILE not found"
else
  JOB_COUNT=$(grep -c "^\s\{2\}[a-z].*:$" "$CI_FILE" || true)
  echo "  Jobs found: $JOB_COUNT"

  if grep -q "astral-sh/setup-uv\|install.*uv" "$CI_FILE"; then
    echo "✅ PASS: CI installs uv"
  else
    echo "❌ FAIL: CI does not install uv via astral-sh/setup-uv"
  fi

  if grep -q "docker build\|acr build" "$CI_FILE"; then
    echo "✅ PASS: CI builds Docker image"
  else
    echo "❌ FAIL: CI does not build Docker image"
  fi

  if grep -q "docker push\|acr build" "$CI_FILE"; then
    echo "✅ PASS: CI pushes Docker image"
  else
    echo "❌ FAIL: CI does not push Docker image"
  fi

  if grep -q "kubectl apply\|k8s/\|kubernetes/" "$CI_FILE"; then
    echo "✅ PASS: CI deploys to Kubernetes"
  else
    echo "❌ FAIL: CI does not deploy to Kubernetes"
  fi

  if grep -q "github.sha\|GITHUB_SHA" "$CI_FILE"; then
    echo "✅ PASS: Image tagged with commit SHA"
  else
    echo "❌ FAIL: Image not tagged with commit SHA"
  fi
fi
```

---

### 8. Summary

After running all checks, provide:
- A count of PASS vs FAIL
- A prioritized list of issues to fix
- Prompt to fix each FAIL if you can.
- Re-run failed checks after fixing to confirm resolution
