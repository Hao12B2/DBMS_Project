CREATE DATABASE DBMS_QLDATPHONGKS
GO
USE DBMS_QLDATPHONGKS
GO
CREATE TABLE EMPLOYEE(
	Employee_id varchar(20) constraint PK_employee primary key, 
	Employee_name nvarchar(50) not null,
	Gender nvarchar(6),
	Birthday date check (DATEDIFF(year, Birthday, GETDATE())>=18), --Nhân viên phải trên 18 tuổi
	Identify_Card varchar(20) not null check(len(Identify_Card)=12), --CCCD đúng định dạng
	Phone varchar(12) not null check(len(Phone)=10), 
	Mail varchar(50) check(Mail like'%@gmail.com'),
	Employee_address nvarchar(255)
);

CREATE TABLE ACCOUNT(
	Username varchar(20) constraint PK_account primary key,
	Pass varchar(20) not null check(len(Pass)>=6),
	Role varchar(20),
	Employee_id varchar(20) constraint FK_employee references EMPLOYEE(Employee_id)
	ON DELETE CASCADE -- Xóa tài khoản nhân viên thì thông tin nhân viên đó cũng bị xóa
);

CREATE TABLE CUSTOMER(
	Customer_id varchar(20) constraint PK_customer primary key, 
	Customer_name nvarchar(50) not null,
	Gender nvarchar(6),
	Birthday date check (DATEDIFF(year, Birthday, GETDATE())>=18), --Khách hàng phải trên 18 tuổi
	Identify_card varchar(20) not null check(len(Identify_Card)=12) , --CCCD đúng định dạng
	Phone varchar(10) not null check(len(Phone)=10),
	Mail varchar(50) check(Mail like'%@gmail.com'),
	Customer_address nvarchar(255)
);

CREATE TABLE TYPE_ROOM(
	Type_room_id varchar(20) constraint PK_typeroom primary key,
	Type_room_name nvarchar(50),
	Unit money, --VND
	Discount_room float --phần trăm giảm giá tiền phòng
);

CREATE TABLE ROOM(
	Room_id varchar(20) constraint PK_room primary key,
	Room_status bit DEFAULT 0,
	Room_type varchar(20) constraint FK_room references TYPE_ROOM(Type_room_id)
);

CREATE TABLE SERVICE_ROOM(
	Service_room_id varchar(20) constraint PK_service_room primary key,
	Service_room_name nvarchar(100),
	Unit money, --VND
	Discount_service float --phần trăm giảm giá tiền dịch vụ
);

CREATE TABLE BILL(
	Bill_id varchar(20) constraint PK_bill primary key,
	Pay_time datetime, --Xác định đã thanh toán, pay_time chính là thời gian thanh toán hóa đơn
	Employee_id varchar(20) constraint FK references EMPLOYEE(Employee_id),
	Payment_method nvarchar(20), -- Phương thức thanh toán 
	Total_money money, --Tạo triggers tự động tính tổng tiền gộp số tiền dịch vụ và số tiền phòng, nhớ trừ ra
);

CREATE TABLE DETAILS_BILL(
	Details_bill_id varchar(20) constraint PK_details_bill primary key,
	Total_day int,
	Bill_id varchar(20) constraint FK_bill_id references BILL(Bill_id)
	ON DELETE CASCADE -- Khi khách hàng hủy đặt phòng hoặc k tới nhận phòng thì xóa Bill_ID và các dữ liệu liên quan đến BILL_id này đều bị xóa
);

CREATE TABLE DETAILS_RESERVED(
	Customer_id varchar(20) constraint FK_customer_id references CUSTOMER(Customer_id),
	Room_id varchar(20) constraint FK_room_id_reserved references ROOM(room_id),
	Details_bill_id varchar(20) constraint FK_details_bill_id_reserved references DETAILS_BILL(Details_bill_id)
	ON DELETE CASCADE, -- Khi khách hàng hủy đặt phòng hoặc k tới nhận phòng thì xóa Bill_ID và các dữ liệu liên quan đến BILL_id này đều bị
	Reserved_day int default 0,
	Date_check_in datetime, --Thời gian check-in phải có rõ ngày tháng năm giờ phút giây
	Constraint PK_details_reserved Primary Key (Customer_id, Room_id, Details_bill_id),
	Check_room_received bit DEFAULT 0, --Để xác định được đã tới nhận phòng hay chưa
	Deposit money, -- số tiền cọc 10% tiền phòng, nếu như thuê phòng trực tiếp thì deposit = null
	Check_paid_deposit bit, --Check xem đã trả tiền cọc hay chưa, nếu như thuê phòng trực tiếp thì = null 
	Date_create datetime,
);

CREATE TABLE DETAILS_USED_SERVICE(
	Room_id varchar(20) constraint FK_room_id_service references ROOM(Room_id),
	Details_bill_id varchar(20) constraint FK_details_bill_id_service references DETAILS_BILL(Details_bill_id)
	ON DELETE CASCADE,
	Service_room_id varchar(20) constraint FK_service_room_id references SERVICE_ROOM(Service_room_id),
	Number_of_service int default 0,
	Date_used datetime,
	Constraint FK_details_used_service Primary Key (Room_id, Details_bill_id, Service_room_id, Date_used)
);

--Bảng OFFICIAL_CUSTOMER cho biết khách hàng chính thức của khách sạn (checkin thành công)
CREATE TABLE OFFICIAL_CUSTOMER(
	Official_customer_id varchar(20) constraint PK_official_customer primary key, 
	Customer_name nvarchar(50) not null,
	Gender nvarchar(6),
	Birthday date check (DATEDIFF(year, Birthday, GETDATE())>=18), --Khách hàng phải trên 18 tuổi
	Identify_card varchar(20) not null check(len(Identify_Card)=12) , --CCCD đúng định dạng
	Phone varchar(10) not null check(len(Phone)=10),
	Mail varchar(50) check(Mail like'%@gmail.com'),
	Customer_address nvarchar(255)
);

-- Bảng TRACKING_LOG để ghi nhận lịch sử thay đổi đối với khách hàng chính thức hoặc xóa khách hàng nhằm tránh mất dữ liệu khách hàng đã từng đặt phòng
CREATE TABLE TRACKING_LOG(
	Id int DEFAULT 1 constraint PK_trackinglog primary key,
	Customer_id varchar(20) constraint FK_customer_id_trackinglog references OFFICIAL_CUSTOMER(Official_customer_id), 
	Customer_name nvarchar(50), 
	Identify_card varchar(20) not null check(len(Identify_Card)=12),
	Operation char(3),
	Updated_at datetime,
);

GO
INSERT INTO EMPLOYEE(Employee_id, Employee_name, Gender, Birthday, Identify_Card, Phone, Mail, Employee_address)
VALUES
('NV01', N'Nguyễn Văn Hào', 'Nam', '2003-10-09', '012345488233', '0352500861', 'haovan@gmail.com', 'HCM'),
('NV02', N'Nguyễn Phú Thành', 'Nam', '2003-05-15', '345673883233', '0126438487', 'thanh@gmail.com', 'HCM'),
('NV03', N'Lê Thúy An', N'Nữ', '1975-04-30', '864471718234', '0986421373', 'an@gmail.com', 'HCM'),
('NV04', N'Nguyễn Văn An', 'Nam', '1990-01-01', '123456789012', '0987654321', 'nva@gmail.com', N'Hà Nội'),
('NV05', N'Trần Thị Bống', 'Nữ', '1991-02-02', '234567890123', '0976543210', 'ttb@gmail.com', N'Hải Phòng'),
('NV06', N'Lê Văn Cường', 'Nam', '1992-03-03', '345678901234', '0965432109', 'lvc@gmail.com', N'Đà Nẵng'),
('NV07', N'Phạm Thị Dung', N'Nữ','1993-04-04','456789012345','0954321098','ptd@gmail.com', N'Huế'),
('NV08', N'Hoàng Văn Nam','Nam','1994-05-05','567890123456','0943210987','hve@gmail.com', N'Nha Trang'),
('NV09', N'Ngô Thị Phước', N'Nữ','1995-06-06','678901234567','0932109876','ntf@gmail.com', N'Cần Thơ')

GO
INSERT INTO ACCOUNT(Username, Pass, Employee_id, Role)
VALUES 
('hao123', '123456', 'NV01', 'Staff'),
('thanh234', '234567', 'NV02', 'Staff'),
('an345', '345678', 'NV03', 'Staff'),
('an456', '456789', 'NV04', 'Staff'),
('bong567', '567890', 'NV05', 'Staff'),
('cuong678', '678901', 'NV06', 'Staff'),
('dung789', '789012', 'NV07', 'Staff'),
('nam890', '890123', 'NV08', 'Sysadmin'),
('phuoc901','901234','NV09', 'Staff');

GO
INSERT INTO CUSTOMER(Customer_id, Customer_name, Gender, Birthday, Identify_card, Phone, Mail, Customer_address)
VALUES 
('KH0001', N'Vương Dinh Hiếu', 'Nam', '2003-01-01', '123483573817','0846362655','hieu@gmail.com','HCM'),
('KH0002', N'Võ Hoàng Bửu', 'Nam','2003-12-03', '012736736462','0123448344','buu@gmail.com', N'Quảng Ngãi'),
('KH0003', N'Lê Vân Bình','Nam','2001-03-03','345678912345','0932109876','binhle@gmail.com', N'Đà Nẵng'),
('KH0004', N'Trần Văn Dũng', 'Nam', '1999-05-05', '567891234567', '0910987654','dungtran@gmail.com', N'Hải Phòng'),
('KH0005', N'Nguyễn Thị Mai Hương', N'Nữ','1998-06-06','678912345678','0909876543','huongnguyen@gmail.com', N'Huế'),
('KH0006', N'Lê Thị Ngọc Anh', N'Nữ', '1996-08-08', '891234567890', '0908765432','ngocanhle@gmail.com',N'Cần Thơ'),
('KH0007', N'Nguyễn Văn Quang','Nam','1995-09-09','912345678901','0897654321','quangnguyen@gmail.com', N'Đà Lạt')

GO
INSERT INTO TYPE_ROOM(Type_room_id, Type_room_name, Unit, Discount_room)
VALUES
('STD', N'Phòng Standard', 375000, 0),
('SUP', N'Phòng Superior', 525000, 0.3),
('DLX', N'Phòng Deluxe', 885000, 0.15),
('SUT', N'Phòng Suite', 1999000, 0.25),
('CNT', N'Phòng Connecting', 1500000, 0),
('TWB', N'Phòng Twin Bed Room', 700000, 0),
('DOB', N'Phòng Double Bed Room', 445000, 0),
('TRB', N'Phòng Triple Bed Room', 900000, 0);

GO
INSERT INTO ROOM(Room_id, Room_status, Room_type)
VALUES
('STD001', '0', 'STD'),
('STD002', '0', 'STD'),
('STD003', '0', 'STD'),

('SUP001', '0', 'SUP'),
('SUP002', '0', 'SUP'),
('SUP003', '0', 'SUP'),

('DLX001', '0', 'DLX'),
('DLX002', '0', 'DLX'),
('DLX003', '0', 'DLX'),

('SUT001', '0', 'SUT'),
('SUT002', '0', 'SUT'),
('SUT003', '0', 'SUT'),

('CNT001', '0', 'CNT'),
('CNT002', '0', 'CNT'),
('CNT003', '0', 'CNT'),

('TWB001', '0', 'TWB'),
('TWB002', '0', 'TWB'),
('TWB003', '0', 'TWB'),

('DOB001', '0', 'DOB'),
('DOB002', '0', 'DOB'),
('DOB003', '0', 'DOB'),

('TRB001', '0', 'TRB'),
('TRB002', '0', 'TRB'),
('TRB003', '0', 'TRB');

GO
INSERT INTO SERVICE_ROOM(Service_room_id, Service_room_name, Unit, Discount_service)
VALUES
('SVC001', N'Giặt là', 40000, 0),
('SVC002', N'Spa', 450000, 0.2),
('SVC003', N'Thuê xe', 200000, 0.3),
('SVC004', N'Đưa đón sân bay', 200000, 0.1),
('SVC005', N'Buffet sáng', 300000, 0),
('SVC006', N'Hoa quả', 200000, 0),
('SVC007', N'Nước ngọt', 100000, 0);

GO
INSERT INTO BILL(Bill_id, Pay_time, Employee_id, Payment_method)
VALUES 
('Bill0001', '2023-03-17 11:50:00', 'NV01', N'Chuyển khoản'),
--('Bill0002', , , ), --  Xóa do kiểm tra ngày hiện tại quá hạn check in 12h hôm sau vẫn chưa nhận phòng
('Bill0003', '2023-03-18 11:35:00', 'NV03', N'Chuyển khoản'),
('Bill0004', '2023-03-18 8:35:00', 'NV04', N'Tiền mặt'),
('Bill0005', '2023-03-18 9:35:00', 'NV05', N'Chuyển khoản'),
('Bill0006', '2023-03-18 9:50:00', 'NV06', N'Tiền mặt'),
('Bill0007', '2023-03-18 11:05:00', 'NV07', N'Chuyển khoản');

GO
INSERT INTO DETAILS_BILL(Details_bill_id, Total_day, Bill_id)
VALUES
('Bill0001A', 1, 'Bill0001'), 
--('Bill0002A', 2, 'Bill0002'), -- Xóa do kiểm tra ngày hiện tại quá hạn check in 12h hôm sau vẫn chưa nhận phòng
('Bill0003A', 3, 'Bill0003'), 
('Bill0004A', 1, 'Bill0004'), 
('Bill0005A', 2, 'Bill0005'), 
('Bill0006A', 1, 'Bill0006'),
('Bill0007A', 1, 'Bill0007');

GO
INSERT INTO DETAILS_RESERVED(Customer_id, Room_id, Details_bill_id, Reserved_day, Date_check_in, Check_room_received, Check_paid_deposit, Date_create)
VALUES
('KH0001', 'STD001', 'Bill0001A', 1, '2023-03-16 8:00:00', '1', 1, '2023-03-14 19:00:00'),
--('KH0002', 'STD002', 'Bill0002A', 2, '2023-03-17 9:00:00', '0', 1, '2023-03-15 08:00:00'), --Xóa do kiểm tra ngày hiện tại quá hạn check in 12h hôm sau vẫn chưa nhận phòng
('KH0003', 'STD003', 'Bill0003A', 3, '2023-03-17 10:30:00', '1', 1, '2023-03-13 16:00:00'),

('KH0004', 'SUP001', 'Bill0004A', 1, '2023-03-17 8:30:00', '1', 1, '2023-03-14 18:00:00'),
('KH0005', 'SUP002', 'Bill0005A', 2, '2023-03-17 9:30:00', '1', 0, '2023-03-17 9:30:00'),
('KH0006', 'SUP003', 'Bill0006A', 1, '2023-03-17 9:45:00', '1', 0, '2023-03-17 9:45:00'),

('KH0007', 'DLX001', 'Bill0007A', 1, '2023-03-17 14:10:00', '1', 0, '2023-03-17 14:10:00');

GO
INSERT INTO DETAILS_USED_SERVICE(Room_id, Details_bill_id, Service_room_id, Number_of_service, Date_used)
VALUES 
('STD001','Bill0001A', 'SVC002', 1, '2023-03-16 15:15:00'),
--('STD002','Bill0002A', , , ), -- đặt cọc rồi mà quá hạn check in vẫn chưa nhận phòng
('STD003','Bill0003A', 'SVC001', 1, '2023-03-17 14:30:00'),

('SUP001','Bill0004A', 'SVC001', 1, '2023-03-17 16:30:00'),
('SUP002','Bill0005A', 'SVC001', 1, '2023-03-17 17:30:00'),
('SUP003','Bill0006A', 'SVC001', 1, '2023-03-17 14:45:00'),

('DLX001','Bill0007A', 'SVC001', 1, '2023-03-17 17:00:00');

GO
INSERT INTO OFFICIAL_CUSTOMER(Official_customer_id, Customer_name, Gender, Birthday, Identify_card, Phone, Mail, Customer_address)
VALUES
('KH0001', N'Vương Dinh Hiếu', 'Nam', '2003-01-01', '123483573817','0846362655','hieu@gmail.com','HCM'),
('KH0003', N'Lê Vân Bình','Nam','2001-03-03','345678912345','0932109876','binhle@gmail.com', N'Đà Nẵng'),
('KH0004', N'Trần Văn Dũng', 'Nam', '1999-05-05', '567891234567', '0910987654','dungtran@gmail.com', N'Hải Phòng'),
('KH0005', N'Nguyễn Thị Mai Hương', N'Nữ','1998-06-06','678912345678','0909876543','huongnguyen@gmail.com', N'Huế'),
('KH0006', N'Lê Thị Ngọc Anh', N'Nữ', '1996-08-08', '891234567890', '0908765432','ngocanhle@gmail.com',N'Cần Thơ'),
('KH0007', N'Nguyễn Văn Quang','Nam','1995-09-09','912345678901','0897654321','quangnguyen@gmail.com', N'Đà Lạt');

GO
INSERT INTO TRACKING_LOG 
VALUES
(1,	'KH0001', N'Vương Dinh Hiếu', '123483573817', 'INS', '2023-03-14 19:00:00.000'),
(3,	'KH0003', N'Lê Vân Bình', '345678912345', 'INS', '2023-03-13 16:00:00.000'),
(4,	'KH0004', N'Trần Văn Dũng', '567891234567', 'INS', '2023-03-14 18:00:00.000'),
(5,	'KH0005', N'Nguyễn Thị Mai Hương', '678912345678', 'INS', '2023-03-17 09:30:00.000'),
(6,	'KH0006', N'Lê Thị Ngọc Anh', '891234567890', 'INS', '2023-03-17 09:45:00.000'),
(7,	'KH0007', N'Nguyễn Văn Quang', '912345678901', 'INS', '2023-03-17 14:10:00.000');

GO

-------------- 1. Trigger cập nhật tình trạng phòng khi có người đặt
create trigger Update_status_room_reserved on Details_Reserved
after insert, update 
as
begin
	update Room
	set room_status = 1
	from Room
	where Room.room_id = (select room_id 
							from inserted 
							where Date_create = Date_check_in or inserted.Check_room_received = 'TRUE') 
end;

GO
-------------- 2. Trigger cập nhật tiền cọc phòng = 30% giá tiền phòng(đặt online)
create trigger Update_deposit on DETAILS_RESERVED
after insert
as
begin
	declare @deposit money, @date_create DateTime, @date_checkin DateTime, @details_bill_id varchar(20);

	select @date_create = Date_create, @date_checkin = Date_check_in, @details_bill_id = Details_bill_id from inserted;

    select @deposit = 0.3 * Unit
	from TYPE_ROOM tr 
	join ROOM r on tr.Type_room_id = r.Room_type
	join inserted ins on ins.Room_id = r.Room_id;

	--khi ngày tạo chi tiết đặt phòng khác với ngày check in thì đặt online -> cần tính cọc,
	--còn đặt offline thì ngày tạo chi tiết đặt phòng cũng là ngày check in luôn -> không cần cọc -> gán bằng 0
	if(@date_create <> @date_checkin)
		update DETAILS_RESERVED set Deposit = @deposit where DETAILS_RESERVED.Details_bill_id = @details_bill_id;
	else 
		update DETAILS_RESERVED set Deposit = 0 where DETAILS_RESERVED.Details_bill_id = @details_bill_id;
end;

GO
-------------- 3. Trigger tính tổng tiền cho hóa đơn khi cập nhật bảng chi tiết sử dụng dịch vụ(không cần bảng chi tiết đặt phòng vì mình
--đã có tổng số ngày ở rồi)
CREATE TRIGGER Calc_total_money_service ON DETAILS_USED_SERVICE 
AFTER INSERT, UPDATE
AS 
BEGIN 
--Khai báo biến
DECLARE @details_bill_id varchar(20), @money_service money, @disco float, @number_used_old int = 0, @number_used_new int;

-- Lấy mã chi tiết hóa đơn, số lượng sử dụng dịch vụ mới được cập nhật từ hàng vừa chèn
SELECT @details_bill_id = Details_bill_id, @number_used_new = Number_of_service FROM inserted

--Lấy số lượng sử dụng dịch vụ cũ vừa được xóa
select @number_used_old = Number_of_service from deleted where deleted.Details_bill_id = @details_bill_id;

--Tính tiền dịch vụ
SET @money_service = (SELECT  SUM(Unit * (@number_used_new - @number_used_old) * (1 - Discount_service) ) 
						FROM SERVICE_ROOM JOIN inserted ON SERVICE_ROOM.Service_room_id = inserted.Service_room_id
						WHERE inserted.Details_bill_id = @details_bill_id)

DECLARE @total_money_old money;
SELECT @total_money_old = Total_money FROM BILL WHERE Bill_id = (select Bill_id from DETAILS_BILL WHERE Details_bill_id = @details_bill_id)
-- Update the total_money in Bill table using details_bill_id 
UPDATE BILL 
SET Total_money = @total_money_old + @money_service
WHERE Bill_id = (SELECT bill_id 
					FROM Details_Bill 
					WHERE details_bill_id = @details_bill_id); 
END;

GO
-------------- 4. Trigger cập nhật trạng thái phòng thành 0 khi thanh toán
--Kiểm tra xem trong Bill mà ngày tạo khác null(đã thanh toán) thì kết bảng và đặt lại trạng thái phòng
create trigger Update_status_room_checkouted on Bill 
after update as
begin
    update Room
    set Room_status = 0
    where Room.room_id in ( select room_id
                            from Details_Reserved 
                            where details_bill_id in ( select Details_bill_id
                                                       from DETAILS_BILL
                                                       where DETAILS_BILL.Bill_id = (select Bill_id from inserted where inserted.Pay_time is not null) ) )
end;

GO
-------------- 5. Trigger cập nhật số ngày đã đặt trước cho tổng số ngày trong chi tiết hóa đơn khi đặt thành công hoặc gia hạn thành công
CREATE TRIGGER Update_total_day ON DETAILS_RESERVED
AFTER INSERT, UPDATE
AS
BEGIN
  -- Declare a variable to store the detail bill id of the inserted or updated row
  DECLARE @details_bill_id varchar(20), @total_day int;
  -- Assign the value of detail bill id from the inserted table
  SELECT @details_bill_id = Details_bill_id, @total_day = Reserved_day FROM inserted;
  
  --cập nhật số ngày đã đặt trước cho tổng số ngày trong chi tiết hóa đơn 
  --khi mà đặt thành công hoặc gia hạn thành công
  UPDATE DETAILS_BILL
  SET Total_day = @total_day
  WHERE DETAILS_BILL.Details_bill_id = @details_bill_id;
END;


GO
-------------- 6. Trigger xóa khỏi Details_Reserved nếu sau 30 phút mà vẫn chưa chuyển tiền cọc(đặt online) 
create trigger Update_status_room_deposited on DETAILS_RESERVED
after update
as
begin
	--Xóa khỏi bảng Details_Reserved
	delete from DETAILS_RESERVED
	where GETDATE()> DATEADD(minute, 30, Date_create) 
		  and Check_paid_deposit = 0				   
		  and Date_create <> Date_check_in;
end;


GO
-------------- 7. Trigger update tình trạng phòng và xóa hóa đơn khi xóa chi tiết đặt phòng (do không chuyển cọc, do không nhận phòng)
create trigger Delete_bill_and_details_bill on DETAILS_RESERVED
after delete
as
begin
	
	update ROOM
	set Room_status = 0
	from Room join deleted on Room.Room_id = deleted.Room_id
	where ROOM.Room_id = deleted.Room_id;

	--xóa khỏi bảng Bill và Details_Bill
	delete from BILL where BILL.Bill_id in (select Bill_id  from DETAILS_BILL join deleted on  deleted.Details_bill_id = DETAILS_BILL.Details_bill_id);

	delete from DETAILS_BILL where DETAILS_BILL.Details_bill_id in (select old.Details_bill_id from deleted as old); 
	
	--không cần xóa trong Details_Used_Service vì khi xóa Details_bill_id trong Details_Bill sẽ tự 
	--động xóa (do delete cascade)
end;


GO
-------------- 8. Trigger cập nhật tiền phòng vào hóa đơn mỗi khi thêm, cập nhật ngày đặt phòng(trường hợp khách hàng không sử dụng dịch vụ) cho từng chi tiết đặt phòng

CREATE TRIGGER Update_room_money ON DETAILS_RESERVED
AFTER INSERT, UPDATE
AS
BEGIN

  DECLARE  @details_bill_id varchar(20), @total_day int, @price money, @disco float, @total_money money = 0.0000, @total_day_old int = 0;

  SELECT @details_bill_id = inserted.Details_bill_id, @total_day = inserted.Reserved_day FROM inserted;

  SELECT @price = Unit, @disco =Discount_room FROM TYPE_ROOM JOIN ROOM ON TYPE_ROOM.Type_room_id = ROOM.Room_type
						JOIN DETAILS_RESERVED ON ROOM.Room_id = DETAILS_RESERVED.Room_id
						WHERE Details_Reserved.details_bill_id = @details_bill_id;

  select @total_day_old = Reserved_day from deleted where deleted.Details_bill_id = @details_bill_id;

  SELECT @total_money = Total_money FROM BILL WHERE BILL.Bill_id = (select Bill_id from DETAILS_BILL where DETAILS_BILL.Details_bill_id = @details_bill_id) and Total_money is not null
  --Cập nhật tiền phòng
  if(@total_day > @total_day_old)
	UPDATE BILL
	SET Total_money = @total_money + @price * (1 - @disco) * (@total_day - @total_day_old) - (select Deposit from DETAILS_RESERVED where Details_bill_id =  @details_bill_id)
	WHERE Bill_id = (SELECT bill_id 
					FROM Details_Bill 
					WHERE details_bill_id = @details_bill_id); 
END;

GO
-------------- 9. Trigger tính thêm tiền vào trong hóa đơn nếu check in sớm hơn 14h (đối với khách hàng đặt phòng online)
create trigger Update_total_money_checkin_early_onl on DETAILS_RESERVED
after update
as
begin
	--khai báo biến
	declare @date_checkin_new DateTime, @date_checkin_old DateTime, @room_id varchar(20), @price money, @total_money money = 0.0000, @details_bill_id varchar(20), @bill_id varchar(20);

	--lấy các giá trị cho biến
	select @date_checkin_new = Date_check_in, @room_id = Room_id, @details_bill_id = Details_bill_id from inserted

	select @date_checkin_old = Date_check_in from deleted

	select @bill_id = Bill_id from DETAILS_BILL where DETAILS_BILL.Details_bill_id = @details_bill_id

	select @price = Unit from TYPE_ROOM join ROOM on TYPE_ROOM.Type_room_id = ROOM.Room_type where ROOM.Room_id = @room_id

	select @total_money = Total_money from BILL where Bill_id = @bill_id and Total_money is not null

	if ( @date_checkin_new <> @date_checkin_old and DATEPART(HOUR, @date_checkin_new) >= 5 and DATEPART(HOUR, @date_checkin_new) <= 8 )--kiểm tra giờ checkin mới chèn hoặc cập nhật nếu từ 5-9 thì tính thêm 50% giá phòng 
		begin
			update BILL
			set Total_money = @total_money + 0.5 * @price
			where Bill_id = @bill_id
		end
		else if ( @date_checkin_new <> @date_checkin_old and DATEPART(HOUR, @date_checkin_new) >= 9 and DATEPART(HOUR, @date_checkin_new) <= 13 )----kiểm tra giờ checkin mới chèn hoặc cập nhật nếu từ 9-14 thì tính thêm 30% giá phòng
			 begin
			 update BILL
			 set Total_money = @total_money + 0.3 * @price
			 where Bill_id = @bill_id
			 end
end;


GO
-------------- 10. Trigger tính thêm tiền vào trong hóa đơn nếu check in sớm hơn 14h (đối với khách hàng đặt phòng offline)
create trigger Update_total_money_checkin_early_off on DETAILS_RESERVED
after insert
as
begin
	--khai báo biến
	declare @date_checkin DateTime, @room_id varchar(20), @price money, @total_money money = 0.0000, @details_bill_id varchar(20), @bill_id varchar(20);

	--lấy các giá trị cho biến
	select @date_checkin= Date_check_in, @room_id = Room_id, @details_bill_id = Details_bill_id from inserted

	select @bill_id = Bill_id from DETAILS_BILL where DETAILS_BILL.Details_bill_id = @details_bill_id

	select @price = Unit from TYPE_ROOM join ROOM on TYPE_ROOM.Type_room_id = ROOM.Room_type where ROOM.Room_id = @room_id

	select @total_money = Total_money from BILL where Bill_id = @bill_id and Total_money is not null

	if ( DATEPART(HOUR, @date_checkin) >= 5 and DATEPART(HOUR, @date_checkin) <= 8 )--kiểm tra giờ checkin mới chèn hoặc cập nhật nếu từ 5-9 thì tính thêm 50% giá phòng 
	begin
		update BILL
		set Total_money = @total_money + 0.5 * @price
		where Bill_id = @bill_id
	end
	else if ( DATEPART(HOUR, @date_checkin) >= 9 and DATEPART(HOUR, @date_checkin) <= 13 )----kiểm tra giờ checkin mới chèn hoặc cập nhật nếu từ 9-14 thì tính thêm 30% giá phòng
		 begin
			update BILL
			set Total_money = @total_money + 0.3 * @price
			where Bill_id = @bill_id
		 end
end;

GO
--------------11. Trigger ghi nhận lịch sử khi thêm khách hàng------------
CREATE TRIGGER TrackingLogCustomer_Ins
ON OFFICIAL_CUSTOMER
AFTER INSERT
AS
declare @Cusomer_id varchar(20), @Customer_name nvarchar(50), @Identify_card varchar(20), @Update_at Datetime, @Operation char(3);
DECLARE @maxID int = (SELECT COALESCE(MAX(ID),0) FROM TRACKING_LOG)
BEGIN 
	SET NOCOUNT ON;
	SELECT	
		@Cusomer_id = Official_customer_id,
		@Customer_name = Customer_name,
		@Identify_card=Identify_card
	FROM inserted
	INSERT INTO TRACKING_LOG(
		ID,
		Customer_id,
		Customer_name,
		Identify_card,
		Operation,
		Updated_at
		)
	values(@maxID+1,@Cusomer_id,@Customer_name,@Identify_card,'INS',GETDATE())
END


-------------12. Trigger ghi nhận lịch sử khi xóa khách hàng----------------
GO
CREATE TRIGGER TrackingLogCustomer_Del
ON OFFICIAL_CUSTOMER
AFTER DELETE
AS
declare @Cusomer_id varchar(20), @Customer_name nvarchar(50), @Identify_card varchar(20), @Update_at Datetime, @Operation char(3);
DECLARE @maxID int = (SELECT COALESCE(MAX(ID),0) FROM TRACKING_LOG)
BEGIN 
	SET NOCOUNT ON;
	SELECT	
		@Cusomer_id = Official_customer_id,
		@Customer_name = Customer_name,
		@Identify_card=Identify_card
	FROM deleted
	INSERT INTO TRACKING_LOG(
		ID,
		Customer_id,
		Customer_name,
		Identify_card,
		Operation,
		Updated_at
		)
	values(@maxID+1,@Cusomer_id,@Customer_name,@Identify_card,'DEL',GETDATE())
END

------------13. Trigger ghi nhận lịch sử khi cập nhật khách hàng-------------
GO
CREATE TRIGGER TrackingLogCustomer_Upd
ON OFFICIAL_CUSTOMER
AFTER UPDATE
AS
declare @Cusomer_id varchar(20), @Customer_name nvarchar(50), @Identify_card varchar(20), @Update_at Datetime, @Operation char(3);
DECLARE @maxID int = (SELECT COALESCE(MAX(ID),0) FROM TRACKING_LOG)
BEGIN 
	SET NOCOUNT ON;
	SELECT	
		@Cusomer_id = Official_customer_id,
		@Customer_name = Customer_name,
		@Identify_card=Identify_card
	FROM deleted
	INSERT INTO TRACKING_LOG(
		ID,
		Customer_id,
		Customer_name,
		Identify_card,
		Operation,
		Updated_at
		)
	values(@maxID+1,@Cusomer_id,@Customer_name,@Identify_card,'UPD',GETDATE())
END

-----test trigger trên---
--INSERT INTO CUSTOMER(Customer_id, Customer_name, Gender, Birthday, Identify_card, Phone, Mail, Customer_address)
--VALUES
--('KH0008', N'Võ Thị Minh Thục', 'Nữ', '2003-05-01', '123212312341','0846362325','thuc@gmail.com',N'Quảng Ngãi');
-------


-----------14. Trigger thông báo khi xóa BILL - Thông báo là Đã xóa Bill ---------------------------
GO
CREATE TRIGGER Noti_Delete_BILL on BILL
FOR DELETE
AS
BEGIN
DECLARE @Bill_id varchar(20)
SELECT @Bill_id = ol.Bill_id
FROM 
	deleted AS ol
IF (@Bill_id NOT IN (SELECT Bill_id FROM BILL))
PRINT N'Đã xóa Hóa đơn có mã' + RTRIM(@Bill_id)
END

-----------15. Trigger thông báo khi thêm BILL  - Thông báo là Đã thêm Bill ---------------------------
GO
CREATE TRIGGER Noti_Insert_BILL on BILL
FOR INSERT
AS
BEGIN
DECLARE @Bill_id varchar(20)
SELECT @Bill_id = ol.Bill_id
FROM 
	inserted AS ol
IF (@Bill_id IN (SELECT Bill_id FROM BILL))
PRINT N'Đã thêm Hóa đơn có mã ' + RTRIM(@Bill_id)
END

-----------16. Trigger thông báo khi cập nhật BILL - Thông báo là Đã cập nhật Bill ---------------------------
GO
CREATE TRIGGER Noti_Update_BILL on BILL
FOR UPDATE
AS
BEGIN
DECLARE @Bill_id varchar(20)
SELECT @Bill_id = ol.Bill_id
FROM 
	deleted AS ol
IF (@Bill_id IN (SELECT Bill_id FROM BILL))
PRINT N'Đã cập nhật Hóa đơn có mã ' + RTRIM(@Bill_id)
END

-----------17. Triggers thông báo khi thêm DETAILS_BILL - Thông báo là Đã thêm DETAILS_BILL ---------------------------
GO
CREATE TRIGGER Noti_Insert_DETAIL_BILL on DETAILS_BILL
FOR INSERT
AS
BEGIN
DECLARE @DetailBill_id varchar(20), @Bill_id varchar(20)
SELECT @DetailBill_id = ol.Details_bill_id, @Bill_id=ol.Bill_id
FROM 
	inserted AS ol
IF (@DetailBill_id IN (SELECT Details_bill_id FROM DETAILS_BILL))
PRINT N'Đã thêm Chi tiết Hóa đơn của Hóa đơn có mã ' + RTRIM(@Bill_id)
END

-----------18. Triggers thông báo khi cập nhật DETAILS_BILL - Thông báo là Đã cập nhật DETAILS_Bill ---------------------------
GO
CREATE TRIGGER Noti_Update_DETAIL_BILL on DETAILS_BILL
FOR UPDATE
AS
BEGIN
DECLARE @DetailBill_id varchar(20), @Bill_id varchar(20)
SELECT @DetailBill_id = ol.Details_bill_id, @Bill_id=ol.Bill_id
FROM 
	deleted AS ol
IF (@DetailBill_id IN (SELECT Details_bill_id FROM DETAILS_BILL))
PRINT N'Đã cập nhật Chi tiết Hóa đơn của Hóa đơn có mã ' + RTRIM(@Bill_id)
END

-------------19. Triggers thông báo khi xóa Customer------------------
GO
CREATE TRIGGER Noti_Delete_CUS on CUSTOMER
FOR DELETE
AS
BEGIN
DECLARE @Customer_id varchar(20), @Customer_name nvarchar(50)
SELECT @Customer_id=ol.Customer_id, @Customer_name=ol.Customer_name
FROM deleted AS ol
IF (@Customer_id NOT IN (SELECT Customer_id FROM CUSTOMER))
PRINT N'Đã xóa thông tin Khách hàng ' + RTRIM(@Customer_name)
END
-----TEST--
--DELETE
--FROM CUSTOMER
--WHERE Customer_id='KH0001'
--------------
-------------20. Triggers thông báo khi thêm Customer------------------
GO
CREATE TRIGGER Noti_Insert_CUS on CUSTOMER
FOR INSERT
AS
BEGIN
DECLARE @Customer_id varchar(20), @Customer_name nvarchar(50)
SELECT @Customer_id = new.Customer_id, @Customer_name = new.Customer_name
FROM inserted AS new
IF (@Customer_id IN (SELECT Customer_id FROM CUSTOMER))
PRINT N'Đã thêm thông tin Khách hàng ' + RTRIM(@Customer_name)
END


-------------21. Triggers thông báo lỗi khi thêm Customer mà thông tin CCCD của Customer đã tồn tại------------------
--GO
--CREATE TRIGGER Noti_Update_CUS on CUSTOMER
--FOR INSERT
--AS
--BEGIN
--DECLARE @Identify_card varchar(20), @Customer_name nvarchar(50)
--SELECT @Identify_card=ol.Identify_card, @Customer_name=ol.Customer_name
--FROM deleted AS ol
--IF (@Identify_card  IN (SELECT Identify_card FROM CUSTOMER))
--BEGIN
--	PRINT N'thông tin Khách hàng ' + RTRIM(@Customer_name) + N' đã tồn tại trước đó';
--	RollBack;
--END
--END
GO
CREATE TRIGGER Noti_Update_CUS ON CUSTOMER
FOR INSERT
AS
BEGIN
  IF (SELECT COUNT(*) FROM CUSTOMER c JOIN inserted i ON c.Identify_card = i.Identify_card) > 1
  BEGIN
    RAISERROR('Thông tin khách hàng đã tồn tại trước đó!', 16, 1);
    ROLLBACK TRANSACTION;
  END
END

---------------------22. Trigger thông báo khi thêm Phiếu đặt phòng thành công---------------
GO
CREATE TRIGGER Noti_Insert_Reserved_Room on DETAILS_RESERVED
FOR INSERT
AS
BEGIN
DECLARE @Room_id varchar(20)
SELECT @Room_id=ol.Room_id
FROM inserted AS ol
IF (@Room_id IN (SELECT Room_id FROM DETAILS_RESERVED))
PRINT N'Đã thêm phiếu đặt phòng cho phòng ' + RTRIM(@Room_id) + N' thành công'
END



---------------------23. Trigger thông báo khi cập nhật Phiếu đặt phòng thành công---------------
GO
CREATE TRIGGER Noti_Update_Reserved_Room on DETAILS_RESERVED
FOR UPDATE
AS
BEGIN
DECLARE @Room_id varchar(20)
SELECT @Room_id=ol.Room_id
FROM deleted AS ol
IF (@Room_id IN (SELECT Room_id FROM DETAILS_RESERVED))
PRINT N'Đã cập nhật phiếu đặt phòng cho phòng ' + RTRIM(@Room_id) + N' thành công'
END


---------------------24. Trigger thông báo khi thêm Phiếu sử dụng dịch vụ thành công---------------
GO
CREATE TRIGGER Noti_Insert_Use_Service on DETAILS_USED_SERVICE
FOR INSERT
AS
BEGIN
DECLARE @Room_id varchar(20)
SELECT @Room_id=ol.Room_id
FROM inserted AS ol
IF (@Room_id IN (SELECT Room_id FROM DETAILS_USED_SERVICE))
PRINT N'Đã thêm phiếu sử dụng dịch vụ cho phòng ' + RTRIM(@Room_id) + N' thành công'
END

---------------------25. Trigger thông báo khi cập nhật Phiếu sử dụng dịch vụ thành công---------------
GO
CREATE TRIGGER Noti_Update_Use_Service on DETAILS_USED_SERVICE
FOR UPDATE
AS
BEGIN
DECLARE @Room_id varchar(20)
SELECT @Room_id=ol.Room_id
FROM deleted AS ol
IF (@Room_id IN (SELECT Room_id FROM DETAILS_USED_SERVICE))
PRINT N'Đã cập nhật phiếu sử dụng dịch vụ cho phòng ' + RTRIM(@Room_id) + N' thành công'
END

----------------------26. Trigger theo dõi hoạt động thông tin khách hàng chính thức------------------------------
GO
CREATE TRIGGER Insert_Official_Customer
ON DETAILS_RESERVED
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO OFFICIAL_CUSTOMER (Official_customer_id, Customer_name, Gender, Birthday, Identify_card, Phone, Mail, Customer_address)
    SELECT CUSTOMER.Customer_id, Customer_name, Gender, Birthday, Identify_card, Phone, Mail, Customer_address
    FROM inserted JOIN CUSTOMER on inserted.Customer_id=CUSTOMER.Customer_id
    WHERE check_room_received = 1;
END;

GO
---------------------27. Trigger cập nhật tiền vào hóa đơn khi cập nhật giảm giá dịch vụ---------------
create trigger Update_Bill_When_Change_Discount_Service on SERVICE_ROOM
after update
as
begin
	declare @service_id varchar(20), @dis_new float, @dis_old float, @price money, @date_change DATE;

	select @service_id = Service_room_id, @price = Unit, @date_change = convert(date, GETDATE()), @dis_new = Discount_service from inserted;

	select @dis_old = Discount_service from deleted

	--Chọn ra mã chi tiết hóa đơn, số lượng  và số ngày đã thay đổi khi cập nhật giảm giá mới của dịch vụ đó
	--chọn ra mã chi tiết hóa đơn, mã hóa đơn trong chi tiết hóa đơn của những hóa đơn chưa thanh toán và kết với bảng trên
	--Lấy tiền dịch vụ sau khi thay đổi và mã hóa đơn rồi thực hiện cập nhật lại những hóa đơn nào có mã trùng với mã hóa đơn đó
	update BILL
	set Total_money = Total_money + money_service_changed_dis
	from BILL join (select sum(Number_of_service * (@dis_old - @dis_new) * @price) as money_service_changed_dis, Bill_id
					from (select P.Details_bill_id, Bill_id, Number_of_service, day_changed  
							from (select DETAILS_BILL.Details_bill_id, BILL.Bill_id 
									from DETAILS_BILL join BILL on DETAILS_BILL.Bill_id = BILL.Bill_id 
									where BILL.Pay_time is not null) as P 
								join (select dus.Details_bill_id, Number_of_service, DATEDIFF(day, convert(date, Date_used), @date_change) as day_changed 
										from SERVICE_ROOM sr join DETAILS_USED_SERVICE dus on sr.Service_room_id = dus.Service_room_id 
										where sr.Service_room_id = @service_id) as Q 
								on P.Details_bill_id = Q.Details_bill_id) as R
							where day_changed >= 0 
							group by Bill_id) as S
				on BILL.Bill_id = S.Bill_id 
	where BILL.Bill_id = S.Bill_id
end

GO
---------------------28. Trigger cập nhật tiền phòng vào hóa đơn khi cập nhật giảm giá phòng---------------
create trigger Update_Bill_When_Change_Discount_Room on TYPE_ROOM
after update
as
begin
	declare @type_room_id varchar(20), @dis_new float, @dis_old float, @price money;

	select @type_room_id = Type_room_id, @dis_new = Discount_room, @price = Unit from inserted;

	select @dis_old = Discount_room from deleted;
	update BILL
	SET Total_money = Total_money + money_dis_room_changed
	from BILL join ( select sum(changed_day * (@dis_old - @dis_new) * @price) as money_dis_room_changed, Bill_id --Tính tiền giảm giá mới
					from DETAILS_BILL join (select Details_bill_id, Reserved_day - DATEDIFF(day, convert(date, Date_check_in), convert(date, GETDATE())) as changed_day
											from DETAILS_RESERVED  --Lấy ra mã chi tiết hóa đơn, số ngày thay đổi giảm giá của những phòng đang đặt thuộc loại phòng mà bị thay đổi giảm giá
											where Room_id in (select Room_id --Lấy ra những mã phòng thuộc loại phòng mà bị thay đổi giảm giá
																from ROOM 
																where Room_type = @type_room_id) 
																and (Reserved_day >= DATEDIFF(day, convert(date, Date_check_in), convert(date, GETDATE()))) ) as Q
									on DETAILS_BILL.Details_bill_id = Q.Details_bill_id
									group by DETAILS_BILL.Bill_id ) as P
			on BILL.Bill_id = P.Bill_id
	where BILL.Bill_id = P.Bill_id

