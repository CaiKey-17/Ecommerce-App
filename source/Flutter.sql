

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";



DELIMITER $$


CREATE DEFINER=`root`@`%` PROCEDURE `AddMoreToCart` (IN `p_OrderId` VARCHAR(50), IN `p_ProductId` INT)   BEGIN

    DECLARE v_PriceProduct DOUBLE;
    DECLARE v_Quantity INT;
    DECLARE v_Price_Total DOUBLE;


    SELECT price INTO v_PriceProduct FROM order_details WHERE fk_order_Id = p_OrderId and fk_product_Id = p_ProductId;
    
    UPDATE order_details
    SET quantity = quantity + 1, total = total + v_PriceProduct
    WHERE fk_order_Id = p_OrderId AND fk_product_Id = p_ProductId;


    SELECT sum(quantity) INTO v_Quantity from order_details
    WHERE fk_order_Id = p_OrderId
    GROUP BY fk_order_Id ;
    
    SELECT sum(total) INTO v_Price_Total from order_details
    WHERE fk_order_Id = p_OrderId
    GROUP BY fk_order_Id ;

    

    UPDATE orders
        SET quantity_total = v_Quantity,price_total = v_Price_Total
        WHERE id = p_OrderId;


END$$

CREATE DEFINER=`root`@`%` PROCEDURE `AddPointToCart` (IN `p_OrderId` INT)   BEGIN
    DECLARE v_GetVoucher DOUBLE;
    DECLARE v_CustomerID INT;

    
    SELECT id_fk_customer INTO v_CustomerID FROM orders WHERE id = p_OrderId;
        
    SELECT points INTO v_GetVoucher FROM customer WHERE id = v_CustomerID;

    UPDATE orders
    SET point_total = v_GetVoucher,total = (price_total+ship+tax)-(v_GetVoucher+coupon_total) 
    WHERE id = p_OrderId;



END$$

