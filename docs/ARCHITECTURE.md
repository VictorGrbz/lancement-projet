# Architecture du plugin `lancement-projet`

> Document de conception (étape 1 du PLAN.md). Il fixe la liste des composants, leurs noms, leur rôle et qui peut les invoquer, avant d'écrire quoi que ce soit. Il est écrit en français pour validation par le mainteneur ; les noms de composants sont en anglais, comme les skills, l'agent et les messages du plugin.

## 1. Objectif et principes

Le plugin emballe une méthode de travail générique avec Claude Code : cadrage guidé, PLAN.md par étapes, exécution étape par étape, commit sécurisé, finition web.

Principes de conception :

1. **Aucune présupposition personnelle** : pas de stack par défaut, pas d'hébergement imposé, pas de dossiers ou fichiers propres à un utilisateur.
2. **Tout est manuel, sauf l'agent** : quatre skills, tous à invocation manuelle (voir §4). Le modèle ne lance jamais seul un skill qui écrit des fichiers ou publie du code.
3. **L'interaction reste dans le fil principal** : un sous-agent lancé via le tool Agent n'a pas accès à `AskUserQuestion`. Toute question à l'utilisateur est donc posée par un skill, jamais par un agent. Aucun skill n'utilise `context: fork`.
4. **Le PLAN.md est l'unique état partagé** entre sessions (voir §5 et §6).
5. **Défense en profondeur sur les garde-fous critiques** : les interdictions (`git add -A`, `--amend`, `--no-verify`, `--force`...) sont écrites dans le skill et, si le format de motif le permet, dans `disallowed-tools` (à vérifier à l'étape 3).
6. **Skills et messages en anglais**, mais les sorties adaptées à l'utilisateur (message de commit, contenu du PLAN.md) suivent sa langue.

## 2. Vue d'ensemble des composants

| Composant | Type | Invocation | Commande |
|---|---|---|---|
| `new-project` | skill | manuelle uniquement | `/lancement-projet:new-project` |
| `run-step` | skill | manuelle uniquement | `/lancement-projet:run-step` |
| `commit` | skill | manuelle uniquement | `/lancement-projet:commit` |
| `finish-web` | skill | manuelle uniquement | `/lancement-projet:finish-web` |
| `project-manager` | agent | modèle (appelé par `new-project`) ; pas de commande | n/a |
| `check-secrets` | hook | automatique (PostToolUse) | **différé à la v1.1** (voir §3.6) |

## 3. Fiches composants

### 3.1 Skill `new-project`

- **Rôle** : mener un cadrage guidé avec l'utilisateur, puis produire le PLAN.md du projet (fiche de cadrage + étapes).
- **Conservé** :
  - lancement du cadrage ; questions de contraintes (délai, budget, technique, type de projet) ;
  - question du dépôt Git dédié (nom demandé, jamais choisi seul ; public par défaut, signalé explicitement) ;
  - proposition de stack avec recherche web ciblée, et recherche de briques existantes avec vérification de maintenance avant de tout réinventer ;
  - PLAN.md conforme au contrat du §5 (Cadrage produit, étapes avec objectif / fichiers / destination / fait quand, étape 0 d'init Git si dépôt dédié, section Vérification automatique avec hook PostToolUse proposé) ;
  - revue de cadrage (par l'agent `project-manager`) avant validation ;
  - si un PLAN.md existe déjà, présenter les modifications au lieu de l'écraser.
- **CLAUDE.md de l'exécutant** : après le choix de la stack et avant l'écriture du plan, le skill crée un `CLAUDE.md` dans le dossier du projet à partir de `executor-claude-template.md`. Une session ouverte dans ce dossier n'hérite d'aucune autre consigne : ce fichier est son socle commun (une étape à la fois, jamais « fait » sans preuve, arrêts aux lignes `Stop`, règles Git). S'il existe déjà, rien n'est écrasé : le skill propose d'y ajouter une section « Executor rules » et n'écrit qu'après confirmation.
- **Réglages du projet** : le `.claude/settings.json` du projet cible n'impose ni `model` ni `effortLevel` ; seul le hook de vérification est proposé, après validation. Aucun hébergement, stockage ni stack par défaut.
- **Fichiers d'appui** : `interview.md` (interview en 5 points : vision, 2 à 3 cas d'usage en histoires courtes, critères de succès mesurables avec refus du non vérifiable, hors périmètre avec 2 à 3 exclusions proposées, ce qui peut mal tourner avec chaque risque et sa parade ; un point à la fois ; 2 ou 3 options avec pour et contre quand une réponse ouvre plusieurs voies ; fiche validée section par section ; relance sur le vague ; mode brouillon ; jamais de stack pendant l'interview), `plan-template.md` (contrat du PLAN.md) et `executor-claude-template.md` (modèle du CLAUDE.md de l'exécutant).
- **Invocation** : manuelle uniquement (`disable-model-invocation: true`). Il écrit des fichiers, effectue des recherches web et pose de nombreuses questions : il ne doit jamais partir sur une phrase anodine.

### 3.2 Skill `run-step`

- **Rôle** : lire le PLAN.md, prendre la première étape non faite, l'exécuter, vérifier son critère de « fait », la marquer comme faite, puis proposer un commit.
- **Règles** : une seule étape par appel ; si le critère de fait n'est pas vérifiable, arrêt et question ; arrêt obligatoire à chaque ligne `Stop` de l'étape, jusqu'au feu vert de l'utilisateur ; jamais d'enchaînement sur l'étape suivante sans validation ; ne modifie que le PLAN.md (statut) et les fichiers de l'étape ; le récapitulatif liste tout ce qui a été ajouté sans être demandé (ou dit « nothing added ») ; termine en **suggérant** `/lancement-projet:commit` (texte, pas d'appel : un skill manuel ne peut pas en lancer un autre).
- **Invocation** : manuelle uniquement. Il modifie le projet ; un déclenchement sur une phrase du type « on en est où ? » serait dangereux.

### 3.3 Skill `commit`

- **Rôle** : enregistrer le travail en un commit propre puis, séparément, le pousser, avec deux validations distinctes.
- **Langue** : le message suit la langue et le style des commits existants (voir §8).
- **Garde-fous conservés** : validations séparées pour le commit et le push ; jamais `git add -A` ni `git add .` ; alerte sur les fichiers sensibles ; jamais `--amend`, `--no-verify`, `--force`, `--force-with-lease`, `-f` ; pas de push si la branche locale est en retard ; vérification du remote, de l'URL et de la nouvelle branche distante avant push ; `git status` après chaque action.
- **Frontmatter prévu** : `disable-model-invocation: true` ; `allowed-tools` limité aux commandes git en lecture (`status`, `diff`, `log`, `branch`, `remote`, `fetch`) ; `add`, `commit` et `push` ne sont volontairement **pas** pré-approuvés, afin que le mécanisme de permissions ajoute un troisième filet.
- **Invocation** : manuelle uniquement. Un commit ou un push ne doit jamais partir sans demande explicite.

### 3.4 Skill `finish-web`

- **Rôle** : passe de finition d'un projet web, enchaînant audit, critique, relecture indépendante, validation, polish et diagnostic final avec le plugin Impeccable.
- **Prérequis** : le plugin **Impeccable** doit être installé (version testée : 4.1.1) ; sinon, le skill explique l'installation et s'arrête.
- **Enchaînement** : (1) vérif Impeccable, (2) cible, (3) audit, (4) critique, (5) relecture indépendante, (6) comptage des couleurs en dur, (7) synthèse et validation explicite, (8) polish (P0 d'abord, plafond de passes d'Impeccable respecté), (9) diagnostic final (sévérité auto appliquée, mention signalée, route jamais sans validation), (10) récapitulatif avant/après puis **proposition** de commit, sans commit automatique.
- **Relecture indépendante** : un seul sous-agent `impeccable:impeccable-finish-reviewer`, en rapport seul, relit le build contre la direction du projet, les maquettes approuvées (`.impeccable/mocks/`) et le PLAN.md. Ce relecteur n'a pas de navigateur : il exige des captures `desktop.png` et `mobile.png` dans `.impeccable/review/`, faute de quoi il répond `recapture`. L'étape est donc **sautée proprement, en le disant**, si l'agent n'est pas disponible, s'il n'existe aucune maquette approuvée ou si les captures manquent. Sa conclusion (`ship`, `fix`, `rebuild`, `recapture`) est rapportée telle quelle.
- **Comptage des couleurs** : le nombre de valeurs de couleur écrites en dur dans le code (hors fichier de tokens ou de thème) est compté avant et après les corrections, avec la même méthode, et donné au récapitulatif.
- **Dépendance** : Impeccable est requis et documenté comme tel dans le README. Pas de version dégradée sans lui en v1.
- **Invocation** : manuelle uniquement (`disable-model-invocation: true`). Workflow long et modifiant le code.

### 3.5 Agent `project-manager`

- **Rôle** : relire, dans un contexte neuf et sans interaction, la fiche de cadrage et le PLAN.md produits par `new-project`, et renvoyer une liste de défauts (aucune réécriture).
- **Ce qu'il ne fait pas** : aucune interview (`AskUserQuestion` n'est pas disponible aux sous-agents) ; les règles d'interview vivent dans `skills/new-project/interview.md`.
- **Contrôles** : cadrage en cinq sections (dont les risques, chacun avec sa parade) ; critères de succès mesurables ; pas de stack dans le cadrage (un service externe peut être nommé comme dépendance dans un risque) ; hors périmètre présent ; chaque étape a objectif, fichiers, destination, fait quand vérifiable ; étapes de taille raisonnable ; lignes `Stop` aux bons endroits (ni oubliées, ni superflues) ; `CLAUDE.md` présent à côté du PLAN.md, sinon une étape du plan le crée ; étape 0 Git présente si dépôt dédié ; cohérence du contrat (§5).
- **Frontmatter prévu** : `name`, `description` courte (elle est chargée à chaque session), `tools: Read`, `model: sonnet`, `maxTurns` bas. Les champs ignorés pour les agents de plugin (`permissionMode`, `hooks`, `mcpServers`) ne sont pas utilisés.
- **Invocation** : par le modèle (c'est le principe d'un agent). `new-project` l'appelle explicitement en fin de cadrage. Si l'appel échoue, `new-project` fait la revue lui-même avec la même grille.

### 3.6 Hook `check-secrets` (différé)

- **Rôle** : après chaque Write ou Edit, signaler une clé ou un mot de passe écrit dans un fichier, sans jamais afficher la valeur.
- **Motifs** : génériques (préfixes `sk-`, `AKIA`, `ghp_`, JWT, blocs de clé PEM...).
- **Invocation** : automatique (via `hooks/hooks.json`, `${CLAUDE_PLUGIN_ROOT}`).
- **Décision proposée** : **hors v1.0.0**, repris en v1.1 (l'étape 7 du PLAN.md devient une étape de la v1.1). Raisons : le `commit` alerte déjà sur les fichiers sensibles ; Node n'est pas garanti chez l'utilisateur et le hook échouerait en silence ; un faux positif bloquant en démo est un risque ; la v1 doit être testable avant le 14/10.
- Le hook de « Vérification automatique » du PLAN.md (JSON valide) reste un outil de développement dans `.claude/settings.json` du dépôt : il n'est pas livré dans le plugin.

## 4. Récapitulatif des modes d'invocation

| Composant | `disable-model-invocation` | `user-invocable` | Justification |
|---|---|---|---|
| `new-project` | `true` | défaut | écrit des fichiers, long ; coût de contexte nul tant qu'il n'est pas appelé |
| `run-step` | `true` | défaut | modifie le projet |
| `commit` | `true` | défaut | action irréversible potentielle (push) |
| `finish-web` | `true` | défaut | workflow long, modifie le code |
| `project-manager` | n/a | n/a | agent, appelé par le modèle |

Les descriptions restent courtes et précises, y compris pour les skills manuels (elles servent au menu de commandes).

## 5. Contrat du PLAN.md

`new-project` écrit ce format, `project-manager` le contrôle, `run-step` le lit. Il est défini dans `skills/new-project/plan-template.md` et ne doit plus changer sans mettre à jour les trois composants.

- Titre et description en une phrase.
- **Cadrage produit** : vision, cas d'usage, critères de succès mesurables, hors périmètre, risques.
- **Contexte pour l'exécutant** : stack retenue, documentation de référence, contraintes, règles Git, fichiers privés, renvoi vers le `CLAUDE.md` du projet pour les règles générales.
- **Étapes** numérotées. Chaque étape contient : objectif, fichiers, destination, fait quand, et une ligne `Status: todo` ou `Status: done`. Deux lignes facultatives peuvent s'y ajouter : `Note` (par exemple suggérer des sous-agents Explore et Plan) et `Stop` (le moment où l'exécutant s'arrête et attend la validation de l'utilisateur). Tout moment où une décision de l'utilisateur est requise (avant des corrections issues d'un rapport, après la lecture d'un document fourni) reçoit une ligne `Stop`, car une simple consigne « demande » n'est pas tenue de façon fiable. L'étape 0 (initialisation Git) est présente si un dépôt dédié est demandé.
- **Vérification automatique** : hook PostToolUse proposé, jamais installé sans validation.

