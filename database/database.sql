--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

-- Started on 2025-06-01 15:03:02

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
-- TOC entry 223 (class 1255 OID 16390)
-- Name: sp_createaccount(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: tomato_user
--

CREATE FUNCTION public.sp_createaccount(in_email character varying, in_passwordhash character varying, in_salt character varying, in_phonenumber character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Login_Info WHERE Email = in_email) THEN
        RETURN 'Email already exists.';
    ELSE
        INSERT INTO Login_Info (Email, PasswordHash, Salt, PhoneNumber)
        VALUES (in_email, in_passwordhash, in_salt, in_phonenumber);
         RETURN 'Account created successfully.';
    END IF;
END;
$$;


ALTER FUNCTION public.sp_createaccount(in_email character varying, in_passwordhash character varying, in_salt character varying, in_phonenumber character varying) OWNER TO tomato_user;

--
-- TOC entry 224 (class 1255 OID 16391)
-- Name: sp_getdiseasehistorybyid(integer); Type: FUNCTION; Schema: public; Owner: tomato_user
--

CREATE FUNCTION public.sp_getdiseasehistorybyid(in_userid integer) RETURNS TABLE(predictionid integer, imagepath character varying, predictedat timestamp without time zone, diseasename character varying, cause text, symptoms text, conditions text, treatment text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        PH.PredictionID, 
        PH.ImagePath, 
        PH.PredictedAt, 
        DI.DiseaseName, 
        DI.Cause, 
        DI.Symptoms, 
        DI.Conditions, 
        DI.Treatment
    FROM Prediction_History PH
    JOIN Prediction_Boxes PB ON PH.PredictionID = PB.PredictionID
    JOIN Disease_Info DI ON DI.DiseaseID = PB.DiseaseID
    WHERE PH.UserID = in_userid;
END;
$$;


ALTER FUNCTION public.sp_getdiseasehistorybyid(in_userid integer) OWNER TO tomato_user;

--
-- TOC entry 225 (class 1255 OID 16392)
-- Name: sp_getdiseaseinfo(integer); Type: FUNCTION; Schema: public; Owner: tomato_user
--

CREATE FUNCTION public.sp_getdiseaseinfo(in_diseaseid integer) RETURNS TABLE(diseasename character varying, cause text, symptoms text, conditions text, treatment text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT di.DiseaseName, di.Cause, di.Symptoms, di.Conditions, di.Treatment
    FROM Disease_Info di
    WHERE DiseaseID = in_diseaseid;
END;
$$;


ALTER FUNCTION public.sp_getdiseaseinfo(in_diseaseid integer) OWNER TO tomato_user;

--
-- TOC entry 226 (class 1255 OID 16393)
-- Name: sp_getpasswordinfobyemail(character varying); Type: FUNCTION; Schema: public; Owner: tomato_user
--

CREATE FUNCTION public.sp_getpasswordinfobyemail(in_email character varying) RETURNS TABLE(userid integer, passwordhash character varying, salt character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT li.UserID, li.PasswordHash, li.Salt
    FROM Login_Info li
    WHERE li.Email = in_email AND li.IsActive = TRUE;
END;
$$;


ALTER FUNCTION public.sp_getpasswordinfobyemail(in_email character varying) OWNER TO tomato_user;

--
-- TOC entry 230 (class 1255 OID 16394)
-- Name: sp_getuseridbyemail(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_getuseridbyemail(in_email character varying) RETURNS TABLE(userid integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT li.userid FROM login_info li WHERE email = in_email;
END;
$$;


ALTER FUNCTION public.sp_getuseridbyemail(in_email character varying) OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 16395)
-- Name: sp_insertpredictiondetail(integer, integer); Type: FUNCTION; Schema: public; Owner: tomato_user
--

CREATE FUNCTION public.sp_insertpredictiondetail(in_predictionid integer, in_diseaseid integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Prediction_Boxes (PredictionID, DiseaseID)
    VALUES (in_predictionid, in_diseaseid);
END;
$$;


ALTER FUNCTION public.sp_insertpredictiondetail(in_predictionid integer, in_diseaseid integer) OWNER TO tomato_user;

--
-- TOC entry 228 (class 1255 OID 16396)
-- Name: sp_insertpredictionhistory(integer, character varying); Type: FUNCTION; Schema: public; Owner: tomato_user
--

CREATE FUNCTION public.sp_insertpredictionhistory(in_userid integer, in_imagepath character varying, OUT new_predictionid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO Prediction_History (UserID, ImagePath)
    VALUES (in_userid, in_imagepath)
    RETURNING PredictionID INTO new_predictionid;
END;
$$;


ALTER FUNCTION public.sp_insertpredictionhistory(in_userid integer, in_imagepath character varying, OUT new_predictionid integer) OWNER TO tomato_user;

--
-- TOC entry 229 (class 1255 OID 16397)
-- Name: sp_resetpassword(integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: tomato_user
--

CREATE FUNCTION public.sp_resetpassword(in_user_id integer, in_newpasswordhash character varying, in_salt character varying, OUT result_message character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    check_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM Login_Info WHERE UserID = in_user_id AND IsActive = TRUE
    ) INTO check_exists;

    IF NOT check_exists THEN
        result_message := 'Email not found or account is not active.';
        RETURN;
    END IF;

    UPDATE Login_Info
    SET PasswordHash = in_newpasswordhash, Salt = in_salt
    WHERE UserID = in_user_id;

    result_message := 'Password reset successfully.';
END;
$$;


ALTER FUNCTION public.sp_resetpassword(in_user_id integer, in_newpasswordhash character varying, in_salt character varying, OUT result_message character varying) OWNER TO tomato_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 16398)
-- Name: disease_info; Type: TABLE; Schema: public; Owner: tomato_user
--

CREATE TABLE public.disease_info (
    diseaseid integer NOT NULL,
    diseasename character varying(100) NOT NULL,
    cause text,
    symptoms text,
    conditions text,
    treatment text
);


ALTER TABLE public.disease_info OWNER TO tomato_user;

--
-- TOC entry 218 (class 1259 OID 16403)
-- Name: login_info; Type: TABLE; Schema: public; Owner: tomato_user
--

CREATE TABLE public.login_info (
    userid integer NOT NULL,
    email character varying(255) NOT NULL,
    passwordhash character varying(255) NOT NULL,
    salt character varying(255) NOT NULL,
    phonenumber character varying(20) NOT NULL,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    isactive boolean DEFAULT true
);


ALTER TABLE public.login_info OWNER TO tomato_user;

--
-- TOC entry 219 (class 1259 OID 16410)
-- Name: login_info_userid_seq; Type: SEQUENCE; Schema: public; Owner: tomato_user
--

CREATE SEQUENCE public.login_info_userid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.login_info_userid_seq OWNER TO tomato_user;

--
-- TOC entry 4830 (class 0 OID 0)
-- Dependencies: 219
-- Name: login_info_userid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tomato_user
--

ALTER SEQUENCE public.login_info_userid_seq OWNED BY public.login_info.userid;


--
-- TOC entry 220 (class 1259 OID 16411)
-- Name: prediction_boxes; Type: TABLE; Schema: public; Owner: tomato_user
--

CREATE TABLE public.prediction_boxes (
    predictionid integer NOT NULL,
    diseaseid integer NOT NULL
);


ALTER TABLE public.prediction_boxes OWNER TO tomato_user;

--
-- TOC entry 221 (class 1259 OID 16414)
-- Name: prediction_history; Type: TABLE; Schema: public; Owner: tomato_user
--

CREATE TABLE public.prediction_history (
    predictionid integer NOT NULL,
    userid integer NOT NULL,
    imagepath character varying(500) NOT NULL,
    predictedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.prediction_history OWNER TO tomato_user;

--
-- TOC entry 222 (class 1259 OID 16420)
-- Name: prediction_history_predictionid_seq; Type: SEQUENCE; Schema: public; Owner: tomato_user
--

CREATE SEQUENCE public.prediction_history_predictionid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prediction_history_predictionid_seq OWNER TO tomato_user;

--
-- TOC entry 4831 (class 0 OID 0)
-- Dependencies: 222
-- Name: prediction_history_predictionid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tomato_user
--

ALTER SEQUENCE public.prediction_history_predictionid_seq OWNED BY public.prediction_history.predictionid;


--
-- TOC entry 4662 (class 2604 OID 16464)
-- Name: login_info userid; Type: DEFAULT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.login_info ALTER COLUMN userid SET DEFAULT nextval('public.login_info_userid_seq'::regclass);


--
-- TOC entry 4665 (class 2604 OID 16465)
-- Name: prediction_history predictionid; Type: DEFAULT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.prediction_history ALTER COLUMN predictionid SET DEFAULT nextval('public.prediction_history_predictionid_seq'::regclass);


--
-- TOC entry 4668 (class 2606 OID 16428)
-- Name: disease_info disease_info_pkey; Type: CONSTRAINT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.disease_info
    ADD CONSTRAINT disease_info_pkey PRIMARY KEY (diseaseid);


--
-- TOC entry 4670 (class 2606 OID 16430)
-- Name: login_info login_info_email_key; Type: CONSTRAINT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.login_info
    ADD CONSTRAINT login_info_email_key UNIQUE (email);


--
-- TOC entry 4672 (class 2606 OID 16432)
-- Name: login_info login_info_pkey; Type: CONSTRAINT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.login_info
    ADD CONSTRAINT login_info_pkey PRIMARY KEY (userid);


--
-- TOC entry 4674 (class 2606 OID 16434)
-- Name: prediction_boxes prediction_boxes_pkey; Type: CONSTRAINT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.prediction_boxes
    ADD CONSTRAINT prediction_boxes_pkey PRIMARY KEY (predictionid, diseaseid);


--
-- TOC entry 4676 (class 2606 OID 16436)
-- Name: prediction_history prediction_history_pkey; Type: CONSTRAINT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.prediction_history
    ADD CONSTRAINT prediction_history_pkey PRIMARY KEY (predictionid);


--
-- TOC entry 4677 (class 2606 OID 16437)
-- Name: prediction_boxes prediction_boxes_diseaseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.prediction_boxes
    ADD CONSTRAINT prediction_boxes_diseaseid_fkey FOREIGN KEY (diseaseid) REFERENCES public.disease_info(diseaseid);


--
-- TOC entry 4678 (class 2606 OID 16442)
-- Name: prediction_boxes prediction_boxes_predictionid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.prediction_boxes
    ADD CONSTRAINT prediction_boxes_predictionid_fkey FOREIGN KEY (predictionid) REFERENCES public.prediction_history(predictionid) ON DELETE CASCADE;


--
-- TOC entry 4679 (class 2606 OID 16447)
-- Name: prediction_history prediction_history_userid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: tomato_user
--

ALTER TABLE ONLY public.prediction_history
    ADD CONSTRAINT prediction_history_userid_fkey FOREIGN KEY (userid) REFERENCES public.login_info(userid) ON DELETE CASCADE;


-- Completed on 2025-06-01 15:03:03

--
-- PostgreSQL database dump complete
--

