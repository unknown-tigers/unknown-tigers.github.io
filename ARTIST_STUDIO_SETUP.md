# UNKNOWN / Artist Studio deployment checklist

Status: **public preview is live; artist registration is not live**.

Backend: Supabase project nqqdetebfghhpomcnvgp.
Hosting: GitHub Pages unknown-tigers.github.io.
Account: UNKNOWN / unowntigers@gmail.com. Keep Modular Friends separate.

## Before enabling user signup
1. Review the actual RLS USING and WITH CHECK expressions using SUPABASE_SECURITY_AUDIT.sql in Supabase SQL Editor. Verify users cannot read or edit another artist's data, cannot approve their own profile/artworks, and images remain private.
2. Confirm storage.objects policies restrict files to owner-ID path prefix and the private artist-submissions bucket.
3. Retrieve only the public publishable/anon key from Supabase Dashboard > Project Settings > API Keys; never use a secret or service_role key in a webpage.
4. Confirm allowed redirect URL is https://unknown-tigers.github.io/ for authentication emails.
5. Stage the existing Artist Studio v4.1 front-end privately and run two-account tests with different browsers: sign-up, email confirmation, login, profile, work and image upload, edits, submission, no unauthorized access, no auto-approval.
6. Only then link registration publicly and create a curation/admin workflow.

No artist-submitted work or internal credentials should be committed to this repository.