Le contenu est rédigé dans la langue de l'utilisateur ; `run-step` lit le fichier par sens et ne dépend pas d'un analyseur strict, mais la ligne `Status` reste en anglais pour rester repérable.

## 6. Principe orchestrateur et exécutant (version générique)

- **Session de cadrage (orchestrateur)** : l'utilisateur lance `/lancement-projet:new-project`. Le skill mène l'interview dans le fil principal, cherche les briques existantes, propose la stack, fait relire par `project-manager`, obtient la validation, puis écrit le PLAN.md dans le dossier du projet (créé si besoin, chemin demandé et jamais choisi seul). Cette session ne réalise aucune étape du plan.
- **Session d'exécution (exécutant)** : l'utilisateur ouvre une nouvelle session **dans le dossier du projet** et lance `/lancement-projet:run-step`, puis, entre chaque étape, `/lancement-projet:commit` s'il valide. Le contexte est neuf : seul le PLAN.md porte l'état. On peut faire `/clear` entre deux étapes.
- **Pourquoi deux sessions** : le cadrage consomme beaucoup de contexte (interview, recherches web) qui n'aide pas l'exécution ; à l'inverse l'exécution accumule du code. Le PLAN.md sert de contrat entre les deux. `finish-web` s'exécute dans la session du projet, en fin de plan.
- **Si l'utilisateur est déjà dans le dossier du projet** : `new-project` fonctionne aussi dans cette session ; la séparation reste recommandée, pas obligatoire.

