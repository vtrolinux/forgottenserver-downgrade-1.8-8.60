function onUpdateDatabase()
	logMigration("> Updating database to version 38 (player prey cards and charm points)")

	db.query([[
		ALTER TABLE `players`
			ADD `bonus_rerolls` BIGINT UNSIGNED NOT NULL DEFAULT 0,
			ADD `charmpoints` INT UNSIGNED NOT NULL DEFAULT 0
	]])

	db.query([[
		UPDATE `players` p
		INNER JOIN `player_prey` pp
			ON pp.`player_id` = p.`id` AND pp.`slot` = 0
		SET p.`bonus_rerolls` = pp.`wildcards`
		WHERE p.`bonus_rerolls` = 0 AND pp.`wildcards` > 0
	]])

	return true
end
