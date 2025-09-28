#!/bin/bash
# Script d'activation automatique de l'environnement Hermes

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

echo "✅ Environnement Hermes activé !"
echo "🐍 Python: $(python --version)"
echo "📍 Environnement: $VIRTUAL_ENV"

# Lancer un nouveau shell avec le bon prompt
exec bash --rcfile <(echo "PS1='(hermes) \u@\h:\w\$ '")