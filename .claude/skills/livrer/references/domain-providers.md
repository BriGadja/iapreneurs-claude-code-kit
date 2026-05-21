# Domain providers — configuration DNS post-deploy (registrar-aware)

> **Lis ce fichier uniquement si** `/livrer` Étape 3.5 a demandé à l'utilisateur de configurer un domaine custom et qu'il a fourni `URL_CIBLE`, `registrar`, `DNS_TYPE` et `DNS_TARGET`.
>
> But : guider l'utilisateur à coller la valeur DNS exacte chez son registrar, avec les gotchas spécifiques (point final OVH, proxy Cloudflare, etc.).

## Sélection registrar

Selon `{registrar}` choisi en Étape 3.5.2 et type d'URL (`sous-domaine` si `URL_CIBLE` contient au moins 2 points pour `.fr`/`.com`, sinon apex), applique la procédure correspondante ci-dessous.

## OVH + sous-domaine (cas le plus fréquent — Discoverly, IAPreneurs)

> 1. Va sur **www.ovh.com/manager → Web Cloud → Domaines → `{domaine-parent}` → Zone DNS**
> 2. Clique **"Ajouter une entrée"** → choisis type **CNAME**
> 3. **Sous-domaine** : `{sous-domaine}` (ex: `discoverly` pour `discoverly.sablia.fr`) — **PAS l'URL complète**
> 4. **Cible** : `{DNS_TARGET}.` ⚠️ **AVEC LE POINT FINAL** ← gotcha classique OVH, sans le point l'entrée est mal interprétée
> 5. TTL : laisse la valeur par défaut (3600s = 1h)
> 6. Valide. La propagation prend généralement 5-15 min chez OVH.

## OVH + apex (domaine racine)

> ⚠️ OVH ne supporte PAS ALIAS/ANAME pour apex. Tu dois utiliser des **records A** vers les IPs Vercel.
> 1. Manager OVH → Zone DNS → **modifier le record A par défaut** (sous-domaine = laisse vide) → cible `{DNS_TARGET}` (IP Vercel)
> 2. Si Vercel demande plusieurs IPs, ajoute autant de records A que nécessaire
> 3. Doc Vercel à jour pour les IPs : https://vercel.com/docs/projects/domains/working-with-domains#dns-records

## Gandi + sous-domaine

> Gandi LiveDNS → ton domaine → **Records → Add Record** → Type CNAME → Name `{sous-domaine}` → Hostname `{DNS_TARGET}.` (avec point final aussi) → TTL 1800.

## Cloudflare + sous-domaine

> ⚠️ Cloudflare DNS proxy + Vercel SSL = SSL cassé (Vercel reçoit du HTTPS Cloudflare au lieu du HTTP origin, l'issu Let's Encrypt échoue).
> 1. Dashboard Cloudflare → ton domaine → **DNS → Records → Add record** → Type CNAME → Name `{sous-domaine}` → Target `{DNS_TARGET}`
> 2. **Proxy status : "DNS only" (nuage GRIS, PAS orange)** ← non-négociable pour Vercel
> 3. Save.

## Hostinger + sous-domaine

> hPanel → ton domaine → **DNS / Nameservers → DNS Zone Editor → Add Record** → Type CNAME → Name `{sous-domaine}` → Points to `{DNS_TARGET}` → TTL 14400. Pas de point final requis chez Hostinger (auto-ajouté).

## Autre registrar (réponse "Autre" en 3.5.2)

> Pattern générique : crée un record **{DNS_TYPE}** avec name=`{sous-domaine ou @}` et target/value=`{DNS_TARGET}`. Doc Vercel "Add a domain" : https://vercel.com/docs/projects/domains/add-a-domain — section "Configure DNS" couvre les cas par registrar.

## Retour au SKILL.md

Une fois la configuration DNS faite chez le registrar, retourne à l'Étape 3.5.5 du SKILL.md (attente propagation).