CREATE DEFINER=`root`@`%` PROCEDURE `AddToCart` (IN `p_CustomerID` INT, IN `p_ProductId` INT,IN `p_ColorId` INT, IN `p_Quantity` INT)   BEGIN
    DECLARE id_Real INT;
    DECLARE v_OrderId VARCHAR(50);
    DECLARE v_OrderIdTemp VARCHAR(50);
    DECLARE v_PriceProduct DOUBLE;
    DECLARE v_Quantity INT;
    DECLARE v_Total_donhang DOUBLE;
    DECLARE v_Total DOUBLE;

    DECLARE v_TempID VARCHAR(100);
    DECLARE v_Stt INT;




    IF p_CustomerID = -1 THEN
        IF(SELECT COUNT(*) FROM users WHERE temp_id LIKE 'T%') = 0 THEN
            SET v_TempID = 'T1';
        ELSE
            SELECT temp_id INTO v_TempID 
            FROM users 
            WHERE temp_id LIKE 'T%' 
            ORDER BY CAST(SUBSTRING_INDEX(temp_id, 'T', -1) AS UNSIGNED) DESC 
            LIMIT 1;

            SET v_Stt = CAST(SUBSTRING_INDEX(v_TempID, 'T', -1) AS UNSIGNED) + 1;
            SET v_TempID = CONCAT('T', v_Stt);
        END IF;
        
        INSERT INTO users(temp_id) VALUES(v_TempID);
        SELECT id INTO id_Real FROM users WHERE temp_id = v_TempID ;
        INSERT INTO customer(id,points) VALUES(id_Real,0);
        SELECT id_Real as id,v_TempID as temp_id;
    ELSE
        SELECT id INTO id_Real FROM users WHERE id = p_CustomerID LIMIT 1;
        SELECT id_Real as id,-1 as temp_id;

    END IF;


    IF p_ColorId<0 THEN
        SELECT price INTO v_PriceProduct FROM product_variant WHERE id = p_ProductId;
    ELSE
        SELECT color_price INTO v_PriceProduct FROM product_variant v,product_color c WHERE v.id = p_ProductId  and v.id = c.fk_variant_product and c.id = p_ColorId;
    END IF;

    SELECT v_PriceProduct as Price;



    SET v_Total = p_Quantity * v_PriceProduct;
    
    IF (SELECT COUNT(*) FROM orders WHERE id_fk_customer = id_Real AND process = 'giohang') = 0 THEN
        SELECT id INTO v_OrderIdTemp FROM orders ORDER BY id DESC LIMIT 1;
        IF v_OrderIdTemp IS NULL THEN
            SET v_OrderId = 1;
        ELSE
            SET v_OrderId = v_OrderIdTemp + 1;
        END IF;

        INSERT INTO orders(id, quantity_total, price_total,process,coupon_total,point_total,ship,tax,id_fk_customer)
        VALUES (v_OrderId,p_Quantity,v_Total,'giohang',0,0,0,0,id_Real);

        IF p_ColorId>0 THEN
            INSERT INTO order_details(price, quantity, total, fk_order_Id, fk_product_Id,fk_color_Id)
            VALUES (v_PriceProduct, p_Quantity, v_Total, v_OrderId, p_ProductId,p_ColorId);
        ELSE
            INSERT INTO order_details(price, quantity, total, fk_order_Id, fk_product_Id)
            VALUES (v_PriceProduct, p_Quantity, v_Total, v_OrderId, p_ProductId);
        END IF;

    ELSE
        SELECT id INTO v_OrderId FROM orders WHERE id_fk_customer = id_Real AND process = 'giohang' LIMIT 1;
        IF p_ColorId>0 THEN
            IF (SELECT COUNT(*) FROM order_details WHERE fk_order_Id = v_OrderId AND fk_product_Id = p_ProductId AND fk_color_Id = p_ColorId) > 0 THEN
                UPDATE order_details
                SET quantity = quantity + p_Quantity, total = total + v_Total
                WHERE fk_order_Id = v_OrderId AND fk_product_Id = p_ProductId AND fk_color_Id = p_ColorId;
            ELSE
                INSERT INTO order_details(price, quantity, total, fk_order_Id, fk_product_Id,fk_color_Id)
                VALUES (v_PriceProduct, p_Quantity, v_Total, v_OrderId, p_ProductId,p_ColorId);
            END IF;
        ELSE
            IF (SELECT COUNT(*) FROM order_details WHERE fk_order_Id = v_OrderId AND fk_product_Id = p_ProductId) > 0 THEN
                UPDATE order_details
                SET quantity = quantity + p_Quantity, total = total + v_Total
                WHERE fk_order_Id = v_OrderId AND fk_product_Id = p_ProductId;
            ELSE
                INSERT INTO order_details(price, quantity, total, fk_order_Id, fk_product_Id)
                VALUES (v_PriceProduct, p_Quantity, v_Total, v_OrderId, p_ProductId);
            END IF;
        END IF;
        
           

        SELECT SUM(quantity) INTO v_Quantity FROM order_details
        WHERE fk_order_Id = v_OrderId
        GROUP BY fk_order_Id;

        SELECT SUM(total) INTO v_Total_donhang FROM order_details
        WHERE fk_order_Id = v_OrderId
        GROUP BY fk_order_Id;

        UPDATE orders
        SET quantity_total = v_Quantity, price_total = v_Total_donhang
        WHERE id = v_OrderId;
    END IF;

    

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `AddVoucherToCart` (IN `p_OrderId` INT, IN `p_VoucherId` INT)   BEGIN
    DECLARE v_GetVoucher DOUBLE;
    DECLARE v_Quantity INT;
        
    SELECT  max_allowed_uses INTO v_Quantity FROM coupons WHERE id = p_VoucherId;

    IF v_Quantity > 0 THEN
        SELECT coupon_value INTO v_GetVoucher FROM coupons WHERE id = p_VoucherId;

        UPDATE orders
        SET coupon_total = v_GetVoucher,fk_coupon_Id = p_VoucherId,total = (price_total+ship+tax)-(v_GetVoucher+point_total) 
        WHERE id = p_OrderId;
    
    END IF;



