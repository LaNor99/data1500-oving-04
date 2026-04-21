# Oppgavesett 1.4: Databasemodell og implementasjon for Nettbasert Undervisning

I dette oppgavesettet skal du designe en database for et nettbasert undervisningssystem. Les casen nøye og løs de fire deloppgavene som følger.

Denne oppgaven er en øving og det forventes ikke at du kan alt som det er spurt etter her. Vi skal gå gjennom mange av disse tingene detaljert i de nærmeste ukene. En lignende oppbygging av oppgavesettet, er det ikke helt utelukket at, skal bli brukt i eksamensoppgaven.

Du bruker denne filen for å besvare deloppgavene. Du må eventuelt selv finne ut hvordan du kan legge inn bilder (images) i en Markdown-fil som denne. Da kan du ta et bilde av dine ER-diagrammer, legge bildefilen inn på en lokasjon i repository og henvise til filen med syntaksen i Markdown. 

Det er anbefalt å tegne ER-diagrammer med [mermaid.live](https://mermaid.live/) og legge koden inn i Markdown (denne filen) på følgende måte:
```
```mermaid
erDiagram
    studenter 
    ...
``` 
Det finnes bra dokumentasjon [EntityRelationshipDiagram](https://mermaid.js.org/syntax/entityRelationshipDiagram.html) for hvordan tegne ER-diagrammer med mermaid-kode. 

## Case: Databasesystem for Nettbasert Undervisning

Det skal lages et databasesystem for nettbasert undervisning. Brukere av systemet er studenter og lærere, som alle logger på med brukernavn og passord. Det skal være mulig å opprette virtuelle klasserom. Hvert klasserom har en kode, et navn og en lærer som er ansvarlig.

Brukere kan deles inn i grupper. En gruppe kan gis adgang ("nøkkel") til ett eller flere klasserom.

I et klasserom kan studentene lese beskjeder fra læreren. Hvert klasserom har også et diskusjonsforum, der både lærere og studenter kan skrive innlegg. Til et innlegg kan det komme flere svarinnlegg, som det igjen kan komme svar på (en hierarkisk trådstruktur). Både beskjeder og innlegg har en avsender, en dato, en overskrift og et innhold (tekst).

## Del 1: Konseptuell Datamodell

**Oppgave:** Beskriv en konseptuell datamodell (med tekst eller ER-diagram) for systemet. Modellen skal kun inneholde entiteter, som du har valgt, og forholdene mellom dem, med kardinalitet. Du trenger ikke spesifisere attributter i denne delen.

**Ditt svar:** Se er_diagram.mmd
- Entiteter: ACCOUNT, GROUP_MEMBERSHIP, CLASS_GROUP, CLASSROOM_ACCESS, VIRTUAL_CLASSROOM, CLASSROOM_MESSAGE, DISCUSSION_FORUM, FORUM_POST


## Del 2: Logisk Skjema (Tabellstruktur)

**Oppgave:** Oversett den konseptuelle modellen til en logisk tabellstruktur. Spesifiser tabellnavn, attributter (kolonner), datatyper, primærnøkler (PK) og fremmednøkler (FK). Tegn et utvidet ER-diagram med [mermaid.live](https://mermaid.live/) eller eventuelt på papir.


**Ditt svar:** Se er_diagram.mmd
- ACCOUNT: user_id (PK(SERIAL)), username (VARCHAR(50)), password (VARCHAR(128)), role (ENUM)
- GROUP_MEMBERSHIP: user_id og group_id (sammensatt PK(INT)), user_id (FK(INT)), group_id (FK(INT))
- CLASS_GROUP: group_id (PK (SERIAL)), group_name (VARCHAR(50))
- CLASSROOM_ACCESS: group_id og classroom_id (sammensatt PK (INT)), group_id (FK(INT)), classroom_id (FK(INT))
- VIRTUAL_CLASSROOM: classroom_id (PK (SERIAL)), classroom_code (VARCHAR(50)), classroom_name (VARCHAR(50)), user_id (FK(INT))
- CLASSROOM_MESSAGE: message_id (PK (SERIAL)), post_date (TIMESTAMP), subject ((VARCHAR(50))), content (TEXT), user_id (FK(INT)), classroom_id (FK(INT))
- DISCUSSION_FORUM: forum_id (PK (SERIAL)), classroom_id (FK(INT))
- FORUM_POST: post_id (PK (SERIAL)), post_date (TIMESTAMP), subject ((VARCHAR(50))), content (TEXT), parent_post_id (FK(INT) av post_id), user_id (FK(INT)), forum_id (FK(INT))


## Del 3: Datadefinisjon (DDL) og Mock-Data

**Oppgave:** Skriv SQL-setninger for å opprette tabellstrukturen (DDL - Data Definition Language) og sett inn realistiske mock-data for å simulere bruk av systemet.


**Ditt svar:** Se 01-init-database.sql


## Del 4: Spørringer mot Databasen

**Oppgave:** Skriv SQL-spørringer for å hente ut informasjonen beskrevet under. For hver oppgave skal du levere svar med både relasjonsalgebra-notasjon og standard SQL.

### 1. Finn de 3 nyeste beskjeder fra læreren i et gitt klasserom (f.eks. klasserom_id = 1).

*   **Relasjonsalgebra:**
    > $$ \lambda_{3} ( \tau_{post\_date\,DESC} ( \pi_{subject, content, username, post\_date} ( \sigma_{classroom\_id = 1} (CLASSROOM\_MESSAGE \bowtie ACCOUNT) ) ) ) $$
    - $\sigma$ (Sigma): Seleksjon. Operator for WHERE-klausulen. Filtrerer ut radene der classroom_id = 1.
    - $\pi$ (Pi): Projeksjon. Operator for SELECT-klausulen. Beholder bare de kolonnene vi skriver.
    - $\tau$ (Tau): Sortering. Operatoren for ORDER BY-klausulen. Sorterer på post_date i synkende rekkefølge.
    - $\lambda$ (Lambda): Limit. Brukes i utvidet algebra for å begrense antall rader som returneres.
    

*   **SQL:**
    ```sql
    SELECT subject, content, username, post_date
    FROM CLASSROOM_MESSAGE cm
    JOIN ACCOUNT a ON cm.user_id = a.user_id
    WHERE classroom_id = 1
    ORDER BY post_date DESC
    LIMIT 3;
    ```

### 2. Vis en hel diskusjonstråd startet av en spesifikk student (f.eks. avsender_id = 2).

*   **Relasjonsalgebra**
    > Trenger ikke å skrive en relasjonsalgebra setning her, siden det blir for komplekst og uoversiktlig. 

*   **SQL (med `WITH RECURSIVE`):**

    Du kan vente med denne oppgaven til vi har gått gjennom avanserte SQL-spørringer (tips: må bruke en rekursiv konstruksjon `WITH RECURSIVE diskusjonstraad AS (..) SELECT FROM diskusjonstraad ...`)
    ```sql
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
    ```

### 3. Finn alle studenter i en spesifikk gruppe (f.eks. gruppe_id = 1).

*   **Relasjonsalgebra:**
    > $$\pi_{user\_id, username, role, group\_id} (\sigma_{group\_id = 1 \land role = 'student'} (ACCOUNT \bowtie GROUP\_MEMBERSHIP))$$
    - $\bowtie$ (Natural Join): Koble tabeller på felles kolonnenavn.
    - $\sigma$ (Sigma): Seleksjon. Operator for WHERE-klausulen. Filtrerer ut radene der group_id = 1, og role = 'student'.
    - $\land$ (og-tegn): I stedet for AND bruker man ofte symbolet $\land$ mellom betingelsene i seleksjonen.
    - $\pi$ (Pi): Projeksjon. Operator for SELECT-klausulen. Beholder bare de kolonnene vi skriver.


*   **SQL:**
    ```sql
    SELECT a.user_id, a.username, a.role, gm.group_id
    FROM ACCOUNT a
    JOIN GROUP_MEMBERSHIP gm ON a.user_id = gm.user_id
    WHERE gm.group_id = 1 AND a.role = 'student';
    ```

### 4. Finn antall grupper.

*   **Relasjonsalgebra (med aggregering):**
    > $$_{COUNT(group\_id) \rightarrow number\_of\_groups} \mathcal{G} (CLASS\_GROUP)$$
    - $\mathcal{G}$: Aggregering: De vanligste aggregeringsfunksjonene er SUM, COUNT, AVG, MAX, MIN. Utfører beregninger på tvers av rader.
    - $\rightarrow$: Brukes for å gi resultatet et beskrivende kolonnenavn (tilsvarer AS i SQL).


*   **SQL:**
    ```sql
    SELECT COUNT(group_id) AS number_of_groups
    FROM CLASS_GROUP;
    ```

## Del 5: Implementer i postgreSQL i din Docker container

**Oppgave:** Gjenbruk `docker-compose.yml` fra Oppgavesett 1.3 (er i denne repositorien allerede, så du trenger ikke å gjøre noen endringer) og prøv å legge inn din skript for opprettelse av databasen for nettbasert undervsining med noen testdata i filen `01-init-database.sql` i mappen `init-scripts`. Du trenger ikke å opprette roller. 

Lagre alle SQL-spørringene dine fra oppgave 4 i en fil `oppgave4_losning.sql` i mappen `test-scripts` for at man kan teste disse med kommando:

```bash
docker-compose exec postgres psql -U admin -d data1500_db -f test-scripts/oppgave4_losning.sql
```
