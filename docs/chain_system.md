# Chain System

O Chain System e um mecanismo de combate que permite que ataques e spells "saltem" (chain) de um alvo para criaturas proximas, criando um efeito cascata visual com magic effects desenhados ao longo do caminho.

---

## Sumario

- [Visao Geral](#visao-geral)
- [Como Funciona](#como-funciona)
- [Configuracao](#configuracao)
- [Spell Chain (Lua API)](#spell-chain-lua-api)
- [Weapon Chain (Automatico)](#weapon-chain-automatico)
- [Talkaction do Jogador](#talkaction-do-jogador)
- [Exemplos de Spells](#exemplos-de-spells)
- [Constantes e Enums](#constantes-e-enums)
- [Arquitetura Interna (C++)](#arquitetura-interna-c)

---

## Visao Geral

Existem dois subsistemas independentes:

1. **Spell Chain** - Spells (de monstros ou jogadores) configurados via Lua que encadeiam de alvo em alvo. Usa `CALLBACK_PARAM_CHAINVALUE` para definir parametros e `CALLBACK_PARAM_CHAINPICKER` para filtrar alvos.

2. **Weapon Chain** - Ataques corporais de jogadores que automaticamente encadeiam para criaturas proximas. Configuravel por tipo de arma via `config.lua` e ativavel/desativavel pelo jogador via comando `!chain`.

Ambos convergem no mesmo algoritmo de selecao de alvos (`pickChainTargets`) e no mesmo sistema de efeitos visuais.

---

## Como Funciona

### Algoritmo de Selecao de Alvos (BFS-Greedy)

```
1. Inicia a partir do alvo original (ou do caster se self-target)
2. Encontra espectadores dentro de chainDistance do alvo atual
3. Filtra: NPCs, PZ, caster, alvos invalidos (canDoCombat, line-of-sight)
4. Seleciona o espectador mais proximo (distancia euclidiana)
5. Adiciona ao resultado e repete a partir desse novo alvo
6. Se nenhum alvo valido for encontrado e backtracking=true:
   - Volta ao alvo anterior e tenta outra direcao (max 10 tentativas)
7. Para ao atingir maxTargets ou quando nao ha mais alvos
```

### Fluxo de Execucao

```
doCombat(caster, target)
  |
  +-> params.chainCallback existe?
       |
       SIM -> doCombatChain(caster, target, aggressive)
       |        |
       |        +-> chainCallback->getChainValues() -> maxTargets, distance, backtracking
       |        +-> pickChainTargets() -> vector<pair<Position, vector<creatureID>>>
       |        +-> Para cada hop do chain:
       |             g_scheduler.addEvent(delay, [effect + doCombat])
       |             delay = hop_index * max(50, COMBAT_CHAIN_DELAY)
       |
       NAO -> fluxo normal de combate
```

### Efeito Visual

O efeito visual (`doChainEffect`) usa pathfinding A* para traçar uma rota entre cada par de alvos do chain. Em cada tile intermediario do caminho, um magic effect e emitido, criando um "raio" visual entre os alvos.

---

## Configuracao

### config.lua

```lua
-- Chain System
toggleChainSystem = true                -- Ativa/desativa o chain system globalmente
combatChainDelay = 50                   -- Delay em ms entre cada salto do chain
combatChainTargets = 5                  -- Numero maximo de alvos encadeados (weapon chain)

-- Formulas de dano por tipo de arma (multiplicador do skill)
combatChainSkillFormulaAxe = 0.9
combatChainSkillFormulaClub = 0.7
combatChainSkillFormulaSword = 1.1
combatChainSkillFormulaFist = 1.0
combatChainSkillFormulaDistance = 0.9
combatChainSkillFormulaWandsAndRods = 1.0
```

---

## Spell Chain (Lua API)

### Parametros

| Constante | Tipo | Descricao |
|-----------|------|-----------|
| `COMBAT_PARAM_CHAIN_EFFECT` | uint16 | Magic effect exibido no caminho entre alvos do chain |

### Callbacks

| Constante | Assinatura da Funcao Lua | Retorno |
|-----------|--------------------------|---------|
| `CALLBACK_PARAM_CHAINVALUE` | `getChainValue(creature)` | `maxTargets, chainDistance, backtracking` |
| `CALLBACK_PARAM_CHAINPICKER` | `canChainTarget(creature, target)` | `boolean` |

### CALLBACK_PARAM_CHAINVALUE

Define os parametros do chain dinamicamente por criatura. A funcao Lua recebe a criatura que esta atacando e retorna 3 valores:

- **maxTargets** (number) - Numero maximo de alvos que o chain atingira
- **chainDistance** (number) - Distancia maxima em sqm entre cada salto do chain
- **backtracking** (boolean) - Se true, o chain pode voltar ao alvo anterior se nao encontrar alvo valido

```lua
function getChainValue(creature)
    -- Monstros com mais HP encadeiam mais
    if creature:isMonster() then
        local hpPercent = creature:getHealth() / creature:getMaxHealth()
        if hpPercent > 0.5 then
            return 3, 4, true   -- 3 alvos, alcance 4sqm, com backtracking
        else
            return 2, 3, false  -- 2 alvos, alcance 3sqm, sem backtracking
        end
    end
    return 2, 3, false
end

combat:setCallback(CALLBACK_PARAM_CHAINVALUE, "getChainValue")
```

### CALLBACK_PARAM_CHAINPICKER

Filtro opcional chamado para cada potencial alvo do chain. Permite regras customizadas de validacao.

```lua
function canChainTarget(creature, target)
    -- Monstros so chain em jogadores
    if creature:isMonster() and target:isPlayer() then
        return true
    end
    -- Jogadores nao chain em summons de outros jogadores
    if creature:isPlayer() and target:isSummon() then
        return false
    end
    return true
end

combat:setCallback(CALLBACK_PARAM_CHAINPICKER, "canChainTarget")
```

---

## Weapon Chain (Automatico)

### Como Ativar

O jogador ativa/desativa o chain system via talkaction:

```
!chain on      -- Ativa o chain em ataques corporais
!chain off     -- Desativa o chain
```

O estado e persistido no storage do jogador (key: `40001`).

### Comportamento

Quando ativo, cada ataque corporal com arma tentara encadear para criaturas proximas:

1. O jogador ataca um alvo normalmente
2. Se o chain system esta ativo, um `Combat` separado e configurado com `setupChain(weapon)`
3. `doCombatChain()` e chamado - se encontrar alvos validos, o dano e aplicado em cascata
4. Se nenhum alvo for encontrado, o ataque normal prossegue
5. O dano do chain usa formula baseada no skill da arma com multiplicador configuravel

### Formulas de Dano por Tipo de Arma

| Tipo de Arma | Formula Padrao | Efeito Visual |
|--------------|----------------|---------------|
| Fist | skill * 1.0 | CONST_ME_HITAREA |
| Sword | skill * 1.1 | CONST_ME_SLASH |
| Club | skill * 0.7 | CONST_ME_BLACK_BLOOD |
| Axe | skill * 0.9 | CONST_ANI_WHIRLWINDAXE |
| Distance/Ammo | skill * 0.9 | CONST_ANI_HOLY |
| Wand/Rod | level * 1.0 | Varia por elemento |

### Desabilitando Chain por Arma (XML)

No XML de items, adicione o atributo `chain` na tag `<attribute>`:

```xml
<!-- Desabilita chain nesta arma -->
<attribute key="chain" value="false" />

<!-- Define multiplicador customizado (override da formula global) -->
<attribute key="chain" value="1.5" />
```

---

## Talkaction do Jogador

### !chain

Arquivo: `data/scripts/talkactions/player/chain_system.lua`

```lua
local chainStorage = 40001

local function onSay(player, words, param)
    if param == "on" then
        player:setStorageValue(chainStorage, 1)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Chain system ativado.")
    elseif param == "off" then
        player:setStorageValue(chainStorage, 0)
        player:sendTextMessage(MESSAGE_INFO_DESCR, "Chain system desativado.")
    else
        local state = player:getStorageValue(chainStorage) == 1 and "ativado" or "desativado"
        player:sendTextMessage(MESSAGE_INFO_DESCR, string.format("Chain system: %s. Use !chain on ou !chain off.", state))
    end
    return false
end
```

---

## Exemplos de Spells

### Death Chain (Monstro)

```lua
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_DEATHDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MORTAREA)
combat:setParameter(COMBAT_PARAM_CHAIN_EFFECT, CONST_ME_MORTAREA)

function getChainValue(creature)
    return 2, 3, false  -- 2 alvos, 3sqm de alcance, sem backtracking
end

combat:setCallback(CALLBACK_PARAM_CHAINVALUE, "getChainValue")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    return combat:execute(creature, var)
end

spell:name("death chain")
spell:words("###6009")
spell:needLearn(true)
spell:cooldown("2000")
spell:isSelfTarget(true)
spell:register()
```

### Extended Fire Chain (3 alvos)

```lua
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREATTACK)
combat:setParameter(COMBAT_PARAM_CHAIN_EFFECT, CONST_ME_FIREATTACK)

function getChainValue(creature)
    return 3, 3, false  -- 3 alvos, 3sqm, sem backtracking
end

combat:setCallback(CALLBACK_PARAM_CHAINVALUE, "getChainValue")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    return combat:execute(creature, var)
end

spell:name("extended fire chain")
spell:words("###6010")
spell:needLearn(true)
spell:cooldown("2000")
spell:isSelfTarget(true)
spell:register()
```

### Chain com Filtro Customizado

```lua
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
combat:setParameter(COMBAT_PARAM_CHAIN_EFFECT, CONST_ME_BLACK_BLOOD)

function getChainValue(creature)
    return 3, 4, true
end

combat:setCallback(CALLBACK_PARAM_CHAINVALUE, "getChainValue")

-- Filtro: so encadeia em jogadores (nao em PZ)
function canChainTarget(creature, target)
    if target:isPlayer() then
        local tile = target:getTile()
        if tile and tile:hasFlag(TILESTATE_PROTECTIONZONE) then
            return false
        end
        return true
    end
    return false
end

combat:setCallback(CALLBACK_PARAM_CHAINPICKER, "canChainTarget")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    return combat:execute(creature, var)
end

spell:name("player hunt chain")
spell:words("###6011")
spell:needLearn(true)
spell:cooldown("3000")
spell:isSelfTarget(true)
spell:register()
```

### Chain com Valores Dinamicos

```lua
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ENERGYAREA)
combat:setParameter(COMBAT_PARAM_CHAIN_EFFECT, CONST_ME_PINK_ENERGY_SPARK)

combat:setFormula(COMBAT_FORMULA_LEVELMAGIC, 0, 0, -1.2, -4)

function getChainValue(creature)
    -- Chefe encadeia mais quando esta com pouca vida
    if creature:getName() == "The Boss" then
        local hpPercent = creature:getHealth() / creature:getMaxHealth()
        if hpPercent < 0.3 then
            return 5, 5, true   -- Fase enrageada: 5 alvos, 5sqm, com backtracking
        end
    end
    return 2, 3, false
end

combat:setCallback(CALLBACK_PARAM_CHAINVALUE, "getChainValue")

local spell = Spell("instant")

function spell.onCastSpell(creature, var)
    return combat:execute(creature, var)
end

spell:name("boss energy chain")
spell:words("###6012")
spell:needLearn(true)
spell:cooldown("1500")
spell:isSelfTarget(true)
spell:register()
```

---

## Constantes e Enums

### Lua (registrados automaticamente)

| Constante | Valor | Uso |
|-----------|-------|-----|
| `COMBAT_PARAM_CHAIN_EFFECT` | 10 | `combat:setParameter()` - Define o efeito visual do chain |
| `CALLBACK_PARAM_CHAINVALUE` | 4 | `combat:setCallback()` - Callback para parametros do chain |
| `CALLBACK_PARAM_CHAINPICKER` | 5 | `combat:setCallback()` - Callback filtro de alvos |

### Storage Keys

| Key | Uso |
|-----|-----|
| 40001 | Chain system toggle do jogador (1 = on, 0 = off) |

---

## Arquitetura Interna (C++)

### Classes

```
ChainCallback : public CallBack
  - m_chainTargets (uint8_t)  - Max alvos
  - m_chainDistance (uint8_t)  - Distancia em sqm
  - m_backtracking (bool)      - Permite voltar ao alvo anterior
  - m_fromLua (bool)           - Se true, obtem valores via callback Lua
  + getChainValues(creature, &maxTargets, &distance, &backtracking)
  + setFromLua(bool)

ChainPickerCallback : public CallBack
  + onChainCombat(creature, target) -> bool
```

### CombatParams (novos campos)

```cpp
std::unique_ptr<ChainCallback> chainCallback;
std::unique_ptr<ChainPickerCallback> chainPickerCallback;
uint8_t chainEffect = CONST_ME_NONE;
```

### Combat (novos metodos)

```cpp
// Publicos
void setupChain(Weapon* weapon);
bool doCombatChain(Creature* caster, Creature* target, bool aggressive);
void setChainCallback(uint8_t targets, uint8_t distance, bool backtracking);

// Privados (static)
static void doChainEffect(const Position& origin, const Position& pos, uint8_t effect);
static vector<pair<Position, vector<uint32_t>>> pickChainTargets(
    Creature* caster, const CombatParams& params,
    uint8_t distance, uint8_t maxTargets, bool aggressive, bool backtracking,
    Creature* initialTarget = nullptr);
static bool isValidChainTarget(
    Creature* caster, Creature* currentTarget, Creature* potentialTarget,
    const CombatParams& params, bool aggressive);
```

### Fluxo do Weapon Chain

```
Player ataca com arma
  -> Weapon::internalUseWeapon()
    -> Player::checkChainSystem()
      -> Verifica config toggle
      -> Verifica storage 40001 do jogador
    -> [se ativo] Combat::setupChain(weapon)
      -> Configura area 7x7
      -> Configura formula por tipo de arma
      -> Cria ChainCallback com config values
    -> [se ativo] Combat::doCombatChain(caster, target, aggressive)
      -> [se sem alvos] fallback para Combat::doTargetCombat() normal
    -> [se inativo] Combat::doTargetCombat() normal
```

### Seguranca dos Eventos Agendados

Os hits do chain sao agendados via `g_scheduler.addEvent()`. Para evitar dangling pointers:

- **Combat_ptr** e capturado por valor (shared_ptr mantem o Combat vivo)
- **Creature IDs** sao capturados em vez de ponteiros
- No lambda agendado, creatures sao resolvidas via `g_game.getCreatureByID(id)`
- Se uma criatura nao existe mais quando o evento dispara, o hit e ignorado

---

## Notas de Implementacao

1. O algoritmo `pickChainTargets` usa SpectatorVec que internamente usa `shared_ptr<Creature>`, garantindo que criaturas nao sao destruidas durante a selecao.

2. Os eventos agendados capturam o `Combat_ptr` (shared_ptr<Combat>) para manter o objeto de combate vivo ate todos os hits serem aplicados.

3. O `doCombat()` original e modificado para detectar `params.chainCallback` e redirecionar para `doCombatChain()` quando presente. Isso permite que spells Lua existentes continuem funcionando normalmente.

4. O `setupChain()` cria um `Combat` temporario separado para o weapon chain, nao modificando o combat original da arma.

5. Usa `ConfigManager::getInteger()` / `ConfigManager::getFloat()` para acessar configuracoes, `CallBackParam` como enum class, e `g_scheduler.addEvent()` para agendamento de eventos.