END$$

CREATE DEFINER=`root`@`%` PROCEDURE `Cancel` (IN `p_OrderId` INT)   BEGIN

	DECLARE v_Process VARCHAR(255) ;
	DECLARE v_customerId int;
	DECLARE v_points int;
	DECLARE v_couponId int;

	SELECT process INTO v_Process FROM orders WHERE id = p_OrderId;

    IF v_Process = 'dangdat' THEN

        SELECT id_fk_customer INTO v_customerId FROM orders
        WHERE id = p_OrderId;

        SELECT fk_coupon_Id INTO v_couponId FROM orders
        WHERE id = p_OrderId;

        SELECT point_total INTO v_points FROM orders
        WHERE id = p_OrderId;

        UPDATE coupons
        SET max_allowed_uses = max_allowed_uses + 1
        WHERE id = v_couponId;

        UPDATE customer
        SET points =  v_points
        WHERE id = v_customerId;

        
        UPDATE product_variant
        SET quantity = quantity + (
            SELECT quantity
            FROM order_details
            WHERE order_details.fk_product_Id = product_variant.id AND order_details.fk_order_Id = p_OrderId
        )
        WHERE id IN (
            SELECT fk_product_Id
            FROM order_details
            WHERE fk_order_Id = p_OrderId
        );
        

        UPDATE orders
        SET process  = 'dahuy'
        WHERE id = p_OrderId;

        DELETE FROM bills 
        WHERE fk_order_Id = p_OrderId;

    
    END IF;
    
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `DeleteToCart` (IN `p_id` INT)   BEGIN
	DECLARE v_Quantity INT;
	DECLARE v_Total_Product DOUBLE;
    DECLARE v_OrderId INT;

    SELECT fk_order_Id INTO v_OrderId FROM order_details
    WHERE id = p_id;
   
   DELETE FROM order_details
   WHERE Id = p_id;
   
   
   	SELECT sum(quantity) INTO v_Quantity from order_details
        WHERE fk_order_Id = v_OrderId
        GROUP BY fk_order_Id ;
  	SELECT sum(total) INTO v_Total_Product from order_details
        WHERE fk_order_Id = v_OrderId
        GROUP BY fk_order_Id ;

        

 	UPDATE orders
            SET quantity_total = v_Quantity,price_total = v_Total_Product
            WHERE id = v_OrderId;
    

END$$

CREATE DEFINER=`root`@`%` PROCEDURE `MinusToCart` (IN `p_OrderId` VARCHAR(50), IN `p_ProductId` INT)   BEGIN

    DECLARE v_PriceProduct DOUBLE;
    DECLARE v_Quantity INT;
    DECLARE v_Quantity_check INT;
    DECLARE v_Price_Total DOUBLE;


    SELECT price INTO v_PriceProduct FROM order_details  WHERE fk_order_Id = p_OrderId and fk_product_Id = p_ProductId;




    
    UPDATE order_details
    SET quantity = quantity - 1, total = total - v_PriceProduct
    WHERE fk_order_Id = p_OrderId AND fk_product_Id = p_ProductId;

    SELECT quantity INTO v_Quantity_check FROM order_details WHERE fk_order_Id = p_OrderId and fk_product_Id = p_ProductId;


    IF v_Quantity_check = 0 THEN
        DELETE FROM order_details WHERE fk_order_Id = p_OrderId and fk_product_Id = p_ProductId;
    END IF;



    SELECT sum(quantity) INTO v_Quantity from order_details
    WHERE fk_order_Id = p_OrderId
    GROUP BY fk_order_Id ;
    
    SELECT sum(total) INTO v_Price_Total from order_details
    WHERE fk_order_Id = p_OrderId
    GROUP BY fk_order_Id ;

    

    UPDATE orders
        SET quantity_total = v_Quantity,price_total = v_Price_Total
        WHERE id = p_OrderId;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `Ordering` (IN `p_OrderId` VARCHAR(50), IN `p_Payment` VARCHAR(50) CHARACTER SET utf8)   BEGIN

	DECLARE v_customerId int;
	DECLARE v_couponId int;
	DECLARE v_points int;
    
    
    SELECT id_fk_customer INTO v_customerId FROM orders WHERE Id = p_OrderId;
    SELECT fk_coupon_Id INTO v_couponId FROM orders WHERE id = p_OrderId;
    SELECT point_total INTO v_points FROM orders WHERE id = p_OrderId;
    
    
    
   UPDATE product_variant
    SET quantity = quantity - (
        SELECT quantity
        FROM order_details
        WHERE order_details.fk_product_Id = product_variant.id AND order_details.fk_order_Id = p_OrderId
    )
    WHERE id IN (
        SELECT fk_product_Id
        FROM order_details
        WHERE fk_order_Id = p_OrderId
    );
    
   
    UPDATE coupons
    SET max_allowed_uses = max_allowed_uses -1
    WHERE id = v_couponId;

    UPDATE customer
    SET points = 0
    WHERE id = v_customerId;
    
    
        
    UPDATE orders
    SET process = 'dangdat'
    WHERE id = p_OrderId;

    INSERT INTO `bills`(`created_at`,`status_order`,`method_payment`, `fk_order_Id`) VALUES (NOW(),'Chưa thanh toán',p_Payment ,p_OrderId);
    
