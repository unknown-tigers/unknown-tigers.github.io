-- UNKNOWN: inspection only. No database changes.
select schemaname, tablename, policyname, cmd, roles, qual, with_check
from pg_policies
where (schemaname='public' and tablename in ('artist_profiles','artworks','artwork_images'))
   or (schemaname='storage' and tablename='objects' and policyname like 'UNKNOWN%')
order by schemaname,tablename,policyname;

select c.relname as table_name, c.relrowsecurity as rls_enabled
from pg_class c join pg_namespace n on n.oid=c.relnamespace
where n.nspname='public' and c.relname in ('artist_profiles','artworks','artwork_images');

select table_name,column_name,data_type,is_nullable
from information_schema.columns
where table_schema='public' and table_name in ('artist_profiles','artworks','artwork_images')
order by table_name,ordinal_position;
