-- UNKNOWN: curated-only RLS hardening. Run only in UNKNOWN Supabase.
BEGIN;
ALTER TABLE public.artist_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.artworks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.artwork_images ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "UNKNOWN profile owner insert draft" ON public.artist_profiles;
DROP POLICY IF EXISTS "UNKNOWN profile owner update draft" ON public.artist_profiles;
CREATE POLICY "UNKNOWN profile owner insert draft" ON public.artist_profiles FOR INSERT TO authenticated WITH CHECK (id=auth.uid() AND submission_status='draft');
CREATE POLICY "UNKNOWN profile owner update draft" ON public.artist_profiles FOR UPDATE TO authenticated USING (id=auth.uid() AND submission_status='draft') WITH CHECK (id=auth.uid() AND submission_status IN ('draft','submitted'));
DROP POLICY IF EXISTS "UNKNOWN artwork owner insert draft" ON public.artworks;
DROP POLICY IF EXISTS "UNKNOWN artworks owner update draft" ON public.artworks;
CREATE POLICY "UNKNOWN artwork owner insert draft" ON public.artworks FOR INSERT TO authenticated WITH CHECK (artist_id=auth.uid() AND status='draft' AND position BETWEEN 1 AND 10 AND EXISTS(SELECT 1 FROM public.artist_profiles p WHERE p.id=artist_id AND p.submission_status='draft'));
CREATE POLICY "UNKNOWN artworks owner update draft" ON public.artworks FOR UPDATE TO authenticated USING(artist_id=auth.uid() AND status='draft') WITH CHECK(artist_id=auth.uid() AND status IN ('draft','submitted') AND position BETWEEN 1 AND 10);
DROP POLICY IF EXISTS "UNKNOWN image owner insert draft" ON public.artwork_images;
CREATE POLICY "UNKNOWN image owner insert draft" ON public.artwork_images FOR INSERT TO authenticated WITH CHECK(position BETWEEN 1 AND 3 AND split_part(storage_path,'/',1)=auth.uid()::text AND EXISTS(SELECT 1 FROM public.artworks a JOIN public.artist_profiles p ON p.id=a.artist_id WHERE a.id=artwork_id AND a.artist_id=auth.uid() AND a.status='draft' AND p.submission_status='draft'));
UPDATE storage.buckets SET public=false WHERE id='artist-submissions';
DROP POLICY IF EXISTS "UNKNOWN storage upload own" ON storage.objects;
DROP POLICY IF EXISTS "UNKNOWN storage read own" ON storage.objects;
CREATE POLICY "UNKNOWN storage upload own" ON storage.objects FOR INSERT TO authenticated WITH CHECK(bucket_id='artist-submissions' AND (storage.foldername(name))[1]=auth.uid()::text AND EXISTS(SELECT 1 FROM public.artist_profiles p WHERE p.id=auth.uid() AND p.submission_status='draft'));
CREATE POLICY "UNKNOWN storage read own" ON storage.objects FOR SELECT TO authenticated USING(bucket_id='artist-submissions' AND (storage.foldername(name))[1]=auth.uid()::text);
CREATE OR REPLACE FUNCTION public.unknown_submit_for_review() RETURNS void LANGUAGE plpgsql SECURITY INVOKER SET search_path='' AS $$
DECLARE uid uuid:=auth.uid(); n integer; missing integer;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'Sign in first'; END IF;
 PERFORM 1 FROM public.artist_profiles WHERE id=uid AND submission_status='draft' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Draft profile required'; END IF;
 SELECT count(*) INTO n FROM public.artworks WHERE artist_id=uid AND status='draft';
 IF n<1 OR n>10 THEN RAISE EXCEPTION 'One to ten artworks required'; END IF;
 SELECT count(*) INTO missing FROM public.artworks a WHERE a.artist_id=uid AND a.status='draft' AND (nullif(btrim(a.title),'') IS NULL OR NOT EXISTS(SELECT 1 FROM public.artwork_images i WHERE i.artwork_id=a.id));
 IF missing>0 THEN RAISE EXCEPTION 'Title and saved image required for every artwork'; END IF;
 UPDATE public.artworks SET status='submitted' WHERE artist_id=uid AND status='draft';
 UPDATE public.artist_profiles SET submission_status='submitted',submitted_at=now() WHERE id=uid AND submission_status='draft';
END; $$;
REVOKE ALL ON FUNCTION public.unknown_submit_for_review() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.unknown_submit_for_review() TO authenticated;
COMMIT;
-- WARNING: inspect other existing policies/triggers for bypass before applying.
-- Trusted curator approval is NOT yet implemented. No public submissions until complete.