#!/bin/bash

# Quick test of the threat modeling setup (dry run)
# This verifies the configuration without actually running attacks

echo "🔍 Threat Modeling Setup Verification"
echo "====================================="
echo ""

# Check workflow files
echo "1. Checking GitHub Actions workflows..."
if [ -f ".github/workflows/threat-modeling.yml" ]; then
    echo "   ✅ threat-modeling.yml found"
else
    echo "   ❌ threat-modeling.yml missing"
    exit 1
fi

if [ -f ".github/workflows/security-check.yml" ]; then
    echo "   ✅ security-check.yml found"
else
    echo "   ❌ security-check.yml missing"
    exit 1
fi

echo ""
echo "2. Checking documentation..."
if [ -f ".github/THREAT_MODELING.md" ]; then
    echo "   ✅ THREAT_MODELING.md found"
else
    echo "   ❌ THREAT_MODELING.md missing"
fi

if [ -f ".github/SETUP_COMPLETE.md" ]; then
    echo "   ✅ SETUP_COMPLETE.md found"
else
    echo "   ❌ SETUP_COMPLETE.md missing"
fi

echo ""
echo "3. Checking backend configuration..."
if [ -f "back/pom.xml" ]; then
    echo "   ✅ Maven project found"
else
    echo "   ❌ Maven project missing"
fi

echo ""
echo "4. Validating workflow syntax..."
if command -v yamllint &> /dev/null; then
    yamllint .github/workflows/*.yml 2>&1 | head -5
else
    echo "   ⚠️  yamllint not installed (optional)"
    # Basic YAML check
    if grep -q "^name:" .github/workflows/threat-modeling.yml; then
        echo "   ✅ Workflow file appears valid"
    fi
fi

echo ""
echo "5. Checking for Attack Simulation tool..."
ATTACK_SIM_PATH="../../../FDSI/Attack-Simulation-FDSI"
if [ -d "$ATTACK_SIM_PATH" ]; then
    echo "   ✅ Attack-Simulation-FDSI found at $ATTACK_SIM_PATH"
    if [ -f "$ATTACK_SIM_PATH/attack-engine/AttackEngine.java" ]; then
        echo "   ✅ AttackEngine.java found"
    else
        echo "   ⚠️  AttackEngine.java not found"
    fi
else
    echo "   ⚠️  Attack-Simulation-FDSI not found (expected at $ATTACK_SIM_PATH)"
    echo "      Workflow will checkout from GitHub"
fi

echo ""
echo "========================================="
echo "✅ Setup verification complete!"
echo ""
echo "Next steps:"
echo "1. Review the configuration:"
echo "   cat .github/SETUP_COMPLETE.md"
echo ""
echo "2. Commit and push to trigger workflow:"
echo "   git add .github/"
echo "   git commit -m 'Add automated threat modeling'"
echo "   git push origin develop"
echo ""
echo "3. View results in GitHub Actions:"
echo "   https://github.com/YOUR_USERNAME/AWS_Login_Service-TDSE/actions"
echo ""