END$$

DELIMITER ;





    DELIMITER ;;
    CREATE PROCEDURE `Confirm`(
        IN p_OrderId INT,
        IN p_Address VARCHAR(255) CHARACTER Set utf8,
        IN p_CouponTotal DOUBLE,
        IN p_Email VARCHAR(255),
        IN p_FkCouponId INT,
        IN p_PointTotal DOUBLE,
        IN p_PriceTotal DOUBLE,
        IN p_Ship DOUBLE
    )
    BEGIN
        
        DECLARE v_Tax DOUBLE;    
        DECLARE v_Total DOUBLE;    
        DECLARE v_customerId INT;    
        SET v_Tax = p_PriceTotal* 0.02;
        SET v_Total = (p_PriceTotal+ v_Tax + p_Ship) - p_CouponTotal - p_PointTotal ;
        
        SELECT id_fk_customer INTO v_customerId FROM orders WHERE id = p_OrderId;

        
   UPDATE product_variant pv
JOIN (
    SELECT od.fk_product_id, SUM(od.quantity) AS total_quantity
    FROM order_details od
    WHERE od.fk_order_id = p_OrderId AND od.fk_color_id IS NULL
    GROUP BY od.fk_product_id
) AS sub ON pv.id = sub.fk_product_id
SET pv.quantity = pv.quantity - sub.total_quantity;

        
      UPDATE product_color pc
JOIN (
    SELECT od.fk_color_id, SUM(od.quantity) AS total_quantity
    FROM order_details od
    WHERE od.fk_order_id = p_OrderId AND od.fk_color_id IS NOT NULL
    GROUP BY od.fk_color_id
) AS sub ON pc.id = sub.fk_color_id
SET pc.quantity = pc.quantity - sub.total_quantity;

        
        IF p_FkCouponId != -1 THEN
            UPDATE coupons
            SET max_allowed_uses = max_allowed_uses -1
            WHERE id = p_FkCouponId;
        END IF;
        
        IF p_PointTotal != 0 THEN
            UPDATE customer
            SET points = 0
            WHERE id = v_customerId;
        END IF;
        
        
    
        UPDATE orders
        SET 
        total = v_Total,
        process = 'dangdat',
        created_at = NOW(),
        address = p_Address,
        email = p_Email,
        fk_coupon_id = p_FkCouponId,
        point_total = p_PointTotal,
        ship = p_Ship,
        tax = v_Tax
        WHERE id = p_OrderId;
                
            INSERT INTO bills (created_at, fk_order_id, method_payment,status_order) VALUES (NOW(),p_OrderId, 'tienmat','chuathanhtoan');

        
    END ;;
    DELIMITER ;


    


ALTER TABLE product_variant
DROP COLUMN price;




