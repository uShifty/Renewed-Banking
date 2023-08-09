CREATE TABLE IF NOT EXISTS `bank_accounts` (
	`id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`amount` INT(11) NULL DEFAULT '0',
	`isFrozen` INT(11) NULL DEFAULT '0',
	`creator` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8_general_ci',
	PRIMARY KEY (`id`) USING BTREE,
	-- If Player Deleted Character All Acccoutns Crated is Deleted.
	FOREIGN KEY (`creator`) REFERENCES `players` (`citizenid`)
		ON DELETE CASCADE
		ON UPDATE CASCADE
)
COLLATE='utf8_general_ci'
ENGINE=INNODB;

CREATE TABLE IF NOT EXISTS `bank_transactions` (
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
	`date` timestamp NULL DEFAULT current_timestamp(),
	PRIMARY KEY (`id`) USING BTREE,
	FOREIGN KEY (`account`) REFERENCES `players` (`citizenid`)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT `bank_transactions_bank_accounts` FOREIGN KEY (`account`) REFERENCES `bank_accounts` (`id`)
		ON DELETE CASCADE
		ON UPDATE CASCADE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `player_accounts` (
	`charid` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`account` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	CONSTRAINT `unique_charid_account` UNIQUE (`charid`, `account`),
	FOREIGN KEY (`charid`) REFERENCES `players` (`citizenid`)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT `player_accounts_bank_accounts` FOREIGN KEY (`account`) REFERENCES `bank_accounts` (`id`)
		ON DELETE CASCADE
		ON UPDATE CASCADE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB;