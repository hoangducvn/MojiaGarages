ALTER TABLE `player_vehicles` ADD COLUMN `posX` float NOT NULL;
ALTER TABLE `player_vehicles` ADD COLUMN `posY` float NOT NULL;
ALTER TABLE `player_vehicles` ADD COLUMN `posZ` float NOT NULL;
ALTER TABLE `player_vehicles` ADD COLUMN `rotX` float NOT NULL;
ALTER TABLE `player_vehicles` ADD COLUMN `rotY` float NOT NULL;
ALTER TABLE `player_vehicles` ADD COLUMN `rotZ` float NOT NULL;
ALTER TABLE `player_vehicles` ADD COLUMN `lastUpdate` int(11) NOT NULL DEFAULT '0';
