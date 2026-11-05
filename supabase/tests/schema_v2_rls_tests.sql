\set ON_ERROR_STOP on
\set QUIET on
\ir test_mock_supabase_auth.sql
\ir ../migrations/20261104120000_init_schema.sql
\set QUIET off
INSERT INTO auth.users VALUES ('a0000000-0000-0000-0000-000000000001','cristian@example.com'),('b0000000-0000-0000-0000-000000000002','other@example.com');
\echo '=== As Cristian (authenticated) ==='
SET ROLE authenticated; SET test.uid = 'a0000000-0000-0000-0000-000000000001';
INSERT INTO users (id,display_name,birth_date,sex,height_cm,body_weight_kg,experience_level,goal) VALUES ('a0000000-0000-0000-0000-000000000001','Cristian','2003-04-15','male',178,75.5,'beginner','muscle_gain');
INSERT INTO routines (id,user_id,name) VALUES ('c0000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000001','Push day');
INSERT INTO exercises (id,routine_id,name,position) VALUES ('e0000000-0000-0000-0000-000000000001','c0000000-0000-0000-0000-000000000001','Bench press',1);
INSERT INTO workout_sets (exercise_id,performed_on,set_number,weight_kg,reps) VALUES ('e0000000-0000-0000-0000-000000000001','2026-11-03',1,62.5,8);
SELECT 'cristian sees' who, (SELECT count(*) FROM users) u,(SELECT count(*) FROM routines) r,(SELECT count(*) FROM exercises) e,(SELECT count(*) FROM workout_sets) s;
\set ON_ERROR_STOP off
\echo '--- Cristian tries to create a profile for someone else (expect error) ---'
INSERT INTO users (id,display_name,birth_date,sex,height_cm,body_weight_kg,experience_level,goal) VALUES ('b0000000-0000-0000-0000-000000000002','Fake','2000-01-01','male',170,70,'beginner','strength');
\set ON_ERROR_STOP on
\echo '=== As the other user ==='
SET test.uid = 'b0000000-0000-0000-0000-000000000002';
INSERT INTO users (id,display_name,birth_date,sex,height_cm,body_weight_kg,experience_level,goal) VALUES ('b0000000-0000-0000-0000-000000000002','Other','2000-01-01','female',165,60,'beginner','strength');
SELECT 'other sees' who, (SELECT count(*) FROM users) u,(SELECT count(*) FROM routines) r,(SELECT count(*) FROM exercises) e,(SELECT count(*) FROM workout_sets) s;
\echo '--- other tries to update / delete Cristian data (expect 0 rows) ---'
UPDATE workout_sets SET weight_kg = 999; DELETE FROM routines;
\set ON_ERROR_STOP off
\echo '--- other tries to log a set on Cristian exercise (expect error) ---'
INSERT INTO workout_sets (exercise_id,performed_on,set_number,weight_kg,reps) VALUES ('e0000000-0000-0000-0000-000000000001','2026-11-03',2,100,1);
\echo '--- other tries to add an exercise to Cristian routine (expect error) ---'
INSERT INTO exercises (routine_id,name,position) VALUES ('c0000000-0000-0000-0000-000000000001','Hack',2);
\echo '=== Signed out (anon) ==='
RESET test.uid; SET ROLE anon;
SELECT count(*) FROM workout_sets;
INSERT INTO routines (user_id,name) VALUES ('a0000000-0000-0000-0000-000000000001','x');
\set ON_ERROR_STOP on
\echo '=== Back as Cristian: data untouched? ==='
RESET ROLE; SET ROLE authenticated; SET test.uid = 'a0000000-0000-0000-0000-000000000001';
SELECT r.name, e.name, s.weight_kg FROM workout_sets s JOIN exercises e ON e.id=s.exercise_id JOIN routines r ON r.id=e.routine_id;
\echo '=== Deleting the auth user cascades ==='
RESET ROLE; DELETE FROM auth.users WHERE id='a0000000-0000-0000-0000-000000000001';
SELECT (SELECT count(*) FROM users) u,(SELECT count(*) FROM routines) r,(SELECT count(*) FROM exercises) e,(SELECT count(*) FROM workout_sets) s;