end

GO
---------------------29. Trigger cập nhật thông tin khách hàng chính thức khi thay đổi thông tin khách hàng---------------
CREATE TRIGGER Update_Official_Customer
ON CUSTOMER
AFTER UPDATE
AS
BEGIN
   UPDATE OFFICIAL_CUSTOMER
   SET OFFICIAL_CUSTOMER.Customer_name=inserted.Customer_name,
       OFFICIAL_CUSTOMER.Gender=inserted.Gender,
	   OFFICIAL_CUSTOMER.Birthday=inserted.Birthday,
	   OFFICIAL_CUSTOMER.Identify_card=inserted.Identify_card,
	   OFFICIAL_CUSTOMER.Phone=inserted.Phone,
	   OFFICIAL_CUSTOMER.Mail=inserted.Mail,
	   OFFICIAL_CUSTOMER.Customer_address=inserted.Customer_address
   FROM inserted
   WHERE Official_customer_id=inserted.Customer_id;
END;

GO
---------*****************************************************************************************************---------
---------============================ CÁC VIEW LIÊN QUAN ĐẾN HÓA ĐƠN VÀ ĐẶT PHÒNG ============================---------

GO
---------1. View BILL ---------
CREATE VIEW view_BILL as SELECT * FROM BILL

GO
---------2. View DETAILS_BILL ---------
CREATE VIEW view_DETAILS_BILL as SELECT * FROM DETAILS_BILL

GO
---------3. View DETAILS_RESERVED ---------
CREATE VIEW view_DETAILS_RESERVED as SELECT * FROM DETAILS_RESERVED

GO
---------4. View DETAILS_RESERVED_CHECKED_IN ---------
CREATE VIEW view_DETAILS_RESERVED_CHECKED_IN as SELECT * FROM view_DETAILS_RESERVED WHERE (Check_room_received = 1)

GO
---------5. View DETAILS_RESERVED_NOT_CHECK_IN ---------
CREATE VIEW view_DETAILS_RESERVED_NOT_CHECK_IN as SELECT * FROM view_DETAILS_RESERVED WHERE (Check_room_received = 0)

GO
---------6. View DETAILS_RESERVED_PAID_DEPOSIT ---------
CREATE VIEW view_DETAILS_RESERVED_PAID_DEPOSIT as SELECT * FROM view_DETAILS_RESERVED WHERE (Check_paid_deposit = 1)

GO
---------7. View DETAILS_RESERVED_UNPAID_DEPOSIT ---------
CREATE VIEW view_DETAILS_RESERVED_UNPAID_DEPOSIT as SELECT * FROM view_DETAILS_RESERVED WHERE (Check_paid_deposit = 0)

---------============================ CÁC PROCEDURE LIÊN QUAN ĐẾN HÓA ĐƠN VÀ ĐẶT PHÒNG ============================---------

GO
---------1. Procedure thêm chi tiết đặt phòng cho khách hàng ---------
CREATE PROCEDURE spAdd_detail_reserved 
				@customer_id varchar(20), @room_id varchar(20), @detail_bill_id varchar(20), @reserved_day int, 
				@date_checkin datetime, @check_room_received bit, @check_paid_deposit bit, @date_create datetime
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO DETAILS_RESERVED (Customer_id, Room_id, Details_bill_id, Reserved_day, Date_check_in, Check_room_received, Check_paid_deposit, Date_create)
		VALUES (@customer_id, @room_id, @detail_bill_id, @reserved_day, @date_checkin, @check_room_received, @check_paid_deposit, @date_create)
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('KHÔNG THÊM ĐƯỢC VÀO BẢNG CHI TIẾT ĐẶT PHÒNG!', 16, 1)
	END CATCH
END;

GO
---------2. Procedure tạo thêm hóa đơn mới chỉ có mã hóa đơn ---------
CREATE PROCEDURE spAdd_bill @bill_id varchar(20)
AS
BEGIN
  -- Bắt đầu một giao dịch
  BEGIN TRANSACTION;
  -- Kiểm tra xem mã hóa đơn đã tồn tại trong bảng invoice chưa
  IF EXISTS
  (
    -- Lấy bản ghi có mã hóa đơn trùng với tham số đầu vào
    SELECT 1
    FROM BILL
    WHERE Bill_id = @bill_id
  )
  BEGIN
    -- Nếu đã tồn tại thì hủy giao dịch và in ra thông báo lỗi
    ROLLBACK TRANSACTION;
    RAISERROR ('MÃ HÓA ĐƠN ĐÃ TỒN TẠI! VUI LÒNG CHỌN MÃ KHÁC.', 16, 1)
  END
  ELSE
  BEGIN
    -- Nếu chưa tồn tại thì thêm vào bảng invoice một bản ghi mới chỉ với mã hóa đơn
    INSERT INTO BILL(Bill_id) VALUES (@bill_id);
    -- Kết thúc giao dịch và in ra kết quả
    COMMIT TRANSACTION;
  END
END

GO
---------3. Procedure thêm vào chi tiết hóa đơn mã chi tiết đơn và mã hóa đơn ---------
CREATE PROCEDURE spAdd_detail_bill @detail_bill_id varchar(20), @bill_id varchar(20)
AS
BEGIN
  -- Bắt đầu một giao dịch
  BEGIN TRANSACTION;
  -- Kiểm tra xem mã hóa đơn đã tồn tại trong bảng BILL chưa
  IF EXISTS
  (
    -- Lấy bản ghi có mã hóa đơn trùng với tham số đầu vào
    SELECT 1
    FROM BILL
    WHERE Bill_id = @bill_id
  )
  BEGIN
    -- Nếu đã tồn tại thì kiểm tra xem mã chi tiết đơn đã tồn tại trong bảng invoice_detail chưa
    IF EXISTS
    (
      -- Lấy bản ghi có mã chi tiết đơn trùng với tham số đầu vào
      SELECT 1
      FROM DETAILS_BILL
      WHERE Details_bill_id = @detail_bill_id
    )
    BEGIN
      -- Nếu đã tồn tại thì hủy giao dịch và in ra thông báo lỗi
      ROLLBACK TRANSACTION;
      RAISERROR ('MÃ CHI TIẾT HÓA ĐƠN ĐÃ TỒN TẠI! VUI LÒNG CHỌN MÃ KHÁC.', 16, 1)
    END
    ELSE
    BEGIN
	  -- Nếu chưa tồn tại thì thêm vào bảng DETAILS_BILL một bản ghi mới với mã chi tiết đơn và mã hóa đơn
      INSERT INTO DETAILS_BILL(Details_bill_id, Bill_id) VALUES (@detail_bill_id, @bill_id);
      -- Kết thúc giao dịch và in ra kết quả
      COMMIT TRANSACTION;
    END;
  END
  ELSE
  BEGIN
    -- Nếu không tồn tại thì hủy giao dịch và in ra thông báo lỗi
    ROLLBACK TRANSACTION;
    RAISERROR ('MÃ HÓA ĐƠN KHÔNG TỒN TẠI! VUI LÒNG CHỌN MÃ HỢP LỆ.', 16, 1)
  END
END

GO
---------4. Procedure chỉnh sửa cho chi tiết đặt phòng ---------
create procedure spModify_reserved_day 
				@customer_id varchar(20), @room_id varchar(20), @detail_bill_id varchar(20), @reserved_day int,
				@date_checkin datetime, @check_room_received bit, @check_paid_deposit bit
as
begin
	begin transaction
	begin try
		update DETAILS_RESERVED
		set Reserved_day = @reserved_day, Date_check_in = @date_checkin, Check_room_received = @check_room_received, 
		Check_paid_deposit = @check_paid_deposit
		where Customer_id = @customer_id and Room_id = @room_id and Details_bill_id = @detail_bill_id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('CẬP NHẬT CHI TIẾT ĐẶT PHÒNG KHÔNG THÀNH CÔNG!', 16, 1)
	end catch
end

GO
---------5. Procedure xóa hóa đơn ---------
create procedure spDelete_bill
				@bill_id varchar(20)
as
begin
	begin transaction
	begin try
		delete from BILL where Bill_id = @bill_id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('KHÔNG XÓA ĐƯỢC HÓA ĐƠN!', 16, 1)
	end catch
end

GO
---------6. Procedure xóa chi tiết đặt phòng ---------
create procedure spDelete_detail_reserved 
				@customer_id varchar(20), @room_id varchar(20), @detail_bill_id varchar(20)
as
begin
	begin transaction
	begin try
		delete from DETAILS_RESERVED where Details_bill_id = @detail_bill_id and Room_id = @room_id and Customer_id = @customer_id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('KHÔNG XÓA ĐƯỢC CHI TIẾT ĐẶT PHÒNG!', 16, 1)
	end catch
end

GO
---------7. Procedure cập nhật hóa đơn ---------
create procedure spUpdate_bill 
				@bill_id varchar(20), @pay_time datetime, @employee_id varchar(20), @payment_method nvarchar(20)
as
begin
	begin transaction
	begin try
		update BILL
		set Pay_time = @pay_time, Employee_id = @employee_id, Payment_method = @payment_method
		where Bill_id = @bill_id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('KHÔNG CẬP NHẬT ĐƯỢC HÓA ĐƠN!', 16, 1)
	end catch
end

GO
---------8. Procedure xóa chi tiết hóa đơn ---------
create procedure spDelete_detail_bill
				@detail_bill_id varchar(20)
as
begin
	begin transaction
	begin try
		delete from DETAILS_BILL where Details_bill_id = @detail_bill_id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('KHÔNG XÓA ĐƯỢC CHI TIẾT HÓA ĐƠN!', 16, 1)
	end catch
end
---------============================ CÁC FUNCTION LIÊN QUAN ĐẾN HÓA ĐƠN VÀ ĐẶT PHÒNG ============================---------

GO
---------1. Function xem danh sách khách hàng đã ở khách sạn trong khoảng thời gian cụ thể ---------
CREATE FUNCTION ftGet_customer_list (@start_day date, @end_day date)
RETURNS TABLE
AS
RETURN
  -- Chọn ra thông tin khách hàng bằng cách lấy trong bảng chi tiết đặt phòng những mã khách hàng mà đã nhận phòng trong ngày đó
  -- và kết với bảng Customer
  SELECT DISTINCT c.Customer_id, c.Customer_name, c.Birthday, c.Gender, c.Identify_card, c.Phone, c.Mail, c.Customer_address
  FROM view_DETAILS_RESERVED dr INNER JOIN view_CUSTOMER c ON dr.Customer_id = c.Customer_id
  WHERE (Check_room_received = 'TRUE') and (dr.Date_check_in BETWEEN @start_day AND @end_day);

