# CLAUDE.md — Template à adapter

> Ce fichier est un **template**. Tu le copies dans ton projet, tu adaptes les 5 couches du début à ton cas, tu gardes les 4 règles de comportement à la fin (elles s'appliquent à n'importe quel projet).

---

# {Nom de ton projet}

## Identité

{En 2-3 phrases, dis ce qu'est ton projet, à qui il s'adresse, et le résultat qu'il livre. Exemple : "Application web qui automatise la génération de devis pour un freelance ou une petite agence française. Le client final reçoit des demandes via formulaire, un moteur n8n qualifie + calcule + stocke le devis, le pro relit et envoie."}

## Stack

{Liste les technos du projet. Exemple :}

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

- `/brainstorm` — clarifier une idée vague (3 questions max)
- `/create-prd` — produire un Product Requirements Document structuré
- `/plan` — découper UNE phase en tâches numérotées avec critères "Fait quand"
- `/execute` — exécuter le plan tâche par tâche, cocher les cases
- `/validate` — vérifier que la phase marche pour de vrai (3 options proposées)
- 7 skills `n8n-*` — voir `.claude/skills/n8n/README.md` (czlonkowski, MIT)

Workflow type : `/brainstorm` → `/create-prd` → `/plan` Phase 1 → `/execute` → `/validate` → `/plan` Phase 2 → ...
