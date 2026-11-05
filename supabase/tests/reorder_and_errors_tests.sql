\set QUIET on
\ir test_mock_supabase_auth.sql
\ir ../migrations/20261104120000_init_schema.sql
INSERT INTO auth.users VALUES ('a0000000-0000-0000-0000-000000000001','c@x'),('b0000000-0000-0000-0000-000000000002','o@x');
\set QUIET off
SET ROLE authenticated; SET test.uid='a0000000-0000-0000-0000-000000000001';
INSERT INTO users (id,display_name,birth_date,sex,height_cm,body_weight_kg,experience_level,goal) VALUES ('a0000000-0000-0000-0000-000000000001','C','2003-04-15','male',178,75.5,'beginner','muscle_gain');
INSERT INTO routines (id,user_id,name) VALUES ('c0000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000001','Push day');
INSERT INTO exercises (id,routine_id,name,position) VALUES
 ('e0000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000001','Bench press',1),
 ('e0000000-0000-0000-0000-000000000002','c0000000-0000-0000-0000-000000000001','Overhead press',2),
 ('e0000000-0000-0000-0000-000000000003','c0000000-0000-0000-0000-000000000001','Dips',3);
\echo '--- reorder to Dips, Bench, OHP (single statement, as owner) ---'
SELECT public.reorder_exercises('c0000000-0000-0000-0000-000000000001', ARRAY['e0000000-0000-0000-0000-000000000003','e0000000-0000-0000-0000-000000000001','e0000000-0000-0000-0000-000000000002']::uuid[]);
SELECT name, position FROM exercises ORDER BY position;
\echo '--- other user tries to reorder Cristian routine ---'
SET test.uid='b0000000-0000-0000-0000-000000000002';
SELECT public.reorder_exercises('c0000000-0000-0000-0000-000000000001', ARRAY['e0000000-0000-0000-0000-000000000002','e0000000-0000-0000-0000-000000000001','e0000000-0000-0000-0000-000000000003']::uuid[]);
SET test.uid='a0000000-0000-0000-0000-000000000001';
SELECT name, position FROM exercises ORDER BY position;
\echo '--- SQLSTATE codes the app must map ---'
\set VERBOSITY verbose
INSERT INTO routines (user_id,name) VALUES ('a0000000-0000-0000-0000-000000000001','Push day');
INSERT INTO workout_sets (exercise_id,performed_on,set_number,weight_kg,reps) VALUES ('e0000000-0000-0000-0000-000000000001','2026-11-03',1,60,0);
INSERT INTO routines (user_id,name) VALUES ('b0000000-0000-0000-0000-000000000002','Hack');
