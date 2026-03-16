--
-- PostgreSQL database dump
--

\restrict BxIIDByIifeQcuqtEdBRU2PbmcMEbmtOz6IT32t5ne7Kc2lT8B58uFi3c1McyU7

-- Dumped from database version 14.20 (Homebrew)
-- Dumped by pg_dump version 17.9 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: kabir
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO kabir;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO interview_user;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.categories (
    id uuid NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.categories OWNER TO interview_user;

--
-- Name: note_problems; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.note_problems (
    note_id uuid NOT NULL,
    problem_id uuid NOT NULL
);


ALTER TABLE public.note_problems OWNER TO interview_user;

--
-- Name: note_shares; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.note_shares (
    note_id uuid NOT NULL,
    user_id uuid NOT NULL,
    permission character varying NOT NULL,
    shared_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.note_shares OWNER TO interview_user;

--
-- Name: notes; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.notes (
    id uuid NOT NULL,
    owner_id uuid NOT NULL,
    title character varying NOT NULL,
    content text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.notes OWNER TO interview_user;

--
-- Name: problem_categories; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.problem_categories (
    problem_id uuid NOT NULL,
    category_id uuid NOT NULL
);


ALTER TABLE public.problem_categories OWNER TO interview_user;

--
-- Name: problem_set_items; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.problem_set_items (
    problem_set_id uuid NOT NULL,
    problem_id uuid NOT NULL,
    order_index integer NOT NULL
);


ALTER TABLE public.problem_set_items OWNER TO interview_user;

--
-- Name: problem_sets; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.problem_sets (
    id uuid NOT NULL,
    name character varying NOT NULL,
    description text
);


ALTER TABLE public.problem_sets OWNER TO interview_user;

--
-- Name: problems; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.problems (
    id uuid NOT NULL,
    title character varying NOT NULL,
    difficulty character varying NOT NULL,
    description text,
    leetcode_url character varying
);


ALTER TABLE public.problems OWNER TO interview_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: interview_user
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying NOT NULL,
    password_hash character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO interview_user;

--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.alembic_version (version_num) FROM stdin;
d240ae2e2c7f
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.categories (id, name) FROM stdin;
e4b842e6-a09f-4240-8091-8dd811f12e4f	Array
50aad385-21b7-481d-8f56-426548123df3	Dynamic Programming
2bb70499-c3ca-4450-87d9-3220368158be	Graph
d11c7a98-7dc5-4af7-8f4e-aed35cc46d2e	Tree
41ec2abd-dbce-4fe7-a6b5-f77265558950	Binary Search
87007e8e-b693-4803-a6da-a652e249d006	Sliding Window
2d07554b-c9b7-4865-805f-e355dc62766f	Backtracking
\.


--
-- Data for Name: note_problems; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.note_problems (note_id, problem_id) FROM stdin;
\.


--
-- Data for Name: note_shares; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.note_shares (note_id, user_id, permission, shared_at) FROM stdin;
9f0cd6ac-f4ab-464f-8a93-72b75ae07693	5884daa6-758e-4a70-a1c3-8f225e96794f	read	2026-03-08 10:55:01.538014+05:30
\.


--
-- Data for Name: notes; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.notes (id, owner_id, title, content, created_at, updated_at) FROM stdin;
3aeb599a-3db3-41ce-9eb0-e5eaac3362ec	23d27f7f-816f-4ea9-a4de-dd78c4683551	Two Sum Approach	Use hashmap to track complements	2026-03-07 13:05:48.299526+05:30	2026-03-07 13:05:48.29953+05:30
f88bf3fb-34a7-4e23-9cfe-13235a5fa308	23d27f7f-816f-4ea9-a4de-dd78c4683551	Two Sum Approach	Use hashmap to track complements	2026-03-07 13:11:02.369457+05:30	2026-03-07 13:11:02.36946+05:30
9f0cd6ac-f4ab-464f-8a93-72b75ae07693	0b871318-5c5e-4a30-aaed-7b5da05c4ad9	Two Sum Approach	Use hashmap to track complements	2026-03-08 05:23:28.72103+05:30	2026-03-08 05:23:28.721034+05:30
\.


--
-- Data for Name: problem_categories; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.problem_categories (problem_id, category_id) FROM stdin;
92ee4f2e-bd59-46da-8d87-334fd4afab20	e4b842e6-a09f-4240-8091-8dd811f12e4f
4d6a9afe-7fca-45d9-be03-59a6ea90bc19	50aad385-21b7-481d-8f56-426548123df3
5138f566-dc4e-4e7b-a6dc-c8cf34cef861	d11c7a98-7dc5-4af7-8f4e-aed35cc46d2e
8cffa322-bc99-4210-acbd-93c3a6691c0f	2bb70499-c3ca-4450-87d9-3220368158be
\.


--
-- Data for Name: problem_set_items; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.problem_set_items (problem_set_id, problem_id, order_index) FROM stdin;
027bd85d-ca5b-4d2a-8474-5067756261fa	92ee4f2e-bd59-46da-8d87-334fd4afab20	1
027bd85d-ca5b-4d2a-8474-5067756261fa	4d6a9afe-7fca-45d9-be03-59a6ea90bc19	2
027bd85d-ca5b-4d2a-8474-5067756261fa	5138f566-dc4e-4e7b-a6dc-c8cf34cef861	3
027bd85d-ca5b-4d2a-8474-5067756261fa	8cffa322-bc99-4210-acbd-93c3a6691c0f	4
\.


--
-- Data for Name: problem_sets; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.problem_sets (id, name, description) FROM stdin;
027bd85d-ca5b-4d2a-8474-5067756261fa	leetcode_150	Top Leetcode interview questions
\.


--
-- Data for Name: problems; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.problems (id, title, difficulty, description, leetcode_url) FROM stdin;
d63b953b-70d5-4a85-a59c-137759b788b5	Two Sum	Easy	\N	\N
41accbbe-2ca9-4f04-a351-95b5e624a0e8	Best Time to Buy and Sell Stock	Easy	\N	\N
b3d2130d-2f21-4af6-b26d-fb12858d6600	Contains Duplicate	Easy	\N	\N
36884086-fc36-4dbb-a613-dc03567a1165	Product of Array Except Self	Medium	\N	\N
477598bb-9c18-4a62-8dcc-7aeda537e24e	Maximum Subarray	Medium	\N	\N
11ba32ff-81c1-47ba-8e7d-169d4093470e	Maximum Product Subarray	Medium	\N	\N
e935d06d-4f53-4171-83de-46d84d8050a6	Find Minimum in Rotated Sorted Array	Medium	\N	\N
bab38fca-7151-45db-b3ae-7f85f6adb959	Search in Rotated Sorted Array	Medium	\N	\N
3b03fd42-f598-46c0-972b-b9febbd254fa	3Sum	Medium	\N	\N
fb4b1ce8-2331-44f7-8cea-96dc95793ddc	Container With Most Water	Medium	\N	\N
92ee4f2e-bd59-46da-8d87-334fd4afab20	Two Sum	Easy	\N	\N
4d6a9afe-7fca-45d9-be03-59a6ea90bc19	Maximum Subarray	Medium	\N	\N
5138f566-dc4e-4e7b-a6dc-c8cf34cef861	Binary Tree Level Order Traversal	Medium	\N	\N
8cffa322-bc99-4210-acbd-93c3a6691c0f	Number of Islands	Medium	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: interview_user
--

COPY public.users (id, email, password_hash, created_at, updated_at) FROM stdin;
77981aec-99c1-4087-99c8-042a1f630bbb	test@example.com	$2b$12$Vm.5xznVDjQIu2LUNOabxusvfP1CVU8ajvnncxQyJk.4LcDmBK3gS	2026-03-07 17:14:27.819902+05:30	\N
23d27f7f-816f-4ea9-a4de-dd78c4683551	user@example.com	$2b$12$pcYTcdfq/.hw3e5bHcOpneq.O8sFA5B7XFXGT3A/eCmxGx3E3ebTe	2026-03-07 17:32:40.736615+05:30	\N
0b871318-5c5e-4a30-aaed-7b5da05c4ad9	user1@example.com	$2b$12$EE0qc32KHgcXdywp52EV/uGnMdaVnxBLwYtt6.yLXoP8BXVxcaXYe	2026-03-08 10:47:32.133383+05:30	\N
5884daa6-758e-4a70-a1c3-8f225e96794f	friend@example.com	$2b$12$lVpaQo0/RFevtViCVWDInuCug6zZaJnZrup9so3pFO6GtF4dSIKhi	2026-03-08 10:47:56.995715+05:30	\N
\.


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: note_problems note_problems_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.note_problems
    ADD CONSTRAINT note_problems_pkey PRIMARY KEY (note_id, problem_id);


--
-- Name: note_shares note_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.note_shares
    ADD CONSTRAINT note_shares_pkey PRIMARY KEY (note_id, user_id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: problem_categories problem_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problem_categories
    ADD CONSTRAINT problem_categories_pkey PRIMARY KEY (problem_id, category_id);


--
-- Name: problem_set_items problem_set_items_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problem_set_items
    ADD CONSTRAINT problem_set_items_pkey PRIMARY KEY (problem_set_id, problem_id);


--
-- Name: problem_sets problem_sets_name_key; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problem_sets
    ADD CONSTRAINT problem_sets_name_key UNIQUE (name);


--
-- Name: problem_sets problem_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problem_sets
    ADD CONSTRAINT problem_sets_pkey PRIMARY KEY (id);


--
-- Name: problems problems_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problems
    ADD CONSTRAINT problems_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: interview_user
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: note_problems note_problems_note_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.note_problems
    ADD CONSTRAINT note_problems_note_id_fkey FOREIGN KEY (note_id) REFERENCES public.notes(id);


--
-- Name: note_problems note_problems_problem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.note_problems
    ADD CONSTRAINT note_problems_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES public.problems(id);


--
-- Name: note_shares note_shares_note_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.note_shares
    ADD CONSTRAINT note_shares_note_id_fkey FOREIGN KEY (note_id) REFERENCES public.notes(id);


--
-- Name: note_shares note_shares_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.note_shares
    ADD CONSTRAINT note_shares_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notes notes_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: problem_categories problem_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problem_categories
    ADD CONSTRAINT problem_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: problem_categories problem_categories_problem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problem_categories
    ADD CONSTRAINT problem_categories_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES public.problems(id);


--
-- Name: problem_set_items problem_set_items_problem_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problem_set_items
    ADD CONSTRAINT problem_set_items_problem_id_fkey FOREIGN KEY (problem_id) REFERENCES public.problems(id);


--
-- Name: problem_set_items problem_set_items_problem_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: interview_user
--

ALTER TABLE ONLY public.problem_set_items
    ADD CONSTRAINT problem_set_items_problem_set_id_fkey FOREIGN KEY (problem_set_id) REFERENCES public.problem_sets(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: kabir
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict BxIIDByIifeQcuqtEdBRU2PbmcMEbmtOz6IT32t5ne7Kc2lT8B58uFi3c1McyU7

