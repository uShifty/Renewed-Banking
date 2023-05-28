CREATE TABLE `bank_accounts` (
	`id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`amount` INT(11) NULL DEFAULT '0',
	`isFrozen` INT(11) NULL DEFAULT '0',
	`creator` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8_general_ci'
ENGINE=INNODB;

CREATE TABLE `bank_transactions` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`account` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`trans_id` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`title` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`message` VARCHAR(255) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`amount` INT(11) NULL DEFAULT NULL,
	`trans_type` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`receiver` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`issuer` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`time` INT(11) UNSIGNED ZEROFILL NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=23;

CREATE TABLE `player_accounts` (
	`charid` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`account` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci'
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;