

ALTER TABLE product_variant
ADD COLUMN price Double AS (original_price - original_price * (discount_percent / 100.0)) STORED;

INSERT INTO `brand` (`name`, `images`) VALUES
('Acer', 'acer_logo.png'),
('Apple', 'apple_logo.png'),
('Asus', 'asus_logo.png'),
('Dell', 'dell_logo.png'),
('Lenovo', 'lenovo_logo.png'),
('LG', 'lg_logo.png'),
('MSI', 'msi_logo.png'),
('Samsung', 'samsung_logo.png'),
('Sony', 'sony_logo.png'),
('Xiaomi', 'xiaomi_logo.png');



INSERT INTO `category` (`name`, `images`) VALUES
('Bàn phím', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Bộ nguồn', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Card đồ họa', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Chuột', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Điện thoại', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Laptop', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Linh kiện máy tính', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Màn hình', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Ổ cứng', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('PC - Máy tính bàn', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg'),
('Tai nghe', 'https://backstage.vn/storage/2023/10/Son-Tung-M-TP-chinh-thuc-quay-tro-lai-Vietnam-Idol-2023-sau-9-nam-e1697374758118-1140x570.jpg');



INSERT INTO `coupons` (`id`, `coupon_value`, `created_at`, `max_allowed_uses`, `name`) VALUES
(1, 10000, '2025-02-26 10:05:36', 0, 'A1B2C'),
(2, 20000, '2025-02-26 10:05:36', 8, 'D3E4F'),
(3, 50000, '2025-02-26 10:05:36', 9, 'G5H6I'),
(4, 100000, '2025-02-26 10:05:36', 3, 'J7K8L'),
(5, 10000, '2025-02-26 10:05:36', 10, 'M9N0O');




INSERT INTO `product` (`id`, `created_at`, `fk_brand`, `fk_category`, `name`, `short_description`) VALUES
(1, '2025-03-18 03:32:49', 'Apple', 'Laptop', 'MacBook Air M2', 'Mỏng, nhẹ, mạnh mẽ với chip M2'),
(2, '2025-03-18 03:32:49', 'Dell', 'Laptop', 'Dell XPS 15', 'Màn hình OLED, CPU Intel Gen 13'),
(3, '2025-03-18 03:32:49', 'Asus', 'Laptop', 'Asus ROG Strix G16', 'Laptop gaming mạnh mẽ, RTX 4060'),
(4, '2025-03-18 03:32:49', 'HP', 'Laptop', 'HP Spectre x360', 'Thiết kế 2-in-1, màn hình cảm ứng'),
(5, '2025-03-18 03:32:49', 'Lenovo', 'Laptop', 'Lenovo Legion 5', 'Dành cho gaming, Ryzen 7 6800H'),
(6, '2025-03-18 03:32:49', 'MSI', 'Laptop', 'MSI Stealth 15M', 'Laptop mỏng nhẹ, RTX 4070'),
(7, '2025-03-18 03:32:49', 'Apple', 'Điện thoại', 'iPhone 15 Pro', 'Titanium, camera zoom quang học 5X'),
(8, '2025-03-18 03:32:49', 'Samsung', 'Điện thoại', 'Samsung Galaxy S23 Ultra', 'Bút S Pen, camera 200MP'),
(9, '2025-03-18 03:32:49', 'Google', 'Điện thoại', 'Google Pixel 8', 'Android thuần, camera AI tốt nhất'),
(10, '2025-03-18 03:32:49', 'OnePlus', 'Điện thoại', 'OnePlus 11', 'Snapdragon 8 Gen 2, màn hình AMOLED 120Hz'),
(11, '2025-03-18 03:35:18', 'Dell', 'PC - Máy tính bàn', 'Dell OptiPlex 7090', 'Máy tính văn phòng mạnh mẽ, Intel i7-12700'),
(12, '2025-03-18 03:35:18', 'HP', 'PC - Máy tính bàn', 'HP EliteDesk 800 G6', 'Dòng máy tính doanh nghiệp cao cấp'),
(13, '2025-03-18 03:35:18', 'Asus', 'PC - Máy tính bàn', 'Asus ProArt Station D940MX', 'Máy tính đồ họa chuyên nghiệp'),
(14, '2025-03-18 03:35:18', 'MSI', 'PC - Máy tính bàn', 'MSI Codex R Gaming PC', 'PC gaming, RTX 4070, Ryzen 7 7700X'),
(15, '2025-03-18 03:35:18', 'Lenovo', 'PC - Máy tính bàn', 'Lenovo ThinkCentre M90t', 'Máy tính doanh nghiệp hiệu suất cao');



INSERT INTO `product_color` (`id`, `color_name`, `color_price`, `fk_variant_product`, `quantity`, `image`) VALUES
(1, 'Space Gray', 1200000, 1, 5, 'macbook_space_gray.jpg'),
(2, 'Silver', 1200000, 1, 5, 'macbook_silver.jpg'),
(3, 'Black', 1300000, 2, 4, 'macbook_black.jpg'),
(4, 'Lunar White', 999000, 6, 10, 'iphone_15_white.jpg'),
(5, 'Titanium Black', 999000, 6, 10, 'iphone_15_black.jpg'),
(6, 'Blue', 1200000, 8, 5, 'galaxy_s23_blue.jpg'),
(7, 'Green', 1200000, 8, 5, 'galaxy_s23_green.jpg'),
(8, 'Obsidian', 850000, 9, 8, 'pixel_8_obsidian.jpg'),
(9, 'Volcanic Red', 780000, 10, 6, 'oneplus_11_red.jpg'),
(10, 'Emerald Green', 780000, 10, 6, 'oneplus_11_green.jpg');


INSERT INTO `product_image` (`id`, `fk_image_product`, `image`) VALUES
(1, 1, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_air_m2_1_1_1.jpg'),
(2, 1, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_air_m2_1_1_1.jpg'),
(3, 2, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_air_m2_1_1_1.jpg'),
(4, 3, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_air_m2_1_1_1.jpg'),
(5, 3, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_air_m2_1_1_1.jpg'),
(6, 4, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_air_m2_1_1_1.jpg'),
(7, 7, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_air_m2_1_1_1.jpg'),
(8, 7, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_air_m2_1_1_1.jpg'),
(9, 8, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(10, 9, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(11, 11, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(12, 11, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(13, 12, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(14, 13, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(15, 13, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(16, 14, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(17, 14, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(18, 15, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(19, 15, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png'),
(20, 15, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_redmi_note_14_6gb_128gb_-_3.png');



INSERT INTO `product_variant` (`id`, `fk_variant_product`, `name_variant`, `quantity`, `discount_percent`, `import_price`, `original_price`) VALUES
(1, 1, 'MacBook Air M2 - 8GB RAM', 10, 4, 1000000, 1200000),
(2, 1, 'MacBook Air M2 - 16GB RAM', 8, 3, 1100000, 1300000),
(3, 2, 'Dell XPS 15 - i7 Gen 13', 12, 4, 1150000, 1300000),
(4, 3, 'Asus ROG Strix G16 - RTX 4060', 5, 7, 1300000, 1500000),
(5, 4, 'HP Spectre x360 - OLED', 15, 5, 900000, 1100000),
(6, 7, 'iPhone 15 Pro - 128GB', 20, 5, 850000, 999000),
(7, 7, 'iPhone 15 Pro - 256GB', 18, 5, 950000, 1099000),
(8, 8, 'Samsung Galaxy S23 Ultra - 512GB', 10, 4, 1100000, 1200000),
(9, 9, 'Google Pixel 8 - 128GB', 25, 3, 750000, 850000),
(10, 10, 'OnePlus 11 - 256GB', 30, 4, 700000, 780000),
(11, 11, 'Dell OptiPlex 7090 - i7-12700/16GB RAM/512GB SSD', 10, 3, 1300000, 1500000),
(12, 11, 'Dell OptiPlex 7090 - i5-12400/8GB RAM/256GB SSD', 15, 4, 1000000, 1200000),
(13, 12, 'HP EliteDesk 800 G6 - i7-10700/16GB RAM/512GB SSD', 8, 3, 1200000, 1400000),
(14, 13, 'Asus ProArt D940MX - i9-12900K/32GB RAM/1TB SSD', 5, 5, 1800000, 2000000),
(15, 14, 'MSI Codex R - Ryzen 7 7700X/RTX 4070/16GB RAM/1TB SSD', 7, 3, 1600000, 1800000),
(16, 15, 'Lenovo ThinkCentre M90t - i7-11700/16GB RAM/512GB SSD', 12, 4, 1150000, 1350000);

