# UNKNOWN / Artist Studio — current technical state

Site: https://unknown-tigers.github.io/
GitHub org: unknown-tigers — entirely separate from Modular Friends.
Supabase project: nqqdetebfghhpomcnvgp, bucket artist-submissions (private).

## Confirmed
- UNKNOWN website hosted through GitHub Pages.
- Supabase tables and private upload bucket previously created.
- Client-side draft studio source exists and was syntax checked.
- Production website does not expose an artist signup form.
- Public GitHub repositories must never include a service_role key, database password, or private artist work.

## Still unverified / do NOT mark as completed
1. Full RLS predicates, especially prevention of self-approval.
2. Current Supabase publishable/anon key (not a secret; required for actual client connection).
3. Email verification and authorized redirect URLs for unknown-tigers.github.io.
4. Live sign-up, login, image upload, submission with real accounts.
5. Separate user A/user B ownership tests and storage isolation tests.
6. Curator approval workflow, public approved-artists display, legal privacy notices.

## Sequential release gates
GATE A: execute SUPABASE_SECURITY_AUDIT.sql and inspect results.
GATE B: correct any insecure database policy before exposing registration.
GATE C: configure only a publishable key in the browser, test privately.
GATE D: test account A and B, submissions, 1–3 images per artwork, 10 works cap.
GATE E: implement trusted-only approval and public approved content.
GATE F: enable invitation-only rollout. Keep public registration closed until E is complete.

Do not rely on robots noindex for privacy. GitHub Pages are publicly reachable.
