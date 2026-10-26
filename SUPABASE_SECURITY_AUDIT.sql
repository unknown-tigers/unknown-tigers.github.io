-- UNKNOWN ARTIST STUDIO — READ ONLY SECURITY CHECK (26 October 2026)
-- Run in UNKNOWN Supabase SQL editor. This script DOES NOT change any data.
-- Important: RLS enabled alone is insufficient. Examine USING and WITH CHECK.
select schemaname,tablename,policyname,cmd,roles,qual,with_check from pg_policies
where (schemaname='public' and tablename in ('artist_profiles','artworks','artwork_images'))
   or (schemaname='storage' and tablename='objects' and policyname like 'UNKNOWN%')
order by schemaname,tablename,policyname;

select n.nspname as schema_name,c.relname as table_name,c.relrowsecurity as rls_enabled,
c.relforcerowsecurity as rls_forced
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where (n.nspname='public' and c.relname in ('artist_profiles','artworks','artwork_images'))
order by c.relname;

select table_name,column_name,data_type,is_nullable,column_default
from information_schema.columns where table_schema='public'
and table_name in ('artist_profiles','artworks','artwork_images')
order by table_name,ordinal_position;

select id,name,public,file_size_limit,allowed_mime_types
from storage.buckets where id='artist-submissions';

-- Inspect all triggers and SECURITY DEFINER functions before any policy migration:
select event_object_table,trigger_name,action_statement from information_schema.triggers
where event_object_schema='public' and event_object_table in ('artist_profiles','artworks','artwork_images');

select n.nspname,p.proname,pg_get_functiondef(p.oid) as definition
from pg_proc p join pg_namespace n on n.oid=p.pronamespace
where n.nspname='public' and (p.proname ilike '%artist%' or p.proname ilike '%approval%')
order by p.proname;

-- Required security results before opening registration:
-- Profiles: artists can only read and modify own DRAFT; never set approved.
-- Artworks: artists can only read own; writes draft-only; never approve.
-- Image metadata: only owner's draft artworks can receive inserts/deletes.
-- Storage: private bucket; owner-ID first path segment; no public SELECT.
-- Curatorial approval must be a trusted server-side workflow, not browser code.