## 7. Décision sur la question du sous-agent

Constat : un sous-agent lancé via le tool Agent n'a pas accès à `AskUserQuestion`. Un agent chargé de mener l'interview s'arrêterait donc après sa première question, sans que l'utilisateur la reçoive.

Décision :

- L'interview est menée par le skill `new-project` dans le fil principal ; ses règles vivent dans `skills/new-project/interview.md`.
- L'agent est **conservé** avec un rôle non interactif : relire la fiche de cadrage et le PLAN.md (`tools: Read`), dans un contexte indépendant de celui qui les a écrits, et renvoyer les défauts. C'est le rôle de la « revue de cadrage » ; un relecteur neuf trouve ce que l'auteur ne voit plus.
- Le plugin n'utilise `context: fork` nulle part.
- Nom : `project-manager` (choix du mainteneur, plus proche de l'agent d'origine). Sa `description` doit dire clairement qu'il relit le cadrage et le plan sans interviewer, pour ne pas laisser croire qu'il mène le cadrage.

## 8. Décisions de nommage et de conception

| Sujet | Décision | Alternative | Justification |
|---|---|---|---|
| Lancement | `new-project` | `kickoff` | explicite, proche de l'ancienne commande ; la redondance avec le préfixe donne `/lancement-projet:new-project`, acceptée |
| Exécution | `run-step` | `next-step` | dit l'action : exécuter la prochaine étape non faite |
| Commit | `commit` | n/a | déjà explicite ; le préfixe évite la collision avec d'autres plugins |
| Finition | `finish-web` | `polish-web` | précise le périmètre web ; évite la confusion avec la sous-commande `polish` d'Impeccable |
| Agent | `project-manager` | `plan-reviewer` | proche de l'agent d'origine ; rôle réel = relecteur non interactif, à préciser dans sa description |
| Langue des commits | celle des commits existants (~10 derniers) ; dépôt vide ou mixte : anglais | toujours anglais | le message reste cohérent avec l'historique du projet |
| Hook | différé à la v1.1 | garder en v1 | voir §3.6 |
| Marketplace | nom distinct `victorgrbz-plugins` | même nom que le plugin | voir §9 |
| Direction artistique et animation | reportées en v2 (option possible dans le même catalogue) | les inclure dans `new-project` | trop spécifiques pour une v1 : elles supposent un outil de maquettes externe et un workflow d'animation dédié |

## 9. Distribution

