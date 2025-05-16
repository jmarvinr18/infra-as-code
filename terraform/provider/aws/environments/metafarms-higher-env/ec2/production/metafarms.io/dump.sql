--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2 (Debian 15.2-1.pgdg110+1)
-- Dumped by pg_dump version 15.2 (Debian 15.2-1.pgdg110+1)

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

--
-- Name: admin_users_status_enum; Type: TYPE; Schema: public; Owner: metafarm_user
--

CREATE TYPE public.admin_users_status_enum AS ENUM (
    'inactive',
    'active'
);


ALTER TYPE public.admin_users_status_enum OWNER TO metafarm_user;

--
-- Name: projects_status_enum; Type: TYPE; Schema: public; Owner: metafarm_user
--

CREATE TYPE public.projects_status_enum AS ENUM (
    'active',
    'inactive',
    'deleted'
);


ALTER TYPE public.projects_status_enum OWNER TO metafarm_user;

--
-- Name: referrals_status_enum; Type: TYPE; Schema: public; Owner: metafarm_user
--

CREATE TYPE public.referrals_status_enum AS ENUM (
    'active',
    'inactive',
    'deleted'
);


ALTER TYPE public.referrals_status_enum OWNER TO metafarm_user;

--
-- Name: users_status_enum; Type: TYPE; Schema: public; Owner: metafarm_user
--

CREATE TYPE public.users_status_enum AS ENUM (
    'inactive',
    'active'
);


ALTER TYPE public.users_status_enum OWNER TO metafarm_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_user_credentials; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.admin_user_credentials (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    admin_user_id bigint NOT NULL,
    email character varying NOT NULL,
    password character varying NOT NULL
);


ALTER TABLE public.admin_user_credentials OWNER TO metafarm_user;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.admin_users (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    email character varying NOT NULL,
    status public.admin_users_status_enum DEFAULT 'active'::public.admin_users_status_enum NOT NULL
);


ALTER TABLE public.admin_users OWNER TO metafarm_user;

--
-- Name: events; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.events (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id integer NOT NULL,
    event character varying NOT NULL,
    block_number bigint NOT NULL,
    block_hash character varying NOT NULL,
    transaction_hash character varying NOT NULL,
    address character varying NOT NULL,
    payload json DEFAULT '{}'::json NOT NULL,
    chain_id character varying
);


ALTER TABLE public.events OWNER TO metafarm_user;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: metafarm_user
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO metafarm_user;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: metafarm_user
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: files; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.files (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    file_name character varying NOT NULL,
    file_url character varying NOT NULL,
    key character varying NOT NULL,
    file_type character varying NOT NULL,
    file_size integer NOT NULL
);


ALTER TABLE public.files OWNER TO metafarm_user;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO metafarm_user;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: metafarm_user
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO metafarm_user;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: metafarm_user
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: nfts; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.nfts (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    image character varying,
    amount real NOT NULL,
    price real NOT NULL,
    detail character varying,
    metadata character varying,
    network character varying,
    project_id integer NOT NULL,
    name character varying,
    symbol character varying,
    contract_address character varying,
    collection_id character varying,
    granted_addresses jsonb DEFAULT '[]'::jsonb NOT NULL,
    on_chain_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    fiat_price character varying,
    beneficiary character varying
);


ALTER TABLE public.nfts OWNER TO metafarm_user;

--
-- Name: nfts_id_seq; Type: SEQUENCE; Schema: public; Owner: metafarm_user
--

CREATE SEQUENCE public.nfts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.nfts_id_seq OWNER TO metafarm_user;

--
-- Name: nfts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: metafarm_user
--

ALTER SEQUENCE public.nfts_id_seq OWNED BY public.nfts.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.projects (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    status public.projects_status_enum DEFAULT 'active'::public.projects_status_enum NOT NULL,
    name character varying NOT NULL,
    overview character varying NOT NULL,
    about_us character varying NOT NULL,
    description character varying NOT NULL,
    categories jsonb DEFAULT '[]'::jsonb NOT NULL,
    revenue_streams jsonb DEFAULT '[]'::jsonb NOT NULL,
    attachments jsonb DEFAULT '[]'::jsonb NOT NULL,
    cliff_time real NOT NULL,
    annual_profit real NOT NULL,
    logo character varying NOT NULL,
    banner character varying NOT NULL,
    id integer NOT NULL,
    nft_name character varying,
    nft_symbol character varying,
    contract_address character varying,
    collection_id character varying,
    granted_addresses jsonb DEFAULT '[]'::jsonb NOT NULL,
    on_chain_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    "maxSupply" character varying,
    uri character varying,
    nft_image character varying,
    nft_detail character varying,
    nft_metadata character varying,
    nft_network character varying,
    is_show_revenue_streams boolean DEFAULT true NOT NULL
);


ALTER TABLE public.projects OWNER TO metafarm_user;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: metafarm_user
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO metafarm_user;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: metafarm_user
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: purchases; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.purchases (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    beneficiary character varying NOT NULL,
    collection_address character varying NOT NULL,
    on_chain_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    token_id character varying,
    token character varying,
    price character varying,
    minted_to character varying,
    minted_token_id bigint
);


ALTER TABLE public.purchases OWNER TO metafarm_user;

--
-- Name: purchases_id_seq; Type: SEQUENCE; Schema: public; Owner: metafarm_user
--

CREATE SEQUENCE public.purchases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchases_id_seq OWNER TO metafarm_user;

--
-- Name: purchases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: metafarm_user
--

ALTER SEQUENCE public.purchases_id_seq OWNED BY public.purchases.id;


--
-- Name: referrals; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.referrals (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    code character varying NOT NULL,
    status public.referrals_status_enum DEFAULT 'active'::public.referrals_status_enum NOT NULL
);


ALTER TABLE public.referrals OWNER TO metafarm_user;

--
-- Name: referrals_id_seq; Type: SEQUENCE; Schema: public; Owner: metafarm_user
--

CREATE SEQUENCE public.referrals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.referrals_id_seq OWNER TO metafarm_user;

--
-- Name: referrals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: metafarm_user
--

ALTER SEQUENCE public.referrals_id_seq OWNED BY public.referrals.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: metafarm_user
--

CREATE TABLE public.users (
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    id bigint NOT NULL,
    wallet_address character varying NOT NULL,
    email character varying,
    username character varying,
    status public.users_status_enum DEFAULT 'active'::public.users_status_enum NOT NULL,
    sign_in_message character varying,
    referral_id bigint
);


ALTER TABLE public.users OWNER TO metafarm_user;

