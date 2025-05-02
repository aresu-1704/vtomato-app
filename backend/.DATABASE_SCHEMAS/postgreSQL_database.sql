CREATE USER tomato_user WITH PASSWORD 'TomatoPassword123!';

CREATE DATABASE tomato_disease_app
    WITH
    OWNER = tomato_user
    ENCODING = 'UTF8'
    LC_COLLATE = 'Vietnamese_Vietnam.1258'
    LC_CTYPE = 'Vietnamese_Vietnam.1258'
    LOCALE_PROVIDER = 'libc'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

CREATE TABLE IF NOT EXISTS public.disease_info
(
    diseaseid integer NOT NULL,
    diseasename character varying(100) COLLATE pg_catalog."default" NOT NULL,
    cause text COLLATE pg_catalog."default",
    symptoms text COLLATE pg_catalog."default",
    conditions text COLLATE pg_catalog."default",
    treatment text COLLATE pg_catalog."default",
    CONSTRAINT disease_info_pkey PRIMARY KEY (diseaseid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.disease_info
    OWNER to tomato_user;

CREATE TABLE IF NOT EXISTS public.login_info
(
    userid integer NOT NULL DEFAULT nextval('login_info_userid_seq'::regclass),
    email character varying(255) COLLATE pg_catalog."default" NOT NULL,
    passwordhash character varying(255) COLLATE pg_catalog."default" NOT NULL,
    salt character varying(255) COLLATE pg_catalog."default" NOT NULL,
    phonenumber character varying(20) COLLATE pg_catalog."default" NOT NULL,
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    isactive boolean DEFAULT true,
    CONSTRAINT login_info_pkey PRIMARY KEY (userid),
    CONSTRAINT login_info_email_key UNIQUE (email)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.login_info
    OWNER to tomato_user;

CREATE TABLE IF NOT EXISTS public.prediction_boxes
(
    predictionid integer NOT NULL,
    diseaseid integer NOT NULL,
    CONSTRAINT prediction_boxes_pkey PRIMARY KEY (predictionid, diseaseid),
    CONSTRAINT prediction_boxes_diseaseid_fkey FOREIGN KEY (diseaseid)
        REFERENCES public.disease_info (diseaseid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT prediction_boxes_predictionid_fkey FOREIGN KEY (predictionid)
        REFERENCES public.prediction_history (predictionid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.prediction_boxes
    OWNER to tomato_user;

CREATE TABLE IF NOT EXISTS public.prediction_history
(
    predictionid integer NOT NULL DEFAULT nextval('prediction_history_predictionid_seq'::regclass),
    userid integer NOT NULL,
    imagepath character varying(500) COLLATE pg_catalog."default" NOT NULL,
    predictedat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT prediction_history_pkey PRIMARY KEY (predictionid),
    CONSTRAINT prediction_history_userid_fkey FOREIGN KEY (userid)
        REFERENCES public.login_info (userid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.prediction_history
    OWNER to tomato_user;

CREATE SEQUENCE IF NOT EXISTS public.login_info_userid_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.login_info_userid_seq
    OWNED BY public.login_info.userid;

ALTER SEQUENCE public.login_info_userid_seq
    OWNER TO tomato_user;

CREATE SEQUENCE IF NOT EXISTS public.prediction_history_predictionid_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.prediction_history_predictionid_seq
    OWNED BY public.prediction_history.predictionid;

ALTER SEQUENCE public.prediction_history_predictionid_seq
    OWNER TO tomato_user;

CREATE OR REPLACE FUNCTION public.sp_createaccount(
	in_email character varying,
	in_passwordhash character varying,
	in_salt character varying,
	in_phonenumber character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM Login_Info WHERE Email = in_email) THEN
        RETURN 'Email already exists.';
    ELSE
        INSERT INTO Login_Info (Email, PasswordHash, Salt, PhoneNumber)
        VALUES (in_email, in_passwordhash, in_salt, in_phonenumber);
         RETURN 'Account created successfully.';
    END IF;
END;
$BODY$;

ALTER FUNCTION public.sp_createaccount(character varying, character varying, character varying, character varying)
    OWNER TO tomato_user;


CREATE OR REPLACE FUNCTION public.sp_findphonenumberbyemail(
	in_email character varying)
    RETURNS TABLE(phonenumber character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY SELECT li.PhoneNumber FROM Login_Info li WHERE Email = in_email;
END;
$BODY$;

ALTER FUNCTION public.sp_findphonenumberbyemail(character varying)
    OWNER TO tomato_user;

CREATE OR REPLACE FUNCTION public.sp_getdiseasehistorybyid(
	in_userid integer)
    RETURNS TABLE(predictionid integer, imagepath character varying, predictedat timestamp without time zone, diseasename character varying, cause text, symptoms text, conditions text, treatment text)
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
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
$BODY$;

ALTER FUNCTION public.sp_getdiseasehistorybyid(integer)
    OWNER TO tomato_user;

CREATE OR REPLACE FUNCTION public.sp_getdiseaseinfo(
	in_diseaseid integer)
    RETURNS TABLE(diseasename character varying, cause text, symptoms text, conditions text, treatment text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT di.DiseaseName, di.Cause, di.Symptoms, di.Conditions, di.Treatment
    FROM Disease_Info di
    WHERE DiseaseID = in_diseaseid;
END;
$BODY$;

ALTER FUNCTION public.sp_getdiseaseinfo(integer)
    OWNER TO tomato_user;

CREATE OR REPLACE FUNCTION public.sp_getpasswordinfobyemail(
	in_email character varying)
    RETURNS TABLE(userid integer, passwordhash character varying, salt character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT li.UserID, li.PasswordHash, li.Salt
    FROM Login_Info li
    WHERE li.Email = in_email AND li.IsActive = TRUE;
END;
$BODY$;

ALTER FUNCTION public.sp_getpasswordinfobyemail(character varying)
    OWNER TO tomato_user;

CREATE OR REPLACE FUNCTION public.sp_insertpredictiondetail(
	in_predictionid integer,
	in_diseaseid integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO Prediction_Boxes (PredictionID, DiseaseID)
    VALUES (in_predictionid, in_diseaseid);
END;
$BODY$;

ALTER FUNCTION public.sp_insertpredictiondetail(integer, integer)
    OWNER TO tomato_user;

CREATE OR REPLACE FUNCTION public.sp_insertpredictionhistory(
	in_userid integer,
	in_imagepath character varying,
	OUT new_predictionid integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO Prediction_History (UserID, ImagePath)
    VALUES (in_userid, in_imagepath)
    RETURNING PredictionID INTO new_predictionid;
END;
$BODY$;

ALTER FUNCTION public.sp_insertpredictionhistory(integer, character varying)
    OWNER TO tomato_user;

CREATE OR REPLACE FUNCTION public.sp_resetpassword(
	in_email character varying,
	in_newpasswordhash character varying,
	in_salt character varying,
	OUT result_message character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    check_exists BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM Login_Info WHERE Email = in_email AND IsActive = TRUE
    ) INTO check_exists;

    IF NOT check_exists THEN
        result_message := 'Email not found or account is not active.';
        RETURN;
    END IF;

    UPDATE Login_Info
    SET PasswordHash = in_newpasswordhash, Salt = in_salt
    WHERE Email = in_email;

    result_message := 'Password reset successfully.';
END;
$BODY$;

ALTER FUNCTION public.sp_resetpassword(character varying, character varying, character varying)
    OWNER TO tomato_user;

ALTER TABLE IF EXISTS public.disease_info
    ADD CONSTRAINT disease_info_pkey PRIMARY KEY (diseaseid);

ALTER TABLE IF EXISTS public.login_info
    ADD CONSTRAINT login_info_email_key UNIQUE (email);

ALTER TABLE IF EXISTS public.login_info
    ADD CONSTRAINT login_info_pkey PRIMARY KEY (userid);

ALTER TABLE IF EXISTS public.prediction_boxes
    ADD CONSTRAINT prediction_boxes_diseaseid_fkey FOREIGN KEY (diseaseid)
    REFERENCES public.disease_info (diseaseid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.prediction_boxes
    ADD CONSTRAINT prediction_boxes_pkey PRIMARY KEY (predictionid, diseaseid);

ALTER TABLE IF EXISTS public.prediction_boxes
    ADD CONSTRAINT prediction_boxes_predictionid_fkey FOREIGN KEY (predictionid)
    REFERENCES public.prediction_history (predictionid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.prediction_history
    ADD CONSTRAINT prediction_history_pkey PRIMARY KEY (predictionid);

ALTER TABLE IF EXISTS public.prediction_history
    ADD CONSTRAINT prediction_history_userid_fkey FOREIGN KEY (userid)
    REFERENCES public.login_info (userid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;


INSERT INTO Disease_Info (DiseaseID, DiseaseName, Cause, Symptoms, Conditions, Treatment) VALUES (0, N'Đốm nâu', N'Bệnh do nấm Alternaria solani gây ra. Nấm này tồn tại trong tàn dư cây bệnh, đất và có thể lây lan qua hạt giống hoặc cây giống nhiễm bệnh. Bào tử nấm được phát tán qua nước mưa hoặc gió, xâm nhập vào cây qua các vết thương hoặc bề mặt lá.', N'Bệnh bắt đầu xuất hiện trên lá già dưới gốc với các đốm nhỏ màu nâu hoặc đen, có viền vàng. Các đốm này thường có hình tròn hoặc hình bầu dục, với đường kính khoảng 6–12 mm, và có thể có các vòng đồng tâm. Lá bị nhiễm bệnh sẽ vàng và rụng sớm, dẫn đến giảm khả năng quang hợp và năng suất cây trồng. Trái cà chua có thể bị nứt hoặc có vết thối ở cuống do nấm xâm nhập.', N'Bệnh phát triển mạnh trong điều kiện thời tiết ấm áp và ẩm ướt, với nhiệt độ tối ưu từ 28–30°C. Mưa nhiều, độ ẩm cao và tưới nước bằng phương pháp phun mưa tạo điều kiện thuận lợi cho sự phát triển của nấm. Mật độ trồng dày và thông thoáng kém cũng làm tăng nguy cơ nhiễm bệnh.', N'Để điều trị hiệu quả bệnh đốm vòng sớm (Early Blight) trên cây cà chua, cần áp dụng đồng bộ các biện pháp canh tác, sinh học và hóa học. Trước tiên, nên sử dụng giống cà chua có khả năng kháng bệnh và thực hiện luân canh với các cây không thuộc họ Cà để giảm nguồn bệnh tồn tại trong đất . Vệ sinh đồng ruộng bằng cách thu gom và tiêu hủy tàn dư cây bệnh sau thu hoạch, đồng thời cắt bỏ lá gốc và lá bị nhiễm bệnh trong quá trình sinh trưởng để hạn chế sự lây lan của nấm . Áp dụng hệ thống tưới nhỏ giọt thay vì tưới phun mưa nhằm giảm độ ẩm trên lá, kết hợp với việc phủ gốc bằng rơm rạ hoặc vật liệu hữu cơ để ngăn bào tử nấm bắn lên lá . Về biện pháp hóa học, khi bệnh mới xuất hiện, có thể sử dụng các loại thuốc trừ nấm chứa hoạt chất như chlorothalonil, mancozeb, azoxystrobin hoặc difenoconazole, phun luân phiên theo hướng dẫn để đạt hiệu quả cao . Ngoài ra, các chế phẩm sinh học chứa vi khuẩn Bacillus subtilis hoặc dung dịch baking soda kết hợp với phân đạm cá cũng có thể được sử dụng để kiểm soát bệnh một cách an toàn và thân thiện với môi trường .');
INSERT INTO Disease_Info (DiseaseID, DiseaseName, Cause, Symptoms, Conditions, Treatment) VALUES (2, N'Sương mai', N'Bệnh sương mai trên cà chua do nấm Phytophthora infestans gây ra – đây cũng chính là tác nhân gây ra bệnh sương mai khoai tây. Loại nấm này có thể tồn tại trong đất, tàn dư thực vật hoặc lan truyền qua không khí và nước mưa. Khi gặp điều kiện thuận lợi, bào tử nấm phát tán rất nhanh và có thể lây lan trên diện rộng.', N'Bệnh sương mai trên cà chua do nấm Phytophthora infestans gây ra – đây cũng chính là tác nhân gây ra bệnh sương mai khoai tây. Loại nấm này có thể tồn tại trong đất, tàn dư thực vật hoặc lan truyền qua không khí và nước mưa. Khi gặp điều kiện thuận lợi, bào tử nấm phát tán rất nhanh và có thể lây lan trên diện rộng.', N'Bệnh phát triển mạnh trong điều kiện thời tiết mát mẻ và ẩm ướt, đặc biệt khi nhiệt độ dao động từ 15–25°C, độ ẩm cao, có mưa phùn hoặc sương mù kéo dài. Các vùng trồng cà chua trong mùa mưa hoặc thiếu thông thoáng là môi trường lý tưởng để bệnh bùng phát nhanh chóng.', N'Cần kiểm tra đồng ruộng thường xuyên để phát hiện sớm và tiêu hủy các cây bị bệnh. Áp dụng luân canh với các cây trồng không cùng họ cà (Solanaceae) để cắt đứt vòng đời nấm bệnh. Sử dụng các loại thuốc hóa học như Mancozeb, Metalaxyl, Chlorothalonil hoặc các chế phẩm sinh học như nấm đối kháng Trichoderma. Ngoài ra, cần đảm bảo khoảng cách trồng hợp lý, tỉa bớt lá già, không tưới vào chiều tối và hạn chế tưới nước lên lá để giảm độ ẩm.');
INSERT INTO Disease_Info (DiseaseID, DiseaseName, Cause, Symptoms, Conditions, Treatment) VALUES (3, N'Sâu đục lá', N'Sâu đục lá cà chua (tên khoa học: Tuta absoluta) là một loài sâu hại nguy hiểm có nguồn gốc từ Nam Mỹ và hiện đã lan rộng đến nhiều nước trên thế giới, bao gồm cả Việt Nam. Ấu trùng của loài này gây hại chính bằng cách chui vào và đục lá, thân, hoa, và cả quả cà chua. Chúng có khả năng sinh sản rất nhanh, mỗi con cái có thể đẻ đến 250–300 trứng trong vòng đời của nó, khiến mức độ phá hoại rất lớn nếu không được kiểm soát kịp thời.', N'Triệu chứng điển hình là sự xuất hiện của các đường đục ngoằn ngoèo hoặc khoang trống nhỏ bên trong lá cà chua. Lá bị hại sẽ bị héo khô dần, biến màu vàng hoặc nâu. Trên quả, sâu để lại các lỗ nhỏ và vết thối, làm giảm chất lượng nghiêm trọng. Trong điều kiện nặng, cây có thể còi cọc, năng suất sụt giảm mạnh và dễ bị chết cây non.', N'Sâu phát triển mạnh trong điều kiện thời tiết ấm, khô và ít mưa, đặc biệt từ 20°C đến 30°C. Vụ Đông Xuân và Xuân Hè là giai đoạn thuận lợi cho sâu phát triển. Vườn trồng dày, thiếu thông thoáng, hoặc canh tác liên tục cà chua trong nhiều vụ không luân canh cũng là điều kiện lý tưởng cho sâu phát sinh, lây lan và tồn tại dai dẳng.', N'Để phòng và trị sâu đục lá cà chua hiệu quả, cần áp dụng tổng hợp nhiều biện pháp. Trước hết là biện pháp canh tác như luân canh cây trồng với những cây không thuộc họ cà (Solanaceae), vệ sinh đồng ruộng, thu gom và tiêu huỷ lá bị hại, tỉa lá già để hạn chế nơi trú ngụ của sâu. Kết hợp với đó là biện pháp sinh học như sử dụng ong ký sinh (Trichogramma spp.), bọ bắt mồi và bẫy pheromone để bắt sâu trưởng thành. Ngoài ra, có thể áp dụng biện pháp cơ học như đặt bẫy dính màu vàng, bẫy ánh sáng để giảm mật độ sâu. Khi mật độ sâu cao, cần sử dụng thuốc hóa học như Emamectin benzoate, Abamectin hoặc Spinosad, chú ý luân phiên hoạt chất để tránh kháng thuốc và phun đúng thời điểm sáng sớm hoặc chiều mát, tập trung vào mặt dưới lá – nơi sâu thường cư trú. Việc kết hợp đồng bộ các biện pháp trên sẽ giúp kiểm soát sâu đục lá hiệu quả và bền vững.');
INSERT INTO Disease_Info (DiseaseID, DiseaseName, Cause, Symptoms, Conditions, Treatment) VALUES (4, N'Mốc lá', N'Bệnh mốc lá cà chua do nấm Passalora fulva (tên cũ: Cladosporium fulvum) gây ra. Nấm này thường tồn tại và phát tán qua bào tử trong không khí, đất, hoặc trên bề mặt lá và tàn dư thực vật. Khi gặp điều kiện thuận lợi, bào tử sẽ nảy mầm và xâm nhập qua khí khổng trên lá để gây bệnh.', N'Ban đầu, các đốm nhỏ màu vàng xuất hiện ở mặt trên của lá, sau đó lan rộng và chuyển thành màu nâu nhạt hoặc nâu xám. Ở mặt dưới lá, ngay vị trí đốm bệnh, xuất hiện một lớp mốc nhung màu xám ô liu hoặc xanh xám – đây là đặc trưng nổi bật của bệnh. Lá bị bệnh sẽ héo và rụng sớm, làm giảm khả năng quang hợp và ảnh hưởng nghiêm trọng đến năng suất trái.', N'Bệnh phát triển mạnh trong điều kiện môi trường ẩm ướt, đặc biệt là trong nhà lưới hoặc nhà màng có độ ẩm cao (>85%) và nhiệt độ mát từ 18–25°C. Tưới nước vào chiều tối hoặc mật độ trồng dày, kém thông thoáng sẽ tạo điều kiện thuận lợi cho bệnh bùng phát nhanh chóng.', N'Cần cắt tỉa lá già, giữ khoảng cách trồng hợp lý để tạo sự thông thoáng. Không tưới nước lên lá, đặc biệt vào chiều tối. Khi phát hiện bệnh, phun các loại thuốc đặc trị nấm như Mancozeb, Chlorothalonil, Copper oxychloride, hoặc kết hợp với các chế phẩm sinh học chứa Trichoderma. Vệ sinh vườn kỹ lưỡng sau mỗi vụ trồng và luân canh với cây khác họ để hạn chế nguồn bệnh tồn dư.');
INSERT INTO Disease_Info (DiseaseID, DiseaseName, Cause, Symptoms, Conditions, Treatment) VALUES (5, N'Virus khảm lá', N'Bệnh khảm cà chua do virus gây ra, phổ biến nhất là virus khảm thuốc lá (Tobacco Mosaic Virus – TMV), virus khảm cà chua (Tomato Mosaic Virus – ToMV) và một số loại khác như CMV. Virus lan truyền qua hạt giống, tàn dư cây bệnh, công cụ làm vườn, và đặc biệt là qua côn trùng chích hút như rầy mềm (aphids).', N'Lá cà chua nhiễm virus sẽ có hiện tượng biến màu thành từng mảng xanh đậm – xanh nhạt xen kẽ, tạo vân giống như vết khảm. Lá thường bị xoăn, biến dạng hoặc nhỏ lại. Cây bị bệnh phát triển kém, còi cọc, đậu trái ít hoặc trái nhỏ, méo mó, mất giá trị thương phẩm. Nếu nhiễm sớm, cây có thể không ra hoa hoặc không đậu quả.', N'Bệnh dễ phát sinh trong điều kiện nhiệt độ cao, ánh sáng mạnh, và đặc biệt là khi cây sinh trưởng kém hoặc bị stress. Vườn trồng dày, thiếu thông thoáng, sử dụng hạt giống không sạch bệnh hoặc không kiểm soát côn trùng cũng góp phần làm bệnh lây lan nhanh chóng.', N'Hiện chưa có thuốc đặc trị virus, nên phòng bệnh là chủ yếu. Cần sử dụng hạt giống sạch bệnh, xử lý hạt bằng nước nóng hoặc thuốc sát khuẩn trước khi gieo. Vệ sinh vườn sạch sẽ, tiêu hủy cây bệnh, khử trùng dụng cụ làm vườn. Kiểm soát côn trùng truyền bệnh bằng bẫy vàng hoặc thuốc trừ sâu sinh học. Ngoài ra, có thể sử dụng các chế phẩm tăng sức đề kháng như nano bạc, acid humic để hỗ trợ cây chống lại virus.');
INSERT INTO Disease_Info (DiseaseID, DiseaseName, Cause, Symptoms, Conditions, Treatment) VALUES (6, N'Đốm lá Septoria', N'Bệnh do nấm Septoria lycopersici gây ra. Nấm này tồn tại trong tàn dư cây bệnh, đất và có thể lây lan qua nước mưa, gió, côn trùng hoặc dụng cụ làm vườn bị nhiễm bào tử nấm .', N'Bệnh thường xuất hiện đầu tiên trên các lá già gần gốc cây với các đốm nhỏ, tròn, màu nâu xám, có viền sẫm màu. Các đốm này dần lan rộng, hợp nhất, khiến lá chuyển vàng và rụng sớm, làm giảm khả năng quang hợp và ảnh hưởng đến năng suất cây trồng .​', N'Bệnh phát triển mạnh trong điều kiện thời tiết ẩm ướt, nhiệt độ từ 15–27°C, đặc biệt khi có mưa nhiều hoặc tưới nước bằng phương pháp phun mưa. Mật độ trồng dày và thông khí kém cũng tạo điều kiện thuận lợi cho bệnh lây lan .', N'Để điều trị bệnh đốm lá Septoria trên cây cà chua, cần áp dụng đồng bộ các biện pháp phòng trừ cả hóa học, sinh học và canh tác. Trước tiên, nên sử dụng giống cà chua sạch bệnh và có khả năng kháng hoặc chịu đựng bệnh đốm lá Septoria. Trong quá trình trồng, cần đảm bảo mật độ cây hợp lý, tạo khoảng cách thông thoáng giữa các cây để giảm độ ẩm trên lá, đồng thời tránh tưới nước lên lá bằng phương pháp phun mưa; thay vào đó, sử dụng hệ thống tưới nhỏ giọt để hạn chế sự phát triển của nấm. Khi phát hiện lá bị nhiễm bệnh, cần loại bỏ và tiêu hủy ngay để ngăn ngừa sự lây lan. Ngoài ra, việc luân canh cây trồng với các cây không thuộc họ Cà giúp giảm nguồn bệnh tồn tại trong đất. Về biện pháp hóa học, có thể sử dụng các loại thuốc trừ nấm chứa hoạt chất như chlorothalonil, mancozeb hoặc azoxystrobin. Cần phun thuốc theo đúng liều lượng và thời gian hướng dẫn để đạt hiệu quả cao. Việc áp dụng đồng bộ các biện pháp trên sẽ giúp kiểm soát hiệu quả bệnh đốm lá Septoria, bảo vệ cây cà chua và nâng cao năng suất.​');
INSERT INTO Disease_Info (DiseaseID, DiseaseName, Cause, Symptoms, Conditions, Treatment) VALUES (7, N'Nhện đỏ ăn lá', N'Bệnh nhện đỏ trên cây cà chua, chủ yếu do loài nhện Tetranychus urticae gây ra, là một vấn đề nghiêm trọng trong điều kiện thời tiết nóng và khô. Nhện đỏ hút nhựa từ lá, làm lá chuyển màu vàng, khô héo và có thể dẫn đến rụng lá sớm. Chúng thường xuất hiện ở mặt dưới của lá, tạo ra mạng nhện mỏng và khó phát hiện nếu không kiểm tra kỹ.​', N'Triệu chứng ban đầu của bệnh nhện đỏ bao gồm các đốm nhỏ màu trắng hoặc vàng trên lá, tạo nên hiện tượng lốm đốm hoặc mốc trắng. Khi mật độ nhện tăng cao, lá cây có thể chuyển sang màu đồng hoặc bạc, trở nên giòn và dễ rụng. Ngoài ra, mạng nhện mỏng do nhện tạo ra có thể bao phủ mặt dưới của lá, cành và cả quả, làm giảm khả năng quang hợp và ảnh hưởng đến năng suất cây trồng.', N'Bệnh nhện đỏ phát triển mạnh trong điều kiện thời tiết nóng, khô và nhiều bụi, đặc biệt vào mùa hè. Cây trồng bị stress do thiếu nước, dinh dưỡng kém hoặc bị sâu bệnh khác cũng dễ bị nhện đỏ tấn công hơn. Môi trường khô hạn và thiếu độ ẩm tạo điều kiện thuận lợi cho nhện đỏ sinh sôi và lây lan nhanh chóng.', N'Để điều trị hiệu quả, cần áp dụng kết hợp các biện pháp canh tác, sinh học và hóa học. Trước tiên, nên duy trì độ ẩm thích hợp và vệ sinh vườn sạch sẽ để hạn chế môi trường thuận lợi cho nhện đỏ phát triển. Có thể sử dụng vòi nước mạnh để rửa trôi nhện đỏ khỏi cây. Ngoài ra, việc sử dụng dầu neem hoặc xà phòng diệt côn trùng cũng giúp kiểm soát nhện đỏ hiệu quả. Trong trường hợp nhiễm nặng, có thể sử dụng các loại thuốc trừ nhện chuyên dụng như abamectin, bifenazate hoặc spiromesifen, tuân thủ đúng liều lượng và thời gian phun để đạt hiệu quả cao. Việc áp dụng đồng bộ các biện pháp trên sẽ giúp kiểm soát hiệu quả bệnh nhện đỏ, bảo vệ cây cà chua và nâng cao năng suất.​');
INSERT INTO Disease_Info (DiseaseID, DiseaseName, Cause, Symptoms, Conditions, Treatment) VALUES (8, N'Xoăn vàng lá', N'Bệnh chủ yếu do virus Tomato yellow leaf curl virus (TYLCV) gây ra, thuộc chi Begomovirus trong họ Geminiviridae. Virus này lây lan qua môi giới truyền bệnh chính là bọ phấn trắng (Bemisia tabaci) và bọ trĩ .​', N'Xoăn vàng lá cà chua là một bệnh nguy hiểm do virus gây ra, thường được truyền bởi bọ phấn trắng. Cây bị bệnh thường có biểu hiện lá non bị xoăn lại, biến dạng và chuyển sang màu vàng, nhất là ở phần ngọn. Lá thường nhỏ lại, mọc chen chúc và khô giòn, cây chậm phát triển, còi cọc và ít ra hoa hoặc không đậu trái. Nếu bệnh nặng, toàn cây có thể bị vàng úa, không phát triển được, ảnh hưởng nghiêm trọng đến năng suất và chất lượng quả. Bệnh thường xuất hiện sớm từ giai đoạn cây con và lan nhanh nếu không được kiểm soát kịp thời.', N'Bệnh xoăn vàng lá cà chua (Tomato Yellow Leaf Curl Virus – TYLCV) thường phát triển mạnh trong điều kiện nhiệt độ cao, độ ẩm từ 30–80%, đặc biệt trong môi trường ấm áp và ẩm ướt. Đây là môi trường lý tưởng cho sự sinh sôi của bọ phấn trắng (Bemisia tabaci) – tác nhân chính truyền virus TYLCV. Việc trồng cà chua liên tục trên cùng một diện tích mà không luân canh với các loại cây trồng khác làm tăng nguy cơ tích tụ mầm bệnh trong đất và môi trường xung quanh, tạo điều kiện cho virus tồn tại và lây lan qua các vụ mùa. Sử dụng cây giống đã nhiễm virus hoặc mang mầm bệnh mà chưa biểu hiện triệu chứng rõ ràng có thể là nguồn lây lan bệnh sang các cây khỏe mạnh. Cây cà chua ở giai đoạn non (dưới 4 tuần tuổi) dễ bị nhiễm virus hơn và khi nhiễm bệnh ở giai đoạn này, cây thường bị ảnh hưởng nghiêm trọng hơn về sinh trưởng và năng suất. ', N'​Để phòng trừ hiệu quả bệnh xoăn vàng lá cà chua (Tomato Yellow Leaf Curl Virus – TYLCV), cần áp dụng tổng hợp các biện pháp canh tác, sinh học và hóa học. Trước tiên, nên sử dụng các giống cà chua có khả năng kháng hoặc chịu đựng virus TYLCV để giảm nguy cơ nhiễm bệnh. Việc vệ sinh đồng ruộng, loại bỏ tàn dư cây trồng vụ trước và cỏ dại – đặc biệt là các cây thuộc họ Cà như cà chua, thuốc lá, khoai tây – giúp loại bỏ nguồn bệnh tiềm ẩn. Luân canh với các cây không phải là ký chủ của virus, như các loại cây họ bầu bí, cũng là một biện pháp hiệu quả để ngăn ngừa sự lây lan của bệnh. Để kiểm soát bọ phấn trắng, tác nhân truyền bệnh chính, có thể sử dụng bẫy dính màu vàng để giám sát và giảm mật độ quần thể, kết hợp với việc phun các loại thuốc bảo vệ thực vật phù hợp theo nguyên tắc 4 đúng (đúng thuốc, đúng liều lượng, đúng thời điểm, đúng cách). Ngoài ra, việc che phủ luống ươm bằng lưới chống côn trùng và trồng xen canh với các cây không mẫn cảm với bệnh như bí hoặc dưa chuột cũng giúp hạn chế sự tiếp xúc của bọ phấn với cây trồng. Khi phát hiện cây bị nhiễm bệnh, cần nhổ bỏ và tiêu hủy ngay để tránh lây lan sang các cây khỏe mạnh. Việc áp dụng đồng bộ các biện pháp trên sẽ góp phần bảo vệ cây cà chua khỏi bệnh xoăn vàng lá và duy trì năng suất ổn định.');

