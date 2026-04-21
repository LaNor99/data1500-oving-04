-- ============================================================================
-- TEST-SKRIPT FOR OPPGAVESETT 1.4: Databasemodellering og implementering
-- ============================================================================

-- Kjør med: docker-compose exec postgres psql -U admin -d data1500_db -f test-scripts/oppgave4_losning.sql
-- 1. Finn de 3 nyeste beskjeder fra læreren i et gitt klasserom (f.eks. klasserom_id = 1).
\echo '\nFinn de 3 nyeste beskjeder fra læreren i et gitt klasserom'

SELECT subject, content, username, post_date
FROM CLASSROOM_MESSAGE cm
JOIN ACCOUNT a ON cm.user_id = a.user_id
WHERE classroom_id = 1
ORDER BY post_date DESC
LIMIT 3;

-- 2. Vis en hel diskusjonstråd startet av en spesifikk student (f.eks. avsender_id = 2).
\echo '\nVis en hel diskusjonstråd startet av en spesifikk student'

WITH RECURSIVE discussion_thread AS (
    SELECT *, CAST(post_id AS TEXT) AS path, 0 AS level
    FROM FORUM_POST
    WHERE user_id = 3 AND parent_post_id IS NULL

    UNION ALL

    SELECT f.*, dt.path || ' -> ' || f.post_id, dt.level + 1
    FROM FORUM_POST f
    INNER JOIN discussion_thread dt ON f.parent_post_id = dt.post_id
)
SELECT REPEAT('  ', dt.level) || dt.subject AS subject,
       REPEAT('  ', dt.level) || dt.content AS content,
       a.username,
       dt.post_date
FROM discussion_thread dt
LEFT JOIN ACCOUNT a ON dt.user_id = a.user_id
ORDER BY path;

-- 3. Finn alle studenter i en spesifikk gruppe (f.eks. gruppe_id = 1).
\echo '\nFinn alle studenter i en spesifikk gruppe'

SELECT a.user_id, a.username, a.role, gm.group_id
FROM ACCOUNT a
JOIN GROUP_MEMBERSHIP gm ON a.user_id = gm.user_id
WHERE gm.group_id = 1 AND a.role = 'student';

-- 4. Finn antall grupper.
\echo '\nFinn antall grupper'

SELECT COUNT(group_id) AS number_of_groups
FROM CLASS_GROUP;

-- En test SQL-spørring mot metadata i PostgreSQL
select nspname as schema_name from pg_catalog.pg_namespace;
