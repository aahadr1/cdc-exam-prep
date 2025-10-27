# Oral Prep - Application de Préparation aux Examens Oraux

Une application Next.js moderne pour préparer vos examens oraux en étudiant vos documents PDF et en vous entraînant avec des modules d'apprentissage interactifs.

## 🚀 Fonctionnalités

- **Authentification sécurisée** : Système complet de connexion/inscription avec Supabase
- **Gestion de projets** : Créez et organisez vos projets d'étude
- **Upload de documents** : Importez jusqu'à 10 documents (50 Mo max chacun) par projet
- **Modules d'apprentissage** (à venir) :
  - Apprendre avec l'agent IA
  - Quiz interactifs
  - Fiches de révision
  - Vidéos explicatives
- **Entraînement oral** (à venir) :
  - Tests de connaissances oraux
  - Oraux blancs complets

## 🛠️ Stack Technique

- **Framework** : Next.js 14 (App Router)
- **Langage** : TypeScript
- **Styling** : Tailwind CSS
- **Base de données** : Supabase (PostgreSQL)
- **Authentification** : Supabase Auth
- **Stockage** : Supabase Storage
- **Upload** : React Dropzone

## 📋 Prérequis

- Node.js 18+ et npm
- Un compte Supabase (gratuit)

## 🔧 Installation

1. **Cloner le projet** (si applicable)

2. **Installer les dépendances**
```bash
npm install
```

3. **Configurer Supabase**

   a. Créez un projet sur [supabase.com](https://supabase.com)
   
   b. Exécutez le script SQL dans l'éditeur SQL de Supabase (voir `supabase-setup.sql`)
   
   c. Créez un fichier `.env.local` à la racine :
   ```
   NEXT_PUBLIC_SUPABASE_URL=votre_url_supabase
   NEXT_PUBLIC_SUPABASE_ANON_KEY=votre_cle_anon
   ```
   
   Vous trouverez ces valeurs dans :
   Settings → API → Project URL et anon/public key

4. **Configurer l'authentification Supabase**
   - Allez dans Authentication → Settings
   - Activez "Enable email confirmations" (optionnel)
   - Ajoutez `http://localhost:3000/**` dans "Site URL" et "Redirect URLs"

5. **Lancer l'application en développement**
```bash
npm run dev
```

L'application sera accessible sur [http://localhost:3000](http://localhost:3000)

## 📁 Structure du Projet

```
oral-prep/
├── app/
│   ├── (auth)/              # Pages d'authentification
│   │   ├── login/
│   │   └── signup/
│   ├── (dashboard)/         # Pages du tableau de bord
│   │   └── projets/
│   │       ├── page.tsx     # Liste des projets
│   │       ├── nouveau/     # Création de projet
│   │       └── [projectId]/ # Page d'un projet
│   ├── globals.css
│   └── layout.tsx
├── components/              # Composants réutilisables
│   ├── Sidebar.tsx
│   ├── Topbar.tsx
│   ├── EmptyState.tsx
│   ├── ProjectCard.tsx
│   ├── ModuleCard.tsx
│   └── Uploader.tsx
├── lib/
│   ├── supabase/           # Configuration Supabase
│   │   ├── client.ts
│   │   └── server.ts
│   └── auth.ts             # Utilitaires d'authentification
└── middleware.ts           # Protection des routes
```

## 🗄️ Base de Données

### Tables

- **profiles** : Profils utilisateurs (optionnel, pour extensions futures)
- **projects** : Projets créés par les utilisateurs
- **project_documents** : Documents associés aux projets

### Règles de Sécurité (RLS)

- Les utilisateurs ne peuvent voir que leurs propres projets
- Les utilisateurs ne peuvent accéder qu'aux documents de leurs projets
- Maximum 10 documents par projet (appliqué via trigger)
- Maximum 50 Mo par document (appliqué via contrainte CHECK)

### Storage

- Bucket `project-docs` : Stockage des documents utilisateurs
- Structure : `users/{userId}/{projectId}/docs/{filename}`

## 🚢 Déploiement sur Vercel

1. Poussez votre code sur GitHub

2. Connectez votre repo sur [vercel.com](https://vercel.com)

3. Ajoutez les variables d'environnement :
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`

4. Dans Supabase, ajoutez l'URL de production dans :
   - Authentication → Settings → Site URL
   - Authentication → Settings → Redirect URLs

5. Déployez !

## 🎨 Design

L'interface suit les principes de design :
- **Minimalisme** : Interface épurée et moderne
- **Clarté** : Navigation intuitive
- **Accessibilité** : Contraste et tailles de police optimisés
- **Réactivité** : Responsive sur tous les écrans

## 📝 Prochaines Étapes

- [ ] Intégration IA pour l'agent conversationnel
- [ ] Génération automatique de quiz
- [ ] Système de fiches de révision
- [ ] Génération de vidéos explicatives
- [ ] Simulation d'oral avec enregistrement
- [ ] Analyse de performance et statistiques

## 🤝 Contribution

Ce projet est en développement actif. N'hésitez pas à suggérer des améliorations !

## 📄 Licence

MIT