- Le même dépôt est plugin et catalogue : `.claude-plugin/plugin.json` et `.claude-plugin/marketplace.json`. Le plugin est déclaré avec la source `./` (à vérifier à l'étape 2 avec `claude plugin validate`).
- **Nom du marketplace** : `victorgrbz-plugins`. Un nom distinct du plugin évite `lancement-projet@lancement-projet`, et permet d'ajouter d'autres plugins au même catalogue (par exemple une option de direction artistique en v2). Éviter les préfixes réservés (`claude-*`, `anthropic-*`).
- **Installation en 2 commandes** (à reproduire mot pour mot dans le README) :

```
/plugin marketplace add VictorGrbz/lancement-projet
/plugin install lancement-projet@victorgrbz-plugins
```

- Prérequis documentés : Git, et pour `finish-web` le plugin Impeccable.

## 10. Arborescence finale du dépôt

```
lancement-projet/
├── .claude-plugin/
│   ├── plugin.json              # name, version, description, author, license, repository
│   └── marketplace.json         # marketplace "victorgrbz-plugins"
├── skills/
│   ├── new-project/
│   │   ├── SKILL.md
│   │   ├── interview.md         # interview en 5 points
│   │   ├── plan-template.md     # contrat du PLAN.md
│   │   └── executor-claude-template.md  # modèle du CLAUDE.md de l'exécutant
│   ├── run-step/
│   │   └── SKILL.md
│   ├── commit/
│   │   └── SKILL.md
│   └── finish-web/
│       └── SKILL.md
├── agents/
│   └── project-manager.md
├── hooks/                       # absent en v1.0.0 (hook anti-secrets prévu en v1.1)
├── evals/
│   ├── commit-two-validations/  # prompt.md + graders/*.md
│   ├── commit-behind-branch/
│   ├── new-project-produces-plan/
│   └── run-step-one-at-a-time/
├── docs/
│   └── ARCHITECTURE.md          # ce document
├── .claude/
│   └── settings.json            # outillage de développement du dépôt, non livré dans le plugin
├── README.md                    # anglais
├── README.fr.md                 # français
├── LICENSE                      # MIT
└── .gitignore
```

## 11. Risques et points ouverts (à traiter dans les étapes concernées)

1. **Impeccable** (traité à l'étape 6) : `finish-web` détecte le plugin par la disponibilité du skill `impeccable:impeccable` dans la session et s'arrête avec le message d'installation s'il est absent. Il l'invoque avec l'outil Skill (`audit`, `critique`, `polish`, `doctor`), ce qui fonctionne depuis un skill manuel. Installation : `/plugin marketplace add pbakaus/impeccable` puis `/plugin install impeccable@impeccable`. Pas de `dependencies` dans `plugin.json` : une dépendance vers un autre catalogue est refusée sans liste d'autorisation dans le catalogue racine, et elle imposerait Impeccable à tous les utilisateurs, y compris ceux qui n'utilisent que `commit`. Version testée : 4.1.1, à rappeler dans le README (les sous-commandes peuvent évoluer).
2. **`disallowed-tools`** : vérifier à l'étape 3 que les motifs interdisant `--force`, `--amend`, `--no-verify` sont acceptés ; sinon, les règles restent dans le texte du skill seul.
3. **Évals de `new-project`** : interactif, donc le `prompt.md` doit pré-répondre à toutes les questions ; les contrôles portent sur `file_exists` et sur les sections du PLAN.md.
4. **Références entre skills** : un skill manuel ne peut pas en appeler un autre ; les enchaînements (`run-step` vers `commit`, `finish-web` vers `commit`) sont des suggestions, jamais des appels.
5. **Fichiers d'appui des skills** (`interview.md`, `plan-template.md`) : vérifier à l'étape 4 le mécanisme de chemin relatif (variable de type `${CLAUDE_SKILL_DIR}`).
6. **Chemins locaux** : aucun chemin propre à la machine du mainteneur ne doit figurer dans `.claude/settings.json` (committé, public) ; les autorisations éventuelles vont dans `.claude/settings.local.json` (gitignoré).

## 12. Validation attendue

Le critère de « fait » de l'étape 1 est la validation par le mainteneur de : la liste des composants (§2), les noms (§8), les modes d'invocation (§4), la décision sur l'agent (§7), le report du hook (§3.6), le nom du marketplace (§9) et l'arborescence (§10).
