#include "otpch.h"

#include "familiar.h"
#include "events.h"
#include "game.h"
#include "monster.h"
#include "condition.h"
#include "scheduler.h"
#include "scriptmanager.h"
#include "luascript.h"
#include "spells.h"
#include <map>
#include <vector>
#include <algorithm>

namespace Familiar {

struct FamDef { uint32_t id; std::string name; };

static const std::map<uint32_t, FamDef> FAMILIAR_ID = {
    {1, {994, "Sorcerer familiar"}},
    {2, {993, "Druid familiar"}},
    {3, {992, "Paladin familiar"}},
    {4, {991, "Knight familiar"}},
    {9, {990, "Monk familiar"}},
};

struct FamTimer { int32_t storage; uint32_t countdown; std::string message; };
static const std::vector<FamTimer> FAMILIAR_TIMER = {
    {STORAGE_FAMILIAR_TIMER_10, 10, "10 seconds"},
    {STORAGE_FAMILIAR_TIMER_60, 60, "one minute"},
};

static void ClearFamiliarTimerEvents(Player* player, bool stopEvents)
{
    if (!player) {
        return;
    }

    for (const auto& t : FAMILIAR_TIMER) {
        const auto eventId = player->getStorageValue(static_cast<uint32_t>(t.storage));
        if (stopEvents && eventId && *eventId > 0) {
            g_scheduler.stopEvent(static_cast<uint32_t>(*eventId));
        }
        player->setStorageValue(static_cast<uint32_t>(t.storage), std::optional<int64_t>(-1));
    }
}

static void SendMessageFunction(uint32_t playerId, const std::string& message)
{
    if (Player* player = g_game.getPlayerByID(playerId)) {
        player->sendTextMessage(MESSAGE_INFO_DESCR, "Your summon will disappear in less than " + message);
    }
}

static void RemoveFamiliar(uint32_t creatureId, uint32_t playerId)
{
    if (Creature* creature = g_game.getCreatureByID(creatureId)) {
        if (Player* player = g_game.getPlayerByID(playerId)) {
            g_game.removeCreature(creature);
            ClearFamiliarTimerEvents(player, false);
            player->setStorageValue(STORAGE_FAMILIAR_SUMMON_TIME, std::optional<int64_t>(-1));
        }
    }
}

std::string getFamiliarName(const Player* player)
{
    if (!player || !player->getVocation()) return {};
    uint32_t base = player->getVocation()->getFromVocation();
    if (base == 0) base = player->getVocation()->getId();
    auto it = FAMILIAR_ID.find(base);
    if (it == FAMILIAR_ID.end()) return {};
    return it->second.name;
}

bool dispellFamiliar(Player* player)
{
    if (!player) return false;
    const auto& summons = player->getSummons();
    std::string famName = getFamiliarName(player);
    if (famName.empty()) return false;
    for (const auto& s : summons) {
        if (auto summon = s.lock()) {
            std::string sname = summon->getName();
            std::transform(sname.begin(), sname.end(), sname.begin(), ::tolower);
            std::string fname = famName;
            std::transform(fname.begin(), fname.end(), fname.begin(), ::tolower);
            if (sname == fname) {
                g_game.addMagicEffect(player->getPosition(), CONST_ME_MAGIC_BLUE, player->getInstanceID());
                g_game.addMagicEffect(summon->getPosition(), CONST_ME_POFF, summon->getInstanceID());
                g_game.removeCreature(summon.get());
                ClearFamiliarTimerEvents(player, true);
                player->setStorageValue(STORAGE_FAMILIAR_SUMMON_TIME, std::optional<int64_t>(-1));
                return true;
            }
        }
    }
    return false;
}

bool createFamiliar(Player* player, const std::string& familiarName, uint32_t timeLeft)
{
    if (!player || familiarName.empty()) {
        if (player) {
            player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
            g_game.addMagicEffect(player->getPosition(), CONST_ME_POFF, player->getInstanceID());
        }
        return false;
    }

    auto monsterUnique = Monster::createMonster(familiarName);
    if (!monsterUnique) {
        player->sendCancelMessage(RETURNVALUE_NOTENOUGHROOM);
        g_game.addMagicEffect(player->getPosition(), CONST_ME_POFF, player->getInstanceID());
        return false;
    }

    auto monster = std::shared_ptr<Monster>(std::move(monsterUnique));
    const Position& pos = player->getPosition();
    monster->setInstanceID(player->getInstanceID());

    if (!g_events->eventMonsterOnSpawn(monster.get(), pos, false, true) ||
        !g_game.placeCreature(monster.get(), pos, true, false, CONST_ME_TELEPORT)) {
        player->sendCancelMessage(RETURNVALUE_NOTENOUGHROOM);
        return false;
    }

    monster->setMaster(player);
    // mark summon with guild emblem (ally = green badge)
    monster->setGuildEmblem(GUILDEMBLEM_ALLY);
    int32_t delta = static_cast<int32_t>(player->getSpeed()) - static_cast<int32_t>(monster->getBaseSpeed());
    if (delta < 0) delta = 0;
    g_game.changeSpeed(monster.get(), delta);

    g_game.addMagicEffect(player->getPosition(), CONST_ME_MAGIC_BLUE, player->getInstanceID());
    g_game.addMagicEffect(monster->getPosition(), CONST_ME_TELEPORT, monster->getInstanceID());

    player->setStorageValue(STORAGE_FAMILIAR_SUMMON_TIME, std::optional<int64_t>(static_cast<int64_t>(timeLeft + static_cast<uint32_t>(OTSYS_TIME()))));

    // schedule removal
    g_scheduler.addEvent(timeLeft * 1000, [creatureId = monster->getID(), playerId = player->getID()]() {
        RemoveFamiliar(creatureId, playerId);
    });

    // schedule warning messages and store event ids
    for (const auto& t : FAMILIAR_TIMER) {
        if (timeLeft > t.countdown) {
            uint32_t eventId = g_scheduler.addEvent((timeLeft - t.countdown) * 1000, [playerId = player->getID(), msg = t.message]() {
                SendMessageFunction(playerId, msg);
            });
            player->setStorageValue(static_cast<uint32_t>(t.storage), std::optional<int64_t>(static_cast<int64_t>(eventId)));
        } else {
            player->setStorageValue(static_cast<uint32_t>(t.storage), std::optional<int64_t>(-1));
        }
    }

    return true;
}

bool createFamiliarSpell(Player* player, uint32_t spellId)
{
    if (!player) return false;
    if (!player->isPremium()) {
        g_game.addMagicEffect(player->getPosition(), CONST_ME_POFF, player->getInstanceID());
        player->sendCancelMessage("You need a premium account.");
        return false;
    }

    if (player->getLevel() < 200) {
        player->sendCancelMessage("You need to be at least level 200.");
        g_game.addMagicEffect(player->getPosition(), CONST_ME_POFF, player->getInstanceID());
        return false;
    }

    if (player->getSummons().size() >= 1 && player->getAccountType() < ACCOUNT_TYPE_GOD) {
        player->sendCancelMessage("You can't have other summons.");
        g_game.addMagicEffect(player->getPosition(), CONST_ME_POFF, player->getInstanceID());
        return false;
    }

    std::string famName = getFamiliarName(player);
    if (famName.empty()) {
        player->sendCancelMessage(RETURNVALUE_NOTPOSSIBLE);
        g_game.addMagicEffect(player->getPosition(), CONST_ME_POFF, player->getInstanceID());
        return false;
    }

    uint32_t summonDuration = 15 * 60; // seconds
    uint32_t cooldown = summonDuration * 2; // seconds

    bool created = createFamiliar(player, famName, summonDuration);
    if (created) {
        auto condition = Condition::createCondition(CONDITIONID_DEFAULT, CONDITION_SPELLCOOLDOWN, static_cast<int32_t>(cooldown * 1000), 0, false, spellId);
        if (condition) player->addCondition(std::move(condition));
        return true;
    }

    return false;
}

}
