# lancement-projet

**Une méthode reproductible pour livrer des projets avec Claude Code : cadrage guidé, plan par étapes, commits sécurisés et passe qualité avant la mise en production.**

*[English version](README.md)*

- **Une méthode, pas un prompt.** Le cadrage, le plan, l'exécution, le commit et la finition sont des étapes séparées, avec un passage de relais clair entre elles : un projet ne dépend plus d'une seule longue conversation fragile.
- **La qualité avant la mise en production.** Chaque étape du plan a un contrôle que n'importe qui peut lancer, et les projets web passent par un audit, une critique et une relecture indépendante avant d'être expédiés.
- **Des garde-fous par défaut.** Rien n'est commité ni poussé sans une confirmation distincte et explicite, et les options git dangereuses ne sont jamais utilisées.
- **Pensé pour des personnes qui ne sont pas développeuses.** L'auteur n'est pas développeur et livre des projets en production de cette façon.

## Le cycle

```
/lancement-projet:new-project   interview de cadrage, puis PLAN.md et un CLAUDE.md pour l'exécutant
            |
            v
/lancement-projet:run-step      exécute la prochaine étape du PLAN.md, la vérifie, s'arrête   <-- à répéter
            |
            v
/lancement-projet:commit        une confirmation pour commiter, une autre pour pousser
            |
            v
/lancement-projet:finish-web    audit, critique, relecture, corrections validées   (projets web)
```

Une première session cadre le projet et écrit le plan. Une seconde session, ouverte dans le dossier du projet, l'exécute une étape à la fois. Le `PLAN.md` est le seul état partagé entre les deux, ce qui garde chaque session courte et concentrée.

## Installation

Deux commandes, dans Claude Code :

```
/plugin marketplace add https://github.com/VictorGrbz/lancement-projet.git
/plugin install lancement-projet@victorgrbz-plugins
```

Prérequis : Git. Pour `finish-web`, le plugin [Impeccable](https://impeccable.style) (testé avec la 4.1.1). S'il manque, le skill s'arrête et explique comment l'installer :

```
/plugin marketplace add pbakaus/impeccable
/plugin install impeccable@impeccable
```

## Les quatre skills

| Skill | Ce qu'il fait |
|---|---|
| `/lancement-projet:new-project` | Vous interroge sur cinq points (vision, cas d'usage, critères de succès mesurables, hors périmètre, ce qui peut mal tourner), propose une stack simple, demande si le projet a son propre dépôt, puis écrit `PLAN.md` et un `CLAUDE.md` pour l'exécutant. Un agent relecteur lit le plan avant votre validation. |
| `/lancement-projet:run-step` | Prend la première étape non faite du `PLAN.md`, ne fait que celle-là, lance son contrôle « Done when », la marque faite, suggère un commit et attend. |
| `/lancement-projet:commit` | Montre les fichiers et le message, commite après votre accord, puis redemande avant de pousser. |
| `/lancement-projet:finish-web` | Enchaîne l'audit et la critique d'Impeccable, une relecture indépendante quand des maquettes existent, votre validation, les corrections, puis un contrôle de cohérence final. Compte les couleurs écrites en dur avant et après. |

Les quatre sont manuels : Claude ne les lance jamais de lui-même. Les skills et leurs messages sont en anglais ; ce qu'ils écrivent pour vous (le plan, le message de commit) suit votre langue.

## Exemple de session (illustratif)

```
> /lancement-projet:new-project site de réservation pour une toiletteuse canine
  ... cinq questions, une à la fois, avec des options et une recommandation à chaque fois ...
  PLAN.md écrit : 12 étapes, dont 5 avec une ligne Stop. L'agent relecteur a relevé 9 défauts, tous corrigés.

(nouvelle session, ouverte dans le dossier du projet)
> /lancement-projet:run-step
  Étape 1 : demander à 10 clientes existantes si elles préfèrent réserver en ligne.
  Done when : les réponses sont recueillies et résumées dans docs/survey.md.
  Stop : j'attends que vous rapportiez les réponses.
```

## Garde-fous

- **Deux confirmations pour git.** Une pour le commit, une autre pour le push, avec le dépôt distant, la branche et le nombre de commits annoncés.
- **Jamais** `git add -A` ni `git add .`, `--amend`, `--no-verify`, `--force` ou `--force-with-lease`.
- **Les fichiers sensibles sont signalés** avant tout ajout, et **une branche en retard sur son dépôt distant n'est jamais poussée** : le skill vous le dit et demande comment procéder.
- **Une étape à la fois.** Une étape n'est marquée faite qu'après avoir réellement lancé son contrôle.
- **Les lignes `Stop`.** Quand une décision vous revient (avant des corrections issues d'un rapport, après la lecture d'un document que vous avez fourni), le plan le dit et l'exécutant s'arrête. Une simple consigne « demande à l'utilisateur » n'est pas tenue de façon fiable ; une ligne `Stop` l'est.
- **Un `CLAUDE.md` pour l'exécutant.** La session qui exécute le plan n'hérite d'aucune consigne, donc le plugin écrit ses règles de base dans le projet : une étape à la fois, jamais « fait » sans preuve, signaler tout ajout non demandé.
- **L'interview reste dans la conversation principale.** Les sous-agents ne peuvent pas vous poser de questions, donc le plugin ne leur délègue jamais l'interview.

## Différence avec `commit-commands`

Le plugin officiel d'Anthropic `commit-commands` est conçu pour la vitesse : une commande ajoute et commite, une autre pousse aussi et ouvre une pull request, sans étape de confirmation. `lancement-projet` fait le choix inverse : plus lent, avec des confirmations distinctes et les garde-fous ci-dessus, et il couvre toute la méthode autour du commit (cadrage, plan, exécution, finition). Il n'ouvre pas de pull request ; les deux plugins peuvent coexister.

## Tests

Le comportement est couvert par des evals dans [`evals/`](evals/README.md), lancées avec `claude plugin eval` : le plan contient la section des risques et les lignes `Stop`, l'exécutant fait une seule étape et s'arrête à une ligne `Stop`, et le skill de finition s'arrête proprement quand Impeccable manque.

## À propos

Réalisé par [VictorGrbz](https://github.com/VictorGrbz). Portfolio : [jess-vic.ovh](https://jess-vic.ovh).

Licence MIT.
