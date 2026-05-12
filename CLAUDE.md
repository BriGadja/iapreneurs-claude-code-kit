# CLAUDE.md — Template à adapter

> Ce fichier est un **template**. Tu le copies dans ton projet, tu adaptes les 5 couches du début à ton cas, tu gardes les 4 règles de comportement à la fin (elles s'appliquent à n'importe quel projet).

---

## Premier démarrage (instruction pour Claude Code)

> Cette section est lue par Claude Code à chaque ouverture de session. Elle est **non négociable** et s'applique avant tout autre travail.

À ton premier message de la session :

1. **Vérifie qu'un fichier `PRD.md` existe à la racine du projet.**
   - Si **OUI** : lis-le, résume-le à l'utilisateur en 2-3 phrases, puis demande "Qu'est-ce qu'on attaque aujourd'hui ?"
   - Si **NON** : continue à l'étape 2 — il faut d'abord cadrer ce qu'on construit.

2. **Demande à l'utilisateur ce qu'il veut construire** :
   > "Pas de `PRD.md` dans ce projet. Avant de coder, on cadre. Décris-moi ce que tu veux construire en quelques phrases, à qui ça sert, et le résultat final attendu. Si l'idée n'est pas encore claire, dis-le, on fera un `/brainstorm` d'abord."

3. **Selon la réponse**, propose la suite :
   - Idée **floue** ou exploratoire → propose `/brainstorm` (3 questions max, produit `brainstorm-{sujet}.md`).
   - Idée **claire** (vision + utilisateurs + résultat) → propose `/create-prd` (produit `PRD.md` structuré).
   - Idée **complexe / multi-domaines** → suggère de découper et de commencer par UN sous-projet.

4. **Ne commence aucun code avant qu'un `PRD.md` validé existe à la racine**. C'est la source de vérité pour `/plan`, `/execute`, `/validate`. Sans PRD, tu pars en cacahuète.

5. **Pose des questions sur la nature du projet** pendant `/brainstorm` ou `/create-prd` pour déterminer l'architecture appropriée — c'est `/plan` qui, plus tard, prend les décisions techniques (frameworks, intégrations externes, etc.). Tu n'imposes jamais une stack en silence : tu proposes et tu fais valider.

---

# {Nom de ton projet}

> Tout ce qui suit est à adapter à TON projet quand tu instancies ce template. Les exemples ci-dessous sont génériques.

## Identité