--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: nfts id; Type: DEFAULT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.nfts ALTER COLUMN id SET DEFAULT nextval('public.nfts_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: purchases id; Type: DEFAULT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.purchases ALTER COLUMN id SET DEFAULT nextval('public.purchases_id_seq'::regclass);


--
-- Name: referrals id; Type: DEFAULT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.referrals ALTER COLUMN id SET DEFAULT nextval('public.referrals_id_seq'::regclass);


--
-- Data for Name: admin_user_credentials; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.admin_user_credentials (created_at, updated_at, admin_user_id, email, password) FROM stdin;
2025-04-05 15:19:59.696206	2025-04-05 15:19:59.696206	174386639970086	admin@gmail.com	$2b$10$cvjMz8h9aEcnGFs.OITd1eYkQvj5BKcha/19rfLjRLxBW.//l1Wkq
\.


--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.admin_users (created_at, updated_at, id, email, status) FROM stdin;
2025-04-05 15:19:59.696206	2025-04-05 15:19:59.696206	174386639970086	admin@gmail.com	active
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.events (created_at, updated_at, id, event, block_number, block_hash, transaction_hash, address, payload, chain_id) FROM stdin;
2025-03-09 17:12:57	2025-03-09 17:12:57	1	CollectionPermissionGranted	48939161	0xb10488409ec4d53b2923faa1dc1a4f72eccf08b9aec6aec13664b325458e89ef	0xe99bb8f6843f1ef6eb89b30463507d309a4684edc278482af6c38e301c771d6e	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","maxSupply":100,"name":"XCOMPANY","symbol":"XCOM"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"2","collectionAddress":"0x220859e34710C779e0168956A96960F97B209Fd0"}}	97
2025-03-11 15:07:27	2025-03-11 15:07:27	2	CollectionPermissionGranted	48994251	0x4f158c07e8c69a5d55535e60e685517db5244aeddd3deb1ad1eaa4afde44bc76	0xa3ab4fef532ee383c38bf29d285def103924cbdec8d278e27d1e66151af94024	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":1,"name":"XactualNFT","symbol":"XactualNFT"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"3","collectionAddress":"0xc528b4310B21cBD088fD9231cCDE3498EE2a8994"}}	97
2025-03-11 16:27:36	2025-03-11 16:27:36	3	CollectionPermissionGranted	48995854	0x96fc77e9e04a5bbb00ce673e3885ab6928d33c136fb130c527f621ac4fb204dd	0xed0aae9b66e6d1a2ffaac128eab9f961970a4cd12d2052ca30205bed9540c7bc	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":1000,"name":"XACTUAL_NFT","symbol":"XACTUAL"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"4","collectionAddress":"0x6A72bfD534d220737beDD0C6fC165904b18C53bb"}}	97
2025-03-13 08:34:03	2025-03-13 08:34:03	4	CollectionPermissionGranted	49043942	0x0fff34277f066e81b03fa29c0773a194a57543d6ea52a05773f3d133a6db494d	0xa867f6cdf1183fab3f282b625325ceb674e581a03f855c436fe5b8fbe0c54e63	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":100,"name":"TEST_COLLECTION","symbol":"TEST"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"5","collectionAddress":"0x65ede00975698a240178E6A6213ED4e706BBeAFa"}}	97
2025-03-13 08:45:18	2025-03-13 08:45:18	5	CollectionPermissionGranted	49044167	0xb9dde41bf70130ada66932413767200b7a31d2179545c48af5bf790c1822772e	0x58629d81ad482848a80179debe71518c8d37102a2fd927374f222976a119eb6e	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":100,"name":"TEST_2","symbol":"TEST"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"6","collectionAddress":"0x3B7b5110F5DF4E4D589BDE88E5F5B51A9a76B841"}}	97
2025-03-13 08:55:45	2025-03-13 08:55:45	6	CollectionPermissionGranted	49044376	0xd59d910da888f6f8b1efc59b705d1e1a3c970c02a877ac6011e30230a816bd51	0x880ebe5c55f6a875c39f45af5734669e1c850b5d8f4320f443798873eaddae52	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":100,"name":"TEST_3","symbol":"TEST3"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"7","collectionAddress":"0x077f3e8095c70d7e588dfb4C285d2Fe52e72F4B1"}}	97
2025-03-13 10:26:51	2025-03-13 10:26:51	7	CollectionPermissionGranted	49046198	0x0325ddb0ac5afa9a17509c0ec4177b34037aad8d03db501c1d877c04242d4444	0xb43f9b3484c702c10582ebf0e99b11b257b657b1f4e2ea771e80a05b952871d6	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":1000,"name":"TEST_4","symbol":"TEST_4"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"8","collectionAddress":"0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd"}}	97
2025-03-14 07:24:39	2025-03-14 07:24:39	8	CollectionPermissionGranted	49071354	0xf81b8c9c0a23f8ed427b4f678cc3d89071d898753a8cb06a7c65fb8249640f4f	0x30a82b911463360b5204088a590ca07d5af38e84859ee800866d6958f6d8408b	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":11,"name":"143mega","symbol":"trion"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"9","collectionAddress":"0xfBA46FbBc7C6BD152D03EDFa99DD13bcA7a20De8"}}	97
2025-03-14 07:31:57	2025-03-14 07:31:57	9	CollectionPermissionGranted	49071500	0xb132e89fc7161e2aff7a7f29d93da28d036c6c37181569767c28b22a531bbba6	0xeb7cf93b45bf4437ee1d4653d0f10fc185841a7a58ea204fefaf48d552638d90	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":12,"name":"143252","symbol":"bee"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"10","collectionAddress":"0x8BE0A9d819ACE3aa6645EfF77cb072b5d112fc39"}}	97
2025-03-14 09:46:57	2025-03-14 09:46:57	10	CollectionPermissionGranted	49074200	0x19bc9ee8fe334f2c012986240063d0d7c98e1d5616ae3d0df7c07a2b4f6eecbb	0xa56143c90cc25cf41c7d31ac67adad77eff685c52b0c26a3cf7a8ad30822d07d	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":1000,"name":"Metafarm14325","symbol":"Metafarm"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"11","collectionAddress":"0xe7f3e090112838cbcF83d2525CA1B0A99358DB3F"}}	97
2025-03-18 10:31:47	2025-03-18 10:31:47	11	CollectionPermissionGranted	49190166	0xa8361fd59b43ab105286c30b8ee39c562c6e166f764c8b6045ff72888e0d25b6	0x653646f00bc884ed457dca29f3b6eb31e4e6b1e7c66d6c9875224df68b02f321	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":1,"name":"Son Test","symbol":"trion"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"12","collectionAddress":"0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	97
2025-03-20 17:39:26	2025-03-20 17:39:26	12	CollectionPermissionGranted	49256313	0xae1ae1fa02388171431b31faf84b109c9ad3ec805b0496088973db210936022a	0xeae1d00820b06887a6b1edfc13c4d1d0b6a8b72a557e93b0246ca741d7544d4e	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":1000,"name":"TEST 10","symbol":"TEST"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"13","collectionAddress":"0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	97
2025-03-21 07:16:26	2025-03-21 07:16:26	13	CollectionPermissionGranted	49272653	0x93e1c8b99db18c928eaa4dff22a9a34d260f2ad5889d56baec4a74c55942471a	0xa533ffa721a27896b106cc1114e09eeb57f261b67999b0db1583df088d3723d6	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":100,"name":"Solar","symbol":"Soli"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"14","collectionAddress":"0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6"}}	97
2025-03-21 09:40:08	2025-03-21 09:40:08	14	CollectionPermissionGranted	49275527	0xe292a08ac13469da7a78429a2cd37e934f666dbaae545668adfc914160cba549	0xf303d7bb17282587ad594bd4cdd3427cece1807b7d970dd5fee371fa5545f326	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":10,"name":"213 2nd project","symbol":"SYM"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"15","collectionAddress":"0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6"}}	97
2025-03-22 08:49:15	2025-03-22 08:49:15	15	CollectionPermissionGranted	49303307	0x64faf7df6a3fca2a37d30b322675306bf6ffaf2586a9c38538fb5b94903fff65	0x5459f8dbfaeb0f86820da0e7ff030d4a48d1388be3593152767f725ad7750d6e	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0xf2BC030636C02791C40dfe3b3040b37bbc1fEe50","maxSupply":100000,"name":"TEST 10","symbol":"TEST"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"16","collectionAddress":"0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A"}}	97
2025-03-24 05:06:39	2025-03-24 05:06:39	16	CollectionPermissionGranted	49356452	0xf9a261a910f9cd7a1ea6d25057d6e7fcfe303c024afd0830469e6011f7558ac3	0xacad9f97f790ca7470b11a0d63db2f6ad9978a5a521e7da6fe69a9793e7c4a26	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":1,"name":"1","symbol":"trion"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"17","collectionAddress":"0x47a18F5191E1edCF471Fa968Cb979e8facbF627E"}}	97
2025-04-05 07:28:37	2025-04-05 07:28:37	17	CollectionPermissionGranted	49704881	0xb1ce5f3de7507db932d2eb2870fe6658c2d7869103053b4ce43ed448a2569df2	0x37ed26a6ce33945d985aaf5df22dbf73cc34b65eaee59ceb68673ab8b26109cc	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":10000,"name":"TESTMT","symbol":"MT"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"18","collectionAddress":"0x8f3DCEC35d7cC008B3393e0B4C72E1315eAfb10a"}}	97
2025-04-07 06:14:41	2025-04-07 06:14:41	18	CollectionPermissionGranted	69996935	0x9e3d9a0d6043267b99d8f74fc67a6cc0c0d6f6abb96bcf445651882c1e434c90	0x7c9e0cf03e3a0516a8ad2d3670660f41165f49e25fbc0cc3cb1967e76a3467a0	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":10000,"name":"TEST COLLECTION","symbol":"TEST"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"1","collectionAddress":"0x220859e34710C779e0168956A96960F97B209Fd0"}}	137
2025-04-07 07:45:49	2025-04-07 07:45:49	22	CollectionPermissionGranted	69999465	0xbc689d9b58046117b0b25e3fd5b85f27e2d7744e17ef792b6ad3c7962a4fcabf	0xe65fee569ba450dc37b75fc5b263a1fb9e07a0daef5a4eedcb774d5bbe59a6ab	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":100,"name":"CropChain","symbol":"Crop"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"2","collectionAddress":"0xc528b4310B21cBD088fD9231cCDE3498EE2a8994"}}	137
2025-04-07 09:17:24	2025-04-07 09:17:24	23	CollectionPermissionGranted	70002005	0x340a7570eb0f629c115108ec11e0e0adb889caca899fb82ab7be2b113e6e4d69	0x083ac77f8ca665f8d9d087151e014a248cab4ec2c268e6b0beaea0849e2429b4	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":100,"name":"Aqua","symbol":"AQUA"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"3","collectionAddress":"0x6A72bfD534d220737beDD0C6fC165904b18C53bb"}}	137
2025-04-08 06:04:16	2025-04-08 06:04:16	24	CollectionPermissionGranted	70036914	0xe398edda5b7b5ec7eb9a0fda11af85a7b698b2c3784daae77c563ef96ba17816	0xd8aa2bac409337649258ef5067eefeb27285fa7bbe8ca788669461896ebf1eb2	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","maxSupply":1000,"name":"TEST","symbol":"TEST"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"4","collectionAddress":"0x65ede00975698a240178E6A6213ED4e706BBeAFa"}}	137
2025-04-08 06:55:24	2025-04-08 06:55:24	25	CollectionPermissionGranted	70038355	0xd89149e1fd148ec27972c8aca3979b8be5c079b55f926861b095ae2f01b8aa33	0xdfdf79703e1a7cbd93baa7b3473860f6931eee683492d7a6327fea7abc4c6828	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":10000,"name":"TEST COLLECTION","symbol":"TMT"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"5","collectionAddress":"0x3B7b5110F5DF4E4D589BDE88E5F5B51A9a76B841"}}	137
2025-04-08 07:03:57	2025-04-08 07:03:57	26	CollectionPermissionGranted	70038586	0x504735130891327263cdba37afe2ebced6705f8febd9855ab888011bd0e35e1e	0xa50ec1393dda88167da0b5b4d2efac853fa54f0fd987b83c4cf142ec1f48ae06	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":10000,"name":"TESTTT","symbol":"TESTT"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"6","collectionAddress":"0x077f3e8095c70d7e588dfb4C285d2Fe52e72F4B1"}}	137
2025-04-08 08:48:07	2025-04-08 08:48:07	27	CollectionPermissionGranted	70041522	0xa53b8c4d75cf6a48830d054b18a78f5fb818d6e4c79b4aea4c83073775ce3be6	0x4d422f321bb28d362ccf451f18974a2592b4286372760a6810729dff5a75bef7	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":100,"name":"LB","symbol":"LB"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"7","collectionAddress":"0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd"}}	137
2025-04-08 09:16:35	2025-04-08 09:16:35	29	CollectionPermissionGranted	70042326	0x5826b4d84d79a98ea1a57e3905f4d84ea0ef2287bbd1eac0c26ad24e10024690	0xe63508cde30ea9a98d66f005a1a2bdf6b8dae8c34c027db498dbdf263c7fb222	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06","maxSupply":100000,"name":"TEST","symbol":"TTTT"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"8","collectionAddress":"0xfBA46FbBc7C6BD152D03EDFa99DD13bcA7a20De8"}}	137
2025-04-08 09:22:37	2025-04-08 09:22:37	30	CollectionPermissionGranted	70042496	0x6c35a4ce7d22ce08f419ebe4218891c33fbc0285bfb87a6a6377d22e7f5eaaae	0xd5a986ee2f1cb10c67d129a792b775406dc28ce01d078aabb5b06d53b991918d	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":100000,"name":"TESTTT","symbol":"TTTTT"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"9","collectionAddress":"0x8BE0A9d819ACE3aa6645EfF77cb072b5d112fc39"}}	137
2025-04-08 09:33:37	2025-04-08 09:33:37	31	CollectionPermissionGranted	70042807	0xd7ae9c0be90a75d48ea24e974dd77629436f2951d1e2fb0ed3b767ce333d3e38	0xbaf5325813597c6c94085240f5c00f96bee76577b1af363e122284341389dd24	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":100000,"name":"TTTT","symbol":"TTT"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"10","collectionAddress":"0xe7f3e090112838cbcF83d2525CA1B0A99358DB3F"}}	137
2025-04-08 09:41:21	2025-04-08 09:41:21	32	CollectionPermissionGranted	70043025	0x6f28d41bee501449182f46605d26d0d33e78bd1e0d1c01376db8d606692fd2d1	0x3042d30d89e6d5510b5fe3d876448d751e4dfbde125a4438c45167415d8365e9	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":1000,"name":"AquaWell ","symbol":"AQA"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"11","collectionAddress":"0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	137
2025-04-08 10:05:17	2025-04-08 10:05:17	33	CollectionPermissionGranted	70043701	0xd9744f68d7feef1a743e2789bf15e89021f2c1eaad8c8a42c658c8ceb1279427	0xd7b60483f5e6771d2d6c5e99546f4e54395f5bc449666e2f1ad91e51702c1799	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72","maxSupply":10000,"name":"LB","symbol":"LB"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"12","collectionAddress":"0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	137
2025-04-09 04:41:43	2025-04-09 04:41:43	34	CollectionPermissionGranted	70074961	0x23573e11909c884b70074aee6add1db1fa0cfe9793ca5dbecacea814b78ecd4e	0x10ce08ac0fffc64aa6c4f893e431e71fcf4875660addf142512711f7a3f7c6cb	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	{"input":{"owner":"0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f","maxSupply":10,"name":"Shit Coin","symbol":"$HIT"},"response":{"account":"0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D","collectionId":"13","collectionAddress":"0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6"}}	137
2025-04-15 15:18:43	2025-04-15 15:18:43	35	CollectionPermissionGranted	70336068	0x36471bde06fd1f9ed9278b058ac7dff30cc8f70135dbe821966734b61e706e45	0xb43f44722d6bec7579d97b01d737544162c16faee97bdc1d2866864db6c38ffd	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	{"input":{"owner":"0xF00305EdEF744B3967810BDfa8aE9Df3b332000f","maxSupply":100,"name":"Coffee by Hineleban Farms - Genesis Crop","symbol":"CFEHF1"},"response":{"account":"0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07","collectionId":"14","collectionAddress":"0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6"}}	137
2025-04-16 14:30:51	2025-04-16 14:30:51	37	CollectionPermissionGranted	70375250	0x7b811d126491b5320dfb1bcff7987fa891ae859ec764ec64849a14f12b396907	0xe170442b987c35954ca9c1d8f35f044d597222538d5e46a3f8532de7c89c889c	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	{"input":{"owner":"0xADD6E354d5799948D95859ae1A2b3FB825F78D75","maxSupply":200,"name":"Adlai by Hineleban Farms - Genesis Crop","symbol":"ADLHF1"},"response":{"account":"0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07","collectionId":"15","collectionAddress":"0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A"}}	137
2025-04-16 14:59:45	2025-04-16 14:59:45	38	CollectionPermissionGranted	70376066	0x92df2ecb1bbc753f215297c8a8bec4835445a02ac1c1bffe779e66aa5f690889	0x452489f5d9055b80276a1a9b4efc7beffe7d45756527c13eef7297eac0a70194	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	{"input":{"owner":"0xB9484dB7cBe6BD38cd33C620764cA6Fe2F498Abc","maxSupply":160,"name":"Banana by Hineleban Farms - Genesis Crop","symbol":"BNAHF1"},"response":{"account":"0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07","collectionId":"16","collectionAddress":"0x47a18F5191E1edCF471Fa968Cb979e8facbF627E"}}	137
2025-04-21 15:06:36	2025-04-21 15:06:36	42	CollectionPermissionGranted	70578559	0x9d3e7aaa15c82542bea26fad4764f28d0da218fc76e31c3ed4ef4b91cd4e1f3b	0x61d32e3553d48dccd3a6a38313342e368c5aaae85c0e8d20c0731ec61e9cebd9	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	{"input":{"owner":"0xc57237a6a2f0542B4958905236979765D8839CAF","maxSupply":200,"name":"Casa de Cacao by Ralfe Gourmet - Genesis Crop","symbol":"CDCRG1"},"response":{"account":"0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07","collectionId":"17","collectionAddress":"0x8f3DCEC35d7cC008B3393e0B4C72E1315eAfb10a"}}	137
2025-04-21 15:14:11	2025-04-21 15:14:11	43	CollectionPermissionGranted	70578770	0x3f67fddb5237d2e65db98f6f4ae90275438dad010e04ff99ca9af8e9e1d5486c	0xea00e21c2e06e3e7279d8212d79a1f4c45d548541a4daff315e1c1b2edb6e848	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	{"input":{"owner":"0xc57237a6a2f0542B4958905236979765D8839CAF","maxSupply":200,"name":"Casa de Cacao by Ralfe Gourmet - Genesis Crop","symbol":"CDCRG1"},"response":{"account":"0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07","collectionId":"18","collectionAddress":"0xf9351d944e2D7E32532100C03Bd28b9d91271826"}}	137
2025-04-21 15:37:25	2025-04-21 15:37:25	44	CollectionPermissionGranted	70579411	0x386d1b7c95d7add0abe0d5a0dfbe9f995d1442ce8e1a20ba1cb3f9b43f75bb9c	0xbad4180ca497b72c6d7bbcffadac8abc14396eeac19b8f3ed463fcbec4db949d	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	{"input":{"owner":"0x9ca8f5C30058a22cCce65834466F456f00Fbcc11","maxSupply":300,"name":"Smart Vending Machines by MetaFarms","symbol":"SVMMF1"},"response":{"account":"0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07","collectionId":"19","collectionAddress":"0xAD2199b809Ca8099af1d76Cff387ff5441850aAC"}}	137
2025-04-22 01:55:19	2025-04-22 01:55:19	45	CollectionPermissionGranted	70596836	0xf86ff5d0e0337befdbd3acc81cf1f10e880afdd21e919cb16c5ba0b3cec3df14	0xae71a8deddfe19c584cab9435c9cc9f0539aa3b159ee22617c1334d65a90a61d	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	{"input":{"owner":"0x9ca8f5C30058a22cCce65834466F456f00Fbcc11","maxSupply":300,"name":"Smart Vending Machines by Food Starter","symbol":"SVMFS1"},"response":{"account":"0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07","collectionId":"20","collectionAddress":"0x931Db63A70D051460aB9f1AA3c772063C5B3bB36"}}	137
2025-04-29 08:29:34	2025-04-29 08:29:34	60	CollectionPermissionGranted	70891694	0xd317809353f0dfd79a9bd35297d593d99e0d1fe11cb11cf4b943f10d6fd1363d	0xaabd2d33a68ee2147b203f39fe1c7c626926ab4be7facc55a3ca2f1edff72cfb	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	{"input":{"owner":"0xF1847C672ad3217bB7c923A176636F841DbCF304","maxSupply":250,"name":"Riau Coastal Peatland & Mangrove Conservation - Genesis","symbol":"MGVTG1"},"response":{"account":"0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07","collectionId":"21","collectionAddress":"0x43C1ea7c987e0De7Ad5CB62d44F4372983Cba00c"}}	137
\.


--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.files (created_at, updated_at, id, file_name, file_url, key, file_type, file_size) FROM stdin;
2025-04-07 04:34:44.685691	2025-04-07 04:34:44.685691	174400048492233	Testproject7425-1744000497840.metadata.json	https://storage.eachop.tech/metafarmdev/1744000484684_Testproject7425-1744000497840.metadata.json	1744000484684_Testproject7425-1744000497840.metadata.json	application/json	195
2025-04-07 06:14:29.549228	2025-04-07 06:14:29.549228	174400646974348	TEST COLLECTION-1744006468604.metadata.json	https://storage.eachop.tech/metafarmdev/1744006469548_TEST_COLLECTION-1744006468604.metadata.json	1744006469548_TEST_COLLECTION-1744006468604.metadata.json	application/json	192
2025-04-07 06:44:25.546645	2025-04-07 06:44:25.546645	174400826574995	TEST COLLECTION-1744008278591.metadata.json	https://storage.eachop.tech/metafarmdev/1744008265543_TEST_COLLECTION-1744008278591.metadata.json	1744008265543_TEST_COLLECTION-1744008278591.metadata.json	application/json	192
2025-04-07 07:02:08.19208	2025-04-07 07:02:08.19208	174400932839616	Med-1744009341788.metadata.json	https://storage.eachop.tech/metafarmdev/1744009328187_Med-1744009341788.metadata.json	1744009328187_Med-1744009341788.metadata.json	application/json	158
2025-04-07 07:02:56.093014	2025-04-07 07:02:56.093014	174400937628949	Med-1744009389983.metadata.json	https://storage.eachop.tech/metafarmdev/1744009376092_Med-1744009389983.metadata.json	1744009376092_Med-1744009389983.metadata.json	application/json	158
2025-04-07 07:03:38.205258	2025-04-07 07:03:38.205258	174400941840840	Med-1744009432151.metadata.json	https://storage.eachop.tech/metafarmdev/1744009418204_Med-1744009432151.metadata.json	1744009418204_Med-1744009432151.metadata.json	application/json	158
2025-04-07 07:45:36.948788	2025-04-07 07:45:36.948788	174401193715581	CropChain-1744011949518.metadata.json	https://storage.eachop.tech/metafarmdev/1744011936947_CropChain-1744011949518.metadata.json	1744011936947_CropChain-1744011949518.metadata.json	application/json	167
2025-04-07 09:17:08.586324	2025-04-07 09:17:08.586324	174401742878527	Aqua-1744017442091.metadata.json	https://storage.eachop.tech/metafarmdev/1744017428583_Aqua-1744017442091.metadata.json	1744017428583_Aqua-1744017442091.metadata.json	application/json	162
2025-04-08 06:55:09.04302	2025-04-08 06:55:09.04302	174409530924771	TEST COLLECTION-1744095308308.metadata.json	https://storage.eachop.tech/metafarmdev/1744095309042_TEST_COLLECTION-1744095308308.metadata.json	1744095309042_TEST_COLLECTION-1744095308308.metadata.json	application/json	174
2025-04-08 06:55:15.799377	2025-04-08 06:55:15.799377	174409531599535	TEST COLLECTION-1744095315457.metadata.json	https://storage.eachop.tech/metafarmdev/1744095315798_TEST_COLLECTION-1744095315457.metadata.json	1744095315798_TEST_COLLECTION-1744095315457.metadata.json	application/json	174
2025-04-08 07:03:48.52969	2025-04-08 07:03:48.52969	174409582873161	TESTTT-1744095827819.metadata.json	https://storage.eachop.tech/metafarmdev/1744095828529_TESTTT-1744095827819.metadata.json	1744095828529_TESTTT-1744095827819.metadata.json	application/json	173
2025-04-08 08:47:54.805999	2025-04-08 08:47:54.805999	174410207500426	LB-1744102089272.metadata.json	https://storage.eachop.tech/metafarmdev/1744102074805_LB-1744102089272.metadata.json	1744102074805_LB-1744102089272.metadata.json	application/json	154
2025-04-08 09:16:26.544931	2025-04-08 09:16:26.544931	174410378675013	TEST-1744103785477.metadata.json	https://storage.eachop.tech/metafarmdev/1744103786543_TEST-1744103785477.metadata.json	1744103786543_TEST-1744103785477.metadata.json	application/json	172
2025-04-08 09:22:26.198241	2025-04-08 09:22:26.198241	174410414642701	TESTTT-1744104145049.metadata.json	https://storage.eachop.tech/metafarmdev/1744104146197_TESTTT-1744104145049.metadata.json	1744104146197_TESTTT-1744104145049.metadata.json	application/json	168
2025-04-08 09:33:26.678433	2025-04-08 09:33:26.678433	174410480687533	TTTT-1744104805752.metadata.json	https://storage.eachop.tech/metafarmdev/1744104806678_TTTT-1744104805752.metadata.json	1744104806678_TTTT-1744104805752.metadata.json	application/json	169
2025-04-08 09:41:12.611037	2025-04-08 09:41:12.611037	174410527280840	AquaWell -1744105287370.metadata.json	https://storage.eachop.tech/metafarmdev/1744105272607_AquaWell_-1744105287370.metadata.json	1744105272607_AquaWell_-1744105287370.metadata.json	application/json	177
2025-04-08 10:04:48.347489	2025-04-08 10:04:48.347489	174410668854435	LB-1744106703294.metadata.json	https://storage.eachop.tech/metafarmdev/1744106688347_LB-1744106703294.metadata.json	1744106688347_LB-1744106703294.metadata.json	application/json	156
2025-04-09 04:41:12.74147	2025-04-09 04:41:12.74147	174417367294890	Shit Coin-1744173672299.metadata.json	https://storage.eachop.tech/metafarmdev/1744173672740_Shit_Coin-1744173672299.metadata.json	1744173672740_Shit_Coin-1744173672299.metadata.json	application/json	191
2025-04-15 15:17:04.907944	2025-04-15 15:17:04.907944	174473022512072	Coffee by Hineleban Farms - Genesis Crop-1744730224291.metadata.json	https://storage.eachop.tech/metafarmdev/1744730224907_Coffee_by_Hineleban_Farms_-_Genesis_Crop-1744730224291.metadata.json	1744730224907_Coffee_by_Hineleban_Farms_-_Genesis_Crop-1744730224291.metadata.json	application/json	495
2025-04-16 07:25:17.138569	2025-04-16 07:25:17.138569	174478831734741	TEST-1744788316481.metadata.json	https://storage.eachop.tech/metafarmdev/1744788317137_TEST-1744788316481.metadata.json	1744788317137_TEST-1744788316481.metadata.json	application/json	173
2025-04-16 14:30:34.145164	2025-04-16 14:30:34.145164	174481383434119	Adlai by Hineleban Farms - Genesis Crop-1744813833495.metadata.json	https://storage.eachop.tech/metafarmdev/1744813834142_Adlai_by_Hineleban_Farms_-_Genesis_Crop-1744813833495.metadata.json	1744813834142_Adlai_by_Hineleban_Farms_-_Genesis_Crop-1744813833495.metadata.json	application/json	503
2025-04-16 14:59:37.065905	2025-04-16 14:59:37.065905	174481557726003	Banana by Hineleban Farms - Genesis Crop-1744815576155.metadata.json	https://storage.eachop.tech/metafarmdev/1744815577065_Banana_by_Hineleban_Farms_-_Genesis_Crop-1744815576155.metadata.json	1744815577065_Banana_by_Hineleban_Farms_-_Genesis_Crop-1744815576155.metadata.json	application/json	488
2025-04-21 15:06:25.04773	2025-04-21 15:06:25.04773	174524798526562	Casa de Cacao by Ralfe Gourmet - Genesis Crop-1745247984761.metadata.json	https://storage.eachop.tech/metafarmdev/1745247985045_Casa_de_Cacao_by_Ralfe_Gourmet_-_Genesis_Crop-1745247984761.metadata.json	1745247985045_Casa_de_Cacao_by_Ralfe_Gourmet_-_Genesis_Crop-1745247984761.metadata.json	application/json	671
2025-04-21 15:07:14.805805	2025-04-21 15:07:14.805805	174524803500595	Casa de Cacao by Ralfe Gourmet - Genesis Crop-1745248034525.metadata.json	https://storage.eachop.tech/metafarmdev/1745248034805_Casa_de_Cacao_by_Ralfe_Gourmet_-_Genesis_Crop-1745248034525.metadata.json	1745248034805_Casa_de_Cacao_by_Ralfe_Gourmet_-_Genesis_Crop-1745248034525.metadata.json	application/json	673
2025-04-21 15:13:58.675933	2025-04-21 15:13:58.675933	174524843887573	Casa de Cacao by Ralfe Gourmet - Genesis Crop-1745248438292.metadata.json	https://storage.eachop.tech/metafarmdev/1745248438675_Casa_de_Cacao_by_Ralfe_Gourmet_-_Genesis_Crop-1745248438292.metadata.json	1745248438675_Casa_de_Cacao_by_Ralfe_Gourmet_-_Genesis_Crop-1745248438292.metadata.json	application/json	511
2025-04-21 15:37:14.104524	2025-04-21 15:37:14.104524	174524983430674	Smart Vending Machines by MetaFarms-1745249833530.metadata.json	https://storage.eachop.tech/metafarmdev/1745249834104_Smart_Vending_Machines_by_MetaFarms-1745249833530.metadata.json	1745249834104_Smart_Vending_Machines_by_MetaFarms-1745249833530.metadata.json	application/json	573
2025-04-22 01:55:06.074807	2025-04-22 01:55:06.074807	174528690630636	Smart Vending Machines by Food Starter-1745286905349.metadata.json	https://storage.eachop.tech/metafarmdev/1745286906072_Smart_Vending_Machines_by_Food_Starter-1745286905349.metadata.json	1745286906072_Smart_Vending_Machines_by_Food_Starter-1745286905349.metadata.json	application/json	600
2025-04-22 03:36:28.357992	2025-04-22 03:36:28.357992	174529298855522	Smart Vending Machines by Food Starter-1745292987769.metadata.json	https://storage.eachop.tech/metafarmdev/1745292988357_Smart_Vending_Machines_by_Food_Starter-1745292987769.metadata.json	1745292988357_Smart_Vending_Machines_by_Food_Starter-1745292987769.metadata.json	application/json	600
2025-04-23 02:38:58.326696	2025-04-23 02:38:58.326696	174537593852939	Banana by Hineleban Farms - Genesis Crop-1745375938061.metadata.json	https://storage.eachop.tech/metafarmdev/1745375938326_Banana_by_Hineleban_Farms_-_Genesis_Crop-1745375938061.metadata.json	1745375938326_Banana_by_Hineleban_Farms_-_Genesis_Crop-1745375938061.metadata.json	application/json	488
2025-04-23 02:39:37.433519	2025-04-23 02:39:37.433519	174537597763600	Banana by Hineleban Farms - Genesis Crop-1745375977176.metadata.json	https://storage.eachop.tech/metafarmdev/1745375977432_Banana_by_Hineleban_Farms_-_Genesis_Crop-1745375977176.metadata.json	1745375977432_Banana_by_Hineleban_Farms_-_Genesis_Crop-1745375977176.metadata.json	application/json	488
2025-04-29 08:29:21.535778	2025-04-29 08:29:21.535778	174591536174215	Riau Coastal Peatland & Mangrove Conservation - Genesis-1745915360654.metadata.json	https://storage.eachop.tech/metafarmdev/1745915361476_Riau_Coastal_Peatland_&_Mangrove_Conservation_-_Genesis-1745915360654.metadata.json	1745915361476_Riau_Coastal_Peatland_&_Mangrove_Conservation_-_Genesis-1745915360654.metadata.json	application/json	500
2025-04-29 09:03:58.337914	2025-04-29 09:03:58.337914	174591743853600	Riau Coastal Peatland & Mangrove Conservation - Genesis-1745917437425.metadata.json	https://storage.eachop.tech/metafarmdev/1745917438337_Riau_Coastal_Peatland_&_Mangrove_Conservation_-_Genesis-1745917437425.metadata.json	1745917438337_Riau_Coastal_Peatland_&_Mangrove_Conservation_-_Genesis-1745917437425.metadata.json	application/json	500
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1740844135063	UserLogin1740844135063
2	1740853555529	AdminUsers1740853555529
3	1740941948722	FileStorage1740941948722
4	1740977889357	CreateProjects1740977889357
5	1741574560263	CliffTimeAndProfit1741574560263
6	1741769409597	ProjectLogo1741769409597
7	1741769583234	ProjectLogoNotNull1741769583234
8	1741774211634	ContractAddressNullable1741774211634
9	1741794431379	Crawler1741794431379
10	1741796155899	AddSymbolToProject1741796155899
11	1741796422606	AddOnChainDataToProject1741796422606
12	1741841989759	ManyNftsToOne1741841989759
13	1741848963966	MoveSymbolToNfts1741848963966
14	1741849247246	MoveAddressToNfts1741849247246
15	1741851994308	NftOneToOne1741851994308
16	1741857587611	RevertSplitNftTables1741857587611
17	1741857911747	NftTables1741857911747
18	1741863427817	AddUriSupplyToProject1741863427817
19	1741891475072	NftFiatPriceAndBeneficiary1741891475072
20	1742470972511	IsShowRevenueStreams1742470972511
21	1743489210207	Purchases1743489210207
22	1743656784494	PurchasedTokenAddress1743656784494
23	1743700619699	CrawlMintedEvent1743700619699
24	1743761864966	Referrals1743761864966
\.


--
-- Data for Name: nfts; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.nfts (created_at, updated_at, id, image, amount, price, detail, metadata, network, project_id, name, symbol, contract_address, collection_id, granted_addresses, on_chain_data, fiat_price, beneficiary) FROM stdin;
2025-04-07 06:25:07.824769	2025-04-07 06:25:07.824769	1	\N	1	0.001	\N	\N	\N	1	\N	\N	\N	1	[]	{}	0.002	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06
2025-04-07 07:48:02.984668	2025-04-07 07:48:02.984668	2	\N	10	0.001	\N	\N	\N	3	\N	\N	\N	2	[]	{}	0.001	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72
2025-04-07 09:19:46.868256	2025-04-07 09:19:46.868256	3	\N	10	0.001	\N	\N	\N	4	\N	\N	\N	3	[]	{}	0.001	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72
2025-04-08 07:00:16.552691	2025-04-08 07:00:16.552691	4	\N	1	0.001	\N	\N	\N	6	\N	\N	\N	5	[]	{}	0.002	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06
2025-04-08 07:14:27.987937	2025-04-08 07:14:27.987937	5	\N	1	0.001	\N	\N	\N	7	\N	\N	\N	6	[]	{}	0.002	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06
2025-04-08 08:49:51.196228	2025-04-08 08:49:51.196228	6	\N	10	0.0001	\N	\N	\N	8	\N	\N	\N	7	[]	{}	0.0001	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72
2025-04-08 09:24:03.306791	2025-04-08 09:24:03.306791	7	\N	1000	0.001	\N	\N	\N	10	\N	\N	\N	9	[]	{}	0.002	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72
2025-04-08 09:35:21.633819	2025-04-08 09:35:21.633819	8	\N	1000	0.001	\N	\N	\N	11	\N	\N	\N	10	[]	{}	0.002	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72
2025-04-08 09:43:01.736703	2025-04-08 09:43:01.736703	9	\N	1000	0.0001	\N	\N	\N	12	\N	\N	\N	11	[]	{}	0.0001	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72
2025-04-08 10:07:36.222243	2025-04-08 10:07:36.222243	10	\N	10000	1e-05	\N	\N	\N	13	\N	\N	\N	12	[]	{}	0.00001	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72
2025-04-09 04:44:15.169735	2025-04-09 04:44:15.169735	11	\N	10	0.0001	\N	\N	\N	14	\N	\N	\N	13	[]	{}	0.0001	0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f
2025-04-15 15:27:52.041371	2025-04-15 15:27:52.041371	12	\N	100	5170	\N	\N	\N	15	\N	\N	\N	14	[]	{}	940	0xF00305EdEF744B3967810BDfa8aE9Df3b332000f
2025-04-16 14:36:13.96575	2025-04-16 14:36:13.96575	13	\N	200	4195	\N	\N	\N	17	\N	\N	\N	15	[]	{}	720	0xADD6E354d5799948D95859ae1A2b3FB825F78D75
2025-04-16 15:03:44.216984	2025-04-16 15:03:44.216984	14	\N	160	3787	\N	\N	\N	18	\N	\N	\N	16	[]	{}	650	0xB9484dB7cBe6BD38cd33C620764cA6Fe2F498Abc
2025-04-21 15:17:52.443861	2025-04-21 15:17:52.443861	15	\N	200	4730	\N	\N	\N	20	\N	\N	\N	18	[]	{}	860	0xc57237a6a2f0542B4958905236979765D8839CAF
2025-04-21 15:39:15.197741	2025-04-21 15:39:15.197741	16	\N	300	4400	\N	\N	\N	21	\N	\N	\N	19	[]	{}	800	0x9ca8f5C30058a22cCce65834466F456f00Fbcc11
2025-04-22 01:57:17.368271	2025-04-22 01:57:17.368271	17	\N	300	4400	\N	\N	\N	22	\N	\N	\N	20	[]	{}	800	0x9ca8f5C30058a22cCce65834466F456f00Fbcc11
2025-04-29 08:46:40.033038	2025-04-29 08:46:40.033038	18	\N	250	4400	\N	\N	\N	23	\N	\N	\N	21	[]	{}	800	0xF1847C672ad3217bB7c923A176636F841DbCF304
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.projects (created_at, updated_at, status, name, overview, about_us, description, categories, revenue_streams, attachments, cliff_time, annual_profit, logo, banner, id, nft_name, nft_symbol, contract_address, collection_id, granted_addresses, on_chain_data, "maxSupply", uri, nft_image, nft_detail, nft_metadata, nft_network, is_show_revenue_streams) FROM stdin;
2025-04-07 06:14:30.157274	2025-04-08 06:58:07.343302	deleted	TEST PROJECT	The MedLink Pilot Project will deploy digital record stations and training programs in over 30 rural health clinics, enabling local healthcare providers to securely store and access patient data using blockchain-backed systems. Each NFT purchased through 	At MedLink, we believe that access to reliable, secure, and easily accessible healthcare data should be a fundamental right, not a luxury. Founded by a multidisciplinary team of healthcare professionals, blockchain developers, and humanitarian strategists	The MedLink Pilot Project aims to deploy over 30 decentralized digital health record stations across rural and underserved areas in Southeast Asia and sub-Saharan Africa. These are low-cost, rugged devices pre-installed with our custom blockchain-based software, capable of recording, storing, and retrieving medical histories even in areas with limited internet access.\n\nCurrently, millions of people in these regions rely on memory or handwritten notes to communicate their medical background—if they have any documentation at all. This lack of proper records results in dangerous inefficiencies, from prescribing the wrong medications to duplicating lab tests and missing chronic illness diagnoses entirely. MedLink solves this by putting secure, encrypted data into the hands of providers and patients alike.\n\nEach digital health station funded through NFT-backed investment supports:\n\nHardware deployment and internet setup at a remote clinic\n\nStaff onboarding and medical record training\n\nSecur	["entertainment", "farming", "art"]	[{"stream": "Revenue Source", "description": "Revenue Description"}]	[{"title": "banner.jpg", "fileUrl": "QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ"}, {"title": "logo-social.png", "fileUrl": "QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia"}]	36	15	QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia	QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ	1	TEST COLLECTION	TEST	0x220859e34710C779e0168956A96960F97B209Fd0	1	[]	{"input": {"name": "TEST COLLECTION", "owner": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "symbol": "TEST", "maxSupply": 10000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "1", "collectionAddress": "0x220859e34710C779e0168956A96960F97B209Fd0"}}	10000	https://storage.eachop.tech/metafarmdev/1744008265543_TEST_COLLECTION-1744008278591.metadata.json	Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn	NFT detail	{data:"test"}	BSC Testnet	t
2025-04-07 09:17:09.138724	2025-04-08 07:04:21.43667	deleted	 AquaWell	The AquaWell Impact Network plans to install 50+ solar-powered water purification wells across rural communities in East Africa and Southeast Asia. Each NFT on Metafarm helps fund the construction, installation, and maintenance of one clean water unit. In	At AquaWell, we believe access to clean drinking water is not a privilege—it’s a basic human right. Our team includes water engineers, public health experts, and blockchain developers united by a common goal: to use technology to solve one of the world’s 	Water scarcity affects over 2 billion people worldwide—but the technology to fix it already exists. The problem is not innovation, it’s implementation. AquaWell provides a turnkey solution that bridges the gap between rural need and investor interest through smart crowdfunding and decentralized ownership.\n\nHere’s how it works:\n\n✅ The Hardware\nEach unit includes a solar-powered water pump, a multi-stage filtration system, and a smart meter that tracks water dispensed per household. It’s durable, low-maintenance, and built for the harshest rural environments.\n\n✅ The Software\nEvery unit is registered on-chain with a unique identifier. Smart meters record daily usage data, which is encrypted and sent to AquaWell’s blockchain for real-time reporting and performance tracking. This ensures complete transparency for all NFT investors.\n\n✅ Revenue Streams\n\nHouseholds pay a micro-fee per liter via local mobile payment systems\n\n	["technology", "Ocean"]	[{"stream": "Sea Species", "description": "Sales of Sea Animal"}, {"stream": "Port Rental", "description": "Allow External Parties to port their vehicles"}]	[{"title": "Logo", "fileUrl": "Qmau3jDYzKzaE64MrKSHyq2uPxivTXYj69rjXqj629RYRQ"}]	12	10	Qmau3jDYzKzaE64MrKSHyq2uPxivTXYj69rjXqj629RYRQ	Qmau3jDYzKzaE64MrKSHyq2uPxivTXYj69rjXqj629RYRQ	4	Aqua	AQUA	0x6A72bfD534d220737beDD0C6fC165904b18C53bb	3	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f"]	{"input": {"name": "Aqua", "owner": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "symbol": "AQUA", "maxSupply": 100}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "3", "collectionAddress": "0x6A72bfD534d220737beDD0C6fC165904b18C53bb"}}	100	https://storage.eachop.tech/metafarmdev/1744017428583_Aqua-1744017442091.metadata.json	Qmau3jDYzKzaE64MrKSHyq2uPxivTXYj69rjXqj629RYRQ	AQUA	AQUA	BSC Testnet	t
2025-04-07 07:02:08.784451	2025-04-08 07:04:26.536439	deleted	MedLink	The MedLink Pilot Project will deploy digital record stations and training programs in over 30 rural health clinics, enabling local healthcare providers to securely store and access patient data using blockchain-backed systems. Each NFT purchased through 	At MedLink, we believe that access to reliable, secure, and easily accessible healthcare data should be a fundamental right, not a luxury. Founded by a multidisciplinary team of healthcare professionals, blockchain developers, and humanitarian strategists	he MedLink Pilot Project aims to deploy over 30 decentralized digital health record stations across rural and underserved areas in Southeast Asia and sub-Saharan Africa. These are low-cost, rugged devices pre-installed with our custom blockchain-based software, capable of recording, storing, and retrieving medical histories even in areas with limited internet access.\n\nCurrently, millions of people in these regions rely on memory or handwritten notes to communicate their medical background—if they have any documentation at all. This lack of proper records results in dangerous inefficiencies, from prescribing the wrong medications to duplicating lab tests and missing chronic illness diagnoses entirely. MedLink solves this by putting secure, encrypted data into the hands of providers and patients alike.\n\nEach digital health station funded through NFT-backed investment supports:\n\nHardware deployment and internet setup at a remote clinic\n\nStaff onboarding and medical record training\n	["education", "technology"]	[{"stream": "Selling Med", "description": "Med"}]	[{"title": "Logo", "fileUrl": "QmPk75C4e3L6WNFDzKX85gny4JMPKcrGu91B8QSYhpNZUN"}]	10	10	QmNcFo78DAoWvR7jkBoEDtdixWeAn1cd2xZLjTfmhLvm6d	QmPk75C4e3L6WNFDzKX85gny4JMPKcrGu91B8QSYhpNZUN	2	Med	MED	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	\N	[]	{}	100	https://storage.eachop.tech/metafarmdev/1744009328187_Med-1744009341788.metadata.json	QmNcFo78DAoWvR7jkBoEDtdixWeAn1cd2xZLjTfmhLvm6d	MED	MED	BSC Testnet	t
2025-04-07 07:45:37.552074	2025-04-08 07:04:23.873877	deleted	CropChain	The CropChain Smart Farming Program aims to deploy blockchain-integrated crop tracking kits to over 100 small farms across Latin America and Southeast Asia. These kits use IoT sensors to monitor soil, weather, and crop health while recording data and harv	CropChain is an agritech startup focused on transforming the agricultural supply chain in emerging markets using IoT and blockchain. Our team brings together agronomists, software engineers, and logistics experts who understand both the challenges of trad	\nThe global food system is inefficient and wasteful—especially at the farm level. CropChain addresses this with a simple, modular system built for real-world use:\n\n✅ IoT-Enabled Monitoring: Each supported farm receives a sensor kit that tracks humidity, temperature, crop condition, and soil quality. This data is collected and sent to the CropChain network.\n✅ Blockchain Traceability: Every input (like fertilizers or seeds) and every output (like harvest volume) is recorded on a blockchain ledger. This ensures transparency from farm to market.\n✅ Marketplace Integration: Fa	["technology", "farming"]	[]	[{"title": "Logo", "fileUrl": "QmPSPiWG7n6tAWif6Yjgb824ZQkRXMwmbGanaNTkiGiPSC"}]	10	10	QmPSPiWG7n6tAWif6Yjgb824ZQkRXMwmbGanaNTkiGiPSC	QmPSPiWG7n6tAWif6Yjgb824ZQkRXMwmbGanaNTkiGiPSC	3	CropChain	Crop	0xc528b4310B21cBD088fD9231cCDE3498EE2a8994	2	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f"]	{"input": {"name": "CropChain", "owner": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "symbol": "Crop", "maxSupply": 100}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "2", "collectionAddress": "0xc528b4310B21cBD088fD9231cCDE3498EE2a8994"}}	100	https://storage.eachop.tech/metafarmdev/1744011936947_CropChain-1744011949518.metadata.json	QmPSPiWG7n6tAWif6Yjgb824ZQkRXMwmbGanaNTkiGiPSC	CRop	Crop	BSC Testnet	f
2025-04-08 06:55:16.460755	2025-04-08 07:04:18.235372	deleted	TEST	overview	About	Description	["gaming", "farming"]	[{"stream": "test", "description": "test"}]	[{"title": "nft_image.jpg", "fileUrl": "Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn"}]	36	14.995	QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia	QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ	6	TEST COLLECTION	TMT	0x3B7b5110F5DF4E4D589BDE88E5F5B51A9a76B841	5	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f"]	{"input": {"name": "TEST COLLECTION", "owner": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "symbol": "TMT", "maxSupply": 10000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "5", "collectionAddress": "0x3B7b5110F5DF4E4D589BDE88E5F5B51A9a76B841"}}	10000	https://storage.eachop.tech/metafarmdev/1744095315798_TEST_COLLECTION-1744095315457.metadata.json	Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn	TEST	test	BSC Testnet	t
2025-04-08 06:55:09.613904	2025-04-08 06:55:59.4231	deleted	TEST	overview	About	Description	["gaming", "farming"]	[{"stream": "test", "description": "test"}]	[{"title": "nft_image.jpg", "fileUrl": "Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn"}]	36	14.995	QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia	QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ	5	TEST COLLECTION	TMT	0x3B7b5110F5DF4E4D589BDE88E5F5B51A9a76B841	5	[]	{"input": {"name": "TEST COLLECTION", "owner": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "symbol": "TMT", "maxSupply": 10000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "5", "collectionAddress": "0x3B7b5110F5DF4E4D589BDE88E5F5B51A9a76B841"}}	10000	https://storage.eachop.tech/metafarmdev/1744095309042_TEST_COLLECTION-1744095308308.metadata.json	Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn	TEST	test	BSC Testnet	t
2025-04-08 07:03:49.117956	2025-04-14 04:47:27.088291	deleted	TESTT	overview	about ú	des	["entertainment", "gaming", "farming"]	[]	[{"title": "nft_image.jpg", "fileUrl": "Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn"}]	36	15	QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia	QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ	7	TESTTT	TESTT	0x077f3e8095c70d7e588dfb4C285d2Fe52e72F4B1	6	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f"]	{"input": {"name": "TESTTT", "owner": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "symbol": "TESTT", "maxSupply": 10000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "6", "collectionAddress": "0x077f3e8095c70d7e588dfb4C285d2Fe52e72F4B1"}}	10000	https://storage.eachop.tech/metafarmdev/1744095828529_TESTTT-1744095827819.metadata.json	Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn	nft detail	data	BSC Testnet	f
2025-04-08 09:33:27.302311	2025-04-14 04:47:21.019644	deleted	TESTTT	overview	about us	description	["entertainment"]	[]	[{"title": "nft_image.jpg", "fileUrl": "Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn"}]	36	15	QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia	QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ	11	TTTT	TTT	0xe7f3e090112838cbcF83d2525CA1B0A99358DB3F	10	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f", "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "TTTT", "owner": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "symbol": "TTT", "maxSupply": 100000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "10", "collectionAddress": "0xe7f3e090112838cbcF83d2525CA1B0A99358DB3F"}}	100000	https://storage.eachop.tech/metafarmdev/1744104806678_TTTT-1744104805752.metadata.json	Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn	nft detail	tTT	BSC Testnet	f
2025-04-08 09:41:13.12554	2025-04-14 04:47:18.887326	deleted	AQUA	AquaWell 	AquaWell 	AquaWell 	["technology", "gaming"]	[{"stream": "AquaWell ", "description": "AquaWell "}]	[{"title": "AquaWell ", "fileUrl": "Qmau3jDYzKzaE64MrKSHyq2uPxivTXYj69rjXqj629RYRQ"}]	11	11	Qmau3jDYzKzaE64MrKSHyq2uPxivTXYj69rjXqj629RYRQ	Qmau3jDYzKzaE64MrKSHyq2uPxivTXYj69rjXqj629RYRQ	12	AquaWell 	AQA	0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C	11	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f", "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "AquaWell ", "owner": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "symbol": "AQA", "maxSupply": 1000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "11", "collectionAddress": "0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	1000	https://storage.eachop.tech/metafarmdev/1744105272607_AquaWell_-1744105287370.metadata.json	Qmau3jDYzKzaE64MrKSHyq2uPxivTXYj69rjXqj629RYRQ	AquaWell 	AquaWell 	BSC Testnet	t
2025-04-08 09:16:27.116336	2025-04-08 09:33:38.761549	deleted	TEST PROJECT	overview	about us	description	["technology", "entertainment", "gaming", "farming"]	[{"stream": "TEST", "description": "TEST DESCRIPTION"}]	[{"title": "nft_image.jpg", "fileUrl": "Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn"}]	36	15	QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia	QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ	9	TEST	TTTT	0xfBA46FbBc7C6BD152D03EDFa99DD13bcA7a20De8	8	["0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "TEST", "owner": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "symbol": "TTTT", "maxSupply": 100000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "8", "collectionAddress": "0xfBA46FbBc7C6BD152D03EDFa99DD13bcA7a20De8"}}	100000	https://storage.eachop.tech/metafarmdev/1744103786543_TEST-1744103785477.metadata.json	Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn	test detail	data	BSC Testnet	t
2025-04-08 09:22:26.921617	2025-04-08 09:33:42.587882	deleted	PROJECT DEMO	over	abou	des	["entertainment", "farming"]	[]	[{"title": "nft_image.jpg", "fileUrl": "Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn"}]	36	15	QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia	QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ	10	TESTTT	TTTTT	0x8BE0A9d819ACE3aa6645EfF77cb072b5d112fc39	9	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f", "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "TESTTT", "owner": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "symbol": "TTTTT", "maxSupply": 100000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "9", "collectionAddress": "0x8BE0A9d819ACE3aa6645EfF77cb072b5d112fc39"}}	100000	https://storage.eachop.tech/metafarmdev/1744104146197_TESTTT-1744104145049.metadata.json	Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn	test	data	BSC Testnet	f
2025-04-08 08:47:55.321294	2025-04-14 04:47:22.892517	deleted	Learning Bridge	The LearnBridge Digital Classroom Initiative will deploy over 100 solar-powered learning centers across rural areas, each equipped with tablets, pre-loaded courses, and satellite connectivity. NFT holders fund individual centers and receive a share of rev	With the power of NFT-backed crowdfunding, we enable global investors to fund real classrooms, support real learners, and earn sustainable returns—all with full transparency on how their capital is being used.	Education is the most powerful tool for economic mobility, yet over 250 million children globally lack access to quality schooling. LearnBridge offers a field-ready solution built on three pillars:\n\n✅ Infrastructure\nEach center is a small, solar-powered unit built with local materials and staffed by trained facilitators. Every classroom includes:\n\nOffline-ready tablets\n\nSatellite Wi-Fi connectivity\n\nCurriculum in local languages\n\nGamified learning modules from K–12 to job-skills\n\n✅ Technology\nLearnBridge's blockchain platform tracks:\n\nStudent enrollment and attendance\n\nCurriculum completion\n\nCredential issuance via verifiable NFTs\n\nSmart contract-based revenue payouts to NFT holders\n\nThis ensures investors know exactly what impact they’re funding and can see performance data live.\n\n✅ Revenue Streams\nNGOs and governments pay for center deployment and operations\n\nParents and communities contribute small monthly learning fees\n\nJob-placement partners pay for access to graduating students\n\n	["technology", "education"]	[{"stream": "Tuition Fee", "description": "Tuition Fee"}]	[{"title": "Logo", "fileUrl": "QmVuuEEKKKZt6eJ3Fk8nTSqWYKLbohLcxCGoNR4hvGFFEA"}]	10	10	QmVuuEEKKKZt6eJ3Fk8nTSqWYKLbohLcxCGoNR4hvGFFEA	QmVuuEEKKKZt6eJ3Fk8nTSqWYKLbohLcxCGoNR4hvGFFEA	8	LB	LB	0x82ACC31F994E317bc98b0F6195790634730ad30d	12	["0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "LB", "owner": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "symbol": "LB", "maxSupply": 10000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "12", "collectionAddress": "0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	100	https://storage.eachop.tech/metafarmdev/1744102074805_LB-1744102089272.metadata.json	QmVuuEEKKKZt6eJ3Fk8nTSqWYKLbohLcxCGoNR4hvGFFEA	LB	LB	BSC Testnet	t
2025-04-08 10:04:48.873862	2025-04-14 04:47:16.611706	deleted	LearnBridge – Decentralized Education for All	The LearnBridge Digital Classroom Initiative will deploy over 100 solar-powered learning centers across rural areas, each equipped with tablets, pre-loaded courses, and satellite connectivity. NFT holders fund individual centers and receive a share of rev	LearnBridge is an edtech initiative bridging the global education gap through affordable, decentralized learning centers powered by blockchain technology. Our founders are a team of educators, curriculum designers, and tech innovators committed to making 	Education is the most powerful tool for economic mobility, yet over 250 million children globally lack access to quality schooling. LearnBridge offers a field-ready solution built on three pillars:\n\n✅ Infrastructure\nEach center is a small, solar-powered unit built with local materials and staffed by trained facilitators. Every classroom includes:\n\nOffline-ready tablets\n\nSatellite Wi-Fi connectivity\n\nCurriculum in local languages\n\nGamified learning modules from K–12 to job-skills\n\n✅ Technology\nLearnBridge's blockchain platform tracks:\n\nStudent enrollment and attendance\n\nCurriculum completion\n\nCredential issuance via verifiable NFTs\n\nSmart contract-based revenue payouts to NFT holders\n\nThis ensures investors know exactly what impact they’re funding and can see performance data live.\n\n✅ Revenue Streams\nNGOs and governments pay for center deployment and operations\n\nParents and communities contribute small monthly learning fees\n\nJob-placement partners pay for access to graduating students\n\n	["technology", "education"]	[{"stream": "Tuition Fee", "description": "Tuition Fee"}]	[{"title": "Logo", "fileUrl": "QmVuuEEKKKZt6eJ3Fk8nTSqWYKLbohLcxCGoNR4hvGFFEA"}]	10	10	QmVuuEEKKKZt6eJ3Fk8nTSqWYKLbohLcxCGoNR4hvGFFEA	QmVuuEEKKKZt6eJ3Fk8nTSqWYKLbohLcxCGoNR4hvGFFEA	13	LB	LB	0x82ACC31F994E317bc98b0F6195790634730ad30d	12	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f", "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "LB", "owner": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "symbol": "LB", "maxSupply": 10000}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "12", "collectionAddress": "0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	10000	https://storage.eachop.tech/metafarmdev/1744106688347_LB-1744106703294.metadata.json	QmVuuEEKKKZt6eJ3Fk8nTSqWYKLbohLcxCGoNR4hvGFFEA	LB	LB	BSC Testnet	t
2025-04-09 04:41:13.187086	2025-04-14 04:47:14.150168	deleted	Shit Coin	Make money with shit	Shit farmers	Fertilizer for farmers using crypto	["fertilizer", "farm"]	[]	[{"title": "MetaFarms Early Access Gameplay v1-1744173469822", "fileUrl": "QmNRw8f3G6jRXXGfEwtpz3s6NMrCx5AXeoMnN2LbgVZtwH"}, {"title": "Climate Change Spiral - Fast 30s-1744173515558", "fileUrl": "QmV4QMyggudr8vAQPxdHG3VS5xreJuQHSS8s74vHHDyQsy"}]	36	15	Qmd8FpF3Ja8GxFEjQifWpxnrDQ5c8NwWatDwE1Z35ZcJsw	QmVVKn87NgAt3KwLkJNihY3t7jga9jjiaoLsR8NBZgguSo	14	Shit Coin	$HIT	0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6	13	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f", "0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "Shit Coin", "owner": "0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f", "symbol": "$HIT", "maxSupply": 10}, "response": {"account": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "collectionId": "13", "collectionAddress": "0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6"}}	10	https://storage.eachop.tech/metafarmdev/1744173672740_Shit_Coin-1744173672299.metadata.json	Qmd8FpF3Ja8GxFEjQifWpxnrDQ5c8NwWatDwE1Z35ZcJsw	Cool shit for cool coin	Gen 1 $HIT	BSC Testnet	f
2025-04-15 15:17:05.354806	2025-04-15 16:37:22.799103	active	Coffee by Hineleban Farms	The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. 	Welcome to Hineleban Farms; the birthplace and bedrock of Hineleban Foundation Inc. We are continuously working to bring our core values as Stewards of the Earth into fruition, focusing on environmental conservation and reforestation. 	Hineleban Farms coffee is made from the finest hand-picked ripe red coffee cherries growing on misty cool Mount Kitanglad. For every bag of coffee that is sold, a tree is planted in the customer’s name. \n	["farming"]	[{"stream": "Sale of coffee beans", "description": "Coffee cherries are harvested every cycle to be processed into coffee beans for sale. "}]	[{"title": "Hineleban Coffee Packaging Picture-1744728440065", "fileUrl": "QmYFWiWhtd1Xmij7ZNskm6Wgo5cQ19TCmimWUdkYYgXmJ7"}]	36	15	QmQoBhe5RgRjhT4VzMp9HBwaKXw2BGF4LjEFRobVuvhgUQ	QmfFvp5DDSLJgS3ybTgrpUeCGfEn1Lwh95FW3gwbWFEdso	15	Coffee by Hineleban Farms - Genesis Crop	CFEHF1	0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6	14	["0xF00305EdEF744B3967810BDfa8aE9Df3b332000f", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC", "0x077Dcbfd562D36D98B6fe30661D581f63bFE564f"]	{"input": {"name": "Coffee by Hineleban Farms - Genesis Crop", "owner": "0xF00305EdEF744B3967810BDfa8aE9Df3b332000f", "symbol": "CFEHF1", "maxSupply": 100}, "response": {"account": "0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07", "collectionId": "14", "collectionAddress": "0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6"}}	100	https://storage.eachop.tech/metafarmdev/1744730224907_Coffee_by_Hineleban_Farms_-_Genesis_Crop-1744730224291.metadata.json	QmVi3Y23j6MJP7XXxWCNR3NkArYgajcvQNetbntVvfCNDn	MetaFarms proudly launches its first collaboration with Hineleban Farms to cultivate premium coffee across 25 hectares of land. Owning a Genesis Coffee NFT from this inaugural collection unlocks exclusive rewards and long-term benefits that won’t be offered in future drops.	Farm Coffee ESG Philippines	BSC Testnet	t
2025-04-16 07:25:17.713536	2025-04-16 10:12:39.797018	deleted	TEST	The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The 	fixed	The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. The Tuminugan and Hineleban Products we have tod	["technology"]	[{"stream": "The Tuminugan and Hineleban Products", "description": "The Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. "}]	[{"title": "nft_image.jpg", "fileUrl": "Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn"}]	36	15	QmUF6LLm7S61mS4H3qAb1BXwCHJ6VcXu4fAeLVKDfnzZia	QmQ2VPXBGaEPYEZueAQ2J64nodypUFJUjC7NtwJnCA5zgQ	16	TEST	TEST	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	\N	[]	{}	10000	https://storage.eachop.tech/metafarmdev/1744788317137_TEST-1744788316481.metadata.json	Qmd22cno9e3FB78G9hqGr8bimR8Eq9AApFfdj7W5dax3Zn	vTESTTESTTEST	TEST	BSC Testnet	t
2025-04-16 14:30:34.587329	2025-04-16 14:33:05.390312	active	Adlai by Hineleban Farms	Welcome to Hineleban Farms; the birthplace and bedrock of Hineleban Foundation Inc. We are continuously working to bring our core values as Stewards of the Earth into fruition. Through our journey in environmental conservation and reforestation, the farm has served as an inspiration to those who have lost hope in restoring our Philippine rainforests.\n\n“The spirit of the gathering and giving Mother Tree of the Rainforest that sustains the cycle of all life” - meaning of ‘Hineleban’.\n\nHineleban Foundation was founded in 2008, with the major advocacy of re-establishing the rainforests of the upper mountain ranges of Mindanao beginning with Bukidnon, while creating sustainable livelihood opportunities for the indigenous communities living in the buffer zones of the high mountains. Thereby empowering them to take back their roles of being custodians of the rainforest. \n\nThe Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. We were gifted the names ‘Tuminugan’ and ‘Hineleban’ by the Indigenous People of Bukidnon for sharing the same vision of restoration of our environment and our mother rainforests, and for the full commitment that we have brought to this effort.	fixed	Hineleban Adlai is a gluten-free, indigenous upland grain from the Philippines, offering a healthier alternative to rice with its low glycemic index and fluffy texture. It is celebrated for its nutritional benefits and cultural significance, having been introduced to the market through a transformational business partnership that supports local farmers.\n	["farming"]	[{"stream": "Sale of Adlai Rice", "description": "Adlai rice stalk is harvested every cycle to be immediately sold into wholesale and retail markets. "}]	[{"title": "Hineleban Adlai Packaging Picture-1744813527440", "fileUrl": "QmTHeYn59bFCuMb7a6pdox9jC5AeVooKKobWamFUtCSxf4"}]	36	15	QmQoBhe5RgRjhT4VzMp9HBwaKXw2BGF4LjEFRobVuvhgUQ	QmYfjgbKb9tF3MVe2ouBAFkYYYA218qM6mNaoKbimFX15N	17	Adlai by Hineleban Farms - Genesis Crop	ADLHF1	0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A	15	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f", "0xADD6E354d5799948D95859ae1A2b3FB825F78D75", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "Adlai by Hineleban Farms - Genesis Crop", "owner": "0xADD6E354d5799948D95859ae1A2b3FB825F78D75", "symbol": "ADLHF1", "maxSupply": 200}, "response": {"account": "0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07", "collectionId": "15", "collectionAddress": "0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A"}}	200	https://storage.eachop.tech/metafarmdev/1744813834142_Adlai_by_Hineleban_Farms_-_Genesis_Crop-1744813833495.metadata.json	QmWSSdMYgJigSdoYtWXHF4AGfZU3eWhr1gZQy8ZL1W2v6C	MetaFarms proudly launches its first collaboration with Hineleban Farms to cultivate the hardy Adlai crop across 50 hectares of land. Owning a Genesis Adlai NFT from this inaugural collection unlocks exclusive rewards and long-term benefits that won’t be offered in future drops.	Farm Adlai Rice ESG Philippines	BSC Testnet	t
2025-04-16 14:59:37.507833	2025-04-23 02:39:37.871514	active	Banana by Hineleban Farms	Welcome to Hineleban Farms; the birthplace and bedrock of Hineleban Foundation Inc. We are continuously working to bring our core values as Stewards of the Earth into fruition. Through our journey in environmental conservation and reforestation, the farm has served as an inspiration to those who have lost hope in restoring our Philippine rainforests. \n\n“The spirit of the gathering and giving Mother Tree of the Rainforest that sustains the cycle of all life” - meaning of ‘Hineleban’. \n\nHineleban Foundation was founded in 2008, with the major advocacy of re-establishing the rainforests of the upper mountain ranges of Mindanao beginning with Bukidnon, while creating sustainable livelihood opportunities for the indigenous communities living in the buffer zones of the high mountains. Thereby empowering them to take back their roles of being custodians of the rainforest. \n\nThe Tuminugan and Hineleban Products we have today are all nature’s bounty, each with a unique story of it’s own serendipitous finding. We were gifted the names ‘Tuminugan’ and ‘Hineleban’ by the Indigenous People of Bukidnon for sharing the same vision of restoration of our environment and our mother rainforests, and for the full commitment that we have brought to this effort.	fixed	Hineleban Bananas are sustainably grown in the highlands of the Philippines, known for their rich flavor, nutritional value, and year-round yield. This initiative empowers local farmers through a regenerative agriculture model, made possible by various partnerships that support both community livelihood and environmental stewardship.	["farming"]	[{"stream": "Sale of bananas", "description": "Bananas are grown and harvested regularly throughout the year to be sold into the wholesale and retail markets. "}]	[{"title": "Bananas-1744815241867", "fileUrl": "QmWfzD7u8NeSbTW422gap5n21WJPMSHN5GFTpmvVdrFRa7"}]	36	15	QmQoBhe5RgRjhT4VzMp9HBwaKXw2BGF4LjEFRobVuvhgUQ	QmSeETrgPvofYDS9nafxXPRAjQitXkhJx4NFCvVa3ik8KT	18	Banana by Hineleban Farms - Genesis Crop	BNAHF1	0x47a18F5191E1edCF471Fa968Cb979e8facbF627E	16	["0xB9484dB7cBe6BD38cd33C620764cA6Fe2F498Abc", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC", "0x077Dcbfd562D36D98B6fe30661D581f63bFE564f"]	{"input": {"name": "Banana by Hineleban Farms - Genesis Crop", "owner": "0xB9484dB7cBe6BD38cd33C620764cA6Fe2F498Abc", "symbol": "BNAHF1", "maxSupply": 160}, "response": {"account": "0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07", "collectionId": "16", "collectionAddress": "0x47a18F5191E1edCF471Fa968Cb979e8facbF627E"}}	160	https://storage.eachop.tech/metafarmdev/1745375977432_Banana_by_Hineleban_Farms_-_Genesis_Crop-1745375977176.metadata.json	QmbUKpiqnsSa1J9vQraPv1X7PWktHZDHzQMsftVgb1R57H	MetaFarms proudly launches its first collaboration with Hineleban Farms to cultivate bananas across 48 hectares of land. Owning a Genesis Banana NFT from this inaugural collection unlocks exclusive rewards and long-term benefits that won’t be offered in future drops.	Farm Banana ESG Philippines	BSC Testnet	t
2025-04-21 15:06:25.504687	2025-04-21 15:14:47.430522	deleted	Casa de Cacao by Ralfe Gourmet	Casa de Cacao offers an immersive experience into the world of artisanal chocolate, where tradition meets innovation. With a focus on quality and sustainability, their products are crafted from carefully selected cacao beans, often sourced directly from local farms. Each item is a testament to the rich history and cultural significance of cacao, inviting you to explore its depths through workshops, tastings, and exquisite creations.	fixed	Our cacao project is committed to cultivating five of the world’s most sought-after cacao varieties: Trinitario, Forastero, Criollo, Nacional, and CCN-51. Each variety is carefully selected for its unique flavor profile, high yield, and resilience, ensuring a diverse and premium-quality harvest. From germination to maturation, our trees are nurtured through every stage of growth, with peak production reached between 5 to 7 years and regular harvests every 3-4 months thereafter. We emphasize sustainable farming practices that enrich local communities and protect the environment, while providing a consistent supply of both high-quality cacao beans and seeds. Whether you are a chocolate maker seeking exceptional ingredients or a supporter of ethical agriculture, our project offers an opportunity to be part of a dynamic, responsible, and innovative cacao ecosystem that values quality, sustainability, and long-term growth.	["farming"]	[{"stream": "Sale of cacao seeds and beans", "description": "The revenue generated from germination to harvest with peak productions between 5th and 7th years. "}]	[{"title": "Casa de Cacao Chocolate Packaging-1745247052056", "fileUrl": "QmcSdEyzHfKuTmvxBB5TjspGirBNP9aKCnQ9g94ofLF7uS"}]	60	15	QmZGKMMtuFCQ4PAnsLxYLqKPURSPKtoT4GgNhxMJUeka7a	QmRnrjGpnLfYu9uf37k2vqxGbg6HTyqEBHFh2SJ2H2MsUQ	19	Casa de Cacao by Ralfe Gourmet - Genesis Crop	CDCRG1	0xf9351d944e2D7E32532100C03Bd28b9d91271826	18	["0xc57237a6a2f0542B4958905236979765D8839CAF", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "Casa de Cacao by Ralfe Gourmet - Genesis Crop", "owner": "0xc57237a6a2f0542B4958905236979765D8839CAF", "symbol": "CDCRG1", "maxSupply": 200}, "response": {"account": "0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07", "collectionId": "18", "collectionAddress": "0xf9351d944e2D7E32532100C03Bd28b9d91271826"}}	0	https://storage.eachop.tech/metafarmdev/1745248034805_Casa_de_Cacao_by_Ralfe_Gourmet_-_Genesis_Crop-1745248034525.metadata.json	QmZJ6D6pBG2UhqiwA15kSWskeGm8QMRDUvZFHWpuSKPHcz	Casa de Cacao’s NFT crowdfunding project supports the cultivation of five premium cacao varieties through sustainable, community-enriching practices. Rooted in tradition and driven by innovation, this initiative empowers local farmers while preserving the cultural heritage of artisanal chocolate. NFT holders will play a vital role in growing a diverse, high-quality cacao ecosystem that champions ethical farming and long-term impact.	Farm Cacao Chocolate ESG Philippines	BSC Testnet	t
2025-04-21 15:13:59.098672	2025-04-21 15:15:58.137993	active	Casa de Cacao by Ralfe Gourmet	Casa de Cacao offers an immersive experience into the world of artisanal chocolate, where tradition meets innovation. With a focus on quality and sustainability, their products are crafted from carefully selected cacao beans, often sourced directly from local farms. Each item is a testament to the rich history and cultural significance of cacao, inviting you to explore its depths through workshops, tastings, and exquisite creations.\n	fixed	Our cacao project is committed to cultivating five of the world’s most sought-after cacao varieties: Trinitario, Forastero, Criollo, Nacional, and CCN-51. Each variety is carefully selected for its unique flavor profile, high yield, and resilience, ensuring a diverse and premium-quality harvest. From germination to maturation, our trees are nurtured through every stage of growth, with peak production reached between 5 to 7 years and regular harvests every 3-4 months thereafter. We emphasize sustainable farming practices that enrich local communities and protect the environment, while providing a consistent supply of both high-quality cacao beans and seeds. Whether you are a chocolate maker seeking exceptional ingredients or a supporter of ethical agriculture, our project offers an opportunity to be part of a dynamic, responsible, and innovative cacao ecosystem that values quality, sustainability, and long-term growth.	["farming"]	[{"stream": "Sale of cacao seeds and beans", "description": "Revenue generated from an entire cycle of germination up until harvest, with production peaking between the 5th and 7th years. "}]	[{"title": "Casa de Cacao Chocolate Packaging-1745247052056", "fileUrl": "QmcSdEyzHfKuTmvxBB5TjspGirBNP9aKCnQ9g94ofLF7uS"}]	60	15	QmZGKMMtuFCQ4PAnsLxYLqKPURSPKtoT4GgNhxMJUeka7a	QmRnrjGpnLfYu9uf37k2vqxGbg6HTyqEBHFh2SJ2H2MsUQ	20	Casa de Cacao by Ralfe Gourmet - Genesis Crop	CDCRG1	0xf9351d944e2D7E32532100C03Bd28b9d91271826	18	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f", "0xc57237a6a2f0542B4958905236979765D8839CAF", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "Casa de Cacao by Ralfe Gourmet - Genesis Crop", "owner": "0xc57237a6a2f0542B4958905236979765D8839CAF", "symbol": "CDCRG1", "maxSupply": 200}, "response": {"account": "0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07", "collectionId": "18", "collectionAddress": "0xf9351d944e2D7E32532100C03Bd28b9d91271826"}}	200	https://storage.eachop.tech/metafarmdev/1745248438675_Casa_de_Cacao_by_Ralfe_Gourmet_-_Genesis_Crop-1745248438292.metadata.json	QmZJ6D6pBG2UhqiwA15kSWskeGm8QMRDUvZFHWpuSKPHcz	MetaFarms proudly launches its first collaboration with Casa de Cacao by Ralfe Gourmet, to cultivate different varieties of cacao. Owning a Genesis Cacao NFT from this inaugural collection unlocks exclusive rewards and long-term benefits that won’t be offered in future drops.	Farm Cacao Chocolate ESG Philippines	BSC Testnet	t
2025-04-21 15:37:14.557436	2025-04-22 01:37:21.928238	deleted	Smart Vending Machines by MetaFarms	MetaFarms is what happens when the “Kickstarter of Agriculture” meets the “Roblox of Farming”—and then both jump into the Metaverse wearing overalls and VR headsets. Imagine a world where you can crowdfund real farms, play immersive games that actually help smallholder farmers, and earn rewards that are tied to real-world crops, carbon credits, and even sushi vending machines.\n\nOn MetaFarms, you don’t just click to plant a virtual carrot—you’re directly supporting a farmer in Southeast Asia who’s growing the real thing. Gamers and investors can join forces, funding projects through blockchain-powered NFTs, voting on farm strategies, and watching their impact grow both in-game and out in the fields. Play a game, win a prize, and know that your digital harvest helps put food on real tables and money in real farmers’ pockets.\n\nMetaFarms is making farming fun, transparent, and profitable for everyone—whether you’re a city kid with a smartphone, a sustainability investor, or a farmer looking for a fair shot. It’s a win-win-win: you get to play, farmers thrive, and the planet gets a little greener. Farming just got a whole lot sexier (and a lot more fun)!	fixed	MetaFarms is launching a smart vending machine business that will dispense drinks, snacks, and ready-to-eat meals in high-traffic locations. Leveraging advanced IoT, RFID, and AI technologies, these smart vending machines offer 24/7 convenience, touchless payments, and real-time inventory management for optimal freshness and reduced waste. The machines feature interactive displays for product information and promotions, and can be remotely monitored to ensure efficient restocking and maintenance. By collecting and analyzing consumer purchasing data, MetaFarms can personalize offerings and dynamically adjust product selections to match local demand. This new line of business combines the convenience of e-commerce with the accessibility of traditional retail, creating new revenue streams while delivering a seamless, data-driven snacking experience for consumers and business partners alike.	["technology"]	[{"stream": "Trading and deployment of vending machines", "description": "Revenues from the trading and leasing of vending machines, and from the vending of food and drink items. "}]	[{"title": "VendrBot Vending-1745248966729", "fileUrl": "QmVr7yjVwf1ncrWrqVLChnndANZWCaG7TZeiyk8e8CcuyM"}]	24	10	QmaQdhYfxLkqTN3zrPwXAYVaRYYPCNz6Zi1UJJ5HJTMBx1	QmVr7yjVwf1ncrWrqVLChnndANZWCaG7TZeiyk8e8CcuyM	21	Smart Vending Machines by MetaFarms	SVMMF1	0xAD2199b809Ca8099af1d76Cff387ff5441850aAC	19	["0x077Dcbfd562D36D98B6fe30661D581f63bFE564f", "0x9ca8f5C30058a22cCce65834466F456f00Fbcc11", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC"]	{"input": {"name": "Smart Vending Machines by MetaFarms", "owner": "0x9ca8f5C30058a22cCce65834466F456f00Fbcc11", "symbol": "SVMMF1", "maxSupply": 300}, "response": {"account": "0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07", "collectionId": "19", "collectionAddress": "0xAD2199b809Ca8099af1d76Cff387ff5441850aAC"}}	300	https://storage.eachop.tech/metafarmdev/1745249834104_Smart_Vending_Machines_by_MetaFarms-1745249833530.metadata.json	QmXD6emF9giry2AgmrA4fo9VZ1noudH1F4JZvJuLzFAVGX	MetaFarms purchasing new and used inventory of smart vending machines to be deployed locally/regionally to dispense food and drinks, including ready-to-eat meals. Owning a Genesis Smart Vending Machine NFT from this inaugural collection unlocks exclusive rewards and long-term benefits that won’t be offered in future drops.	Smart Vending ESG Food MRE Meals-Ready-To-Eat Automation IoT	BSC Testnet	t
2025-04-22 01:55:06.542903	2025-04-29 00:00:07.296759	active	Smart Vending Machines by Food Starter	FoodStarter is a Global Agricultural Financing & Investment, farm incubator & fundraising company headquartered in Singapore, with subsidiaries across South East Asia. The FoodStarter Charter defines Food Starter’s role as a Steward, shaping food aficionados and food enthusiasts' culture to do well, do right, and do good for the community around the world.  \n\nWith ESG and sustainability as core values, FoodStarter actively seeks sustainable food security solutions to address present and future challenges. The company also aims to capture investible opportunities that will contribute to a sustainable future for all.	fixed	Food Starter will be acquiring an inventory of mixed vending machines that will dispense drinks, snacks, and ready-to-eat meals in high-traffic locations. Leveraging advanced IoT, RFID, and AI technologies, these smart vending machines offer 24/7 convenience, touchless payments, and real-time inventory management for optimal freshness and reduced waste. The machines feature interactive displays for product information and promotions, and can be remotely monitored to ensure efficient restocking and maintenance. By collecting and analyzing consumer purchasing data, Food Starter can personalize offerings and dynamically adjust product selections to match local demand. This new line of business combines the convenience of e-commerce with the accessibility of traditional retail, creating new revenue streams while delivering a seamless, data-driven snacking experience for consumers and business partners alike.	["technology"]	[{"stream": "Trading and deployment of vending machines", "description": "Revenues derived from the trading and leasing of vending machines, including potential vending revenue from machines that are directly operated by Food Starter. "}]	[{"title": "VendrBot Vending-1745248966729", "fileUrl": "QmVr7yjVwf1ncrWrqVLChnndANZWCaG7TZeiyk8e8CcuyM"}]	24	10	QmafqFfZquDvozWUNA2CFX8BsbnbVzCnb1n8zz4e1SYvh6	QmVr7yjVwf1ncrWrqVLChnndANZWCaG7TZeiyk8e8CcuyM	22	Smart Vending Machines by Food Starter	SVMFS1	0x931Db63A70D051460aB9f1AA3c772063C5B3bB36	20	["0x9ca8f5C30058a22cCce65834466F456f00Fbcc11", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC", "0x077Dcbfd562D36D98B6fe30661D581f63bFE564f"]	{"input": {"name": "Smart Vending Machines by Food Starter", "owner": "0x9ca8f5C30058a22cCce65834466F456f00Fbcc11", "symbol": "SVMFS1", "maxSupply": 300}, "response": {"account": "0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07", "collectionId": "20", "collectionAddress": "0x931Db63A70D051460aB9f1AA3c772063C5B3bB36"}}	300	https://storage.eachop.tech/metafarmdev/1745292988357_Smart_Vending_Machines_by_Food_Starter-1745292987769.metadata.json	QmXD6emF9giry2AgmrA4fo9VZ1noudH1F4JZvJuLzFAVGX	Food Starter will be purchasing an inventory of up to 850 new and used smart vending machines to be deployed locally/regionally to dispense food and drinks, including ready-to-eat meals. Owning a Genesis Smart Vending Machine NFT from this inaugural collection unlocks exclusive rewards and long-term benefits that won’t be offered in future drops.	Smart Vending ESG Food MRE Meals-Ready-To-Eat Automation IoT	BSC Testnet	t
2025-04-29 08:29:22.115214	2025-05-06 09:16:41.763642	active	Riau Coastal Peatland & Mangrove Conservation	360green Pte Ltd (https://360green.io/), based in Singapore, is leading the Riau Coastal, Peatland & Mangrove (RCPM) Conservation Project, dedicated to conserving and restoring critical mangrove and peatland ecosystems along Indonesia's Riau coastline. In collaboration with prominent Indonesian stakeholders such as ARMA Law, PT Green Bomas Indonesia, PT GeoGreen Aero Solusi, and Yayasan Gambut, 360green combines environmental stewardship with robust social impact, aiming for measurable improvements in community welfare and environmental sustainability. This initiative underscores 360green's commitment to transparency, accountability, and high-quality carbon credit generation, benefiting both local communities and the global environment.	fixed	The RCPM Project is a 30-year initiative aimed at conserving and restoring 24,137 hectares of mangrove and peatland ecosystems in Riau Province, Indonesia. Positioned strategically near Singapore and Malaysia, the project mitigates regional haze while preserving vital biodiversity hotspots. Using Verra's AUDD methodology, the project generates over 1.6 million annual carbon credits, supporting global emission reduction goals. Integral to the project's success is extensive community engagement, enhancing local livelihoods through sustainable practices. The project actively contributes to achieving all 17 United Nations Sustainable Development Goals (SDGs).	["farming", "ESG", "UNSDG"]	[{"stream": "Sale of carbon credits", "description": "Revenue from annual sales of carbon credits generated by mangrove-based carbon sequestration."}]	[{"title": "RCPM Project Summary-1745914872795", "fileUrl": "QmSa9sdara7TwJHN5gNWiA2eCRArFcQSZvpDJcRNeJqhWQ"}]	60	15	QmcSJatTEZmahuuPzXuB1Wth5wEm6xi2w7udYCuZKDich3	QmYKmNoTQEAsFfN1CzYAEkVkeLqkeN3wwzv9GBg7f3EF3V	23	Riau Coastal Peatland & Mangrove Conservation - Genesis	MGVTG1	0x43C1ea7c987e0De7Ad5CB62d44F4372983Cba00c	21	["0xF1847C672ad3217bB7c923A176636F841DbCF304", "0x5006Ed3466eF2b796Dc8EBA5430641Dd9599fEeC", "0x077Dcbfd562D36D98B6fe30661D581f63bFE564f"]	{"input": {"name": "Riau Coastal Peatland & Mangrove Conservation - Genesis", "owner": "0xF1847C672ad3217bB7c923A176636F841DbCF304", "symbol": "MGVTG1", "maxSupply": 250}, "response": {"account": "0x1a01fBa06C4DD9a4aE68AA80c43dF36847cFdD07", "collectionId": "21", "collectionAddress": "0x43C1ea7c987e0De7Ad5CB62d44F4372983Cba00c"}}	250	https://storage.eachop.tech/metafarmdev/1745917438337_Riau_Coastal_Peatland_&_Mangrove_Conservation_-_Genesis-1745917437425.metadata.json	QmRatFzN7qzCWB5ZzMBhmmygVGkobxrDxGHnTW1o8PVdxV	This Genesis Mangrove NFT marks the first-ever mangrove conservation project on our marketplace and our inaugural collaboration with 360green, unlocking exclusive rewards and long-term environmental impact, while uplifting the local community in Riau.	Mangrove Peatland Riau ESG Indonesia UNSDG	BSC Testnet	t
\.


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.purchases (created_at, updated_at, id, beneficiary, collection_address, on_chain_data, token_id, token, price, minted_to, minted_token_id) FROM stdin;
2025-04-05 07:37:13	2025-04-05 07:37:13	3	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0x8f3DCEC35d7cC008B3393e0B4C72E1315eAfb10a	{"input": {}, "response": {"price": "1000000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "18", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 1, "collectionAddress": "0x8f3DCEC35d7cC008B3393e0B4C72E1315eAfb10a"}}	18	0x0000000000000000000000000000000000000000	1000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	1
2025-04-08 10:50:15	2025-04-08 10:50:15	2	0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D	0x82ACC31F994E317bc98b0F6195790634730ad30d	{"input": {}, "response": {"price": "10000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "12", "mintedTo": "0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d", "beneficiary": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "mintedTokenId": 2, "collectionAddress": "0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	12	0x0000000000000000000000000000000000000000	10000000000000	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	2
2025-03-20 15:48:50	2025-03-20 15:48:50	10	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd	{"input": {}, "response": {"price": "10000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "8", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 6, "collectionAddress": "0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd"}}	8	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	10000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	6
2025-03-20 16:36:53	2025-03-20 16:36:53	11	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd	{"input": {}, "response": {"price": "10000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "8", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 7, "collectionAddress": "0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd"}}	8	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	10000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	7
2025-03-20 16:38:05	2025-03-20 16:38:05	12	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd	{"input": {}, "response": {"price": "10000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "8", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 8, "collectionAddress": "0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd"}}	8	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	10000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	8
2025-03-20 16:46:05	2025-03-20 16:46:05	13	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd	{"input": {}, "response": {"price": "10000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "8", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 9, "collectionAddress": "0x6716ca9D1B674657EA085Df4C9bb11F121FfFBCd"}}	8	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	10000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	9
2025-04-08 03:13:56	2025-04-08 03:13:56	4	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0xc528b4310B21cBD088fD9231cCDE3498EE2a8994	{"input": {}, "response": {"price": "1000000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "2", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 2, "collectionAddress": "0xc528b4310B21cBD088fD9231cCDE3498EE2a8994"}}	2	0x0000000000000000000000000000000000000000	1000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	2
2025-03-22 10:22:48	2025-03-22 10:22:48	7	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A	{"input": {}, "response": {"price": "100000000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "16", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 3, "collectionAddress": "0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A"}}	16	0x0000000000000000000000000000000000000000	100000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	3
2025-03-22 10:23:21	2025-03-22 10:23:21	8	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A	{"input": {}, "response": {"price": "500000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "16", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 4, "collectionAddress": "0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A"}}	16	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	500000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	4
2025-04-08 07:16:33	2025-04-08 07:16:33	1	0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D	0x077f3e8095c70d7e588dfb4C285d2Fe52e72F4B1	{"input": {}, "response": {"price": "2000", "token": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", "tokenId": "6", "mintedTo": "0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d", "beneficiary": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "mintedTokenId": 1, "collectionAddress": "0x077f3e8095c70d7e588dfb4C285d2Fe52e72F4B1"}}	6	0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359	2000	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	1
2025-03-22 09:25:45	2025-03-22 09:25:45	9	0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06	0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6	{"input": {}, "response": {"price": "500000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "15", "mintedTo": "0x2b6b40e6395b25fb8401262f69e3ecec2a774a06", "beneficiary": "0x2b6B40e6395b25Fb8401262F69e3ecec2a774A06", "mintedTokenId": 5, "collectionAddress": "0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6"}}	15	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	500000000000000000	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	5
2025-04-08 10:47:51	2025-04-08 10:47:51	15	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	0x82ACC31F994E317bc98b0F6195790634730ad30d	{"input": {}, "response": {"price": "10000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "12", "mintedTo": "0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72", "beneficiary": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "mintedTokenId": 1, "collectionAddress": "0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	12	0x0000000000000000000000000000000000000000	10000000000000	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	1
2025-03-23 07:16:30	2025-03-23 07:16:30	25	0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D	0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A	{"input": {}, "response": {"price": "500000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "16", "mintedTo": "0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d", "beneficiary": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "mintedTokenId": 5, "collectionAddress": "0xF220b930B42E12c2079d8eAf6D7c6139332Ce62A"}}	16	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	500000000000000000	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	5
2025-03-24 07:45:21	2025-03-24 07:45:21	26	0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D	0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6	{"input": {}, "response": {"price": "500000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "15", "mintedTo": "0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d", "beneficiary": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "mintedTokenId": 6, "collectionAddress": "0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6"}}	15	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	500000000000000000	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	6
2025-04-01 03:53:30	2025-04-01 03:53:30	30	0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D	0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6	{"input": {}, "response": {"price": "500000000000000000", "token": "0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A", "tokenId": "15", "mintedTo": "0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d", "beneficiary": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "mintedTokenId": 7, "collectionAddress": "0xFe4a4b7f1FEF0755b05Ab15FB08871422CE128D6"}}	15	0xb140a5E507DEC48e8D982AD816c5AA8fC4DE2A4A	500000000000000000	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	7
2025-04-08 10:46:45	2025-04-08 10:46:45	27	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C	{"input": {}, "response": {"price": "100", "token": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", "tokenId": "11", "mintedTo": "0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72", "beneficiary": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "mintedTokenId": 7, "collectionAddress": "0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	11	0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359	100	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	7
2025-04-07 09:35:02	2025-04-07 09:35:02	42	0xd25f7c93D7818dAfBa612094161E89C3DC99fe69	0x6A72bfD534d220737beDD0C6fC165904b18C53bb	{"input": {}, "response": {"price": "1000000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "3", "mintedTo": "0xd25f7c93d7818dafba612094161e89c3dc99fe69", "beneficiary": "0xd25f7c93D7818dAfBa612094161E89C3DC99fe69", "mintedTokenId": 3, "collectionAddress": "0x6A72bfD534d220737beDD0C6fC165904b18C53bb"}}	3	0x0000000000000000000000000000000000000000	1000000000000000	0xd25f7c93d7818dafba612094161e89c3dc99fe69	3
2025-04-08 09:49:53	2025-04-08 09:49:53	47	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	0xe7f3e090112838cbcF83d2525CA1B0A99358DB3F	{"input": {}, "response": {"price": "1000000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "10", "mintedTo": "0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72", "beneficiary": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "mintedTokenId": 2, "collectionAddress": "0xe7f3e090112838cbcF83d2525CA1B0A99358DB3F"}}	10	0x0000000000000000000000000000000000000000	1000000000000000	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	2
2025-04-08 10:47:11	2025-04-08 10:47:11	28	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C	{"input": {}, "response": {"price": "100000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "11", "mintedTo": "0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72", "beneficiary": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "mintedTokenId": 8, "collectionAddress": "0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	11	0x0000000000000000000000000000000000000000	100000000000000	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	8
2025-04-08 10:50:51	2025-04-08 10:50:51	33	0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D	0x82ACC31F994E317bc98b0F6195790634730ad30d	{"input": {}, "response": {"price": "10", "token": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", "tokenId": "12", "mintedTo": "0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d", "beneficiary": "0xcCa4d9BBE2C4acE9100Dd792b04AE31db6ecE04D", "mintedTokenId": 3, "collectionAddress": "0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	12	0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359	10	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	3
2025-04-08 10:53:33	2025-04-08 10:53:33	51	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	0x82ACC31F994E317bc98b0F6195790634730ad30d	{"input": {}, "response": {"price": "10", "token": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", "tokenId": "12", "mintedTo": "0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72", "beneficiary": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "mintedTokenId": 4, "collectionAddress": "0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	12	0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359	10	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	4
2025-04-10 08:00:57	2025-04-10 08:00:57	50	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6	{"input": {}, "response": {"price": "100000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "13", "mintedTo": "0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72", "beneficiary": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "mintedTokenId": 3, "collectionAddress": "0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6"}}	13	0x0000000000000000000000000000000000000000	100000000000000	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	3
2025-04-09 04:47:13	2025-04-09 04:47:13	41	0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f	0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6	{"input": {}, "response": {"price": "100", "token": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", "tokenId": "13", "mintedTo": "0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f", "beneficiary": "0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f", "mintedTokenId": 2, "collectionAddress": "0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6"}}	13	0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359	100	0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f	2
2025-04-08 10:42:43	2025-04-08 10:42:43	52	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C	{"input": {}, "response": {"price": "100000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "11", "mintedTo": "0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72", "beneficiary": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "mintedTokenId": 5, "collectionAddress": "0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	11	0x0000000000000000000000000000000000000000	100000000000000	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	5
2025-04-08 10:44:35	2025-04-08 10:44:35	53	0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72	0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C	{"input": {}, "response": {"price": "100", "token": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", "tokenId": "11", "mintedTo": "0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72", "beneficiary": "0x03ADA9606aD7e7441aa6724B0DD97Bc34De9Ed72", "mintedTokenId": 6, "collectionAddress": "0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	11	0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359	100	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	6
2025-04-09 04:25:11	2025-04-09 04:25:11	72	0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f	0x82ACC31F994E317bc98b0F6195790634730ad30d	{"input": {}, "response": {"price": "10000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "12", "mintedTo": "0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f", "beneficiary": "0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f", "mintedTokenId": 5, "collectionAddress": "0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	12	0x0000000000000000000000000000000000000000	10000000000000	0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f	5
2025-04-09 04:26:29	2025-04-09 04:26:29	73	0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f	0x82ACC31F994E317bc98b0F6195790634730ad30d	{"input": {}, "response": {"price": "10", "token": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", "tokenId": "12", "mintedTo": "0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f", "beneficiary": "0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f", "mintedTokenId": 6, "collectionAddress": "0x82ACC31F994E317bc98b0F6195790634730ad30d"}}	12	0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359	10	0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f	6
2025-04-09 04:27:21	2025-04-09 04:27:21	74	0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f	0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C	{"input": {}, "response": {"price": "100000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "11", "mintedTo": "0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f", "beneficiary": "0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f", "mintedTokenId": 9, "collectionAddress": "0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	11	0x0000000000000000000000000000000000000000	100000000000000	0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f	9
2025-04-09 04:28:13	2025-04-09 04:28:13	75	0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f	0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C	{"input": {}, "response": {"price": "100", "token": "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359", "tokenId": "11", "mintedTo": "0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f", "beneficiary": "0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f", "mintedTokenId": 10, "collectionAddress": "0xe61F0E8625A5668b6208f2b6A8c9Ba0FcEA0a93C"}}	11	0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359	100	0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f	10
2025-04-09 04:46:19	2025-04-09 04:46:19	76	0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f	0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6	{"input": {}, "response": {"price": "100000000000000", "token": "0x0000000000000000000000000000000000000000", "tokenId": "13", "mintedTo": "0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f", "beneficiary": "0x73d2a2C8d28732b3dF80a36b56BC7DC1178BA47f", "mintedTokenId": 1, "collectionAddress": "0xcf1E09Eb25a30F677218118bDFfD63D0Bf1F12b6"}}	13	0x0000000000000000000000000000000000000000	100000000000000	0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f	1
\.


--
-- Data for Name: referrals; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.referrals (created_at, updated_at, id, code, status) FROM stdin;
2025-04-07 06:36:49.716329	2025-04-10 09:23:51.108631	1	test	deleted
2025-04-09 04:55:38.632531	2025-04-14 04:47:06.810471	4	$shit_og	deleted
2025-04-07 09:17:47.568317	2025-04-14 04:47:08.690636	3	xctuality	deleted
2025-04-07 07:48:51.003367	2025-04-14 04:47:10.769376	2	ssskol	deleted
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: metafarm_user
--

COPY public.users (created_at, updated_at, id, wallet_address, email, username, status, sign_in_message, referral_id) FROM stdin;
2025-04-07 06:46:57.519467	2025-04-07 06:48:27.47699	174400841752059	0xbd30948cabadab3a785670d148ef6469957279de	\N	\N	active	Sign with address 0xbd30948cabadab3a785670d148ef6469957279de, nonce 547693	1
2025-04-07 06:49:59.513457	2025-04-07 06:49:59.513457	174400859951325	0xfb0db679b22a6f5ac4f0df7efddca61d7542d6f9	\N	\N	active	Sign with address 0xfb0db679b22a6f5ac4f0df7efddca61d7542d6f9, nonce 230406	\N
2025-04-07 09:20:15.84045	2025-04-07 09:20:15.84045	174401761584084	0x8f12305a9c2ad8697c831ca2102e151ab9cbb775	\N	\N	active	Sign with address 0x8f12305a9c2ad8697c831ca2102e151ab9cbb775, nonce 108100	\N
2025-04-07 09:34:28.655996	2025-04-07 09:34:28.655996	174401846865682	0xd25f7c93d7818dafba612094161e89c3dc99fe69	\N	\N	active	Sign with address 0xd25f7c93d7818dafba612094161e89c3dc99fe69, nonce 682857	\N
2025-04-08 04:18:40.364541	2025-04-08 04:18:40.364541	174408592036460	0x29a6a3150af59fa6e392e1ec3d48f661d1861019	\N	\N	active	Sign with address 0x29a6a3150af59fa6e392e1ec3d48f661d1861019, nonce 704848	\N
2025-04-07 06:46:59.897365	2025-04-26 08:08:01.138148	174400841989773	0x2b6b40e6395b25fb8401262f69e3ecec2a774a06	\N	\N	active	Sign with address 0x2b6b40e6395b25fb8401262f69e3ecec2a774a06, nonce 160541	\N
2025-04-15 15:31:21.256586	2025-04-30 01:58:00.103462	174473108125655	0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07	\N	\N	active	Sign with address 0x1a01fba06c4dd9a4ae68aa80c43df36847cfdd07, nonce 688823	\N
2025-04-07 06:47:29.944811	2025-04-14 17:04:16.559451	174400844994516	0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72	\N	\N	active	Sign with address 0x03ada9606ad7e7441aa6724b0dd97bc34de9ed72, nonce 388262	\N
2025-04-09 04:28:51.331815	2025-04-16 11:45:19.258111	174417293133284	0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f	\N	\N	active	Sign with address 0x73d2a2c8d28732b3df80a36b56bc7dc1178ba47f, nonce 751899	\N
2025-04-05 08:44:37.712218	2025-04-18 17:39:41.43798	174384267771497	0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d	\N	\N	active	Sign with address 0xcca4d9bbe2c4ace9100dd792b04ae31db6ece04d, nonce 515511	\N
2025-04-22 03:33:53.466791	2025-04-22 03:33:53.466791	174529283346718	0x9ca8f5c30058a22ccce65834466f456f00fbcc11	\N	\N	active	Sign with address 0x9ca8f5c30058a22ccce65834466f456f00fbcc11, nonce 459438	\N
2025-04-23 10:37:54.051592	2025-04-23 10:37:54.051592	174540467405166	0xd6bae6d838ce7ec8dfe5e8309710dcaf9fc3a692	\N	\N	active	Sign with address 0xd6bae6d838ce7ec8dfe5e8309710dcaf9fc3a692, nonce 956681	\N
2025-04-10 09:23:28.490287	2025-04-10 09:23:28.490287	174427700849060	0xaa15e482435efe3d79b94fe2741ceef64fb7e46f	\N	\N	active	Sign with address 0xaa15e482435efe3d79b94fe2741ceef64fb7e46f, nonce 295275	\N
\.


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: metafarm_user
--

SELECT pg_catalog.setval('public.events_id_seq', 62, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: metafarm_user
--

SELECT pg_catalog.setval('public.migrations_id_seq', 24, true);


--
-- Name: nfts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: metafarm_user
--

SELECT pg_catalog.setval('public.nfts_id_seq', 18, true);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: metafarm_user
--

SELECT pg_catalog.setval('public.projects_id_seq', 23, true);


--
-- Name: purchases_id_seq; Type: SEQUENCE SET; Schema: public; Owner: metafarm_user
--

SELECT pg_catalog.setval('public.purchases_id_seq', 84, true);


--
-- Name: referrals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: metafarm_user
--

SELECT pg_catalog.setval('public.referrals_id_seq', 4, true);


--
-- Name: admin_users PK_06744d221bb6145dc61e5dc441d; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT "PK_06744d221bb6145dc61e5dc441d" PRIMARY KEY (id);


--
-- Name: admin_user_credentials PK_140463aba33bb2fa8918cd2bce7; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.admin_user_credentials
    ADD CONSTRAINT "PK_140463aba33bb2fa8918cd2bce7" PRIMARY KEY (admin_user_id);


--
-- Name: purchases PK_1d55032f37a34c6eceacbbca6b8; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT "PK_1d55032f37a34c6eceacbbca6b8" PRIMARY KEY (id);


--
-- Name: events PK_40731c7151fe4be3116e45ddf73; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "PK_40731c7151fe4be3116e45ddf73" PRIMARY KEY (id);


--
-- Name: projects PK_6271df0a7aed1d6c0691ce6ac50; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "PK_6271df0a7aed1d6c0691ce6ac50" PRIMARY KEY (id);


--
-- Name: nfts PK_65562dd9630b48c4d4710d66772; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.nfts
    ADD CONSTRAINT "PK_65562dd9630b48c4d4710d66772" PRIMARY KEY (id);


--
-- Name: files PK_6c16b9093a142e0e7613b04a3d9; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT "PK_6c16b9093a142e0e7613b04a3d9" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: referrals PK_ea9980e34f738b6252817326c08; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.referrals
    ADD CONSTRAINT "PK_ea9980e34f738b6252817326c08" PRIMARY KEY (id);


--
-- Name: purchases UQ_11b3b71efbb2381cad3863e791b; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT "UQ_11b3b71efbb2381cad3863e791b" UNIQUE (minted_to, minted_token_id);


--
-- Name: users UQ_196ef3e52525d3cd9e203bdb1de; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_196ef3e52525d3cd9e203bdb1de" UNIQUE (wallet_address);


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: files UQ_a5c218dfdf6ad6092fed2230a88; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT "UQ_a5c218dfdf6ad6092fed2230a88" UNIQUE (key);


--
-- Name: events UQ_bae2a6525632d5fc41c44ac74e8; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT "UQ_bae2a6525632d5fc41c44ac74e8" UNIQUE (transaction_hash);


--
-- Name: admin_user_credentials UQ_c50659adb3eab0688976089cd88; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.admin_user_credentials
    ADD CONSTRAINT "UQ_c50659adb3eab0688976089cd88" UNIQUE (email);


--
-- Name: admin_users UQ_dcd0c8a4b10af9c986e510b9ecc; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT "UQ_dcd0c8a4b10af9c986e510b9ecc" UNIQUE (email);


--
-- Name: nfts UQ_e74df9aef1ddcf80c688f326aa9; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.nfts
    ADD CONSTRAINT "UQ_e74df9aef1ddcf80c688f326aa9" UNIQUE (project_id);


--
-- Name: users UQ_fe0bb3f6520ee0469504521e710; Type: CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_fe0bb3f6520ee0469504521e710" UNIQUE (username);


--
-- Name: IDX_0fac9310ed054c9a42ee8a03b7; Type: INDEX; Schema: public; Owner: metafarm_user
--

CREATE INDEX "IDX_0fac9310ed054c9a42ee8a03b7" ON public.events USING btree (address);


--
-- Name: UQ_referral_code_not_deleted; Type: INDEX; Schema: public; Owner: metafarm_user
--

CREATE UNIQUE INDEX "UQ_referral_code_not_deleted" ON public.referrals USING btree (code, status) WHERE ('status'::text = ANY (ARRAY['active'::text, 'inactive'::text]));


--
-- Name: nfts FK-nft-project; Type: FK CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.nfts
    ADD CONSTRAINT "FK-nft-project" FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: users FK-users-referral; Type: FK CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "FK-users-referral" FOREIGN KEY (referral_id) REFERENCES public.referrals(id);


--
-- Name: admin_user_credentials FK_140463aba33bb2fa8918cd2bce7; Type: FK CONSTRAINT; Schema: public; Owner: metafarm_user
--

ALTER TABLE ONLY public.admin_user_credentials
    ADD CONSTRAINT "FK_140463aba33bb2fa8918cd2bce7" FOREIGN KEY (admin_user_id) REFERENCES public.admin_users(id);


--
-- PostgreSQL database dump complete
--

