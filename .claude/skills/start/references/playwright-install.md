# Playwright MCP — install + test (Étape 5a)

> **Lis ce fichier uniquement si** `/start` Étape 5a vérifie la présence de Playwright MCP.
>
> But : avoir Playwright installé pour que `/execute` et `/validate` puissent vérifier l'UI en navigateur réel (interdit de tester en `file://` — anti-pattern explicite côté `/execute` Étape 2.5).

## Procédure

Lance : `claude mcp list`

- Si `playwright` est listé → ✅ "Playwright OK." Test rapide : *"Tu veux que je vérifie qu'il marche ? (snapshot rapide de google.com)"* — si oui, invoque le MCP pour naviguer + snapshot, rapporte succès/échec.
- Si absent → propose :
  ```
  claude mcp add playwright -- npx -y @playwright/mcp@latest
  ```
  *"Copie-colle dans un autre terminal, dis-moi quand c'est fait."* Attends confirmation. Puis re-`claude mcp list` pour valider.

## Retour au SKILL.md

Une fois Playwright vérifié (présent ou installé), retourne à l'Étape 5b du SKILL.md (n8n MCP si `project_uses_n8n: true`, sinon skip vers 5c).