{En 2-3 phrases, dis ce qu'est ton projet, à qui il s'adresse, et le résultat qu'il livre. Exemple : "Application web qui automatise la génération de devis pour un freelance ou une petite agence française. Le client final reçoit des demandes via formulaire, un moteur n8n qualifie + calcule + stocke le devis, le pro relit et envoie."}

## Stack

{Liste les technos du projet. À remplir APRÈS que `/create-prd` ou `/plan` aient proposé une stack validée par l'utilisateur. Exemple :}

- Frontend : Next.js (App Router) + Tailwind + shadcn/ui
- Backend : n8n (moteur de génération) + Supabase (stockage + auth)
- Hosting : Vercel pour le frontend, n8n self-hosted ou cloud
- Langue : français uniquement (interface, contenus, mentions légales)

## Conventions

{Conventions de code et fichiers. Exemple :}

- Fichiers : kebab-case (`formulaire-devis.tsx`, pas `FormulaireDevis.tsx`)
- Structure : `src/app/` pour les pages, `src/components/` pour les composants réutilisables, `src/lib/` pour les helpers
- Commit : conventionnel (`feat:`, `fix:`, `chore:`)
- Format date : JJ/MM/AAAA
- Devises : EUR uniquement, format `1 234,56 EUR`

## Instructions

{Instructions spécifiques à ton projet. Exemple :}

- Toujours utiliser les composants shadcn/ui (jamais d'éléments HTML bruts pour boutons, inputs, dialog)
- Jamais de pop-ups JavaScript (`alert`, `confirm`) : utiliser des toasts (sonner)
- Toujours valider les téléphones au format français (`+33` ou `06/07`)
- Toujours valider les SIRET (14 chiffres) côté serveur
- TVA par défaut : 20% (configurable en base)

## Contexte métier

{Le vocabulaire et les règles métier propres à ton domaine. Exemple :}

- Un "devis" = document commercial avec mentions légales obligatoires (SIRET, RCS, TVA, conditions de paiement)
- Statuts : `brouillon` → `en_revue` → `envoye` → `accepte` / `refuse`
- Le devis n'est JAMAIS envoyé automatiquement. Le pro doit valider chaque envoi. C'est non-négociable.
- Numérotation : `DEV-AAAA-NNNN` (année + 4 chiffres incrémentaux)

---

## Règles de comportement

### 1. Réfléchir avant de coder

- Énonce tes hypothèses explicitement. Si tu n'es pas sûr, demande.
- Si plusieurs interprétations sont possibles, présente-les. Ne choisis pas en silence.
- Si une approche plus simple existe, dis-le.
- Si quelque chose n'est pas clair, arrête-toi. Nomme ce qui te pose problème. Demande.

### 2. Simplicité d'abord

- Le minimum de code qui résout le problème. Rien de spéculatif.
- Pas de feature au-delà de ce qui est demandé.
- Pas d'abstraction pour du code qui ne sert qu'une fois.
- Pas de "flexibilité" ou de "configurabilité" non demandée.
- Pas de gestion d'erreur pour des scénarios impossibles.
- Si tu écris 200 lignes et que ça peut tenir en 50, refais.

### 3. Modifications chirurgicales

- Touche uniquement aux fichiers que tu dois toucher.
- N'améliore pas le code adjacent qui n'est pas cassé.
- Garde le style existant, même si tu ferais autrement.
- Si tu vois du code mort sans rapport avec ta tâche, mentionne-le, ne le supprime pas.
- Test : chaque ligne modifiée doit tracer directement à la demande utilisateur.

### 4. Exécution orientée but

- Définis le critère de succès avant de commencer.
- Boucle jusqu'à ce que ce critère soit vérifié.
- Reformule la tâche en objectif vérifiable :
  - "Ajoute une validation" devient "Écris des tests pour les inputs invalides, puis fais-les passer"
  - "Corrige le bug" devient "Écris un test qui reproduit le bug, puis fais-le passer"
  - "Refactor X" devient "Vérifie que les tests passent avant et après"

---

## Skills disponibles dans ce kit

- `/brainstorm` — clarifier une idée vague (3 questions max), produit `brainstorm-{sujet}.md`. Route 2 délègue à `research-delegate` pour explorer projets similaires.
- `/create-prd` — produire un `PRD.md` structuré (7 sections, à valider avec l'utilisateur avant sauvegarde)
- `/plan` — découper UNE phase du PRD en tâches numérotées avec critères "Fait quand" ; étape 1bis scout le codebase via `research-delegate` pour éviter de planifier des fichiers qui existent déjà
- `/challenge` *(optionnel)* — passer le plan au crible avant `/execute` : 3 risques + 3 hypothèses non vérifiées + verdict GO/REWORK/STOP. À ajouter dans ton workflow quand tu te sens à l'aise — `/plan` reste suffisant pour démarrer.
- `/execute` — exécuter le plan tâche par tâche, cocher les cases au fur et à mesure. Délègue à `research-delegate` si bloqué par un manque d'info externe (doc d'API, syntaxe de lib).
- `/validate` — vérifier que la phase marche pour de vrai (3 options proposées : navigateur / n8n / autre). Étape 2bis parallélise via `research-delegate` pour les phases multi-dimensions.
- 7 skills `n8n-*` — voir `.claude/skills/n8n/README.md` (czlonkowski, MIT)

## Sous-agents disponibles dans ce kit

- `research-delegate` — sous-agent de recherche read-only. Invoqué automatiquement par `/brainstorm` (route 2), `/plan` (étape 1bis), `/execute` (blocage info externe), `/validate` (phase grosse). Lit jusqu'à 15 sources et renvoie une synthèse en 3-10 bullets. Garde ta fenêtre de contexte principale propre.

Tu n'as pas besoin de l'invoquer manuellement — les skills le font quand pertinent. Voir `.claude/agents/research-delegate.md` pour le détail.

## Workflow type

`/brainstorm` (si idée floue) → `/create-prd` → `/plan` Phase 1 → *(option `/challenge`)* → `/execute` → `/validate` → `/plan` Phase 2 → ...

`/challenge` est optionnel au départ. Ajoute-le quand tu sens que tes plans partent en exécution sans avoir vu un risque évident. C'est une amélioration de méthode qu'on ajoute au fil du temps, pas un prérequis.

---

## MCP & plugin à installer (recommandé)

Le kit fournit un `.mcp.json` **vide** par défaut. Tu n'es obligé de rien installer pour démarrer, mais voilà les MCP et le plugin qui te servent dans 90 % des projets du module.

### MCP — outils externes que Claude Code peut piloter

| MCP | Pour quoi faire | Commande d'installation |
|-----|-----------------|--------------------------|
| **Playwright** | Lancer un navigateur, cliquer, snapshot DOM, screenshot — utilisé par `/validate` option A | `claude mcp add playwright -- npx -y @playwright/mcp@latest` |
| **n8n** (czlonkowski) | Créer / valider / debugger des workflows n8n sans halluciner les nodes | `claude mcp add n8n -e N8N_API_URL=https://ton-instance-n8n.com -e N8N_API_KEY=ton_token -- npx n8n-mcp@latest` |

Une fois ajouté, l'entrée apparaît dans `.mcp.json`. Commit le fichier dans Git pour que ton équipe ait les mêmes outils.

> Pour n8n, récupère `N8N_API_URL` et `N8N_API_KEY` dans **Settings → API** de ton instance n8n.

### Plugin — `frontend-design`

Pour les apps web (Next.js + Tailwind + shadcn/ui), installe le plugin `frontend-design` officiel Anthropic — il sait construire des composants UI propres au lieu de générer du HTML générique :

```bash
claude plugin install frontend-design@claude-code-plugins
```

Tu l'utilises en disant simplement à Claude "construis-moi une page X avec un bouton qui fait Y" — le plugin se charge de structurer la sortie avec les bons composants shadcn.

### Vérifier que tout est en place

```bash
claude mcp list           # liste les MCP installés
claude plugin list        # liste les plugins installés
```

> Si tu n'es pas prêt à toucher aux MCP et plugins maintenant, laisse `.mcp.json` vide et reviens ici plus tard. Aucun skill core du kit n'en dépend pour fonctionner — `/validate` option A bascule sur "tu testes à la main" si Playwright n'est pas installé.
