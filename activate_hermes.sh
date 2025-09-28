#!/bin/bash
# Script d'activation automatique de l'environnement Hermes
# Version Python 3.10 - Compatible VectorBT

echo "🚀 Activation de l'environnement Hermes avec VectorBT"

# Désactiver tous les environnements conda s'ils sont actifs
while [[ "$CONDA_DEFAULT_ENV" != "" ]]; do
    conda deactivate 2>/dev/null || break
done

# Désactiver tout environnement virtuel actif
if [[ "$VIRTUAL_ENV" != "" ]]; then
    deactivate 2>/dev/null || true
fi

# Naviguer vers le projet et activer l'environnement Poetry
cd /home/giujorge/Documents/Projets/Hermes
source .venv/bin/activate

echo "✅ Environnement Hermes activé avec Python 3.10 !"
echo "🐍 Python: $(python --version)"
echo "📍 Environnement: $VIRTUAL_ENV"

# Test VectorBT
echo "🧮 Test VectorBT:"
python -c "
try:
    import vectorbt as vbt
    import numpy as np
    import pandas as pd
    print(f'  ✅ VectorBT {vbt.__version__}')
    print(f'  ✅ NumPy {np.__version__}')  
    print(f'  ✅ Pandas {pd.__version__}')
    print('  🎯 Backtesting professionnel disponible!')
except Exception as e:
    print(f'  ❌ Erreur: {e}')
"

echo ""
echo "💡 Commands utiles:"
echo "  🔬 Jupyter Lab: jupyter lab notebooks/"
echo "  📊 Test VectorBT: python -c \"import vectorbt as vbt; print('OK')\""
echo "  📈 Notebook Smart Momentum: notebooks/data/strategies/trading_strategy_SmartMomentum.ipynb"

# Lancer un nouveau shell avec le bon prompt
exec bash --rcfile <(echo "PS1='(hermes-py3.10) \u@\h:\w\$ '")