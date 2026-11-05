-- Gym progress tracker: initial migration for Supabase (schema v2, approved 2026-11-04) + reorder_exercises()
-- Changes from v1:
--   * users.id is the Supabase Auth user id (auth.users.id); email/password live in auth.users.
--   * Row Level Security on all four tables: each signed-in user sees and changes only their own rows.

CREATE TABLE public.users (
    id                UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
    display_name      TEXT NOT NULL CHECK (char_length(display_name) BETWEEN 1 AND 50),
    birth_date        DATE NOT NULL CHECK (birth_date >= DATE '1900-01-01'),
    sex               TEXT NOT NULL CHECK (sex IN ('male', 'female', 'unspecified')),
    height_cm         NUMERIC(4,1) NOT NULL CHECK (height_cm BETWEEN 50 AND 272),
    body_weight_kg    NUMERIC(5,2) NOT NULL CHECK (body_weight_kg BETWEEN 20 AND 400),
    experience_level  TEXT NOT NULL CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
    goal              TEXT NOT NULL CHECK (goal IN ('strength', 'muscle_gain', 'fat_loss', 'general_fitness')),
    weight_unit       TEXT NOT NULL DEFAULT 'kg' CHECK (weight_unit IN ('kg', 'lb')),
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.routines (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL REFERENCES public.users (id) ON DELETE CASCADE,
    name         TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 60),
    description  TEXT CHECK (char_length(description) <= 500),
    archived_at  TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT routines_user_name_uq UNIQUE (user_id, name)
);

CREATE TABLE public.exercises (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    routine_id    UUID NOT NULL REFERENCES public.routines (id) ON DELETE CASCADE,
    name          TEXT NOT NULL CHECK (char_length(name) BETWEEN 1 AND 60),
    muscle_group  TEXT CHECK (muscle_group IN ('chest', 'back', 'shoulders', 'biceps', 'triceps',
                                               'legs', 'glutes', 'core', 'full_body', 'other')),
    position      SMALLINT NOT NULL CHECK (position >= 1),
    target_sets   SMALLINT CHECK (target_sets BETWEEN 1 AND 20),
    target_reps   SMALLINT CHECK (target_reps BETWEEN 1 AND 100),
    archived_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT exercises_routine_position_uq UNIQUE (routine_id, position) DEFERRABLE INITIALLY IMMEDIATE,
    CONSTRAINT exercises_routine_name_uq UNIQUE (routine_id, name)
);

CREATE TABLE public.workout_sets (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id   UUID NOT NULL REFERENCES public.exercises (id) ON DELETE CASCADE,
    performed_on  DATE NOT NULL,
    set_number    SMALLINT NOT NULL CHECK (set_number BETWEEN 1 AND 50),
    weight_kg     NUMERIC(6,2) NOT NULL CHECK (weight_kg BETWEEN 0 AND 1000),
    reps          SMALLINT NOT NULL CHECK (reps BETWEEN 1 AND 200),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT workout_sets_exercise_day_set_uq UNIQUE (exercise_id, performed_on, set_number)
);

-- ---------- Row Level Security ----------
ALTER TABLE public.users        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routines     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercises    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;

-- Signed-out visitors (anon) get nothing; signed-in users only reach their own rows.
REVOKE ALL ON public.users, public.routines, public.exercises, public.workout_sets FROM anon;
GRANT SELECT, INSERT, UPDATE, DELETE
    ON public.users, public.routines, public.exercises, public.workout_sets TO authenticated;

CREATE POLICY users_own ON public.users FOR ALL TO authenticated
    USING (id = (SELECT auth.uid()))
    WITH CHECK (id = (SELECT auth.uid()));

CREATE POLICY routines_own ON public.routines FOR ALL TO authenticated
    USING (user_id = (SELECT auth.uid()))
    WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY exercises_own ON public.exercises FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM public.routines r
                   WHERE r.id = routine_id AND r.user_id = (SELECT auth.uid())))
    WITH CHECK (EXISTS (SELECT 1 FROM public.routines r
                        WHERE r.id = routine_id AND r.user_id = (SELECT auth.uid())));

CREATE POLICY workout_sets_own ON public.workout_sets FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM public.exercises e JOIN public.routines r ON r.id = e.routine_id
                   WHERE e.id = exercise_id AND r.user_id = (SELECT auth.uid())))
    WITH CHECK (EXISTS (SELECT 1 FROM public.exercises e JOIN public.routines r ON r.id = e.routine_id
                        WHERE e.id = exercise_id AND r.user_id = (SELECT auth.uid())));

-- ---------- Reordering exercises ----------
-- One UPDATE statement, so the DEFERRABLE unique (routine_id, position) is checked once at the end.
-- SECURITY INVOKER: runs with the caller's rights, so the RLS policies above still apply.
CREATE FUNCTION public.reorder_exercises(p_routine_id UUID, p_exercise_ids UUID[])
RETURNS void LANGUAGE sql SECURITY INVOKER SET search_path = '' AS $$
    UPDATE public.exercises e
    SET position = o.new_position, updated_at = now()
    FROM unnest(p_exercise_ids) WITH ORDINALITY AS o(id, new_position)
    WHERE e.id = o.id AND e.routine_id = p_routine_id;
$$;
REVOKE EXECUTE ON FUNCTION public.reorder_exercises(UUID, UUID[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.reorder_exercises(UUID, UUID[]) TO authenticated;
