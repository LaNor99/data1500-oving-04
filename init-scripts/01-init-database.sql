-- ============================================================================
-- DATA1500 - Oppgavesett 1.5: Databasemodellering og implementasjon
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- Opprett grunnleggende tabeller
CREATE TYPE user_role AS ENUM ('student', 'teacher');

CREATE TABLE ACCOUNT (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(128) NOT NULL,
    role user_role
);

CREATE TABLE CLASS_GROUP (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL
);

CREATE TABLE GROUP_MEMBERSHIP (
    user_id INT REFERENCES ACCOUNT(user_id),
    group_id INT REFERENCES CLASS_GROUP(group_id),
    PRIMARY KEY (user_id, group_id)
);

CREATE TABLE VIRTUAL_CLASSROOM (
    classroom_id SERIAL PRIMARY KEY,
    classroom_code VARCHAR(50) NOT NULL,
    classroom_name VARCHAR(50),
    user_id INT REFERENCES ACCOUNT(user_id)
);

CREATE TABLE CLASSROOM_ACCESS (
    group_id INT REFERENCES CLASS_GROUP(group_id),
    classroom_id INT REFERENCES VIRTUAL_CLASSROOM(classroom_id),
    PRIMARY KEY (group_id, classroom_id)
);

CREATE TABLE CLASSROOM_MESSAGE (
    message_id SERIAL PRIMARY KEY,
    post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subject VARCHAR(50),
    content TEXT,
    user_id INT REFERENCES ACCOUNT(user_id),
    classroom_id INT REFERENCES VIRTUAL_CLASSROOM(classroom_id)
);

CREATE TABLE DISCUSSION_FORUM (
    forum_id SERIAL PRIMARY KEY,
    classroom_id INT REFERENCES VIRTUAL_CLASSROOM(classroom_id)
);

CREATE TABLE FORUM_POST (
    post_id SERIAL PRIMARY KEY,
    post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subject VARCHAR(50),
    content TEXT,
    parent_post_id INT REFERENCES FORUM_POST(post_id),
    user_id INT REFERENCES ACCOUNT(user_id),
    forum_id INT REFERENCES DISCUSSION_FORUM(forum_id)
);


-- Sett inn testdata
-- 1. Legg inn brukere (Passordene her er fiktive hashes)
INSERT INTO ACCOUNT (username, password, role) VALUES
('per_laerer', 'hash_pw_123_abc', 'teacher'),
('kari_laerer', 'hash_pw_456_def', 'teacher'),
('ola_student', 'hash_pw_789_ghi', 'student'),
('lise_student', 'hash_pw_012_jkl', 'student'),
('knut_student', 'hash_pw_345_mno', 'student');

-- 2. Legg inn grupper
INSERT INTO CLASS_GROUP (group_name) VALUES
('Klasse 24A'),
('Klasse 24B'),
('Prosjektgruppe Web');

-- 3. Meld brukere inn i grupper
INSERT INTO GROUP_MEMBERSHIP (user_id, group_id) VALUES
(3, 1), -- Ola i 24A
(4, 1), -- Lise i 24A
(5, 3); -- Knut i Prosjektgruppe Web

-- 4. Opprett virtuelle klasserom (Lærere som ansvarlige)
INSERT INTO VIRTUAL_CLASSROOM (classroom_code, classroom_name, user_id) VALUES
('DATA1500', 'Databasesystemer', 1),
('WEB1100', 'Webutvikling', 2);

-- 5. Gi grupper tilgang til klasserom
INSERT INTO CLASSROOM_ACCESS (group_id, classroom_id) VALUES
(1, 1), -- Klasse 24A har tilgang til Databaser
(3, 2); -- Prosjektgruppa har tilgang til Web

-- 6. Legg inn beskjeder fra lærere
INSERT INTO CLASSROOM_MESSAGE (subject, content, user_id, classroom_id, post_date) VALUES
('Velkommen!', 'Velkommen til kurset i databaser. Husk å laste ned PostgreSQL.', 1, 1, '2026-01-05 08:00:00'),
('Innleveringsfrist', 'Husk at oblig 1 må leveres innen fredag kl. 12:00.', 1, 1, '2026-03-01 09:10:00'),
('Nytt læringsmateriell', 'Jeg har lagt ut nye slides om SQL Joins under filer.', 1, 1, '2026-03-21 10:05:33'),
('Viktig info om eksamen', 'Eksamen blir digital i år.', 2, 2, '2026-04-21 08:12:34');