GO
---------2. Function lọc các hóa đơn của khách hàng  ---------
CREATE FUNCTION ftGet_bill_by_customer (@customer_id varchar(20))
RETURNS TABLE
AS
RETURN
(

  SELECT DISTINCT b.*
  FROM view_BILL b
  INNER JOIN view_DETAILS_BILL db on b.Bill_id = db.Bill_id
  INNER JOIN view_DETAILS_RESERVED dr on db.Details_bill_id = dr.Details_bill_id
  WHERE dr.Customer_id = @customer_id
)

GO
---------3. Function lọc các chi tiết đặt phòng ---------
CREATE FUNCTION ftGet_detail_reserved (@string varchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_DETAILS_RESERVED
WHERE ((Details_bill_id = @string) OR (Room_id = @string) OR (Customer_id = @string))
)

GO
---------4. Function lọc các chi tiết đặt phòng theo ngày đặt phòng ---------
CREATE FUNCTION ftGet_detail_reserved_date_create (@date_create DateTime)
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_DETAILS_RESERVED
WHERE DATEDIFF(day, convert(date, Date_create), convert(date, @date_create)) = 0
)

GO
---------5. Function lọc các chi tiết đặt phòng theo ngày nhận phòng ---------
CREATE FUNCTION ftGet_detail_reserved_date_check_in (@date_check_in DateTime)
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_DETAILS_RESERVED
WHERE DATEDIFF(day, convert(date, Date_check_in), convert(date, @date_check_in)) = 0
)

GO
---------6. Function lọc hóa đơn theo ngày thanh toán ---------
CREATE FUNCTION ftGet_bill_by_pay_time (@pay_time DateTime)
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_BILL
WHERE DATEDIFF(day, convert(date, Pay_time), convert(date, @pay_time)) = 0
)

GO
---------7. Function lọc hóa đơn theo 1 thuộc tính---------
CREATE FUNCTION ftSearch_bill(@string nvarchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_BILL
WHERE ((Bill_id = @string) OR (Employee_id = @string) OR (Payment_method LIKE '%' +@string +'%'))
)

---------*******************************************************************************************---------
---------============================ CÁC VIEW LIÊN QUAN ĐẾN KHÁCH HÀNG ============================---------

GO
---------1. VIEW CUSTOMER ---------
CREATE VIEW view_CUSTOMER as SELECT * FROM CUSTOMER

GO
---------2. VIEW OFFICIAL CUSTOMER ---------
CREATE VIEW view_OFFICIAL_CUSTOMER as SELECT * FROM OFFICIAL_CUSTOMER

---------============================ CÁC PROCEDURE LIÊN QUAN ĐẾN KHÁCH HÀNG ============================---------
GO
---------1. PROCEDURE THÊM THÔNG TIN KHÁCH HÀNG ---------
CREATE PROCEDURE ADD_CUSTOMER
	@Customer_id varchar(20),
	@Customer_name nvarchar(50),
	@Gender nvarchar(6),
	@Birthday date, 
	@Identify_card varchar(20),
	@Phone varchar(10), 
	@Mail varchar(50), 
	@Customer_address nvarchar(255)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO CUSTOMER(Customer_id,Customer_name,Gender,Birthday,Identify_card,Phone,Mail,Customer_address)
		VALUES (@Customer_id,@Customer_name,@Gender,@Birthday,@Identify_card,@Phone,@Mail,@Customer_address)
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('KHÁCH HÀNG ĐÃ TỒN TẠI', 16, 1)
	END CATCH
END

GO
---------2. PROCEDURE SỬA THÔNG TIN KHÁCH HÀNG ---------
CREATE PROCEDURE UPDATE_CUSTOMER
	@Customer_id varchar(20),
	@Customer_name nvarchar(50),
	@Gender nvarchar(6),
	@Birthday date, 
	@Identify_card varchar(20),
	@Phone varchar(10), 
	@Mail varchar(50), 
	@Customer_address nvarchar(255)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE CUSTOMER
		SET
			Customer_name=@Customer_name,
			Gender=@Gender,
			Birthday=@Birthday,
			Identify_card=@Identify_card,
			Phone=@Phone,
			Mail=@Mail,
			Customer_address=@Customer_address
		WHERE Customer_id = @Customer_id
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('CẬP NHẬT THÔNG TIN KHÁCH HÀNG KHÔNG THÀNH CÔNG', 25, 1)
	END CATCH
END

GO
---------3. PROCEDURE XÓA THÔNG TIN KHÁCH HÀNG ---------
CREATE PROCEDURE DELETE_CUSTOMER
	@Customer_id varchar(20)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DELETE FROM CUSTOMER WHERE Customer_id=@Customer_id
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('KHÔNG XÓA ĐƯỢC KHÁCH HÀNG', 25, 1)
	END CATCH
END


---------============================ CÁC FUNCTION LIÊN QUAN ĐẾN KHÁCH HÀNG ============================---------

GO
---------1. FUNCTION TÌM THÔNG TIN KHÁCH HÀNG ---------
CREATE FUNCTION Search_Customer(@string nvarchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_CUSTOMER
WHERE ((Customer_id = @string)
OR (Identify_card = @string) OR (Phone LIKE '%' +@string +'%')
OR (Mail LIKE '%' +@string +'%') OR (Customer_address LIKE '%' +@string +'%')))

GO
---------2. FUNCTION TÌM THÔNG TIN KHÁCH HÀNG THEO TÊN KHÁCH HÀNG ---------
CREATE FUNCTION Search_Customer_ByName(@string nvarchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_CUSTOMER
WHERE ( (Customer_name LIKE '%' +@string +'%') ))

GO
---------3. FUNCTION TÌM THÔNG TIN KHÁCH HÀNG THEO GIỚI TÍNH VÀ NGÀY SINH ---------
CREATE FUNCTION Search_Customer_By_GenderAndBirthday(@gender nvarchar(50), @fromdate DateTime , @todate DateTime)
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_CUSTOMER
WHERE Gender=@gender AND Birthday BETWEEN @fromdate AND @todate);

GO
---------4. FUNCTION TÌM THÔNG TIN KHÁCH HÀNG THEO NGÀY SINH ---------
CREATE FUNCTION Search_Customer_By_Birthday(@fromdate DateTime , @todate DateTime)
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_CUSTOMER
WHERE Birthday BETWEEN @fromdate AND @todate);

GO
---------5. FUNCTION TÌM THÔNG TIN KHÁCH HÀNG THEO GIỚI TÍNH ---------
CREATE FUNCTION Search_Customer_By_Gender(@gender nvarchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_CUSTOMER
WHERE Gender=@gender);

GO
---------6. FUNCTION LOAD THÔNG TIN 1 KHÁCH HÀNG ---------
CREATE FUNCTION Load_Customer (@Cutomer_id varchar(20))
RETURNS TABLE AS RETURN
(
SELECT Customer_name,Birthday,Identify_card,Phone,Mail,Customer_address
FROM view_CUSTOMER
WHERE Customer_id=@Cutomer_id
)


GO
---------7. Function sinh mã khách hàng tự động khi thêm mới khách hàng---------
CREATE FUNCTION ftGet_next_customer_id()
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @s VARCHAR(20);
    DECLARE @max_num INT;

    SELECT TOP 1 @max_num = CAST(SUBSTRING([Customer_id], 5, LEN([Customer_id])) AS INT)
    FROM view_CUSTOMER
    WHERE SUBSTRING([Customer_id], 1, 5) = 'KH000'
    ORDER BY CAST(SUBSTRING([Customer_id], 5, LEN([Customer_id])) AS INT) DESC;

    IF (@max_num IS NULL)
    BEGIN
        SET @s = 'KH0001';
    END
    ELSE
    BEGIN
        SET @max_num = @max_num + 1;
        SET @s = 'KH000' + RIGHT(CAST(@max_num AS NVARCHAR(MAX)), LEN(CAST(@max_num AS NVARCHAR(MAX))));
    END

    RETURN @s;
END;
---------******************************************************************************************---------
---------============================ CÁC VIEW LIÊN QUAN ĐẾN NHÂN VIÊN ============================---------

GO
---------1. View EMPLOYEE ---------
CREATE VIEW view_EMPLOYEE as SELECT * FROM EMPLOYEE

---------============================ CÁC PROCEDURE LIÊN QUAN ĐẾN NHÂN VIÊN ============================---------

GO
---------1. PROCEDURE THÊM NHÂN VIÊN ---------
CREATE PROCEDURE ADD_EMPLOYEE
	@Employee_id varchar(20),
	@Employee_name nvarchar(50),
	@Gender nvarchar(6),
	@Birthday date, 
	@Identify_card varchar(20),
	@Phone varchar(10), 
	@Mail varchar(50), 
	@Employee_address nvarchar(255)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		INSERT INTO EMPLOYEE(Employee_id,Employee_name,Gender,Birthday,Identify_card,Phone,Mail,Employee_address)
		VALUES (@Employee_id,@Employee_name,@Gender,@Birthday,@Identify_card,@Phone,@Mail,@Employee_address)
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('KHÔNG THÊM ĐƯỢC NHÂN VIÊN', 25, 1)
	END CATCH
END

GO
---------2. PROCEDURE SỬA THÔNG TIN NHÂN VIÊN ---------
CREATE PROCEDURE UPDATE_EMPLOYEE
	@Employee_id varchar(20),
	@Employee_name nvarchar(50),
	@Gender nvarchar(6),
	@Birthday date, 
	@Identify_card varchar(20),
	@Phone varchar(10), 
	@Mail varchar(50), 
	@Employee_address nvarchar(255)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE EMPLOYEE
		SET
			Employee_name=@Employee_name,
			Gender=@Gender,
			Birthday=@Birthday,
			Identify_card=@Identify_card,
			Phone=@Phone,
			Mail=@Mail,
			Employee_address=@Employee_address
		WHERE Employee_id = @Employee_id
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('CẬP NHẬT THÔNG TIN NHÂN VIÊN KHÔNG THÀNH CÔNG', 25, 1)
	END CATCH
END

GO
---------3. PROCEDURE XÓA NHÂN VIÊN ---------
CREATE PROCEDURE DELETE_EMPLOYEE
	@Employee_id varchar(20)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DELETE FROM EMPLOYEE WHERE Employee_id = @Employee_id
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('KHÔNG XÓA ĐƯỢC NHÂN VIÊN', 25, 1)
	END CATCH
END

---------============================ CÁC FUNCTION LIÊN QUAN ĐẾN NHÂN VIÊN ============================---------

GO
---------1. FUNCTION TÌM THÔNG TIN NHÂN VIÊN ---------
CREATE FUNCTION Search_Employee(@string nvarchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_EMPLOYEE
WHERE ((Employee_id = @string)
OR (Identify_card = @string) OR (Phone LIKE '%' +@string +'%')
OR (Mail LIKE '%' +@string +'%') OR (Employee_address LIKE '%' +@string +'%')))

