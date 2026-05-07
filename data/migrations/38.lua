function onUpdateDatabase()
	logMigration("> Updating database to version 39 (prey free list reroll marker)")

	db.query([[
		ALTER TABLE `player_prey`
			ADD `list_reroll_used` TINYINT(1) NOT NULL DEFAULT 0
	]])

	db.query([[
		UPDATE `player_prey`
		SET `reroll_at` = 0
		WHERE `list_reroll_used` = 0
			AND `state` = 1
			AND `monster_name` = ''
	]])

	return true
end
