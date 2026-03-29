#!/bin/bash

# Commit all threat modeling setup and fixes

cd "$(dirname "$0")"

echo "📝 Committing threat modeling setup and fixes..."
echo ""

# Stage threat modeling files
git add .github/
git add README.md
git add QUICK_REFERENCE.md
git add verify-setup.sh
git add validate-workflows.sh

# Stage compilation fixes
git add back/src/main/java/com/secure/login/model/User.java
git add back/src/main/java/com/secure/login/security/AuthRateLimitFilter.java

echo "Files staged for commit:"
git status --short

echo ""
echo "Creating commit..."

git commit -m "Add automated threat modeling with Attack-Simulation-FDSI

- Add GitHub Actions workflow for automated security testing
- Add quick security check for pull requests
- Fix compilation errors in AuthRateLimitFilter and User model
- Add comprehensive documentation for threat modeling
- Add validation and verification scripts

Features:
- Automated attack simulation (SQL injection, brute force, info leak)
- Weekly scheduled scans
- PR comments with vulnerability summaries
- Interactive dashboard reports
- JSON results with detailed analysis

Fixes:
- Use HTTP 429 numeric value instead of SC_TOO_MANY_REQUESTS constant
- Add @Builder.Default to User.enabled field"

echo ""
echo "✅ Commit created!"
echo ""
echo "Next: Push to remote"
echo "  git push origin develop"