GO
---------2. FUNCTION TÌM THÔNG TIN NHÂN VIÊN THEO TÊN ---------
CREATE FUNCTION Search_Employee_ByName(@string nvarchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_EMPLOYEE
WHERE ( (Employee_name LIKE '%' +@string +'%') ))

GO
---------3. FUNCTION TÌM THÔNG TIN NHÂN VIÊN THEO GIỚI TÍNH VÀ NGÀY SINH ---------
CREATE FUNCTION Search_Employee_By_GenderAndBirthday(@gender nvarchar(50), @fromdate DateTime , @todate DateTime)
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_EMPLOYEE
WHERE Gender=@gender AND Birthday BETWEEN @fromdate AND @todate);

GO
---------4. FUNCTION TÌM THÔNG TIN NHÂN VIÊN THEO NGÀY SINH ---------
CREATE FUNCTION Search_Employee_By_Birthday(@fromdate DateTime , @todate DateTime)
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_EMPLOYEE
WHERE Birthday BETWEEN @fromdate AND @todate);

GO
---------5. FUNCTION TÌM THÔNG TIN NHÂN VIÊN THEO GIỚI TÍNH ---------
CREATE FUNCTION Search_Employee_By_Gender(@gender nvarchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_EMPLOYEE
WHERE Gender=@gender);

GO
---------6. Function lấy thông tin cá nhân của 1 nhân viên khi đăng nhập---------
create function Get_infor_employee(@user_name varchar(20), @pass_word varchar(20))
returns table as return
(
	select *
	from view_EMPLOYEE
	where Employee_id = (select Employee_id
							from ACCOUNT
							where Username = @user_name and Pass = @pass_word)
)

GO
---------7. Function sinh mã nhân viên tự động khi thêm mới nhân viên---------
CREATE FUNCTION ftGet_next_employee_id()
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @s VARCHAR(20);
    DECLARE @max_num INT;

    SELECT TOP 1 @max_num = CAST(SUBSTRING([Employee_id], 3, LEN([Employee_id])) AS INT)
    FROM view_EMPLOYEE
    ORDER BY CAST(SUBSTRING([Employee_id], 3, LEN([Employee_id])) AS INT) DESC;

    IF (@max_num IS NULL)
    BEGIN
        SET @s = 'NV01';
    END
    ELSE
    BEGIN
        SET @max_num = @max_num + 1;
        SET @s = 'NV0' + RIGHT(CAST(@max_num AS NVARCHAR(MAX)), LEN(CAST(@max_num AS NVARCHAR(MAX))));
    END

    RETURN @s;
END;


---------*********************************************************************************************---------
---------============================ CÁC VIEW LIÊN QUAN ĐẾN TRACKING LOG ============================---------

GO
---------1. View TRACKING LOG ---------
CREATE VIEW view_TRACKING_LOG as SELECT * FROM TRACKING_LOG

---------============================ CÁC FUNCTION LIÊN QUAN ĐẾN TRACKING_LOG ============================---------

GO
---------1. FUNCTION TÌM THÔNG TIN TRACKING_LOG ---------
CREATE FUNCTION Search_Tracking(@string nvarchar(50))
RETURNS TABLE AS RETURN
(
SELECT *
FROM TRACKING_LOG
WHERE ((Customer_id = @string) OR (Customer_name LIKE '%' +@string +'%')
OR (Identify_card = @string +'%') OR (Operation LIKE '%' +@string +'%')));

GO
---------2. FUNCTION TÌM THÔNG TIN TRACKING THEO NGÀY CẬP NHẬT----------------
CREATE FUNCTION Search_Tracking_By_Updated(@fromdate DateTime , @todate DateTime)
RETURNS TABLE AS RETURN
(
SELECT *
FROM view_TRACKING_LOG
WHERE Updated_at BETWEEN @fromdate AND @todate);

---------*********************************************************************************************************---------
---------=============================== CÁC VIEW LIÊN QUAN ĐẾN PHÒNG VÀ LOẠI PHÒNG ==============================---------

GO
---------1. View ROOM ---------
create view view_ROOM as select * from ROOM

GO
---------2. View TYPE_ROOM ---------
create view view_TYPE_ROOM as select * from TYPE_ROOM

GO
---------3. View ROOM_WITH_TYPENAME ---------
Create View view_Room_With_TypeName
As
Select Room_id, Type_room_name
From view_TYPE_ROOM vtr, view_ROOM vr
Where vtr.Type_room_id = vr.Room_type

---------============================ CÁC PROCEDURE LIÊN QUAN ĐẾN PHÒNG VÀ LOẠI PHÒNG ============================---------

GO
---------1. Procedure thêm phòng ---------
CREATE PROCEDURE Add_Room @id varchar(20) , @status bit, @type varchar(20)
AS
BEGIN
	BEGIN TRAN
	BEGIN TRY
		Insert Into ROOM (room_id, Room_status, Room_type) Values (@id, @status, @type);
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('KHÔNG THÊM PHÒNG ĐƯỢC!', 16, 1);
	END CATCH
END;

GO
---------2. Procedure cập nhật phòng ---------
CREATE PROC Update_Room @id varchar(20), @type varchar(20)
AS
BEGIN
	begin tran
	begin try
		Update Room Set Room_type = @type
		Where Room_id = @id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('KHÔNG CẬP NHẬT PHÒNG ĐƯỢC', 16, 1);
	end catch
END;

GO
---------3. Procedure xóa phòng ---------
CREATE PROC Delete_Room @id varchar(20)
AS
BEGIN
	begin tran
	begin try
		Delete 
		From ROOM
		WHERE Room_id = @id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('XÓA PHÒNG THẤT BẠI!', 16, 1)
	end catch
END;

GO
---------4. Procedure thêm loại phòng ---------
CREATE PROC Add_Type_Room @id varchar(20), @name nvarchar(50), @unit money, @discount float
AS
BEGIN
	begin tran
	begin try
		INSERT INTO TYPE_ROOM (Type_room_id, Type_room_name, Unit, Discount_room)
		VALUES (@id, @name, @unit, @discount)
		commit tran
	end try
	begin catch
		rollback
		raiserror('THÊM LOẠI PHÒNG MỚI KHÔNG THÀNH CÔNG!', 16, 1)
	end catch
END;

GO
---------5. Procedure cập nhật loại phòng ---------
CREATE PROC Update_Type_Room @id varchar(20), @name nvarchar(50), @unit money, @discount float
AS
BEGIN
	begin tran
	begin try
		UPDATE TYPE_ROOM SET Type_room_name = @name, Unit = @unit, Discount_room = @discount
		WHERE Type_room_id = @id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('CẬP NHẬT LOẠI PHÒNG KHÔNG THÀNH CÔNG!', 16, 1)
	end catch
END;

GO
---------6. Procedure xóa loại phòng ---------
CREATE PROC Delete_Type_Room @id varchar(20)
AS
BEGIN
	begin tran
	begin try
		DELETE 
		FROM TYPE_ROOM
		WHERE Type_room_id = @id
		commit tran
	end try
	begin catch
		rollback
		raiserror('XÓA LOẠI PHÒNG KHÔNG THÀNH CÔNG!', 16, 1)
	end catch
END;

---------============================ CÁC FUNCTION LIÊN QUAN ĐẾN PHÒNG VÀ LOẠI PHÒNG ============================---------

GO
---------1. Function lọc phòng theo mã phòng và loại phòng ---------
CREATE FUNCTION FILTER_ROOM(
   @id varchar(20),
   @type varchar(20)
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM view_Room_With_TypeName
    WHERE (Room_id LIKE '%' + @id +'%') AND (Type_room_name LIKE '%' + @type +'%')
);

GO
---------2. Function lọc loại phòng theo giá tiền ---------
CREATE FUNCTION FILTER_TYPE_ROOM(
   @min money,
   @max money
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM view_TYPE_ROOM
    WHERE Unit >= @min AND Unit <= @max
);

GO
---------3. Function tìm giá tiền loại phòng cao nhất ---------
CREATE FUNCTION Max_Unit_Type_Room()
RETURNS INT
AS
BEGIN
    DECLARE @maxValue INT;

    SELECT @maxValue = MAX(Unit)
    FROM view_TYPE_ROOM

    RETURN @maxValue;
END;

GO
---------4. Function lọc các phòng đã đặt theo ngày ---------

create function ftSearch_room_reserved_by_time (@date_start DateTime, @date_end DateTime)
returns table as return
(
SELECT Room_id, Room_status = 'True', Room_type
FROM view_ROOM
WHERE Room_id IN (
					SELECT DISTINCT Room_id
					FROM view_DETAILS_RESERVED
					WHERE ( ( (CONVERT(date, Date_check_in) <= @date_start) and (@date_start <= DATEADD(day, Reserved_day, CONVERT(date, Date_check_in))) )
							or ( (CONVERT(date, Date_check_in) <= @date_end) and (@date_end <= DATEADD(day, Reserved_day, CONVERT(date, Date_check_in))) )
							or ( (@date_start < CONVERT(date, Date_check_in)) and (@date_end > DATEADD(day, Reserved_day, CONVERT(date, Date_check_in))) )
							and ( (Check_paid_deposit = 1) or (DATEDIFF(day, CONVERT(date, Date_create), CONVERT(date, Date_check_in)) = 0)) )
	)
)

GO
---------5. Function lọc các phòng đã đặt theo ngày và loại phòng---------
create function ftFilter_room_reserved_by_type(@date_start DateTime, @date_end DateTime,
									@type_room varchar(20))
returns table as return
(
	select *
	from (select * from ftSearch_room_reserved_by_time(@date_start, @date_end)) as Q
	where Q.Room_type = @type_room
)

GO
---------6. Function hiển thị các chi tiết hóa đơn của hóa đơn---------
create function ftShow_detail_bill_of_bill(@bill_id varchar(20))
returns table as return
(	
	select * from view_DETAILS_BILL where Bill_id = @bill_id
)



---------************************************************************************************************************************---------
---------=============================== CÁC VIEW LIÊN QUAN ĐẾN DỊCH VỤ VÀ CHI TIẾT SỬ DỤNG DỊCH VỤ==============================---------

GO
---------1. View SERVICE_ROOM ---------
create view view_SERVICE_ROOM as select * from SERVICE_ROOM

GO
---------2. View DETAILS_USED_SERVICE ---------
create view view_DETAILS_USED_SERVICE as select * from DETAILS_USED_SERVICE

GO
---------3. View hiển thị chi tiết sử dụng dịch vụ cho các phòng---------
create view view_DETAILS_USED_SERVICE_BY_ROOM
as
(	
	select dus.Room_id, dus.Details_bill_id, db.Bill_id, sr.Service_room_name, sr.Unit, dus.Number_of_service, dus.Date_used
	from DETAILS_USED_SERVICE as dus
	join DETAILS_BILL as db on dus.Details_bill_id = db.Details_bill_id
	join DETAILS_RESERVED dr on db.Details_bill_id = dr.Details_bill_id
	join SERVICE_ROOM sr on dus.Service_room_id = sr.Service_room_id
)

