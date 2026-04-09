<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d0221,40:2d0b6e,70:5b1fa8,100:8b5cf6&height=240&section=header&text=%E2%9A%94%EF%B8%8F%20TFS%201.8%20Downgrade&fontSize=52&fontColor=ffffff&fontAlignY=40&desc=Protocol%208.60%20%7C%20Modern%20Engine%20%7C%20Custom%20Systems&descAlignY=62&descSize=17&animation=fadeIn" />
</p>

<div align="center">

[![Build Status](https://ci.appveyor.com/api/projects/status/github/Mateuzkl/forgottenserver-downgrade?branch=official&svg=true)](https://ci.appveyor.com/project/Mateuzkl/forgottenserver-downgrade)
&nbsp;
[![License](https://img.shields.io/badge/license-GPL--2.0-blue?style=flat-square)](LICENSE)
&nbsp;
[![Commits](https://img.shields.io/badge/commits-~800-6a0dad?style=flat-square)](https://github.com/Mateuzkl/forgottenserver-downgrade-1.8-8.60/commits)

</div>

<br/>

<div align="center">

![Engine](https://img.shields.io/badge/ENGINE-TFS%201.8-7c3aed?style=for-the-badge)
![Protocol](https://img.shields.io/badge/PROTOCOL-8.60-f97316?style=for-the-badge)
![C++](https://img.shields.io/badge/C++-17-00599C?style=for-the-badge&logo=cplusplus&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%2B-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-vcpkg-0078D4?style=for-the-badge&logo=windows&logoColor=white)

</div>

<br/>

<div align="center">

> **Developed & Optimized by** [Mateuzkl](https://github.com/Mateuzkl)  
> Based on [Nekiro's TFS 1.5 Downgrades](https://github.com/nekiro/TFS-1.5-Downgrades) · Forked from [MillhioreBT's downgrade](https://github.com/MillhioreBT/forgottenserver-downgrade)  
> **Fully reworked** — all systems, optimizations, and custom features by Mateuzkl

</div>

---

## 📋 Índice

<div align="center">

| 🧬 Core Engine | ⚔️ Combat & RPG | 🌍 World Systems | 🏗️ Infrastructure | 📚 Docs & Support |
|:-:|:-:|:-:|:-:|:-:|
| [ClientID .dat](#-clientid-implementation) | [Forge System](#-forge-system-item-fusion) | [Instance System](#-instance-system) | [Compilation](#️-compilation) | [Contributing](#-contributing--issues) |
| [Overview](#-overview) | [Imbuement System](#-imbuement-system) | [Guild Halls](#-guild-halls-system) | [MyAAC SHA256](#-website-myaac--sha256) | [Memory Safety](#-memory-safety--smart-pointer-roadmap) |
| [Extended Protocol](#-extended-options--modified-860-cip-clients) | [Reward Boss](#-reward-boss-system) | [House Protection](#️-house-protection-system) | [Client Config](#-client-configuration-otcv8--mehah) | [Project Status](#-project-status) |
| | [Guild Wars](#️-guild-war-system) | [AutoLoot](#️-autoloot-system) | [Linux Tuning](#-linux-server-tuning) | [Downloads](#-downloads--client-updater) |
| | [Harmony (Monk)](#-harmony-system--monk-vocation) | [Offline Training](#-offline-training-system) | | [Donations](#-support-the-project) |
| | [Forge & Classification](#️-forge--classification-system) | [Live Cast](#-live-cast-system) | | |

</div>

---

## 🧬 ClientID Implementation

<div align="center">

| ✅ ClientID Only | ✅ Full .dat System | ✅ No Conversion Layer |
|:-:|:-:|:-:|
| No ServerID — Items, maps (OTBM), Lua scripts and DB all use ClientID directly | Reads item definitions from the client's `.dat` file — like Canary and Crystal Server | No ServerID/ClientID mapping — the ID you see in the client is the same everywhere |

</div>

This eliminates the traditional ServerID/ClientID mismatch, making content creation and debugging significantly simpler.

> 🗺️ To edit maps compatible with this ClientID system, use the modified RME:  
> **[⬇️ Download RME-CLIENTID](https://github.com/Mateuzkl/RME-CLIENTID)**

---

## 🚀 Overview

This is a **custom modified version** of The Forgotten Server, downgraded to protocol **8.60** but running on the modern **TFS 1.8** engine. It includes numerous exclusive systems and improvements not found in any standard TFS fork.

<div align="center">

| 🔢 ~800 Commits | 🧩 13+ Custom Systems | 🧠 132 Files Audited | 🛡️ Valgrind: 0 Leaks |
|:-:|:-:|:-:|:-:|
| Actively maintained | Fully integrated in C++ | Complete RAII review | Memory-safe base |

</div>

---

## 🎮 Systems & Features

### 🛡️ AutoLoot System

<details>
<summary><b>Click to expand</b></summary>

- **Fully Integrated**: Built directly into the source for maximum performance — no Lua overhead.
- **Bank Integration**: Automatically deposits gold if "AutoMoney" mode is enabled.

| Command | Description |
|---------|-------------|
| `!autoloot` | Opens the GUI management window |
| `!autoloot on/off` | Quickly toggle the system |
| `!autoloot clear` | Clear your entire loot list |

</details>

---

### ⚔️ Guild War System

<details>
<summary><b>Click to expand</b></summary>

- **Real Guild Wars**: Fully working war system with live emblems.
- **Emblems**: Ally, Member, and Enemy emblems update in real-time.

| Command | Description |
|---------|-------------|
| `/war invite, guildname` | Invite a guild to war |
| `/war accept, guildname` | Accept a war declaration |

</details>

---

### ⚔️ Forge & Classification System

<details>
<summary><b>Click to expand</b></summary>

- Items can have **Tier** and **Classification** attributes.
- **Forge**: Tier system allows for item upgrades via fusion and strong progression.
- **Classification**: System for categorizing items by rarity or power.
- Fully integrated with Lua scripting API for custom RPG systems.

</details>

---

### 🏆 Reward Boss System

<details>
<summary><b>Click to expand</b></summary>

- **Tibia-like Rewards**: Global Tibia style boss reward system.
- **Reward Chests**: Stored in reward containers (ID: `21518` / `21584`).
- Configurable reward rates via `config manager`.

| Tracking | Description |
|----------|-------------|
| Damage Done | Tracks your DPS contribution |
| Damage Taken | Tracks survivability contribution |
| Healing Done | Tracks support contribution |
| **Fair Distribution** | Loot distributed by total contribution score |

</details>

---

### 💤 Offline Training System

<details>
<summary><b>Click to expand</b></summary>

- Train skills while offline using beds — **Premium required**.
- **Usage**: Simply click on the bed to start training.
- Automatically calculates gain based on logout duration (**Max 12h**).
- **Configuration**: Efficiency and vocation rates in `config.lua`.

| Trainable Skills |
|:-:|
| Sword · Axe · Club · Distance · Shielding · Magic Level |

</details>

---

### 🏰 Guild Halls System

<details>
<summary><b>Click to expand</b></summary>

- **Guild Leaders** can purchase special Guild Halls paid via Guild Bank balance.
- **Features**: Supports all house features — doors, beds, and protection zones.

| Command | Access | Description |
|---------|--------|-------------|
| `!buyhouse` | Leader / Vice-Leader | Purchase a guild hall |
| `!leavehouse` | Leader | Abandon the hall |

</details>

---

### 🛡️ House Protection System

<details>
<summary><b>Click to expand</b></summary>

- **Per-house control**: Owners can toggle protection state independently per house.
- **Secure**: When enabled, ONLY owner and listed guests can move items.
- Door messages show real ownership info.

| Command | Description |
|---------|-------------|
| `!protecthouse on/off` | Toggle protection state |
| `!houseguest add <name>` | Add a guest to the safe list |
| `!houseguest remove <name>` | Remove a guest |
| `!houseguest list` | View current guest list |

</details>

---

### ⚡ Improved Decay System

<details>
<summary><b>Click to expand</b></summary>

Enhanced decay system for better server performance. Optimized item decay processing and state management — significantly reduces CPU usage on populated servers.

</details>

---

### 📺 Live Cast System

<details>
<summary><b>Click to expand</b></summary>

- Stream your gameplay with `!cast` for others to watch live.
- **Bonus**: Configurable EXP bonus for active casters.
- **Spectators**: Can chat in the dedicated Live Cast channel.

| Command | Access | Description |
|---------|--------|-------------|
| `!cast` | Caster | Start/stop broadcasting |
| `/spectators` | Caster | List current spectators |
| `/kick <name>` | Caster | Kick a spectator |
| `/mute <name>` | Caster | Mute a spectator |
| `/ban <name>` | Caster | Ban a spectator |

</details>

---

### 🔥 Forge System (Item Fusion)

<details>
<summary><b>Click to expand</b></summary>

Fuse two identical items — one is consumed, the other gains **+1 Tier**. Tier is capped by item classification.

| Tier | Success Rate | Extra Materials |
|:----:|:---:|:-:|
| T0 → T1 | 50% | — |
| T1 → T2 | 40% | — |
| T2 → T3 | 30% | — |
| T3 → T4 | 25% | — |
| T4 → T5 | 20% | — |
| T5 → T6 | 15% | Exalted Core required |
| T6 → T7 | 10% | Exalted Core required |
| T7 → T8 | 8% | Exalted Core required |
| T8 → T9 | 5% | Exalted Core required |

**Materials**: Forge Dust · Silver Tokens · Exalted Cores (T5+)  
**On Success**: Upgraded item placed inside an Exaltation Chest and delivered to inventory.

| Command | Description |
|---------|-------------|
| `/forge info` | Show forge info |
| `/forge dust` | Check your Forge Dust |
| `/forge silver` | Check your Silver Tokens |

</details>

---

### 🧿 Imbuement System

<details>
<summary><b>Click to expand</b></summary>

- **Two Methods**: Via **Imbuement Scrolls** or craft from **raw materials** using an Etcher tool.
- **Workbench**: 4-slot station — 1 equipment + up to 3 scrolls or materials.
- **Owner Lock**: Only the item's owner can apply imbuements.

| Tiers | Types Available |
|:-----:|:-:|
| Flawed → Intricate → **Powerful** | **27 types**: Skill boosts, Magic Level, Life/Mana Leech, Critical Hit, Elemental Damage & Protection, Speed, Capacity |

</details>

---

### 🏰 Instance System

<details>
<summary><b>Click to expand</b></summary>

Create **private dungeon instances** — monsters, effects, and items are only visible to players in the same instance.

**Lua API:**
```lua
player:setInstanceId(id)
Game.registerInstanceArea(area)
Game.createMonster(name, pos, extended, force, master, instanceId)
```

**C++ Core**: Spectator filtering, item visibility, and interaction checks all respect instance boundaries.

> **Use Cases**: Solo/party dungeons · Boss rooms · Quests — without interfering with the main world.

</details>

---

### 🧘 Harmony System — Monk Vocation

<details>
<summary><b>Click to expand</b></summary>

Exclusive to **Monks** (vocations 9–10). Gain Harmony points by hitting enemies.

| Virtue | Bonus |
|--------|-------|
| ⚖️ Justice | Increases damage output |
| 🧘 Harmony | Increases XP gain |
| 🛡️ Sustain | Increases defense and survivability |

- **Scaling Bonuses**: XP and damage scale with accumulated Harmony points.
- **Command**: `!harmony` — view your current state and points.

</details>

---

## 🛠️ Compilation

### 🐧 Ubuntu 22.04 / 24.04

> [!IMPORTANT]
> Requires **Boost 1.75+** and **Lua 5.4**
> - **Ubuntu 24.04** ✅ Recommended — comes with all required versions
> - **Ubuntu 22.04** ⚠️ May need manual Boost update (default is 1.74)

#### Step 1 — Install dependencies

```bash
sudo apt install git cmake build-essential liblua5.4-dev libmysqlclient-dev \
  libboost-system-dev libboost-iostreams-dev libboost-filesystem-dev \
  libboost-locale-dev libboost-regex-dev libpugixml-dev libfmt-dev \
  libssl-dev libspdlog-dev libmimalloc-dev -y
```

#### Step 2 — Clone & compile

```bash
git clone -b Revscrypt-full --single-branch \
  https://github.com/Mateuzkl/forgottenserver-downgrade-1.8-8.60.git
cd forgottenserver-downgrade-1.8-8.60
mkdir build && cd build
cmake ..
make -j$(nproc)
```

#### ⚡ Optimized Release Build — Recommended for Production

```bash
mkdir -p build-release && cd build-release
cmake -DCMAKE_BUILD_TYPE=Release \
      -DDISABLE_STATS=1 \
      -DENABLE_SLOW_TASK_DETECTION=OFF \
      -DUSE_MIMALLOC=ON \
      ..
cmake --build . -- -j$(nproc)
```

| CMake Flag | Effect |
|------------|--------|
| `-DCMAKE_BUILD_TYPE=Release` | Enables `-O3 -march=native -flto` — maximum speed |
| `-DDISABLE_STATS=1` | Removes runtime stats collection overhead |
| `-DENABLE_SLOW_TASK_DETECTION=OFF` | Removes per-task timing overhead |
| `-DUSE_MIMALLOC=ON` | Microsoft's mimalloc allocator — faster than glibc malloc |

**Alternative — run mimalloc without recompiling:**
```bash
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libmimalloc.so ./tfs
```

#### 🔧 Linux Server Tuning

```bash
# Maximum CPU performance
sudo cpupower frequency-set -g performance

# Higher process priority
sudo nice -n -10 ./tfs
```

---

### 🪟 Windows

Recommended: **vcpkg** for dependency management.

> 📖 See the full [Windows Compilation Wiki Guide](https://github.com/MillhioreBT/forgottenserver-downgrade/wiki/Compiling-on-Windows-(vcpkg))

---

## 🌐 Website (MyAAC) — SHA256

> [!IMPORTANT]
> This TFS 1.8 uses **SHA256 + salt** for password hashing — **not** traditional SHA1.  
> The standard MyAAC will **not work**. You must use the modified fork below.

**🔗 Modified MyAAC Repository:** [https://github.com/Mateuzkl/myaac](https://github.com/Mateuzkl/myaac)

```bash
git clone https://github.com/Mateuzkl/myaac.git
```

| Change | Details |
|--------|---------|
| **Password Format** | `$SHA256$<salt>$<hash>` — per-account random salt |
| **Legacy Support** | Login works with both new SHA256 and old SHA1 |
| **Auto-Migration** | Old SHA1 passwords are silently upgraded to SHA256 on first login |
| **Security** | SHA256 + salt is resistant to rainbow tables and brute-force |

> ⚠️ Using Znote, Gesior or another AAC? Adapt your password hashing functions to the `$SHA256$<salt>$<hash>` format.

---

## 📦 Client Configuration (OTCv8 / Mehah)

**1. Update `modules/game_features/game_features.lua`:**

```lua
if(version >= 860) then
    g_game.enableFeature(GameAttackSeq)
    g_game.enableFeature(GameBot)
    g_game.enableFeature(GameExtendedOpcode)
    g_game.enableFeature(GameSkillsBase)
    g_game.enableFeature(GamePlayerMounts)
    g_game.enableFeature(GameMagicEffectU16)
    g_game.enableFeature(GameDistanceEffectU16)
    g_game.enableFeature(GameDoubleHealth)
    g_game.enableFeature(GameOfflineTrainingTime)
    g_game.enableFeature(GameDoubleSkills)
    g_game.enableFeature(GameBaseSkillU16)
    g_game.enableFeature(GameAdditionalSkills)
    g_game.enableFeature(GameIdleAnimations)
    g_game.enableFeature(GameEnhancedAnimations)
    g_game.enableFeature(GameSpritesU32)
    g_game.enableFeature(GameExtendedClientPing)
    g_game.enableFeature(GameDoublePlayerGoodsMoney)
end
```

**2. Extended Sprites (`GameSpritesU32`)**
- Download: [Octv8--Classic-8.6](https://github.com/Mateuzkl/Octv8--Classic-8.6)
- Extract `.spr` and `.dat` to your OTCv8 directory

**3. CIP Client with Mounts (DLL)**
- Download: [Client 8.60 + DLL Mount](https://github.com/Mateuzkl/Client-cip-8.60-with-DLL-Mount)

---

## 🎮 Extended Options — Modified 8.60 CIP Clients

DLL patches that extend the old Tibia 8.60 client beyond its original protocol limits:

| DLL Patch | Status | Extends |
|-----------|:------:|---------|
| `__MAGIC_EFFECTS_U16__` | ✅ | Magic effects: **255 → 65535** (uint16) |
| `__DISTANCE_SHOOT_U16__` | ✅ | Projectile effects: **255 → 65535** (uint16) |
| `__PLAYER_HEALTH_U32__` | ✅ | Player HP: **65535 → 4.2 billion** (uint32) |
| `__PLAYER_MANA_U32__` | ✅ | Player Mana: **65535 → 4.2 billion** (uint32) |
| `__PLAYER_SKILLS_U16__` | ⏳ Pending | Skill levels up to 65535 (in development) |
| **Outfit Limit Changer** | ✅ | Outfits: **255 → 65535+** (uint16 count) |

---

## 🧠 Memory Safety & Smart Pointer Roadmap

A full ownership and RAII audit of all **132 source files** was completed. Progressive migration toward modern C++ lifetime management without breaking stability.

### ✅ Fixes Applied — Valgrind: 0 leaks, 0 errors

<details>
<summary><b>Click to see all applied fixes</b></summary>

| File | Fix Applied | Bytes Freed |
|------|-------------|:-----------:|
| `container.h/cpp` | Removed erroneous `incrementReferenceCounter` / `decrementReferenceCounter` calls in `addThing`, `removeThing`, `replaceThing`. Eliminated latent UAF. | **176 bytes** |
| `house.cpp` | Added `House::~House()` to properly decrement refcount of doors in `doorSet` — previously doors were never freed. | **58,351 bytes** |
| `depotlocker.cpp/depotchest.cpp` | `DepotChest` started with `referenceCounter=0`; destructor returned early without freeing. Fixed by calling `incrementReferenceCounter()` at construction. | **4,152 bytes** |
| `creature.h/cpp` | `setRemoved()` now clears `attackedCreature` / `followCreature`. `onThink()` checks `isRemoved()` before interacting with targets. Debug assert on over-decrement. | — |
| `monster.cpp` | Removed dead `onIdleStatus()` call in `death()` — the `!isDead()` guard made it an unreachable no-op. | — |
| `iologindata.cpp` | Removed conditional `decrementReferenceCounter` compensations in `transferLoadedItem` lambdas — aligned with Container fix. | — |

</details>

### 🗺️ Future Roadmap

| Priority | Target Files |
|:--------:|-------------|
| 🔴 **High** | `item.*` · `game.*` · `creature.*` · `iologindata.*` · `container.*` · `player.*` · `monster.*` · `tile.*` · `map.*` |
| 🟡 **Medium** | `chat.*` · `house.*` · `iomapserialize.*` · `luacreature.cpp` · `luagame.cpp` · `decay.*` · `spawn.*` · `protocolgame.*` · `party.*` |
| 🟢 **Low** | `combat.*` · `configmanager.*` · `guild.*` · `housetile.*` · Lua layer files |

> 📄 Full interactive audit report available at `tfs-smart-pointer-review-completo.html` in the repo root.

### 📅 Release Schedule

Memory safety improvements ship as **monthly fix releases** (`fix1`, `fix2`, …) — each verified with Valgrind before publishing.  
→ [View all Releases](https://github.com/Mateuzkl/forgottenserver-downgrade-1.8-8.60/releases)

---

## 🐛 Contributing & Issues

The base is **stable** and all systems are fully working. Found a bug? You're very welcome to help:

- 🐞 **Open an Issue** → [GitHub Issues](https://github.com/Mateuzkl/forgottenserver-downgrade-1.8-8.60/issues)  
  Include: description · steps to reproduce · relevant logs or Valgrind output
- 🔧 **Submit a Pull Request** → Surgical, minimal patches preferred — change only what is necessary

> Any contribution is appreciated. This server is optimized, actively maintained, and packed with exclusive systems. Community involvement helps keep it that way.

*Maintained by [Mateuzkl](https://github.com/Mateuzkl)*

---

## 📢 Project Status

<div align="center">

| Metric | Value |
|:------:|:-----:|
| 📦 Commits | **~800** |
| 🧩 Custom Systems | **13+** |
| 🧠 Files Audited | **132** |
| 🛡️ Memory Leaks | **0** (Valgrind verified) |
| 🔧 Status | **Stable & Active** |

</div>

The focus going forward is on **progressive memory safety** — applying the smart pointer roadmap in monthly fix releases while keeping all exclusive systems fully working.

---

## 🤝 Support the Project

If you enjoy using this server or benefit from the work, any support is deeply appreciated. Donations help fund continued development and motivate new system releases.

<div align="center">

**💜 PIX Key (Chave Aleatória)**

```
f8761afe-5581-417d-afc8-08cac410a1b0
```

*Thank you to everyone who contributes — code, bug reports, or donations.*

</div>

---

## 📥 Downloads & Client Updater

### Manual Download (AppVeyor Artifacts)

1. Open the [AppVeyor Project Page](https://ci.appveyor.com/project/Mateuzkl/forgottenserver-downgrade-1-7-8-60)
2. Click the latest **Job** → go to the **Artifacts** tab
3. Download the `.zip` or `.7z` with the executable and DLLs
4. Extract into your client folder, replacing existing files

### 🔄 Automated Client Updater

Update your CipSoft client, executables and DLLs automatically with just a few clicks:

> 📖 **[Client Updater Tutorial — Mateuzkl/Client_Mout_Updater](https://github.com/Mateuzkl/Client_Mout_Updater)**

---

<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:8b5cf6,50:5b1fa8,100:0d0221&height=140&section=footer&text=Made%20with%20%F0%9F%92%9C%20by%20Mateuzkl&fontSize=18&fontColor=ffffff&fontAlignY=65" />
</p>
