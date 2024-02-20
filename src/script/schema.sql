-- Création de la table pour les employés
CREATE TABLE employes (
      id VARCHAR(20) PRIMARY KEY,
      nom VARCHAR(100) NOT NULL,
      prenom VARCHAR(100) NOT NULL
);

insert into employes values ('EMP01', 'Rasoa', 'Kolo'),
                            ('EMP02', 'Raketa', 'Anya'),
                            ('EMP03', 'Andria', 'Jao'),
                            ('EMP04', 'Rakoto', 'Vaovao'),
                            ('EMP05', 'Aiko', 'Soa');

CREATE TABLE type(
    id varchar(20) primary key,
    label varchar(200) not null
);

insert into type values ('TOO01', 'Ordinateur'),
                        ('T0002', 'Voiture'),
                        ('T0003', 'Outil'),
                        ('T0004', 'Ménager');

-- Création de la table pour les immobilisations
CREATE TABLE immobilisations (
    id VARCHAR(20) PRIMARY KEY,
     description VARCHAR(255) NOT NULL,
     date_achat DATE NOT NULL,
    type_id varchar(20) references type(id)
);

insert into immobilisations values('IMM01', 'Ordinateur de bureau', now(), 'TOO01'),
                                  ('IMM02', 'Geometre', now(), 'T0002'),
                                  ('IMM03', 'Van', now(), 'T0003'),
                                  ('IMM04', 'Ballais', now(), 'T0004');

-- Création de la table pour les tâches
CREATE TABLE taches (
    id VARCHAR(20) PRIMARY KEY,
    description VARCHAR(255) NOT NULL,
    duree_moyenne INT,
    immobilisation_id varchar(20) references immobilisations(id)
);

insert into taches values ('T001', 'Tradding', 4, 'IMM01'),
                          ('T002', 'Développement infomatique', 5, 'IMM01'),
                          ('T003', 'Analyse terrain', 3, 'IMM01'),
                          ('T004', 'Livraison', 7, 'IMM04');

insert into taches values ('T005', 'Etat du terrain', 4, 'IMM02'),
                          ('T006', 'Architecture', 5, 'IMM02'),
                          ('T007', 'Transport', 3, 'IMM03'),
                          ('T008', 'Livraison', 7, 'IMM03');

create table rapport(
    id varchar(20) primary key ,
    employe_id varchar(20) references employes(id),
    details text not null,
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP
);

alter table rapport add column suspicieux integer default 0;
-- Création de la table pour les utilisations des immobilisations par les employés
CREATE TABLE utilisations (
      id VARCHAR(20) PRIMARY KEY,
    rapport_id varchar(20) references rapport(id),
      immobilisation_id VARCHAR(20) NOT NULL,
      tache_id VARCHAR(20) NOT NULL,
      date_debut TIMESTAMP NOT NULL,
      date_fin TIMESTAMP
);


-- Séquence pour la table employes
CREATE SEQUENCE employes_id_seq;

-- Séquence pour la table type
CREATE SEQUENCE type_id_seq;

-- Séquence pour la table immobilisations
CREATE SEQUENCE immobilisations_id_seq;

-- Séquence pour la table taches
CREATE SEQUENCE taches_id_seq;

-- Séquence pour la table rapport
CREATE SEQUENCE rapport_id_seq;

-- Séquence pour la table utilisations
CREATE SEQUENCE utilisations_id_seq;

-- Associating employes table with the sequence
ALTER TABLE employes ALTER COLUMN id SET DEFAULT nextval('employes_id_seq');

-- Associating type table with the sequence
ALTER TABLE type ALTER COLUMN id SET DEFAULT nextval('type_id_seq');

-- Associating immobilisations table with the sequence
ALTER TABLE immobilisations ALTER COLUMN id SET DEFAULT nextval('immobilisations_id_seq');

-- Associating taches table with the sequence
ALTER TABLE taches ALTER COLUMN id SET DEFAULT nextval('taches_id_seq');

-- Associating rapport table with the sequence
ALTER TABLE rapport ALTER COLUMN id SET DEFAULT nextval('rapport_id_seq');

-- Associating utilisations table with the sequence
ALTER TABLE utilisations ALTER COLUMN id SET DEFAULT nextval('utilisations_id_seq');


create or replace view v_immobilisation_en_cours as
select r.date_debut, r.details, e.nom, i.description, r.date_fin, u.date_fin immobilation_date_fin,
    u.id
from utilisations u
    join rapport r on u.rapport_id = r.id
    join employes e on r.employe_id = e.id
    join immobilisations i on u.immobilisation_id = i.id

create or replace view v_somme_heure_utilisation as
    select SUM(EXTRACT(EPOCH FROM (u.date_fin - u.date_debut))) /  3600 AS total_hours,
        count(u.immobilisation_id) nombre_utilisation,
        u.immobilisation_id
        from utilisations u
        group by u.immobilisation_id;