---------============================ CÁC PROCEDURE LIÊN QUAN ĐẾN DỊCH VỤ VÀ CHI TIẾT SỬ DỤNG DỊCH VỤ ===========================---------

GO
---------1. Procedure thêm dịch vụ ---------
CREATE PROC Add_Service_Room @id varchar(20), @name nvarchar(50), @unit money, @discount float
AS
BEGIN
	begin tran
	begin try
		INSERT INTO SERVICE_ROOM (Service_room_id, Service_room_name, Unit, Discount_service) VALUES (@id, @name, @unit, @discount)
		commit tran
	end try
	begin catch
		rollback
		raiserror('THÊM DỊCH VỤ MỚI KHÔNG THÀNH CÔNG!', 16, 1)
	end catch
END;

GO
---------2. Procedure cập nhật dịch vụ ---------
CREATE PROC Update_Service_Room @id varchar(20), @name nvarchar(50), @unit money, @discount float
AS
BEGIN
	begin tran
	begin try
		UPDATE SERVICE_ROOM SET Service_room_name = @name, Unit = @unit, Discount_service = @discount
		WHERE Service_room_id = @id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('CẬP NHẬT DỊCH VỤ KHÔNG THÀNH CÔNG!', 16, 1)
	end catch
END;

GO
---------3. Procedure xóa dịch vụ ---------
CREATE PROC Delete_Service_Room @id varchar(20)
AS
BEGIN
	begin tran
	begin try
		DELETE 
		FROM SERVICE_ROOM
		WHERE Service_room_id = @id
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('XÓA DỊCH VỤ KHÔNG THÀNH CÔNG!', 16, 1)
	end catch
END;

GO
---------4. Procedure thêm chi tiết sử dụng dịch vụ ---------
CREATE PROC Add_Details_Used_Service 
			@room_id varchar(20), @details_bill_id varchar(20), 
			@service_room_id varchar(20),
			@number int, @date_used datetime
AS
BEGIN
	begin tran
	begin try
		INSERT INTO DETAILS_USED_SERVICE (Room_id, Details_bill_id, Service_room_id, Number_of_service, Date_used)
		VALUES (@room_id, @details_bill_id, @service_room_id, @number, @date_used)
		commit tran
	end try
	begin catch
		rollback tran
		raiserror('THÊM CHI TIẾT SỬ DỤNG DỊCH VỤ KHÔNG THÀNH CÔNG!', 16, 1)
	end catch
END;

---------============================ CÁC FUNCTION LIÊN QUAN ĐẾN DỊCH VỤ VÀ CHI TIẾT SỬ DỤNG DỊCH VỤ ============================---------



GO
---------1. Function lọc dịch vụ theo giá tiền ---------
CREATE FUNCTION FILTER_SERVICE(
   @min money,
   @max money
)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM view_SERVICE_ROOM
    WHERE Unit >= @min AND Unit <= @max
);

GO
---------2. Function tìm giá dịch vụ cao nhất ---------
CREATE FUNCTION Max_Unit_Service_Room()
RETURNS INT
AS
BEGIN
    DECLARE @maxValue INT;

    SELECT @maxValue = MAX(Unit)
    FROM SERVICE_ROOM

    RETURN @maxValue;
END;

GO
---------3. Function lọc chi tiết sử dụng dịch vụ ---------
CREATE FUNCTION FILTER_DETAILS_USED_SERVICE(
    @room_id varchar(20), @details_bill_id varchar(20),
    @service_room_id varchar(20),
    @number_min int,  @number_max int, @date_used_start datetime, @date_used_end datetime
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT *
                FROM view_DETAILS_USED_SERVICE
                WHERE (Room_id = @room_id OR @room_id IS NULL)
				AND (Details_bill_id = @details_bill_id OR @details_bill_id IS NULL) 
				AND (Service_room_id = @service_room_id OR @service_room_id IS NULL)
				AND ((Date_used >= @date_used_start AND Date_used<=@date_used_end) 
				OR ( @date_used_start IS NULL AND @date_used_end IS NULL))
				AND ((Number_of_service >= @number_min  AND Number_of_service<=@number_max) 
				OR (@number_min IS NULL AND @number_max IS NULL))
            );

GO
---------4. Function hiển thị dịch vụ và số lượng sử dụng dịch vụ và ngày sử dụng của chi tiết hóa đơn---------
create function ftShow_detail_used_service (@detail_bill_id varchar(20), @bill_id varchar(20))
returns table as return
(	
	select Room_id, Service_room_name, Unit, Number_of_service, Date_used
	from view_DETAILS_USED_SERVICE_BY_ROOM
	where Details_bill_id = @detail_bill_id and Bill_id = @bill_id
)

---------*******************************************************************************************************---------
---------=============================== CÁC VIEW LIÊN QUAN ĐẾN THỐNG KÊ DOANH THU==============================---------

GO
---------1. View hiển thị doanh thu theo tháng - năm---------
create view view_SHOW_REVENUE_GROUPBY_MONTH_YEAR
as 
(
	select YEAR(Pay_time) as [Năm], MONTH(Pay_time) as [Tháng], sum(Total_money) as [Doanh thu]
	from view_BILL
	where Pay_time is not null 
	group by YEAR(Pay_time), MONTH(Pay_time)
)

---------=============================== CÁC FUNCTION LIÊN QUAN ĐẾN THỐNG KÊ DOANH THU==============================---------

GO
---------1. Function hiển thị doanh thu theo tháng của năm cụ thể---------
create function ftShow_revenue_by_month_of_year(@year varchar(20))
returns table as return
(
	select *
	from view_SHOW_REVENUE_GROUPBY_MONTH_YEAR
	where Năm = @year
)


---------=============================== FUNCTION LIÊN QUAN ĐẾN ĐĂNG NHẬP==============================---------

GO
---------1. Function kiểm tra tên tài khoản và mật khẩu(nếu đã có tài khoản thì trả về mã nhân viên)---------
create function ftCheck_login (@user_name varchar(20), @pass_word varchar(20))
returns varchar(20) as
begin 
	declare @result varchar(20)
	set @result = '';
	if exists(select * from ACCOUNT where Username = @user_name and Pass = @pass_word)
	begin
		select @result = Employee_id from ACCOUNT where Username = @user_name
	end
	return @result
end

---------************************************************************************************************************************---------
---------=============================== PROCEDURE LIÊN QUAN ACCOUNT==============================---------

GO
---------1. Procedure thêm 1 tài khoản và tạo 1 user trên SQL Server cho tài khoản đó(Phải thêm nhân viên trước)---------
CREATE PROCEDURE spCreate_account_user_login
				@user_name varchar(20), @pass varchar(20), @employee_id varchar(20), @role varchar(20)
AS
BEGIN
	BEGIN TRAN
	BEGIN TRY	
		--Thêm tài khoản
		INSERT INTO ACCOUNT(Username, Pass, Employee_id, Role) values (@user_name, @pass, @employee_id, @role);
		DECLARE @sqlString nvarchar(2000)
		-- Tạo tài khoản login cho nhân viên, tên người dùng và mật khẩu là tài khoản được tạo trên bảng Account
		SET @sqlString= 'CREATE LOGIN [' + @user_name +'] WITH PASSWORD='''+ @pass +''', 
				DEFAULT_DATABASE=[QLDATPHONGKS], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
		EXEC (@sqlString)
		-- Tạo tài khoản người dùng đối với nhân viên đó trên database (tên người dùng trùng với tên login)
		SET @sqlString= 'CREATE USER ' + @user_name +' FOR LOGIN '+ @user_name
		EXEC (@sqlString)
		-- Thêm người dùng vào vai trò quyền tương ứng (Staff hoặc Manager(sysadmin))
		IF(@role ='Sysadmin')
			SET @sqlString = 'ALTER SERVER ROLE ' + @role + ' ADD MEMBER ' + @user_name;
		ELSE
			SET @sqlString = 'ALTER ROLE '+ @role +' ADD MEMBER ' + @user_name;
		EXEC (@sqlString)
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		RAISERROR('KHÔNG THỰC HIỆN VIỆC THÊM, TẠO USER CHO TÀI KHOẢN NHÂN VIÊN ĐƯỢC!', 16, 1)
	END CATCH
END

GO
---------2. Procedure xóa tài khoản nhân viên khi xóa nhân viên---------
create procedure spDelete_account
				@employee_id varchar(20)
as
begin

	begin try
		declare @user_name varchar(20), @stringSQL nvarchar(200), @SPID smallint, @SQL nvarchar(1000);
		select @user_name =  Username from ACCOUNT where Employee_id = @employee_id

		SELECT @SPID = session_id FROM sys.dm_exec_sessions WHERE login_name = @user_name
		SET @SQL = 'KILL ' + CAST(@SPID as varchar(4))
		EXEC (@SQL)

		begin tran
		set @stringSQL = 'drop user ['+@user_name+']';
		EXEC(@stringSQL);
		set @stringSQL = 'drop login ['+@user_name+']';
		EXEC(@stringSQL);
		commit tran
	end try
	begin catch
		rollback tran;
		raiserror('KHÔNG XÓA ĐƯỢC USER VÀ TÀI KHOẢN', 16, 1)
	end catch
end

---------=============================== FUNCTION LIÊN QUAN ACCOUNT==============================---------

GO
---------1. Function lấy tên tài khoản, mật khẩu và quyền của 1 nhân viên(truyền vào mã nhân viên)---------
create function ftGet_username_pass_role(@employee_id varchar(20))
returns table as return
(
	select * from ACCOUNT where Employee_id = @employee_id
)


---------************************************************************************************************************************---------
---------=============================== USER PHÂN QUYỀN==============================---------	
GO
---------Tạo một vai trò giữ quyền có tên là Staff---------
CREATE ROLE Staff

GO
---------Gán các quyền trên các bảng cho role Staff---------
GRANT SELECT, REFERENCES ON ACCOUNT TO Staff 
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON BILL TO Staff
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON DETAILS_BILL TO Staff
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON DETAILS_RESERVED TO Staff
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON CUSTOMER TO Staff
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON OFFICIAL_CUSTOMER TO Staff
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON DETAILS_USED_SERVICE TO Staff
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON ROOM TO Staff
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON SERVICE_ROOM TO Staff
GRANT SELECT, INSERT, DELETE, UPDATE, REFERENCES ON TRACKING_LOG TO Staff

GO
-- Gán quyền thực thi trên các procedure, function cho role Staff
GRANT EXECUTE TO Staff
GRANT SELECT TO Staff

DENY UPDATE, INSERT, DELETE ON EMPLOYEE to Staff;
DENY EXECUTE ON UPDATE_EMPLOYEE to Staff;
DENY EXECUTE ON ADD_EMPLOYEE to Staff;
DENY EXECUTE ON DELETE_EMPLOYEE to Staff;
DENY SELECT ON ftShow_revenue_by_month_of_year to Staff;
DENY EXECUTE ON spCreate_account_user_login to Staff
DENY SELECT ON ftGet_username_pass_role to Staff
DENY SELECT, REFERENCES ON view_EMPLOYEE TO Staff

