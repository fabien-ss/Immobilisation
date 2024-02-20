--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1 (Debian 16.1-1.pgdg120+1)
-- Dumped by pg_dump version 16.1 (Debian 16.1-1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: callendrier_utilisation; Type: TABLE; Schema: public; Owner: your_username
--

CREATE TABLE public.callendrier_utilisation (
    id integer NOT NULL,
    numero_jour integer,
    annee integer,
    mois integer,
    jour character varying(20),
    immobilisation_id character varying(20),
    heure double precision
);


ALTER TABLE public.callendrier_utilisation OWNER TO your_username;

--
-- Name: callendrier_utilisation_id_seq; Type: SEQUENCE; Schema: public; Owner: your_username
--

CREATE SEQUENCE public.callendrier_utilisation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.callendrier_utilisation_id_seq OWNER TO your_username;

--
-- Name: callendrier_utilisation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: your_username
--

ALTER SEQUENCE public.callendrier_utilisation_id_seq OWNED BY public.callendrier_utilisation.id;


--
-- Name: employes; Type: TABLE; Schema: public; Owner: your_username
--

CREATE TABLE public.employes (
    id character varying(20) NOT NULL,
    nom character varying(100) NOT NULL,
    prenom character varying(100) NOT NULL
);


ALTER TABLE public.employes OWNER TO your_username;

--
-- Name: employes_id_seq; Type: SEQUENCE; Schema: public; Owner: your_username
--

CREATE SEQUENCE public.employes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employes_id_seq OWNER TO your_username;

--
-- Name: immobilisations; Type: TABLE; Schema: public; Owner: your_username
--

CREATE TABLE public.immobilisations (
    id character varying(20) NOT NULL,
    description character varying(255) NOT NULL,
    date_achat date NOT NULL,
    type_id character varying(20),
    details text,
    prix_achat double precision
);


ALTER TABLE public.immobilisations OWNER TO your_username;

--
-- Name: immobilisations_id_seq; Type: SEQUENCE; Schema: public; Owner: your_username
--

CREATE SEQUENCE public.immobilisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.immobilisations_id_seq OWNER TO your_username;

--
-- Name: rapport; Type: TABLE; Schema: public; Owner: your_username
--

CREATE TABLE public.rapport (
    id character varying(20) NOT NULL,
    employe_id character varying(20),
    details text NOT NULL,
    date_debut timestamp without time zone NOT NULL,
    date_fin timestamp without time zone,
    suspicieux integer DEFAULT 0
);


ALTER TABLE public.rapport OWNER TO your_username;

--
-- Name: rapport_id_seq; Type: SEQUENCE; Schema: public; Owner: your_username
--

CREATE SEQUENCE public.rapport_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rapport_id_seq OWNER TO your_username;

--
-- Name: taches; Type: TABLE; Schema: public; Owner: your_username
--

CREATE TABLE public.taches (
    id character varying(20) NOT NULL,
    description character varying(255) NOT NULL,
    duree_moyenne integer,
    immobilisation_id character varying(20)
);


ALTER TABLE public.taches OWNER TO your_username;

--
-- Name: taches_id_seq; Type: SEQUENCE; Schema: public; Owner: your_username
--

CREATE SEQUENCE public.taches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.taches_id_seq OWNER TO your_username;

--
-- Name: type; Type: TABLE; Schema: public; Owner: your_username
--

CREATE TABLE public.type (
    id character varying(20) NOT NULL,
    label character varying(200) NOT NULL
);


ALTER TABLE public.type OWNER TO your_username;

--
-- Name: type_id_seq; Type: SEQUENCE; Schema: public; Owner: your_username
--

CREATE SEQUENCE public.type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.type_id_seq OWNER TO your_username;

--
-- Name: utilisations; Type: TABLE; Schema: public; Owner: your_username
--

CREATE TABLE public.utilisations (
    id character varying(20) NOT NULL,
    rapport_id character varying(20),
    immobilisation_id character varying(20) NOT NULL,
    tache_id character varying(20) NOT NULL,
    date_debut timestamp without time zone NOT NULL,
    date_fin timestamp without time zone
);


ALTER TABLE public.utilisations OWNER TO your_username;

--
-- Name: utilisations_id_seq; Type: SEQUENCE; Schema: public; Owner: your_username
--

CREATE SEQUENCE public.utilisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.utilisations_id_seq OWNER TO your_username;

--
-- Name: v_immobilisation_rapport; Type: VIEW; Schema: public; Owner: your_username
--

CREATE VIEW public.v_immobilisation_rapport AS
 SELECT u.rapport_id,
    u.immobilisation_id,
    r.employe_id
   FROM (public.rapport r
     JOIN public.utilisations u ON (((r.id)::text = (u.rapport_id)::text)))
  GROUP BY u.rapport_id, u.immobilisation_id, r.employe_id;


ALTER VIEW public.v_immobilisation_rapport OWNER TO your_username;

--
-- Name: v_count_nombre_utilisation; Type: VIEW; Schema: public; Owner: your_username
--

CREATE VIEW public.v_count_nombre_utilisation AS
 SELECT count(*) AS nombre,
    immobilisation_id,
    employe_id
   FROM public.v_immobilisation_rapport vr
  GROUP BY employe_id, immobilisation_id;


ALTER VIEW public.v_count_nombre_utilisation OWNER TO your_username;

--
-- Name: v_employe_immobilisation_appartenance; Type: VIEW; Schema: public; Owner: your_username
--

CREATE VIEW public.v_employe_immobilisation_appartenance AS
 SELECT i.id AS immobilisation,
    e.id AS employe
   FROM (public.immobilisations i
     CROSS JOIN public.employes e);


ALTER VIEW public.v_employe_immobilisation_appartenance OWNER TO your_username;

--
-- Name: v_employe_immobilisation; Type: VIEW; Schema: public; Owner: your_username
--

CREATE VIEW public.v_employe_immobilisation AS
 SELECT (COALESCE(vu.nombre, (0)::bigint))::integer AS nombre,
    va.employe,
    va.immobilisation,
    e.nom
   FROM ((public.v_employe_immobilisation_appartenance va
     LEFT JOIN public.v_count_nombre_utilisation vu ON ((((va.immobilisation)::text = (vu.immobilisation_id)::text) AND ((va.employe)::text = (vu.employe_id)::text))))
     JOIN public.employes e ON (((va.employe)::text = (e.id)::text)))
  ORDER BY ((COALESCE(vu.nombre, (0)::bigint))::integer) DESC;


ALTER VIEW public.v_employe_immobilisation OWNER TO your_username;

--
-- Name: v_immobilisation_en_cours; Type: VIEW; Schema: public; Owner: your_username
--

CREATE VIEW public.v_immobilisation_en_cours AS
 SELECT r.date_debut,
    r.details,
    e.nom,
    i.description,
    r.date_fin,
    u.date_fin AS immobilation_date_fin,
    u.id
   FROM (((public.utilisations u
     JOIN public.rapport r ON (((u.rapport_id)::text = (r.id)::text)))
     JOIN public.employes e ON (((r.employe_id)::text = (e.id)::text)))
     JOIN public.immobilisations i ON (((u.immobilisation_id)::text = (i.id)::text)));


ALTER VIEW public.v_immobilisation_en_cours OWNER TO your_username;

--
-- Name: v_moyenne_utilisation; Type: VIEW; Schema: public; Owner: your_username
--

CREATE VIEW public.v_moyenne_utilisation AS
 SELECT sum(heure) AS sum,
    immobilisation_id,
    count(*) AS count,
    jour,
    (sum(heure) / (count(*))::double precision) AS moyenne
   FROM public.callendrier_utilisation
  GROUP BY immobilisation_id, jour
  ORDER BY jour;


ALTER VIEW public.v_moyenne_utilisation OWNER TO your_username;

--
-- Name: v_somme_heure_utilisation; Type: VIEW; Schema: public; Owner: your_username
--

CREATE VIEW public.v_somme_heure_utilisation AS
 SELECT (sum(EXTRACT(epoch FROM (date_fin - date_debut))) / (3600)::numeric) AS total_hours,
    count(immobilisation_id) AS nombre_utilisation,
    immobilisation_id
   FROM public.utilisations u
  GROUP BY immobilisation_id;


ALTER VIEW public.v_somme_heure_utilisation OWNER TO your_username;

--
-- Name: callendrier_utilisation id; Type: DEFAULT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.callendrier_utilisation ALTER COLUMN id SET DEFAULT nextval('public.callendrier_utilisation_id_seq'::regclass);


--
-- Data for Name: callendrier_utilisation; Type: TABLE DATA; Schema: public; Owner: your_username
--

COPY public.callendrier_utilisation (id, numero_jour, annee, mois, jour, immobilisation_id, heure) FROM stdin;
205	1	2024	1	1	IMM02	7.75
206	2	2024	1	2	IMM02	6.76
207	3	2024	1	3	IMM02	7.25
208	4	2024	1	4	IMM02	6.69
209	5	2024	1	5	IMM02	6.98
210	8	2024	1	1	IMM02	6.26
211	9	2024	1	2	IMM02	5.32
212	10	2024	1	3	IMM02	5.32
213	11	2024	1	4	IMM02	5.21
214	12	2024	1	5	IMM02	7.82
215	15	2024	1	1	IMM02	6.24
253	1	2024	2	4	IMM02	5
182	1	2024	1	1	IMM03	5.71
183	2	2024	1	2	IMM03	6.97
184	3	2024	1	3	IMM03	5.09
185	4	2024	1	4	IMM03	5.29
186	5	2024	1	5	IMM03	5.85
187	8	2024	1	1	IMM03	6.64
188	9	2024	1	2	IMM03	7.21
189	10	2024	1	3	IMM03	7.12
190	11	2024	1	4	IMM03	6.95
191	12	2024	1	5	IMM03	7.21
192	15	2024	1	1	IMM03	6.39
193	16	2024	1	2	IMM03	7.19
194	17	2024	1	3	IMM03	6.51
195	18	2024	1	4	IMM03	7.41
196	19	2024	1	5	IMM03	7.57
197	22	2024	1	1	IMM03	5.21
198	23	2024	1	2	IMM03	7.91
199	24	2024	1	3	IMM03	5.59
200	25	2024	1	4	IMM03	5.29
201	26	2024	1	5	IMM03	6.42
202	29	2024	1	1	IMM03	6.83
203	30	2024	1	2	IMM03	5.85
204	31	2024	1	3	IMM03	5.67
216	16	2024	1	2	IMM02	6.09
217	17	2024	1	3	IMM02	6.1
218	18	2024	1	4	IMM02	5.37
219	19	2024	1	5	IMM02	6.17
220	22	2024	1	1	IMM02	6.53
221	23	2024	1	2	IMM02	5.52
222	24	2024	1	3	IMM02	6.1
223	25	2024	1	4	IMM02	5.33
224	26	2024	1	5	IMM02	5.74
225	29	2024	1	1	IMM02	6.23
226	30	2024	1	2	IMM02	5.25
227	31	2024	1	3	IMM02	7.84
228	1	2024	1	1	IMM01	5.96
229	2	2024	1	2	IMM01	7.32
230	3	2024	1	3	IMM01	6.62
231	4	2024	1	4	IMM01	6.64
232	5	2024	1	5	IMM01	5.43
254	1	2024	2	4	IMM01	6
255	1	2024	2	4	IMM03	3
256	2	2024	2	5	IMM02	9
257	1	2024	2	4	IMM02	8
291	2	2024	2	5	IMM02	7.142
292	2	2024	2	5	IMM02	7.142
293	1	2024	2	4	IMM01	6.436
233	8	2024	1	1	IMM01	5.35
234	9	2024	1	2	IMM01	6.18
235	10	2024	1	3	IMM01	6.04
236	11	2024	1	4	IMM01	6.8
237	12	2024	1	5	IMM01	6.51
238	15	2024	1	1	IMM01	5.65
239	16	2024	1	2	IMM01	5.31
240	17	2024	1	3	IMM01	7.09
241	18	2024	1	4	IMM01	7.5
242	19	2024	1	5	IMM01	5.25
243	22	2024	1	1	IMM01	7.01
244	23	2024	1	2	IMM01	7.13
245	24	2024	1	3	IMM01	5.17
246	25	2024	1	4	IMM01	5.24
247	26	2024	1	5	IMM01	5.2
248	29	2024	1	1	IMM01	5.01
249	30	2024	1	2	IMM01	6.4
250	31	2024	1	3	IMM01	6.5
\.


--
-- Data for Name: employes; Type: TABLE DATA; Schema: public; Owner: your_username
--

COPY public.employes (id, nom, prenom) FROM stdin;
EMP0000003	Fabien	Dupain
EMP01	Rasoa	Kolo
EMP02	Raketa	Anya
EMP03	Andria	Jao
EMP04	Rakoto	Vaovao
EMP05	Aiko	Soa
01	Koto	Lola
\.


--
-- Data for Name: immobilisations; Type: TABLE DATA; Schema: public; Owner: your_username
--

COPY public.immobilisations (id, description, date_achat, type_id, details, prix_achat) FROM stdin;
IMM02	Geometre	2024-02-13	T0002	specialisation=topographie, logiciel=AutoCAD, expert_releves=yes, analyse_geospatiale=yes, instruments=station totale, drone=yes, GPS=yes, niveau_laser=yes.\n	1500000
IMM03	Van	2010-02-20	T0003	puissance=60 chevaux, couleur=rouge, climatisation=yes, sieges_cuir=yes, capacite=7 personnes, bluetooth=yes, camera_recule=yes, portes_coulissantes=yes.\n	1500
IMM01	Ordinateur	2010-07-01	TOO01	processeur=Intel Core i7, RAM=16 Go, disque_ssd=yes, carte_graphique=dediee, ecran=tactile, webcam=yes, lecteur_empreintes=yes, ports_usb=4.\n	8000
IMM0000026	Téléphone	2024-02-02	\N	ram=1,\r\nstockage=2	500
\.


--
-- Data for Name: rapport; Type: TABLE DATA; Schema: public; Owner: your_username
--

COPY public.rapport (id, employe_id, details, date_debut, date_fin, suspicieux) FROM stdin;
R000000006	EMP0000003	Ca commence a ralentir	2024-02-01 12:12:00	2024-02-01 18:00:00	0
R000000007	EMP01	Niandry olona lasa	2024-02-01 12:12:00	2024-02-01 19:00:00	0
R000000016	EMP03	Plusieurs marchandises et escorte	2024-02-01 08:02:00	2024-02-01 19:00:00	0
R000000017	01	Here we go again	2024-02-01 05:00:00	2024-02-01 08:00:00	0
R000000019	EMP05	L endroit de la pratique n etait pas accessible	2024-02-02 07:00:00	2024-02-02 16:01:00	0
RAP259	EMP01	Test	2024-01-01 00:00:00	2024-01-01 00:00:00	0
RAP260	EMP01	Test	2024-01-01 00:00:00	2024-01-01 00:00:00	0
R000000020	EMP02	J étais très en retard	2024-02-02 04:00:00	2024-02-02 16:00:00	0
R000000008	EMP02	ok	2024-02-01 12:12:00	2024-02-01 22:06:00	1
R000000025	EMP0000003	Ok	2024-02-01 08:00:00	2024-02-01 18:10:00	0
R000000026	EMP0000003	Test alea	2024-02-02 08:00:00	\N	0
R000000027	EMP03	Test alea	2024-02-02 08:00:00	\N	0
R000000028	EMP02	TEST ALEAO	2024-02-02 08:00:00	\N	0
R000000029	EMP0000003	Azafady eh	2024-02-05 08:00:00	2024-02-05 18:00:00	1
\.


--
-- Data for Name: taches; Type: TABLE DATA; Schema: public; Owner: your_username
--

COPY public.taches (id, description, duree_moyenne, immobilisation_id) FROM stdin;
T001	Tradding	4	IMM01
T002	Développement infomatique	5	IMM01
T003	Analyse terrain	3	IMM01
T005	Etat du terrain	4	IMM02
T006	Architecture	5	IMM02
T007	Transport	3	IMM03
T008	Livraison	7	IMM03
001	Saisie	4	IMM01
\.


--
-- Data for Name: type; Type: TABLE DATA; Schema: public; Owner: your_username
--

COPY public.type (id, label) FROM stdin;
T000000002	Electronique
TOO01	Ordinateur
T0002	Voiture
T0003	Outil
T0004	Ménager
\.


--
-- Data for Name: utilisations; Type: TABLE DATA; Schema: public; Owner: your_username
--

COPY public.utilisations (id, rapport_id, immobilisation_id, tache_id, date_debut, date_fin) FROM stdin;
US00000016	R000000017	IMM03	T008	2024-02-01 05:00:00	2024-02-01 07:00:00
US00000018	R000000020	IMM02	T005	2024-02-02 04:00:00	2024-02-02 11:01:00
US00000007	R000000006	IMM02	T005	2024-02-01 08:12:00	2024-02-13 16:50:00
US00000009	R000000007	IMM01	T002	2024-02-01 12:12:00	2024-02-01 15:00:00
US00000010	R000000007	IMM01	T003	2024-02-01 12:12:00	2024-02-01 16:00:00
US00000008	R000000007	IMM01	T001	2024-02-01 12:12:00	2024-02-01 16:00:00
US00000013	R000000016	IMM03	T007	2024-02-01 08:02:00	2024-02-01 10:00:00
US00000014	R000000016	IMM03	T008	2024-02-01 08:02:00	2024-02-01 19:00:00
US00000011	R000000008	IMM02	T005	2024-02-01 08:20:00	2024-02-01 09:00:00
US00000017	R000000019	IMM02	T005	2024-02-02 07:00:00	2024-02-02 08:00:00
US00000015	R000000017	IMM03	T007	2024-02-01 05:00:00	2024-02-01 09:00:00
US00000019	R000000020	IMM02	T006	2024-02-02 04:00:00	2024-02-02 08:00:00
RAP259	RAP259	IMM02	T006	2024-01-01 00:00:00	2024-01-01 00:00:00
RAP260	RAP260	IMM02	T006	2024-01-01 00:00:00	2024-01-01 00:00:00
US00000025	R000000025	IMM01	001	2024-02-01 08:00:00	2024-02-01 09:00:00
US00000028	R000000028	IMM01	T003	2024-02-02 08:00:00	2024-02-02 09:10:00
US00000029	R000000029	IMM01	T002	2024-02-05 08:00:00	2024-02-05 18:00:00
\.


--
-- Name: callendrier_utilisation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: your_username
--

SELECT pg_catalog.setval('public.callendrier_utilisation_id_seq', 293, true);


--
-- Name: employes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: your_username
--

SELECT pg_catalog.setval('public.employes_id_seq', 3, true);


--
-- Name: immobilisations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: your_username
--

SELECT pg_catalog.setval('public.immobilisations_id_seq', 26, true);


--
-- Name: rapport_id_seq; Type: SEQUENCE SET; Schema: public; Owner: your_username
--

SELECT pg_catalog.setval('public.rapport_id_seq', 29, true);


--
-- Name: taches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: your_username
--

SELECT pg_catalog.setval('public.taches_id_seq', 1, false);


--
-- Name: type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: your_username
--

SELECT pg_catalog.setval('public.type_id_seq', 2, true);


--
-- Name: utilisations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: your_username
--

SELECT pg_catalog.setval('public.utilisations_id_seq', 29, true);


--
-- Name: callendrier_utilisation callendrier_utilisation_pkey; Type: CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.callendrier_utilisation
    ADD CONSTRAINT callendrier_utilisation_pkey PRIMARY KEY (id);


--
-- Name: employes employes_pkey; Type: CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.employes
    ADD CONSTRAINT employes_pkey PRIMARY KEY (id);


--
-- Name: immobilisations immobilisations_pkey; Type: CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.immobilisations
    ADD CONSTRAINT immobilisations_pkey PRIMARY KEY (id);


--
-- Name: rapport rapport_pkey; Type: CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.rapport
    ADD CONSTRAINT rapport_pkey PRIMARY KEY (id);


--
-- Name: taches taches_pkey; Type: CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.taches
    ADD CONSTRAINT taches_pkey PRIMARY KEY (id);


--
-- Name: type type_pkey; Type: CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.type
    ADD CONSTRAINT type_pkey PRIMARY KEY (id);


--
-- Name: utilisations utilisations_pkey; Type: CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.utilisations
    ADD CONSTRAINT utilisations_pkey PRIMARY KEY (id);


--
-- Name: callendrier_utilisation callendrier_utilisation_immobilisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.callendrier_utilisation
    ADD CONSTRAINT callendrier_utilisation_immobilisation_id_fkey FOREIGN KEY (immobilisation_id) REFERENCES public.immobilisations(id);


--
-- Name: immobilisations immobilisations_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.immobilisations
    ADD CONSTRAINT immobilisations_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.type(id);


--
-- Name: rapport rapport_employe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.rapport
    ADD CONSTRAINT rapport_employe_id_fkey FOREIGN KEY (employe_id) REFERENCES public.employes(id);


--
-- Name: taches taches_immobilisation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.taches
    ADD CONSTRAINT taches_immobilisation_id_fkey FOREIGN KEY (immobilisation_id) REFERENCES public.immobilisations(id);


--
-- Name: utilisations utilisations_rapport_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: your_username
--

ALTER TABLE ONLY public.utilisations
    ADD CONSTRAINT utilisations_rapport_id_fkey FOREIGN KEY (rapport_id) REFERENCES public.rapport(id);


--
-- PostgreSQL database dump complete
--

