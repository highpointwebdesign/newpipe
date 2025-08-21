-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               11.5.2-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.8.0.6908
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Dumping structure for table dbrhzbrqhhlw5g.categories
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.categories: ~16 rows (approximately)
REPLACE INTO `categories` (`id`, `name`, `description`) VALUES
	(1, 'Fruits', 'Fresh fruits'),
	(2, 'Dairy', 'Milk and dairy products'),
	(5, 'Cats', NULL),
	(6, 'My Requests', NULL),
	(9, 'Produce', NULL),
	(10, 'Freezer', NULL),
	(11, 'Dry Goods', NULL),
	(12, 'RX Items', NULL),
	(13, 'Soap/Bags/Kitchen', NULL),
	(14, 'Meats', NULL),
	(15, 'Refrigerator', NULL),
	(16, 'Spices', NULL),
	(17, 'Snacks', NULL),
	(18, 'Misc', NULL),
	(19, 'Not Listed', NULL),
	(21, 'RV', NULL);

-- Dumping structure for table dbrhzbrqhhlw5g.ingredient_inventory
CREATE TABLE IF NOT EXISTS `ingredient_inventory` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ingredient_name` varchar(255) NOT NULL,
  `quantity_on_hand` int(11) NOT NULL DEFAULT 0,
  `desired_inventory_level` int(11) NOT NULL DEFAULT 0,
  `sort_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.ingredient_inventory: ~3 rows (approximately)
REPLACE INTO `ingredient_inventory` (`id`, `ingredient_name`, `quantity_on_hand`, `desired_inventory_level`, `sort_order`) VALUES
	(1, 'apples id:1', 4, 5, 3),
	(2, 'oranges id:2', 6, 6, 1),
	(3, 'bananas id:3', 5, 6, 2);