create or replace view v_utilisation as
    select EXTRACT(EPOCH FROM (u.date_fin - u.date_debut)) /  3600 AS total_hours,
           count(u.immobilisation_id) nombre_utilisation,
           u.immobilisation_id,
           t.duree_moyenne,
           t.description
    from utilisations u
             join taches t on u.tache_id = t.id
    group by u.immobilisation_id, t.duree_moyenne, t.description, u.date_fin, u.date_debut;

create table callendrier_utilisation(
    id serial primary key ,
    numero_jour integer,
    annee integer,
    mois integer,
    jour varchar(20),
    immobilisation_id varchar(20) references immobilisations(id),
    heure double precision
);

INSERT INTO callendrier_utilisation (numero_jour, annee, mois, jour, immobilisation_id, heure)
SELECT
    numero_jour,
    2024 as annee,
    1 as mois,
    EXTRACT(ISODOW FROM to_date('2024-01-' || numero_jour, 'YYYY-MM-DD'))
        as jour,
    'IMM01' as immobilisation_id,
    ROUND((RANDOM() * (8 - 5) + 5)::numeric, 2) as heure
FROM
    generate_series(1, 31) as numero_jour
WHERE
    EXTRACT(ISODOW FROM to_date('2024-01-' || numero_jour, 'YYYY-MM-DD')) < 6;

insert into rapport(id, employe_id, details, date_debut, date_fin, suspicieux)
select 'RAP'||nextval('callendrier_utilisation_id_seq'), 'EMP01', 'Test', to_date('2024-01-' || jour || ' 08:00', 'YYYY-MM-DD hh:00'),
       to_date('2024-01-' || jour || ' 10:00', 'YYYY-MM-DD hh:00'), 0
    from generate_series(0, 31) as jour;

drop view  v_moyenne_utilisation;
create or replace view v_moyenne_utilisation as
select sum(heure), immobilisation_id, count(*), jour, sum(heure) / count(*) as moyenne from
    callendrier_utilisation group by immobilisation_id, jour order by jour;

with part1 as
    (
        select employe_id from rapport where date_fin is null
    )
    select e.* from employes e join part1 on part1.employe_id = e.id;

UPDATE utilisations set  date_fin='2024-02-13 16:55:00.0' where id='US00000010'

alter table immobilisations add column details text;

create or replace view v_immobilisation_rapport as
    select
        u.rapport_id, u.immobilisation_id, r.employe_id
        from rapport r join utilisations u on r.id = u.rapport_id
        group by  u.rapport_id, u.immobilisation_id, r.employe_id
;

create or replace view  v_count_nombre_utilisation as
    select count(*) nombre, vr.immobilisation_id, employe_id from v_immobilisation_rapport vr
        group by employe_id, vr.immobilisation_id;

create or replace view v_employe_immobilisation_appartenance as
select i.id immobilisation, e.id employe from immobilisations i cross join employes e;

drop view v_employe_immobilisation;
create or replace view v_employe_immobilisation as
    select coalesce(vu.nombre, 0)::Integer nombre, va.employe, va.immobilisation, e.nom from v_employe_immobilisation_appartenance va
        left join  v_count_nombre_utilisation vu on va.immobilisation = vu.immobilisation_id
                                                        and va.employe = vu.employe_id
        join employes e on va.employe = e.id order by nombre desc


CREATE TABLE Amortissement (
       id serial PRIMARY KEY,
       id_immobilisation varchar(20) references immobilisations(id),
       montant_amortissement DECIMAL(10, 2) NOT NULL,
       date_amortissement DATE NOT NULL
);


select e.* from employes e join rapport r on e.id = r.employe_id join callendrier_utilisation c on c.annee='2024' and c.mois = '1' and c.numero_jour='1' and c.immobilisation_id =


select e.* from employes e join rapport r on e.id = r.employe_id join callendrier_utilisation c where c.annee='2024' and c.mois = '1' and c.numero_jour='1' and immobilisation_id='IMM03'


select e.* from employes e join rapport r on e.id = r.employe_id join callendrier_utilisation c on c.annee='2024' and c.mois = '1' and c.numero_jour='30' and c.immobilisation_id='IMM01'


select e.* from employes e join rapport r on e.id = r.employe_id join callendrier_utilisation c on c.annee='2024' and c.mois = '1' and c.numero_jour='31' and c.immobilisation_id='IMM01'

insert into immobilisations (id, description, date_achat, type_id, details, prix_achat)
select 'IMM'||nextval('immobilisations_id_seq') as id, 'VOITURE' id, now(), 'T0003', 'Test', random()*serie
from generate_series(1,10) as serie