-- 7. Opprett diskusjonsforum
INSERT INTO DISCUSSION_FORUM (classroom_id) VALUES (1), (2);

-- 8. Legg inn diskusjonsposter og svar
-- TRÅD 1: Database-teori med forgreninger
-- Level 1: Hovedinnlegg (post_id 1)
INSERT INTO FORUM_POST (subject, content, user_id, forum_id, parent_post_id, post_date) VALUES
    ('Spørsmål om ER-diagram', 'Hva er egentlig forskjellen på PK og FK?', 3, 1, NULL, '2026-04-21 08:00:00');

-- Level 2: Første svar på hovedinnlegget (post_id 2)
INSERT INTO FORUM_POST (subject, content, user_id, forum_id, parent_post_id, post_date) VALUES
    ('Svar på ER-diagram', 'PK er unik ID for raden, FK peker til en annen tabell.', 1, 1, 1, '2026-04-21 08:05:00');

-- Level 2: ANDRE svar på hovedinnlegget (post_id 3)
INSERT INTO FORUM_POST (subject, content, user_id, forum_id, parent_post_id, post_date) VALUES
    ('Kort forklaring', 'PK identifiserer, FK relaterer tabeller.', 2, 1, 1, '2026-04-21 08:06:00');

-- Level 3: Svar på post 2 (post_id 4)
INSERT INTO FORUM_POST (subject, content, user_id, forum_id, parent_post_id, post_date) VALUES
    ('Oppfølging ER', 'Takk! Kan en tabell ha mer enn én FK?', 3, 1, 2, '2026-04-21 09:30:00');

-- Level 4: Første svar på post 4 (post_id 5)
INSERT INTO FORUM_POST (subject, content, user_id, forum_id, parent_post_id, post_date) VALUES
    ('Svar til Oppfølging', 'Ja, du kan ha så mange FK-er du trenger.', 2, 1, 4, '2026-04-21 10:12:34');

-- Level 4: ANDRE svar på post 4 (post_id 6)
INSERT INTO FORUM_POST (subject, content, user_id, forum_id, parent_post_id, post_date) VALUES
    ('Eksempel på flere FK', 'Absolutt. Tenk på en "Ordre"-tabell; den vil ha en FK til "Kunde" og en annen FK til "Ansatt".',
     1, 1, 4, '2026-04-21 10:15:00');

-- TRÅD 2: Om Docker-problemer (Kortere tråd)
-- Level 1 (Hovedinnlegg) - Blir post_id 7
INSERT INTO FORUM_POST (subject, content, user_id, forum_id, parent_post_id, post_date) VALUES
    ('Docker port-feil', 'Får beskjed om at port 5432 allerede er i bruk?', 4, 1, NULL, '2026-04-21 12:00:00');

-- Level 2 (Svar på post 7) - Blir post_id 8
INSERT INTO FORUM_POST (subject, content, user_id, forum_id, parent_post_id, post_date) VALUES
    ('Løsning: Port-konflikt', 'Sjekk om du har en lokal PostgreSQL-instans kjørende i Windows.', 2, 1, 7, '2026-04-21 12:34:00');


-- Eventuelt: Opprett indekser for ytelse
-- Raskere oppslag på brukernavn ved innlogging
CREATE INDEX idx_account_username ON ACCOUNT(username);

-- Optimaliser søk etter meldinger i et bestemt klasserom
CREATE INDEX idx_message_classroom ON CLASSROOM_MESSAGE(classroom_id);

-- Optimaliser henting av svar tilhørende et hovedinnlegg (tråder)
CREATE INDEX idx_forum_post_parent ON FORUM_POST(parent_post_id);

-- Optimaliser visning av nyeste foruminnlegg
CREATE INDEX idx_forum_post_date ON FORUM_POST(post_date);


-- Vis at initialisering er fullført
SELECT 'Database initialisert!' as status;