-- Dumping structure for table dbrhzbrqhhlw5g.instructions
CREATE TABLE IF NOT EXISTS `instructions` (
  `instruction_id` int(11) NOT NULL AUTO_INCREMENT,
  `recipe_id` varchar(50) NOT NULL,
  `step_number` int(11) NOT NULL,
  `instruction_text` text DEFAULT NULL,
  PRIMARY KEY (`instruction_id`),
  KEY `recipe_id` (`recipe_id`),
  CONSTRAINT `instructions_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.instructions: ~0 rows (approximately)

-- Dumping structure for table dbrhzbrqhhlw5g.inventory_logs
CREATE TABLE IF NOT EXISTS `inventory_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `change_amount` int(11) NOT NULL,
  `change_type` enum('add','remove','adjust') NOT NULL,
  `note` text DEFAULT NULL,
  `changed_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `inventory_logs_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.inventory_logs: ~0 rows (approximately)

-- Dumping structure for table dbrhzbrqhhlw5g.items
CREATE TABLE IF NOT EXISTS `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category_id` int(11) DEFAULT NULL,
  `unit` varchar(20) DEFAULT 'unit',
  `current_quantity` int(11) NOT NULL DEFAULT 0,
  `desired_quantity` int(11) NOT NULL DEFAULT 1,
  `reorder_threshold` int(11) NOT NULL DEFAULT 1,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=89 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.items: ~72 rows (approximately)
REPLACE INTO `items` (`id`, `name`, `category_id`, `unit`, `current_quantity`, `desired_quantity`, `reorder_threshold`, `notes`) VALUES
	(2, 'Oranges', 1, 'pieces', 7, 7, 4, 'Navel oranges'),
	(3, 'Milk', 2, 'liters', 4, 4, 2, '2% milk'),
	(7, 'Navy Beans', NULL, 'unit', 0, 6, 4, NULL),
	(8, 'Honey', 11, 'unit', 3, 3, 2, NULL),
	(11, 'Grapes', 1, 'unit', 2, 2, 1, NULL),
	(12, 'Mangos', 1, 'unit', 5, 5, 4, NULL),
	(19, 'REQ1142914', 6, 'unit', 0, 1, 1, NULL),
	(20, ' TASK1090276', 6, 'unit', 0, 1, 1, NULL),
	(23, 'Aller-Flo', 12, 'unit', 0, 3, 1, NULL),
	(24, 'Apples', 9, 'unit', 0, 4, 2, NULL),
	(25, 'Squash', 9, 'unit', 0, 1, 1, NULL),
	(26, 'Sweet Potatoes', 9, 'unit', 0, 6, 3, NULL),
	(27, 'Bell Peppers', 9, 'unit', 0, 6, 3, NULL),
	(28, 'Assorted Fruits (Kiwi, Cherries, Grapes)', 9, 'unit', 0, 4, 1, NULL),
	(29, 'Peanut Butter', 11, 'unit', 2, 2, 1, NULL),
	(30, 'Strawberry Jam', 11, 'unit', 1, 1, 1, NULL),
	(31, 'Spaghetti Sauce', 11, 'unit', 3, 3, 1, NULL),
	(32, 'Ground Chicken', 14, 'unit', 6, 6, 3, NULL),
	(33, 'Breakfast Sausage', 14, 'unit', 2, 2, 1, NULL),
	(34, 'Butter', 11, 'unit', 3, 3, 2, NULL),
	(35, 'Mixed Veggies', 10, 'unit', 2, 2, 1, NULL),
	(36, 'Wet Wipes (non Chlorox)', 13, 'unit', 0, 10, 2, NULL),
	(37, 'Zip Lock Bags (Gallon)', 11, 'unit', 1, 1, 1, NULL),
	(38, 'Zip Lock Bags (Quart)', 11, 'unit', 1, 1, 1, NULL),
	(39, 'Zip Lock Bags (Sandwich)', 11, 'unit', 1, 1, 1, NULL),
	(41, 'Wipes (Clorox/Lysol)', 13, 'unit', 0, 3, 2, NULL),
	(42, 'Ultra Clean Free and Clear HE Laundry Detergent', 13, 'unit', 0, 1, 1, NULL),
	(43, 'Purfect Bars', 10, 'unit', 3, 3, 1, NULL),
	(44, 'Cheese Blocks (Mild > Medium)', 2, 'unit', 4, 4, 3, NULL),
	(45, 'Frozen Fruit (Mixed Berries)', 10, 'unit', 2, 2, 1, NULL),
	(46, 'Frozen Fruit (Cherries)', 10, 'unit', 3, 3, 1, NULL),
	(47, 'Refried Beans', 11, 'unit', 4, 4, 2, NULL),
	(48, 'Lentils Madras (Yellow PKG)', 11, 'unit', 6, 6, 3, NULL),
	(49, 'Goat Chese', 2, 'unit', 3, 3, 1, NULL),
	(50, 'Ground Beef', 14, 'unit', 4, 4, 2, NULL),
	(51, 'Almond Flour Tortillas', 15, 'unit', 0, 3, 1, NULL),
	(52, 'Chicken Tenders (RAW)', 14, 'unit', 3, 3, 1, NULL),
	(53, 'Chicken Nuggets', 10, 'unit', 3, 2, 1, NULL),
	(54, 'Meatballs', 15, 'unit', 0, 2, 1, NULL),
	(55, 'Chicken Patties (Lunch)', 15, 'unit', 0, 4, 1, NULL),
	(56, 'Nitrile Gloves', 12, 'unit', 0, 1, 1, NULL),
	(57, 'Maple Syrup', 11, 'unit', 2, 2, 1, NULL),
	(58, 'Apple Sauce', 11, 'unit', 5, 5, 2, NULL),
	(59, 'Salt (White)', 16, 'unit', 0, 1, 1, NULL),
	(60, 'Cumin', 16, 'unit', 0, 1, 1, NULL),
	(61, 'Canned Beans', 11, 'unit', 20, 20, 5, NULL),
	(62, 'Chia Seeds', 17, 'unit', 0, 1, 1, NULL),
	(63, 'Neil med Sinus Rinse with Bottle', 12, 'unit', 0, 1, 1, NULL),
	(64, 'Liquid soap Kirkland ultra shine plant-based dish soap unscented', 13, 'unit', 0, 1, 1, NULL),
	(65, 'Garbage Bags (13 Gallon)', 11, 'unit', 1, 1, 1, NULL),
	(66, 'Liquid dishwashing soap Kirkland brand big bottle', 13, 'unit', 0, 1, 1, NULL),
	(67, 'Paprika', 16, 'unit', 0, 1, 1, NULL),
	(68, 'Blue Dish Towels', 19, 'unit', 6, 6, 3, NULL),
	(69, 'Paper Towels', 11, 'unit', 2, 2, 1, NULL),
	(70, 'LED Headlamps', 18, 'unit', 2, 2, 2, NULL),
	(71, 'Rotel', 11, 'unit', 4, 4, 2, NULL),
	(72, 'Distilled Water', 18, 'unit', 1, 1, 1, NULL),
	(73, 'Diced Tomatoes', 11, 'unit', 6, 6, 2, NULL),
	(74, 'Organic Soup', 11, 'unit', 2, 2, 2, NULL),
	(75, 'Lysol Clean & Fresh Concentrate (90 FL OZ Jug)', 13, 'unit', 0, 1, 1, NULL),
	(76, 'Check the snack aisle for something cherry might like', 17, 'unit', 0, 4, 2, NULL),
	(77, 'Almond flour crackers', 17, 'unit', 0, 4, 2, NULL),
	(78, 'Salman (Canned)', 11, 'unit', 4, 4, 2, NULL),
	(79, 'Simple Mills Almond Flour Crackers Find Ground Sea Salt', 17, 'unit', 0, 4, 3, NULL),
	(80, 'Crunch Master Avocado Toast - Guacamole', 17, 'unit', 0, 0, 0, NULL),
	(81, 'Seeds of Change', 11, 'unit', 3, 3, 1, NULL),
	(83, 'REQ1147639', 6, 'unit', 1, 1, 1, NULL),
	(84, 'Almond Flour', 21, 'unit', 3, 5, 3, NULL),
	(85, 'INC0782150', 6, 'unit', 1, 1, 1, NULL),
	(86, 'test', 5, 'unit', 4, 4, 3, NULL),
	(87, 'MagicDraw Demand DMND0185868', 6, 'unit', 1, 1, 1, NULL),
	(88, 'MagicDraw Demand DMND0185869', 6, 'unit', 1, 1, 1, NULL);

-- Dumping structure for table dbrhzbrqhhlw5g.log
CREATE TABLE IF NOT EXISTS `log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entry` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.log: ~0 rows (approximately)

-- Dumping structure for table dbrhzbrqhhlw5g.meals
CREATE TABLE IF NOT EXISTS `meals` (
  `mealID` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `servings` int(11) DEFAULT 4,
  `created_at` datetime DEFAULT current_timestamp(),
  `mealTypeID` int(11) DEFAULT NULL,
  `fav` tinyint(4) NOT NULL DEFAULT 0,
  `isDeleted` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0 false; 1 true',
  `recipe_id` varchar(50) DEFAULT NULL COMMENT 'recipe_id from the import process',
  `details` longtext DEFAULT NULL,
  `uc` datetime NOT NULL DEFAULT current_timestamp(),
  `um` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`mealID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.meals: ~28 rows (approximately)
REPLACE INTO `meals` (`mealID`, `title`, `servings`, `created_at`, `mealTypeID`, `fav`, `isDeleted`, `recipe_id`, `details`, `uc`, `um`) VALUES
	(1, 'Beef and Red Bean Chili', 6, '2025-08-17 16:43:08', 3, 0, 0, '65e397521ddf77bca5c237fb', '**Optional**\r\nAdd 1-2 Seasoned Rice packets from Costco added to mix as optional\r\n\r\nDirections\r\n\r\n1. Brown the beef.\r\n2. Add onion powder, garlic powder, chili powder.\r\n3. Add tomatoes, beans, salt and pepper.\r\n4. Bring to a boil and then simmer for 15-20 minutes.\r\n5. Adjust seasoning with salt and pepper as needed.', '2025-08-17 16:43:08', '2025-08-21 18:29:16'),
	(2, 'Potato Stroganoff Hamburger Helper', 4, '2025-08-17 16:43:08', 3, 0, 0, '65e3a1e92948d057fe6ebd6d', '**NOTES**\r\n- If needed, add 1/2 cup water\r\n- Tapioca - if needed for thickening, mix with a small amount of cold water before adding to sauce pan.\r\n\r\n**Directions**\r\n1. Cook beef separately.\r\n2. Cook potatoes separately.\r\n3. To the cooked beef, add the milk and water and all the seasonings.\r\n4. If needed, add the tapioca thickener at this stage.\r\n5. Add the cooked sliced potatoes.', '2025-08-17 16:43:08', '2025-08-20 01:56:18'),
	(3, 'Chicken Alfredo with Brocolli', 4, '2025-08-17 16:43:08', 3, 0, 0, '65e3a89d761eefa02d605b06', 'Cream sauce, cooked separately\r\n\r\nDirections\r\n\r\n1. Cook the chicken, pasta and broccoli all separately.\r\n2. Mix the cream sauce ingredients together and bring to a slow boil.\r\n3. Combine all the ingredients together.', '2025-08-17 16:43:08', '2025-08-20 16:16:00'),
	(4, 'Fudd Hamburger Helper', 6, '2025-08-17 16:43:08', 3, 0, 0, '65e3abc0f8cd991e2ff05bff', 'Optional if making as a burger patty: Lettuce, mayo, cheese, rotel\r\n\r\n**Directions:**\r\n1. Mix all spices together.\r\n2. Mix spices by hand tenderly into the meat so it doesn’t get too tough.\r\n3. Form 12 patties, flat like tortillas but also loosely packed so doesn’t dry out. (about 80 grams per patty)\r\n4. Preheat the pan on mid heat. Browning both sides of the patties but not cooking all the way through. Those become leftovers to freeze and cooked thoroughly as reheated for future meals.\r\n5. Thoroughly cook the remaining two patties for dinner that night.\r\n6. Make your burger with whatever toppings you prefer.', '2025-08-17 16:43:08', '2025-08-20 02:26:26'),
	(5, 'Tacos or Taco Bowl', 4, '2025-08-17 16:43:08', 3, 0, 0, '65ea48c89c856f6ad662250b', 'Ingredients\r\n\r\nINGREDIENTS DARYL HAD BEEN USING\r\n- 1 pound ground beef\r\n- 1 can refried beans\r\n- Corn chips of in bowl or shells\r\n- 1 can diced tomatoes,\r\n- 1/2 cup shredded cheese\r\n- 1 tablespoon onion powder\r\n- 1/2 teaspoon garlic powder\r\n- 2 teaspoons cumin powder\r\n- 1/2 teaspoon chili powder\r\n- 1 1/2  teaspoons sea salt\r\n\r\nDirections\r\n\r\n1. Brown the beef.\r\n2. Add spices.\r\n3. Add kidney beans.\r\n4. Serve meat and bean mixter over corn chips. Top with desired toppings.', '2025-08-17 16:43:08', '2025-08-20 01:41:49'),
	(6, 'Creamy Bean Soup', 4, '2025-08-17 16:43:08', 3, 0, 0, '65ee372e7bb627c87df43ca2', '**Directions**\r\n1. In a large pot, add beans and broth and spices. Boil. Simmer, covered, 10 minutes.\r\n2. Blend with immersion blender.\r\n3. Serve with cheese on top.', '2025-08-17 16:43:08', '2025-08-20 02:29:33'),
	(7, 'Nugget quick lunch', 2, '2025-08-17 16:43:08', 3, 0, 0, '66804801d104693530f1c13c', 'Don\'t put nuggets in until preheat is done\r\nPlace parchment paper or equivalent in oven\r\nPreheat 425\r\nLay 7 nuggets in oven\r\nSet time for 16 minutes\r\nFlip nuggets over\r\nSet timer for another 6-7 minutes (check periodically for preferred brownness)\r\n\r\nIf you want veggie, we have mixed veggies, green beans, and broccoli. 1/2 to 1 C covered with water. Bring to boil, reduce heat to light boil for 3-4 minutes (broccoli may need an additional min or two)', '2025-08-17 16:43:08', '2025-08-20 02:13:49'),
	(8, 'Salmon Patties', 6, '2025-08-17 16:43:08', 3, 0, 0, '66b7c63aef984308441f4e1c', '1 1/2 tablespoon chia seed (to make 1.5 egg equivalant)\r\n\r\nDirections\r\n1. Add salmon and eggs to a bowl and mix.\r\n2. Make ~7 patties at 80 grams each\r\n3. Add Almond flour\r\n4. ‌Measure out 80g patties, flatter the better\r\n5. Stove at 4.5\r\n6. Cook each side of the patty 4-5 minutes or until golden brown\r\n7. May need to add some oil as you cook the second batch of patties.', '2025-08-17 16:43:08', '2025-08-20 01:52:03'),
	(9, 'Tuscan-Style Cannellini Bean Stew', 6, '2025-08-17 16:43:08', 3, 0, 0, '67f6d3181ecadb49da60fcbf', 'Servings: 6\r\n\r\n**How-to:**\r\n\r\n1. Sauté garlic in olive oil until fragrant.\r\n2. Add tomatoes, beans, broth, herbs, and seasonings.\r\n3. Simmer 15–20 minutes until thickened and cozy.\r\n4. Add greens at the end if using, and finish with lemon juice for brightness.', '2025-08-17 16:43:08', '2025-08-20 01:32:54'),
	(10, 'Black Bean & Ground Chicken Skillet', 2, '2025-08-17 16:43:08', 3, 0, 0, '67f6d7a90dfe222116694fa7', '**Optional:**\r\nServe over cooked rice or pasta\r\n\r\n**How-to:**\r\nBrown chicken with spices, add tomato sauce + black beans, simmer 5–10 min. Serve over rice or pasta. Add cheese if you want.', '2025-08-17 16:43:08', '2025-08-20 16:13:01'),
	(11, 'Cannellini Bean & Ground Chicken Skillet', 4, '2025-08-17 16:43:08', 3, 0, 0, '67f6d8ed0ba832c5d59c9c5b', '', '2025-08-17 16:43:08', '2025-08-20 01:22:52'),
	(12, 'Ground Beef and Navy Bean Hash', 4, '2025-08-17 16:43:08', 3, 0, 0, '67f6db98db7791bf47f312e3', '**INSTRUCTIONS:**\r\nBrown beef with spices. Stir in beans and tomato sauce. Simmer for 5–10 minutes. Serve as-is or over rice.', '2025-08-17 16:43:08', '2025-08-20 02:23:01'),
	(13, 'Navy Bean and Jackfruit Stew', 4, '2025-08-17 16:43:08', 3, 0, 0, '67f6dc0b38817fdb9a7f5ccc', '**Optional:**\r\ncoconut milk splash at the end\r\n\r\n**How-to:**\r\nSauté jackfruit with spices, add beans & tomatoes, simmer 20–30 min. Great on its own or over pasta or rice.', '2025-08-17 16:43:08', '2025-08-20 02:16:50'),
	(14, 'Kidney Bean and Ground Chicken Curry', 4, '2025-08-17 16:43:08', 3, 0, 0, '67f6e8831688ad96ae92de1b', '**INSTRUCTIONS:**\r\nBrown chicken with spices, add beans and coconut milk, simmer 15–20 minutes. Serve over rice.', '2025-08-17 16:43:08', '2025-08-20 02:20:40'),
	(15, 'Spicy Mixed Bean & Ro-Tel Chili', 4, '2025-08-17 16:43:08', 3, 0, 0, '67f6fda74d30ab49c784ad5b', '**How-to:**\r\nCombine beans, Ro-Tel, and seasonings. Simmer for 20–30 minutes. Serve over corn mash (aka polenta), or top with cheese if desired.', '2025-08-17 16:43:08', '2025-08-20 01:48:48'),
	(16, 'Yummy Chicken and Quinoa', 6, '2025-08-17 16:43:08', 3, 0, 0, '68a0acdc4643de04aa6060c1', 'Servings: 6\r\n\r\nDirections\r\nRinse quinoa well. Add to the LARGE pot with water per instructions on the bag. Add all the ingredients except the chicken. Stir. Then place chicken tenders on top. Chicken should not be fully immersed. Cook according to quinoa package directions plus about 10 more minutes.', '2025-08-17 16:43:08', '2025-08-20 01:30:12'),
	(17, 'Taco seasoning', 1, '2025-08-17 16:43:08', 8, 0, 0, '68a0af19cd35e80adf6f7800', 'Use this combination per pound of ground meat. Add 1 tablespoon of water to the meat and spices. Drain the meat before adding the seasoning and water\r\n\r\n\r\n\r\n\r\n', '2025-08-17 16:43:08', '2025-08-20 01:43:44'),
	(18, 'Mac and cheese for one meal', 2, '2025-08-17 16:43:08', 8, 0, 0, '68a0af9f07832d591221fd76', 'This recipe can also be used if you just want the cheese sauce\r\n\r\n', '2025-08-17 16:43:08', '2025-08-20 02:18:24'),
	(19, 'Breakfast Sausage Seasoning', 8, '2025-08-17 16:43:08', 1, 0, 0, '68a0afde9883e9010b8c6b3c', 'Servings: 8\r\n\r\nIngredients\r\n\r\n- 1 teaspoon salt\r\n- 1/2 teaspoon black pepper\r\n- 1 teaspoon sage\r\n- 1/2 teaspoon thyme\r\n- 1/8 teaspoon rosemary\r\n- 1/2 tablespoon Sucanat Cane Sugar\r\n- 1/8 teaspoon cayenne pepper\r\n- 1 pound ground chicken (never beef)', '2025-08-17 16:43:08', '2025-08-20 01:09:12'),
	(20, 'Paleo Porridge (Breakfast Oatmeal)', 27, '2025-08-17 16:43:08', 1, 0, 0, '68a0aff22e3a03e54973987b', 'Servings: 27 servings\r\n\r\nSeparate fiber addition is 1 cup brown flaxseed and 1 cup chia seeds both ground up.\r\n\r\nInstructions\r\n\r\n1. Blend all ingredients in a food processor\r\n2. Store some in fridge and some in freezer\r\n3. Cook servings in boiling water like oatmeal stirring in maples syrup and raisins when serving.', '2025-08-17 16:43:08', '2025-08-20 02:12:17'),
	(21, 'Pizza Crust-GF', 6, '2025-08-17 16:43:08', 3, 0, 0, '68a1eb6e2bb1d83d0de6f7cc', '**Makes 3 medium crusts:**\r\n\r\n1 Tbsp chia seeds + 2.5 Tbsp water = a chia egg\r\n\r\n**Directions:**\r\n\r\n1. Preheat the oven to 425 degrees.\r\n2. Line a round pizza pan or cookie sheet with parchment paper. (I have 4 pizza pans so I can bake all three at once)\r\n3. Combine the dry ingredients in a large bowl. Whisk to blend together.\r\n4. Add eggs and milk to the dry ingredients. Mix well. The batter will be runny—not like typical pizza dough.\r\n5. Use a spatula to spread the batter evenly onto the pan in a circle shape.\r\n6. Bake the crust in the preheated oven for 8-12 minutes.\r\n7. Remove crust from oven and top with sauce and desired toppings. Or freeze the crust for later. Once cooled, place parchment paper between the crusts and they will store perfectly in a ziplock gallon freezer bag until ready to use. I also make sure the size of my circle stays within the range of a gallon bag for this reason.\r\n8. Bake for another 10-15 minutes with toppings.\r\n\r\n‌\r\n**Other Option: Ingredients for 1 large crust:**\r\n- 2 cups almond flour\r\n- 1 cup arrowroot powder or tapioca flour\r\n- 1 1/2 teaspoon baking powder\r\n- 1 1/2 teaspoon salt\r\n- 1 1/2 teaspoon oregano\r\n- 1/4 teaspoon black pepper\r\n- 3 eggs\r\n- 1/2 cup milk\r\n\r\n‌Source: [https://unrefinedkitchen.com/2012/04/14/pizza-crust-primalpaleo/](https://unrefinedkitchen.com/2012/04/14/pizza-crust-primalpaleo/ "smartCard-inline")', '2025-08-17 16:43:08', '2025-08-20 02:02:15'),
	(22, 'Chia seed egg substitute', 1, '2025-08-17 16:43:08', 8, 0, 0, '68a1ec7bd908de7fb29442a6', 'One egg \r\n\r\n*2 tablespoon chia seed\r\n*1/4 cup water\r\n\r\n1 Tbsp chia seeds + 2.5 Tbsp water = a chia egg\r\n\r\nDirections: \r\nSoak chia seeds and water for 10  minutes stirring periodically', '2025-08-17 16:43:08', '2025-08-20 02:30:47'),
	(23, 'Breakfast scramble', 2, '2025-08-17 16:43:08', 1, 0, 0, '68a1f1335869161cad979736', '- add oil to skillet (med-hi)\r\n- dice the potatoes and cook for 7 minutes\r\n- dice bell peppers\r\n- start the oatmeal\r\n- scoop the potatoes to a napkin and add salt and allow to cool\r\n- dump excell oil if needed\r\n- bring to boil water for tea\r\n- add the bell peppers\r\n- saute bell peppers for 7 minutes\r\n- add meat, garbonzo beans, spinach, and salt\r\n- cover for 5-6 minutes\r\n', '2025-08-17 16:43:08', '2025-08-20 01:08:12'),
	(32, 'Black Beans and Rice', 2, '2025-08-17 13:08:27', 2, 0, 0, NULL, '', '2025-08-17 13:08:27', '2025-08-20 00:33:29'),
	(34, 'test', 4, '2025-08-21 10:53:22', 3, 0, 1, NULL, 'test', '2025-08-21 10:53:22', '2025-08-21 16:00:44'),
	(35, 'test', 4, '2025-08-21 10:54:02', 8, 0, 1, NULL, 'test', '2025-08-21 10:54:02', '2025-08-21 16:00:39'),
	(36, 'test 2', 4, '2025-08-21 10:54:32', 2, 0, 1, NULL, 'teata', '2025-08-21 10:54:32', '2025-08-21 16:00:49'),
	(37, 'test 5', 4, '2025-08-21 11:13:05', 4, 0, 1, NULL, 'test', '2025-08-21 11:13:05', '2025-08-21 16:15:49');

-- Dumping structure for table dbrhzbrqhhlw5g.meal_description
CREATE TABLE IF NOT EXISTS `meal_description` (
  `descriptionID` int(11) NOT NULL AUTO_INCREMENT,
  `recipe_id` varchar(50) DEFAULT NULL,
  `date_last_activity` varchar(50) DEFAULT NULL,
  `meal_details` text DEFAULT NULL,
  PRIMARY KEY (`descriptionID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.meal_description: ~0 rows (approximately)

-- Dumping structure for table dbrhzbrqhhlw5g.meal_ingredients
CREATE TABLE IF NOT EXISTS `meal_ingredients` (
  `miID` int(11) NOT NULL AUTO_INCREMENT,
  `mealID` int(11) DEFAULT NULL,
  `ingredientID` int(11) DEFAULT NULL,
  `quantity` decimal(10,2) DEFAULT NULL,
  `unit` int(11) DEFAULT NULL,
  `quantityID` int(11) DEFAULT NULL,
  PRIMARY KEY (`miID`) USING BTREE,
  KEY `meal_id` (`mealID`) USING BTREE,
  CONSTRAINT `meal_ingredients_ibfk_1` FOREIGN KEY (`mealID`) REFERENCES `meals` (`mealID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1254 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.meal_ingredients: ~204 rows (approximately)
REPLACE INTO `meal_ingredients` (`miID`, `mealID`, `ingredientID`, `quantity`, `unit`, `quantityID`) VALUES
	(112, 32, 36, 0.50, 1, NULL),
	(113, 32, 4, 2.00, 18, NULL),
	(114, 32, 66, 2.00, 18, NULL),
	(115, 32, 67, 0.50, 3, NULL),
	(116, 32, 31, 0.50, 3, NULL),
	(117, 32, 69, 0.25, 3, NULL),
	(234, 19, 36, 1.00, 1, NULL),
	(235, 19, 9, 0.50, 1, NULL),
	(236, 19, 33, 1.00, 1, NULL),
	(237, 19, 43, 0.50, 1, NULL),
	(238, 19, 32, 0.25, 1, NULL),
	(239, 19, 38, 0.50, 2, NULL),
	(240, 19, 13, 0.25, 1, NULL),
	(241, 19, 22, 1.00, 17, NULL),
	(286, 11, 22, 1.00, 17, NULL),
	(287, 11, 78, 1.00, 19, NULL),
	(288, 11, 79, 0.50, 3, NULL),
	(289, 11, 20, 1.00, 1, NULL),
	(290, 11, 25, 1.00, 1, NULL),
	(291, 11, 27, 1.00, 1, NULL),
	(292, 11, 36, 0.50, 1, NULL),
	(293, 11, 9, 0.50, 1, NULL),
	(294, 11, 31, 0.50, 3, NULL),
	(322, 16, 77, 1.00, 17, NULL),
	(323, 16, 64, 1.00, 19, NULL),
	(324, 16, 80, 2.00, 3, NULL),
	(325, 16, 36, 2.00, 1, NULL),
	(326, 16, 81, 1.00, 18, NULL),
	(327, 16, 20, 1.00, 1, NULL),
	(328, 16, 25, 1.00, 1, NULL),
	(329, 16, 17, 2.00, 1, NULL),
	(374, 9, 37, 1.00, 17, NULL),
	(375, 9, 78, 2.00, 19, NULL),
	(376, 9, 20, 1.00, 1, NULL),
	(377, 9, 64, 1.00, 19, NULL),
	(378, 9, 43, 1.00, 1, NULL),
	(379, 9, 82, 2.00, 3, NULL),
	(380, 9, 76, 1.00, 2, NULL),
	(381, 9, 36, 0.50, 1, NULL),
	(382, 9, 71, 0.50, 3, NULL),
	(383, 9, 9, 0.25, 1, NULL),
	(411, 5, 15, 1.00, 2, NULL),
	(412, 5, 17, 1.00, 1, NULL),
	(413, 5, 29, 1.00, 1, NULL),
	(414, 5, 20, 1.00, 1, NULL),
	(415, 5, 25, 1.00, 1, NULL),
	(416, 5, 27, 0.50, 1, NULL),
	(417, 5, 36, 0.50, 1, NULL),
	(418, 5, 9, 0.50, 1, NULL),
	(446, 17, 15, 1.00, 2, NULL),
	(447, 17, 17, 1.00, 1, NULL),
	(448, 17, 29, 1.00, 1, NULL),
	(449, 17, 20, 1.00, 1, NULL),
	(450, 17, 25, 1.00, 1, NULL),
	(451, 17, 27, 0.50, 1, NULL),
	(452, 17, 36, 0.50, 1, NULL),
	(453, 17, 9, 0.50, 1, NULL),
	(489, 15, 8, 1.00, 19, NULL),
	(490, 15, 23, 1.00, 19, NULL),
	(491, 15, 82, 1.00, 3, NULL),
	(492, 15, 83, 1.00, 19, NULL),
	(493, 15, 84, 1.00, 19, NULL),
	(494, 15, 15, 1.00, 1, NULL),
	(495, 15, 20, 1.00, 1, NULL),
	(496, 15, 25, 1.00, 1, NULL),
	(497, 15, 17, 1.00, 1, NULL),
	(507, 8, 34, 1.00, 19, NULL),
	(508, 8, 14, 1.50, 2, NULL),
	(509, 8, 45, 4.50, 2, NULL),
	(510, 8, 1, 1.25, 3, NULL),
	(511, 8, 76, 1.00, 2, NULL),
	(556, 2, 21, 1.00, 17, NULL),
	(557, 2, 73, 1.50, 3, NULL),
	(558, 2, 85, 1.00, 19, NULL),
	(559, 2, 45, 1.00, 3, NULL),
	(560, 2, 25, 1.00, 16, NULL),
	(561, 2, 20, 2.00, 1, NULL),
	(562, 2, 36, 2.00, 1, NULL),
	(563, 2, 38, 1.00, 1, NULL),
	(564, 2, 9, 1.00, 1, NULL),
	(565, 2, 41, 1.00, 2, NULL),
	(593, 21, 1, 3.00, 3, NULL),
	(594, 21, 86, 1.50, 3, NULL),
	(595, 21, 87, 2.25, 1, NULL),
	(596, 21, 36, 2.25, 1, NULL),
	(597, 21, 27, 2.25, 1, NULL),
	(598, 21, 9, 0.50, 1, NULL),
	(599, 21, 14, 3.00, 2, NULL),
	(600, 21, 45, 0.75, 3, NULL),
	(736, 20, 89, 2.00, 3, NULL),
	(737, 20, 90, 2.00, 3, NULL),
	(738, 20, 91, 7.50, 3, NULL),
	(739, 20, 92, 3.50, 3, NULL),
	(740, 20, 93, 3.00, 3, NULL),
	(741, 20, 94, 1.00, 3, NULL),
	(742, 20, 95, 2.00, 3, NULL),
	(743, 20, 96, 2.00, 3, NULL),
	(744, 20, 97, 2.00, 3, NULL),
	(745, 20, 74, 2.00, 17, NULL),
	(746, 20, 98, 1.50, 3, NULL),
	(747, 20, 99, 1.00, 3, NULL),
	(748, 20, 36, 3.00, 1, NULL),
	(749, 20, 75, 4.00, 3, NULL),
	(750, 20, 100, 1.00, 3, NULL),
	(751, 20, 14, 1.00, 3, NULL),
	(753, 7, 28, 14.00, 18, NULL),
	(798, 13, 101, 1.00, 19, NULL),
	(799, 13, 83, 1.00, 19, NULL),
	(800, 13, 64, 1.00, 19, NULL),
	(801, 13, 45, 0.25, 3, NULL),
	(802, 13, 36, 1.00, 1, NULL),
	(803, 13, 20, 1.00, 1, NULL),
	(804, 13, 25, 1.00, 1, NULL),
	(805, 13, 29, 1.00, 1, NULL),
	(806, 13, 27, 1.00, 1, NULL),
	(807, 13, 31, 1.00, 3, NULL),
	(817, 18, 102, 1.00, 3, NULL),
	(818, 18, 12, 1.00, 2, NULL),
	(819, 18, 36, 0.25, 1, NULL),
	(820, 18, 6, 0.50, 3, NULL),
	(821, 18, 45, 0.25, 19, NULL),
	(866, 14, 22, 1.00, 17, NULL),
	(867, 14, 23, 1.00, 19, NULL),
	(868, 14, 85, 0.50, 3, NULL),
	(869, 14, 20, 0.75, 1, NULL),
	(870, 14, 25, 0.75, 1, NULL),
	(871, 14, 17, 1.00, 1, NULL),
	(872, 14, 29, 1.00, 1, NULL),
	(873, 14, 103, 0.50, 1, NULL),
	(874, 14, 36, 0.25, 1, NULL),
	(875, 14, 31, 1.00, 3, NULL),
	(896, 12, 21, 1.00, 17, NULL),
	(897, 12, 83, 1.00, 19, NULL),
	(898, 12, 79, 0.50, 3, NULL),
	(899, 12, 25, 1.00, 1, NULL),
	(900, 12, 20, 1.00, 1, NULL),
	(901, 12, 27, 1.00, 1, NULL),
	(902, 12, 29, 1.00, 1, NULL),
	(938, 4, 21, 1.00, 17, NULL),
	(939, 4, 29, 2.00, 1, NULL),
	(940, 4, 9, 0.25, 1, NULL),
	(941, 4, 36, 1.25, 1, NULL),
	(942, 4, 38, 1.25, 1, NULL),
	(943, 4, 20, 0.25, 1, NULL),
	(944, 4, 25, 0.25, 1, NULL),
	(945, 4, 13, 0.25, 1, NULL),
	(946, 4, 102, 4.50, 3, NULL),
	(1024, 6, 20, 0.50, 1, NULL),
	(1025, 6, 25, 1.00, 2, NULL),
	(1026, 6, 15, 0.50, 2, NULL),
	(1027, 6, 17, 0.50, 1, NULL),
	(1028, 6, 43, 1.00, 1, NULL),
	(1029, 6, 104, 2.00, 3, NULL),
	(1030, 6, 23, 2.00, 3, NULL),
	(1031, 6, 105, 2.00, 3, NULL),
	(1032, 6, 82, 2.00, 3, NULL),
	(1033, 6, 6, 0.50, 3, NULL),
	(1034, 6, 35, 0.50, 1, NULL),
	(1035, 6, 9, 0.50, 1, NULL),
	(1036, 6, 13, 0.25, 1, NULL),
	(1037, 22, 14, 2.00, 2, NULL),
	(1038, 22, 45, 0.25, 3, NULL),
	(1074, 10, 22, 1.00, 17, NULL),
	(1075, 10, 8, 1.00, 19, NULL),
	(1076, 10, 79, 0.50, 3, NULL),
	(1077, 10, 20, 0.50, 1, NULL),
	(1078, 10, 25, 0.50, 1, NULL),
	(1079, 10, 29, 1.00, 1, NULL),
	(1080, 10, 36, 0.50, 1, NULL),
	(1081, 10, 9, 0.50, 1, NULL),
	(1082, 10, 102, 2.00, 3, NULL),
	(1127, 3, 22, 1.00, 17, NULL),
	(1128, 3, 102, 2.00, 3, NULL),
	(1129, 3, 81, 1.00, 18, NULL),
	(1130, 3, 25, 0.50, 1, NULL),
	(1131, 3, 36, 1.00, 1, NULL),
	(1132, 3, 20, 1.00, 1, NULL),
	(1133, 3, 38, 0.50, 1, NULL),
	(1134, 3, 9, 0.50, 1, NULL),
	(1135, 3, 85, 1.00, 19, NULL),
	(1136, 3, 41, 3.50, 1, NULL),
	(1137, 23, 7, 0.50, 3, NULL),
	(1138, 23, 73, 2.00, 18, NULL),
	(1139, 23, 22, 0.50, 3, NULL),
	(1140, 23, 71, 0.50, 3, NULL),
	(1141, 23, 36, 0.50, 1, NULL),
	(1142, 23, 74, 0.50, 3, NULL),
	(1143, 23, 75, 4.00, 2, NULL),
	(1144, 23, 45, 1.00, 3, NULL),
	(1145, 23, 76, 1.00, 2, NULL),
	(1146, 23, 42, 1.50, 1, NULL),
	(1152, 36, 78, 4.00, 3, NULL),
	(1156, 37, 92, -0.50, 19, NULL),
	(1157, 37, 86, 4.00, 6, NULL),
	(1158, 37, 4, 5.00, 3, NULL),
	(1245, 1, 25, NULL, 2, 8),
	(1246, 1, 15, NULL, 2, 3),
	(1247, 1, 21, NULL, 17, 8),
	(1248, 1, 64, NULL, 19, 12),
	(1249, 1, 23, NULL, 19, 12),
	(1250, 1, 36, NULL, 1, 12),
	(1251, 1, 6, NULL, 3, 4),
	(1252, 1, 5, NULL, 18, 8),
	(1253, 1, 0, NULL, 0, 0);

-- Dumping structure for table dbrhzbrqhhlw5g.meal_types
CREATE TABLE IF NOT EXISTS `meal_types` (
  `mealTypeID` int(11) NOT NULL AUTO_INCREMENT,
  `mealTypeName` varchar(50) DEFAULT NULL,
  `mealTypeColor` varchar(50) DEFAULT NULL,
  `orderby` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`mealTypeID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.meal_types: ~5 rows (approximately)
REPLACE INTO `meal_types` (`mealTypeID`, `mealTypeName`, `mealTypeColor`, `orderby`) VALUES
	(1, 'Breakfast', '#5C3799', 10),
	(2, 'Lunch', '#1ab5ac', 20),
	(3, 'Dinner', '#2953E8', 30),
	(4, 'Dessert', '#ff887c', 40),
	(8, 'Sides and Sauces and Spices', '#e1e1e1', 500);

-- Dumping structure for table dbrhzbrqhhlw5g.measurementunits
CREATE TABLE IF NOT EXISTS `measurementunits` (
  `unitID` int(11) NOT NULL AUTO_INCREMENT,
  `unitName` varchar(50) NOT NULL,
  `baseUnit` varchar(50) NOT NULL,
  `unitType` enum('volume','weight','length','count') NOT NULL,
  PRIMARY KEY (`unitID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.measurementunits: ~11 rows (approximately)
REPLACE INTO `measurementunits` (`unitID`, `unitName`, `baseUnit`, `unitType`) VALUES
	(1, 'Teaspoon', 'tsp', 'volume'),
	(2, 'Tablespoon', 'Tbsp', 'volume'),
	(3, 'Cup', 'Cup', 'volume'),
	(4, 'Quart', 'qt', 'volume'),
	(6, 'Fluid Ounce', 'fl oz', 'volume'),
	(7, 'Pint', 'pt', 'volume'),
	(8, 'Gallon', 'gal', 'volume'),
	(16, 'Ounce', 'oz', 'weight'),
	(17, 'Pound', 'lb', 'weight'),
	(18, 'Each', 'unit', 'count'),
	(19, 'Can', 'Can', 'count');

-- Dumping structure for table dbrhzbrqhhlw5g.quantity_options
CREATE TABLE IF NOT EXISTS `quantity_options` (
  `quantityID` int(11) NOT NULL AUTO_INCREMENT,
  `optionValue` decimal(4,3) NOT NULL,
  `textValue` varchar(10) NOT NULL,
  PRIMARY KEY (`quantityID`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.quantity_options: ~24 rows (approximately)
REPLACE INTO `quantity_options` (`quantityID`, `optionValue`, `textValue`) VALUES
	(1, 0.125, '1/8'),
	(2, 0.250, '1/4'),
	(3, 0.375, '3/8'),
	(4, 0.500, '1/2'),
	(5, 0.625, '5/8'),
	(6, 0.750, '3/4'),
	(7, 0.875, '7/8'),
	(8, 1.000, '1'),
	(9, 1.250, '1 1/4'),
	(10, 1.500, '1 1/2'),
	(11, 1.750, '1 3/4'),
	(12, 2.000, '2'),
	(13, 2.250, '2 1/4'),
	(14, 2.500, '2 1/2'),
	(15, 2.750, '2 3/4'),
	(16, 3.000, '3'),
	(17, 3.250, '3 1/4'),
	(18, 3.500, '3 1/2'),
	(19, 3.750, '3 3/4'),
	(20, 4.000, '4'),
	(21, 4.250, '4 1/4'),
	(22, 4.500, '4 1/2'),
	(23, 4.750, '4 3/4'),
	(24, 5.000, '5');

-- Dumping structure for table dbrhzbrqhhlw5g.raw_ingredients
CREATE TABLE IF NOT EXISTS `raw_ingredients` (
  `ingredientID` int(11) NOT NULL AUTO_INCREMENT,
  `ingredient_name` varchar(50) NOT NULL,
  `uc` datetime NOT NULL DEFAULT current_timestamp(),
  `um` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ingredientID`),
  UNIQUE KEY `ingredient_name` (`ingredient_name`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='ingredients without any kind of measurements attached';

-- Dumping data for table dbrhzbrqhhlw5g.raw_ingredients: ~85 rows (approximately)
REPLACE INTO `raw_ingredients` (`ingredientID`, `ingredient_name`, `uc`, `um`) VALUES
	(1, 'Almond Flour', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(2, 'Apple', '2025-08-15 19:32:04', '2025-08-19 21:45:48'),
	(4, 'Aussie Bites', '2025-08-15 19:32:04', '2025-08-19 21:54:16'),
	(5, 'Seasoned Rice Packets', '2025-08-15 19:32:04', '2025-08-19 21:45:39'),
	(6, 'Cheddar Cheese', '2025-08-15 19:32:04', '2025-08-19 21:45:20'),
	(7, 'Bell Pepper (Assorted Colors)', '2025-08-15 19:32:04', '2025-08-20 00:48:19'),
	(8, 'Black Beans', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(9, 'Black Pepper', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(10, 'Blueberries', '2025-08-15 19:32:04', '2025-08-20 01:25:58'),
	(11, 'Bread', '2025-08-15 19:32:04', '2025-08-20 01:26:01'),
	(12, 'Butter', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(13, 'Cayenne Pepper', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(14, 'Chia Seeds', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(15, 'Chili Powder', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(16, 'Corn Chips', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(17, 'Cumin', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(19, 'Mixed Vegetables (Frozen)', '2025-08-15 19:32:04', '2025-08-20 01:24:58'),
	(20, 'Garlic Powder', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(21, 'Beef (Ground)', '2025-08-15 19:32:04', '2025-08-20 01:10:44'),
	(22, 'Chicken (Ground)', '2025-08-15 19:32:04', '2025-08-20 01:10:52'),
	(23, 'Kidney Beans', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(24, 'Mango', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(25, 'Onion Powder', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(26, 'Onion', '2025-08-15 19:32:04', '2025-08-20 01:25:08'),
	(27, 'Oregano', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(28, 'Chicken Nuggets', '2025-08-15 19:32:04', '2025-08-20 02:12:44'),
	(29, 'Paparika', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(31, 'Rice', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(32, 'Rosemary', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(33, 'Sage', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(34, 'Salmon', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(35, 'Salt', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(36, 'Sea Salt', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(37, 'Chicken (Shredded)', '2025-08-15 19:32:04', '2025-08-20 01:25:21'),
	(38, 'Sugar (Succinate Cane Sugar)', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(39, 'Taco Shells or Corn Chips', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(40, 'Tacos', '2025-08-15 19:32:04', '2025-08-15 19:41:28'),
	(41, 'Tapioca', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(42, 'Tea Leaves', '2025-08-15 19:32:04', '2025-08-20 01:08:06'),
	(43, 'Thyme', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(44, 'Vanilla Cookies', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(45, 'Water', '2025-08-15 19:32:04', '2025-08-15 19:41:33'),
	(46, 'yeah', '2025-08-15 19:32:04', '2025-08-15 19:32:04'),
	(64, 'Tomatoes (Diced)', '2025-08-19 21:41:06', '2025-08-20 01:24:33'),
	(66, 'Choco Hunks', '2025-08-19 21:55:18', '2025-08-19 21:55:18'),
	(67, 'Sweet Potatoe (Dried Snacks)', '2025-08-19 21:58:43', '2025-08-20 01:24:49'),
	(68, 'Carrots', '2025-08-19 21:58:47', '2025-08-19 21:58:47'),
	(69, 'Cherries (Frozen)', '2025-08-19 21:59:33', '2025-08-19 21:59:33'),
	(70, 'Garbanzo Beans', '2025-08-20 00:43:09', '2025-08-20 00:43:09'),
	(71, 'Spinach (Frozen)', '2025-08-20 00:43:22', '2025-08-20 00:43:22'),
	(72, 'Fruit (Mixed - Strawberries, Black Berries, Bluebe', '2025-08-20 00:44:38', '2025-08-20 00:45:01'),
	(73, 'Red Potatoes', '2025-08-20 00:46:15', '2025-08-20 00:46:15'),
	(74, 'Oatmeal', '2025-08-19 19:50:35', '2025-08-20 00:50:36'),
	(75, 'Maple Syrup', '2025-08-20 00:51:17', '2025-08-20 00:51:17'),
	(76, 'Coconut Oil', '2025-08-20 01:03:17', '2025-08-20 01:03:17'),
	(77, 'Chicken (Breast)', '2025-08-20 01:11:04', '2025-08-20 01:11:04'),
	(78, 'Cannellini Beans', '2025-08-20 01:19:37', '2025-08-20 01:19:37'),
	(79, 'Tomato Sauce', '2025-08-20 01:20:02', '2025-08-20 01:20:02'),
	(80, 'Quinoa', '2025-08-20 01:27:34', '2025-08-20 01:27:34'),
	(81, 'Broccoli (Frozen)', '2025-08-20 01:28:28', '2025-08-20 01:28:28'),
	(82, 'Broth', '2025-08-20 01:31:26', '2025-08-20 01:31:26'),
	(83, 'Navy Beans', '2025-08-20 01:45:08', '2025-08-20 01:45:08'),
	(84, 'Ro-Tel (Rotel)', '2025-08-20 01:45:29', '2025-08-20 01:45:29'),
	(85, 'Coconut Milk', '2025-08-20 01:53:43', '2025-08-20 01:53:43'),
	(86, 'Arrowroot Powder', '2025-08-20 01:56:51', '2025-08-20 01:56:51'),
	(87, 'Baking Powder', '2025-08-20 01:57:32', '2025-08-20 01:57:32'),
	(88, 'Eggs', '2025-08-20 01:59:06', '2025-08-20 01:59:06'),
	(89, 'Cashews (whole)', '2025-08-20 02:02:49', '2025-08-20 02:03:45'),
	(90, 'Brazil Nuts', '2025-08-20 02:02:56', '2025-08-20 02:02:56'),
	(91, 'Walnuts (whole)', '2025-08-20 02:03:07', '2025-08-20 02:03:49'),
	(92, 'Almonds (whole)', '2025-08-20 02:03:23', '2025-08-20 02:03:23'),
	(93, 'Pecans (whole)', '2025-08-20 02:03:36', '2025-08-20 02:03:36'),
	(94, 'Coconut (Unsweetened Shredded)', '2025-08-20 02:04:16', '2025-08-20 02:04:16'),
	(95, 'Pumpkin Seeds', '2025-08-20 02:04:27', '2025-08-20 02:04:27'),
	(96, 'Sunflower Seeds', '2025-08-20 02:04:38', '2025-08-20 02:04:38'),
	(97, 'Hemp Seeds', '2025-08-20 02:04:56', '2025-08-20 02:04:56'),
	(98, 'Cocoa Powder', '2025-08-20 02:05:14', '2025-08-20 02:05:14'),
	(99, 'Cinnamon Powder', '2025-08-20 02:05:26', '2025-08-20 02:05:26'),
	(100, 'Flax Seed', '2025-08-20 02:11:14', '2025-08-20 02:11:14'),
	(101, 'Jack Fruit', '2025-08-20 02:14:12', '2025-08-20 02:14:12'),
	(102, 'Pasta', '2025-08-20 02:17:14', '2025-08-20 02:17:14'),
	(103, 'Tumeric', '2025-08-20 02:19:57', '2025-08-20 02:19:57'),
	(104, 'White Beans', '2025-08-20 02:27:40', '2025-08-20 02:27:40'),
	(105, 'Pinto Beans', '2025-08-20 02:28:19', '2025-08-20 02:28:19'),
	(106, 'Chicken (Cubed)', '2025-08-20 16:13:57', '2025-08-20 16:13:57');

-- Dumping structure for table dbrhzbrqhhlw5g.recipeingredients
CREATE TABLE IF NOT EXISTS `recipeingredients` (
  `recipe_id` varchar(50) NOT NULL,
  `ingredient_id` int(11) NOT NULL,
  `quantity` decimal(10,2) DEFAULT NULL,
  `unit` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`recipe_id`,`ingredient_id`),
  KEY `ingredient_id` (`ingredient_id`),
  CONSTRAINT `recipeingredients_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`),
  CONSTRAINT `recipeingredients_ibfk_2` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`ingredient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.recipeingredients: ~0 rows (approximately)

-- Dumping structure for table dbrhzbrqhhlw5g.recipes
CREATE TABLE IF NOT EXISTS `recipes` (
  `recipe_id` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `date_last_activity` datetime DEFAULT NULL,
  `uc` timestamp NOT NULL DEFAULT current_timestamp(),
  `um` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `isAdded` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`recipe_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.recipes: ~23 rows (approximately)
REPLACE INTO `recipes` (`recipe_id`, `name`, `description`, `date_last_activity`, `uc`, `um`, `isAdded`) VALUES
	('65e397521ddf77bca5c237fb', 'Beef and Red Bean Chili', 'Servings: 6\n\nIngredients\n\n- 1 tablespoon onion powder\n- 3/8 teaspoon garlic powder\n- 1 tablespoon chili powder\n- 1 pound ground beef or **1 can of jackfruit**\n- 2  jars diced tomatoes\n- 2 cans of kidney beans, drained and rinsed\n- 2 teaspoons sea salt\n- 1/2 teaspoon ground pepper\n- 1/2 cup grated cheddar cheese per meal as topping\n- 1-2 Seasoned Rice packets from Costco added to mix as optional\n\nDirections\n\n1. Brown the beef.\n2. Add onion powder, garlic powder, chili powder.\n3. Add tomatoes, beans, salt and pepper.\n4. Bring to a boil and then simmer for 15-20 minutes.\n5. Adjust seasoning with salt and pepper as needed.', '2025-08-16 11:59:40', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('65e3a1e92948d057fe6ebd6d', 'Potato Stroganoff Hamburger Helper', 'Servings: 4\n\nIngredients\n\n- 1 pound ground beef, cooked and drained\n- 1 1/2 cups thinly slice potatoes, cooked and drained\n- 1 can coconut milk (entire can)\n- 1 cup water\n- If needed, 1/2 cup water\n- 1 teaspoon onion powder\n- 2 teaspoon garlic powder\n- 2-4 teaspoon salt\n- 1 teaspoon succant\n- 1 teaspoon black pepper\n- 1 tablespoon tapioca- if needed for thickening. Mixed with a small amount of cold water before adding.\n\nDirections\n\n1. Cook beef separately.\n2. Cook potatoes separately.\n3. To the cooked beef, add the milk and water and all the seasonings.\n4. If needed, add the tapioca thickener at this stage.\n5. Add the cooked sliced potatoes.', '2025-08-16 11:56:37', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('65e3a89d761eefa02d605b06', 'Chicken Alfredo with Brocolli', 'Servings:  4\n\nIngredients\n\n- 1 pound Cubed chicken, cooked separately\n- 1 cup Pasta, cooked separately\n- 1 bag Broccoli florets, cooked separately\n\nCream sauce, cooked separately\n\n- 1/2 teaspoon onion powder\n- 1 teaspoon salt\n- 1 teaspoon garlic powder\n- 1/2 teaspoon succant\n- 1/2 teaspoon black pepper\n- 1 can of coconut milk\n- 3-4 teaspoons of tapioca powder – added to a very little splash of milk or cold water\n\nDirections\n\n1. Cook the chicken, pasta and broccoli all separately.\n2. Mix the cream sauce ingredients together and bring to a slow boil.\n3. Combine all the ingredients together.', '2025-08-16 11:54:56', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('65e3abc0f8cd991e2ff05bff', 'Fudd Hamburger Helper', 'Servings: 6 servings\n\nIngredients:\n\n1 pound ground beef\n2 teaspoons paprika\n1\\.5 teaspoons black pepper\n1 1/4  teaspoons salt\n1 1/3 teaspoon Sucanat Sugar (this sugar is in the fridge)\n1/4 teaspoon garlic powder\n1/4 teaspoon onion powder\n1/4 teaspoon cayenne pepper\n1 1/4 cup pasta for each meal\n\nOptional if making as a burger patty: Lettuce, mayo, cheese, rotel\n\nDirections:\n\n1. Mix all spices together.\n2. Mix spices by hand tenderly into the meat so it doesn’t get too tough.\n3. Form 12 patties, flat like tortillas but also loosely packed so doesn’t dry out. (about 80 grams per patty)\n4. Preheat the pan on mid heat. Browning both sides of the patties but not cooking all the way through. Those become leftovers to freeze and cooked thoroughly as reheated for future meals.\n5. Thoroughly cook the remaining two patties for dinner that night.\n6. Make your burger with whatever toppings you prefer.', '2025-08-16 11:45:06', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('65ea48c89c856f6ad662250b', 'Tacos or Taco Bowl', 'Ingredients\n\nDONT COOK WITH THESE SPICES NEXT TIME-USE THE TACO SEASONING CARD\n\n- 1 pound ground beef\n- 1 can refried beans\n- Corn chips of in bowl or shells\n- 1 can diced tomatoes,\n- 1/2 cup shredded cheese\n- 1 tablespoon onion powder\n- 1/2 teaspoon garlic powder\n- 2 teaspoons cumin powder\n- 1/2 teaspoon chili powder\n- 1 1/2  teaspoons sea salt\n\nDirections\n\n1. Brown the beef.\n2. Add spices.\n3. Add kidney beans.\n4. Serve meat and bean mixter over corn chips. Top with desired toppings.', '2025-08-16 12:02:01', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('65ee372e7bb627c87df43ca2', 'Creamy Bean Soup', 'Servings: 4 servings\n\nIngredients\n\n- 1/2 teaspoon garlic powder\n- 1 tablespoon onion powder\n- 1/2 teaspoon chili powder\n- 1/2 teaspoon cumin\n- 1 teaspoon thyme\n- 2 cups white beans\n- 2 cups kidney beans\n- 2 cups pinto beans\n- 2 cups chicken broth\n- cheddar cheese\n- salt and pepper to taste\n- Cayenne pepper to taste\n\nDirections\n\n1. In a large pot, add beans and broth and spices. Boil. Simmer, covered, 10 minutes.\n2. Blend with immersion blender.\n3. Serve with cheese on top.', '2025-08-16 11:40:55', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('66804801d104693530f1c13c', 'Nugget quick lunch', 'Servings: 2\n\nIngredients:\n\n12 nuggets\n\nInstructions:\n\nDon\'t put nuggets in until preheat is done\nPlace parchment paper or equivalent in oven\nPreheat 425\nLay 4-6 nuggets in oven\nSet time for 16 minutes\nFlip nuggets over\nSet timer for another 6-7 minutes (check periodically for preferred brownness)\n\nIf you want veggie, we have mixed veggies, green beans, and broccoli. 1/2 to 1 C covered with water. Bring to boil, reduce heat to light boil for 3-4 minutes (broccoli may need an additional min or two)', '2025-08-16 11:38:38', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('66b7c63aef984308441f4e1c', 'Salmon Patties', 'Servings: 4-6\n\nIngredients\n\n- 1 can of salmon makes 7 patties\n- 1 1/2 tablespoon chia seed (to make 1.5 egg equivalant)\n- 4 1/2 tablespoons water\n- about 1 1/4 cups of almond flour\n- Coconut oil for pan\n\nDirections\n\n1. Add salmon and eggs to a bowl and mix.\n2. Make 14 patties at 70 grams each\n3. Something here with the flour\n4. ‌\n5. Stove at 4.5', '2025-08-16 11:49:45', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('67f6d3181ecadb49da60fcbf', 'Tuscan-Style Cannellini Bean Stew', 'Servings: 6\n\n**Ingredients:**\n\n- 1 lb chicken breasts - cooked chicken shredded into stew\n- 2 cans cannellini beans (drained)\n- 1 tsp garlic powder\n- 1 can diced tomatoes\n- 2 cups veggie broth\n- 1 tsp dried thyme\n- oil\n- Salt\n- pepper\n- Optional: handful of chopped kale or spinach, squeeze of lemon\n\n**How-to:**\n\n1. Sauté garlic in olive oil until fragrant.\n2. Add tomatoes, beans, broth, herbs, and seasonings.\n3. Simmer 15–20 minutes until thickened and cozy.\n4. Add greens at the end if using, and finish with lemon juice for brightness.', '2025-08-16 11:32:01', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('67f6d7a90dfe222116694fa7', 'Black Bean & Ground Chicken Skillet', '**Servings: 2**\n**Ingredients:**\n\n- 1 lb ground chicken\n- 1 can black beans\n- 1/2 cup tomato sauce\n- 1/2 tsp garlic powder\n- 1/2 tsp onion powder\n- 1 tsp smoked paprika\n- 1/2 tspn Salt\n- 1/2 tspn pepper\n- 1 cup pasta - per meal\n\n‌\n\n- Optional: cooked rice or GF pasta to serve over\n\n**How-to:**\nBrown chicken with spices, add tomato sauce + black beans, simmer 5–10 min. Serve over rice or pasta. Add cheese if you want.', '2025-08-16 11:39:39', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('67f6d8ed0ba832c5d59c9c5b', 'Cannellini Bean & Ground Chicken Skillet', '**Servings: 4**\n\n**Ingredients:**\n\n- 1 lb ground chicken\n- 1 can cannellini beans\n- 1/2 cup tomato sauce\n- 1 tspn Garlic\n- 1 tspn onion powder\n- 1 tspn oregano\n- 1/2 tspn salt\n- 1/2 tspn pepper\n- 1/2 cup rice - per meal\n\n**How-to:**\nBrown chicken with spices, stir in beans + sauce, simmer 10 minutes. Serve as-is or over rice.', '2025-08-16 11:37:20', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('67f6db98db7791bf47f312e3', 'Ground Beef and Navy Bean Hash', 'Servings: 4\n**Ingredients:**\n\n- 1 lb ground beef\n- 1 can navy beans\n- 1/2 cup tomato sauce\n- 1 tsp Onion powder\n- 1 tsp garlic powder\n- 1 tsp oregano\n- 1 tsp paprika\n\n**How-to:**\nBrown beef with spices. Stir in beans and tomato sauce. Simmer for 5–10 minutes. Serve as-is or over rice.', '2025-08-16 11:31:04', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('67f6dc0b38817fdb9a7f5ccc', 'Navy Bean and Jackfruit Stew', '**Servings: 4**\n\n**Ingredients:**\n\n- 1 can jackfruit (shredded)\n- 1 can navy beans\n- 1 can diced tomatoes\n- 1/4 cup water\n- 1 tsp salt\n- 1 tsp Garlic\n- 1 tsp onion powder\n- 1tsp paprika\n- 1 tsp oregano\n- 1/2 cup rice - each meal\n- Optional: coconut milk splash at the end\n\n**How-to:**\nSauté jackfruit with spices, add beans & tomatoes, simmer 20–30 min. Great on its own or over pasta or rice.', '2025-08-16 11:33:45', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('67f6e8831688ad96ae92de1b', 'Kidney Bean and Ground Chicken Curry', '**Servings: 4**\n\n**Ingredients:**\n\n- 1 lb ground chicken\n- 1 can kidney beans\n- 1/2 cup coconut milk\n- 3/4 teaspoon Garlic powder\n- 3/4 teaspoon onion powder\n- 1 teaspoon cumin\n- 1 teaspoon paprika\n- 1/2 teaspoon tumeric\n- 1/4 teaspoon salt\n- 1/2 cup Rice - for each meal\n\n**How-to:**\nBrown chicken with spices, add beans and coconut milk, simmer 15–20 minutes. Serve over rice.', '2025-08-16 11:33:29', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('67f6fda74d30ab49c784ad5b', 'Spicy Mixed Bean & Ro-Tel Chili', 'Servings: 4\n\n**Ingredients:**\n\n- 1 can black beans\n- 1 can kidney beans\n- 1 can navy beans\n- 1 can Ro-Tel\n- 1 cup broth\n- 1 teaspoon Chili powder\n- 1 teaspoon garlic powder\n- 1 teaspoon onion powder\n- 1 teaspoon cumin\n\n**How-to:**\nCombine beans, Ro-Tel, and seasonings. Simmer for 20–30 minutes. Serve over corn mash (aka polenta), or top with cheese if desired.', '2025-08-16 11:32:56', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('68a0acdc4643de04aa6060c1', 'Yummy Chicken and Quinoa', 'Servings: 6\n\nIngredients\n\n- 1 pound uncooked chicken breasts or tenders\n- 1 can diced tomatoes\n- 2 cups uncooked quinoa\n- 1 package frozen broccoli\n- 2 tspn salt\n- 1 tspn garlic\n- 1 tspn onion powder\n- 2 tspn cumin\n\nDirections\n\nRinse quinoa well. Add to the LARGE pot with water per instructions on the bag. Add all the ingredients except the chicken. Stir. Then place chicken tenders on top. Chicken should not be fully immersed. Cook according to quinoa package directions plus about 10 more minutes.', '2025-08-16 12:03:18', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('68a0af19cd35e80adf6f7800', 'Taco seasoning', '1 tbsp chili powder \n1 tsp ground cumin\n1 tsp paprika \n1 tsp garlic powder \n1 tsp onion powder \n1/2 teaspoon oregano \n1/2 teaspoon salt \n1/2 teaspoon black pepper \n\nUse this combination per pound of ground meat. Add 1 tablespoon of water to the meat and spices. Drain the meat before adding the seasoning and water\n\n\n\n\n', '2025-08-16 11:17:29', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('68a0af9f07832d591221fd76', 'Mac and cheese for one meal', 'Servings: 2\n\nThis recipe can also be used if you just want the cheese sauce\n\n1 cup of pasta\n1 tbsp of butter\n1/4 teaspoon of salt\nShredded cheddar cheese based on desired consistency\n1/8 cup of water', '2025-08-16 12:04:26', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('68a0afde9883e9010b8c6b3c', 'Breakfast Sausage', 'Servings: 8\n\nIngredients\n\n- 1 teaspoon salt\n- 1/2 teaspoon black pepper\n- 1 teaspoon sage\n- 1/2 teaspoon thyme\n- 1/8 teaspoon rosemary\n- 1/2 tablespoon Sucanat Cane Sugar\n- 1/8 teaspoon cayenne pepper\n- 1 pound ground chicken (never beef)', '2025-08-16 12:05:40', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('68a0aff22e3a03e54973987b', 'Paleo Porridge', 'Servings: 27 servings\n\nIngredients\n\n- 2 cups cashews\n- 2 cup brazil nuts\n- half bag of walnuts 7-8 cups (1.7 or 2.2 lbs)\n- half bag 1.7 lb or 2.2 lb bag almonds 3.5 -4 cups\n- half bag 1.7 lb bag pecans 3 cups\n- 1 cup unsweetened shredded coconut\n- 2 cup pumpkin seeds\n- 2 cup sunflower seeds\n- 2 cup hempseed\n- 1.5 bags of a 2lb  bag oatmeal\n- 1.5 cup cocoa powder\n- 1 cup cinnamon powder\n- 3 teaspoons sea salt\n- 4 cups Maple Syrup\n\nSeparate fiber addition is 1 cup brown flaxseed and 1 cup chia seeds both ground up.\n\nInstructions\n\n1. Blend all ingredients in a food processor\n2. Store some in fridge and some in freezer\n3. Cook servings in boiling water like oatmeal stirring in maples syrup and raisins when serving.', '2025-08-16 12:08:55', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('68a1eb6e2bb1d83d0de6f7cc', 'Pizza Crust-GF', '**Ingredients for 3 medium crusts:**\n\n3 cups almond flour\n\n1 1/2 cups arrowroot powder or tapioca flour\n\n2 1/4 teaspoons baking powder\n\n2 1/4 teaspoons salt\n\n2 1/4 teaspoon oregano\n\n3/8 teaspoon black pepper\n\n4 eggs\n\n3/4 cups milk\n\n**Directions:**\n\n1. Preheat the oven to 425 degrees.\n2. Line a round pizza pan or cookie sheet with parchment paper. (I have 4 pizza pans so I can bake all three at once)\n3. Combine the dry ingredients in a large bowl. Whisk to blend together.\n4. Add eggs and milk to the dry ingredients. Mix well. The batter will be runny—not like typical pizza dough.\n5. Use a spatula to spread the batter evenly onto the pan in a circle shape.\n6. Bake the crust in the preheated oven for 8-12 minutes.\n7. Remove crust from oven and top with sauce and desired toppings. Or freeze the crust for later. Once cooled, place parchment paper between the crusts and they will store perfectly in a ziplock gallon freezer bag until ready to use. I also make sure the size of my circle stays within the range of a gallon bag for this reason.\n8. Bake for another 10-15 minutes with toppings.\n\n‌\n\n**Other Option: Ingredients for 1 large crust:**\n\n2 cups almond flour\n\n1 cup arrowroot powder or tapioca flour\n\n1 1/2 teaspoon. baking powder\n\n1 1/2 teaspoon. salt\n\n1 1/2 teaspoon oregano\n\n1/4 teaspoon black pepper\n\n3 eggs\n\n1/2 cup milk\n\n‌\n\nSource: [https://unrefinedkitchen.com/2012/04/14/pizza-crust-primalpaleo/](https://unrefinedkitchen.com/2012/04/14/pizza-crust-primalpaleo/ "smartCard-inline")', '2025-08-17 09:47:10', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('68a1ec7bd908de7fb29442a6', 'Chia seed egg substitute', 'One egg \n\n*2 teaspoons chia seed\n*1/4 cup water\n\n\nDirections: \nSoak chia seeds and water for 10  minutes stirring periodically', '2025-08-17 10:04:39', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0),
	('68a1f1335869161cad979736', 'Breakfast scramble', '', '2025-08-17 10:11:47', '2025-08-17 16:42:11', '2025-08-17 11:42:11', 0);

-- Dumping structure for table dbrhzbrqhhlw5g.recipetags
CREATE TABLE IF NOT EXISTS `recipetags` (
  `recipe_id` varchar(50) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`recipe_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `recipetags_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`) ON DELETE CASCADE,
  CONSTRAINT `recipetags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.recipetags: ~13 rows (approximately)
REPLACE INTO `recipetags` (`recipe_id`, `tag_id`) VALUES
	('65e3a89d761eefa02d605b06', 1),
	('65ea48c89c856f6ad662250b', 1),
	('66b7c63aef984308441f4e1c', 1),
	('67f6d8ed0ba832c5d59c9c5b', 1),
	('67f6e8831688ad96ae92de1b', 1),
	('67fc058a3968a44cf95a9b8c', 1),
	('67f6dc0b38817fdb9a7f5ccc', 2),
	('67f6e8831688ad96ae92de1b', 2),
	('67f6fda74d30ab49c784ad5b', 2),
	('6824babde9b3732c346f3c9d', 8),
	('6824bb4a783db57b9ed8e3ca', 8),
	('6824bbd5acc27f4664c20175', 8),
	('68a0acdc4643de04aa6060c1', 151);

-- Dumping structure for table dbrhzbrqhhlw5g.tags
CREATE TABLE IF NOT EXISTS `tags` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `color` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `unique_tag_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=161 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- Dumping data for table dbrhzbrqhhlw5g.tags: ~4 rows (approximately)
REPLACE INTO `tags` (`tag_id`, `name`, `color`) VALUES
	(1, 'RV', 'purple'),
	(2, 'Great', 'orange'),
	(8, 'Haven\'t tried yet', 'pink_dark'),
	(151, 'Favorite', 'green');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
