# Main Port Analysis

Este documento registra a auditoria da branch `main` usada para a etapa de port fiel para Godot 4.

## Arquivos analisados

| Sistema | Fonte na main | Uso no Godot |
| --- | --- | --- |
| Skins, raridades e passivas | `frontend/src/game/skins.ts` | Gerado em `scripts/MainPortData.gd` com 92 skins, nomes, raridades, cores, descricoes e passivas. |
| Assets de skins | `frontend/assets/skins` | Copiados em `godot/assets/skins`; a tela Skins lista todos os PNGs e prioriza metadados da main. |
| Upgrades temporarios | `frontend/src/game/upgrades.ts` | Gerado em `scripts/MainPortData.gd` com 34 upgrades de run, custos visuais/limites/desbloqueios e efeitos base. |
| Upgrades permanentes | `frontend/src/game/balance.ts`, `frontend/src/game/playerAttributes.ts` | Mantidos em `GameState.PERMANENT_UPGRADE_DEFS` e tela `UpgradesScreen.gd`. |
| Efeitos de aneis | `frontend/src/game/rings.ts`, `frontend/src/game/dualArena.ts` | Portados como freeze, burn, poison, chain, area, repulse, phase, critico e time freeze. |
| Liga Neon / duas arenas | `frontend/src/game/dualArena.ts`, `frontend/src/game/achievements.ts` | `LeagueBattleScreen.gd` substitui tela passiva: arena do oponente em cima, jogador embaixo, bot automatico, upgrades e trofeus. |
| Conquistas de liga/infinito | `frontend/src/game/achievements.ts` | Stats e hooks de liga adicionados em `GameState.gd`; recompensas seguem estrutura portavel. |
| Textos/localizacao | `frontend/src/i18n/gameText.ts`, `frontend/src/i18n` | `LocalizationManager.gd` criado com base central EN/PT para telas atuais e futuras. |
| Spawn/respawn de aneis | `frontend/src/game/rings.ts`, `frontend/src/game/dualArena.ts` | Fila de spawn no modo normal, spawn infinito com alvo ativo e spawn separado nas arenas menores da Liga. |

## Skins

- A main possui 92 skins definidas em `skins.ts`.
- Todas foram importadas para `MainPortData.SKINS`.
- A tela `SkinsScreen.gd` usa os dados da main para nome, raridade, descricao, cores e efeito visual.
- A gameplay usa a passiva real quando a skin esta no catalogo; fallback por nome de arquivo so fica para assets futuros sem definicao.

## Upgrades

- A main possui 34 upgrades temporarios em `upgrades.ts`.
- Todos foram importados para `MainPortData.RUN_UPGRADES`.
- O level-up agora sorteia do catalogo completo respeitando `unlocked_upgrades` e `maxLevel`.
- A tela `UpgradesScreen.gd` mostra permanentes compraveis e lista os temporarios de rodada com estado bloqueado/liberado.

## Efeitos

Portados nesta etapa:

- `frost`, `slow_ring`, `freeze_ring`: reduzem rotacao/fechamento e aplicam visual azul.
- `burn`: dano extra e visual quente.
- `poison`: dano extra progressivo simplificado.
- `chain_damage`, `chainLightning`, `chainBreak`: dano em anel vizinho.
- `area_damage`, `shockwave`, `voidPulse`: dano em area por raio proximo.
- `repel_ring`, `ringRepulse`: empurra anel para fora.
- `phase_solid`: chance de atravessar parte solida.
- `criticalOverload`: aumenta dano critico.
- `timeFreeze`, `chronoBreak`: desaceleram todos os aneis por tempo curto.

Pendentes exatos da main:

- Laser visual dedicado, bomba massiva, multihit completo e escudos/revive ainda estao aproximados por dano/area/protecao estrutural.

## Liga Neon

Na main, `dualArena.ts` mostra que a Liga/Boss/duelos usam duas arenas menores com:

- estado separado para cada arena;
- bolinha e aneis independentes;
- upgrades temporarios por arena;
- bot escolhendo upgrades automaticamente;
- respawn de aneis por lotes;
- vitoria/derrota quando uma arena termina ou e esmagada.

No Godot:

- `League.tscn` agora usa `LeagueBattleScreen.gd`.
- Oponente aparece na arena superior e joga automaticamente.
- Jogador aparece na arena inferior.
- O jogador escolhe upgrades temporarios ao subir de nivel.
- O bot escolhe upgrades automaticamente.
- Primeiro a morrer encerra a batalha.
- Vitoria, derrota e saida geram recompensas proporcionais.
- Trofeus sobem/descem e rank vem de `MainPortData.LEAGUE_RANKS`.
- Temporada usa `TimeManager.get_month_key()`.

## Spawn de aneis

- Modo normal agora usa fila: a fase preserva a quantidade total, mas so ativa cerca de 5 aneis por vez.
- Modo infinito mira quantidade ativa menor e mais controlada, escalando com dificuldade e pressao de limpeza rapida.
- Liga Neon usa spawn separado em duas arenas menores, mantendo distancia minima da bolinha e evitando sobreposicao simples por raio.
- A area de spawn continua invisivel, sem debug visual.

## Localizacao

- Ingles segue como idioma padrao de save.
- Portugues continua disponivel.
- `LocalizationManager.gd` centraliza chaves basicas e emite `language_changed`.
- Configuracoes salva/carrega idioma e chama o manager.
- Ainda existem textos antigos hardcoded em algumas telas; a estrutura para remover isso foi criada, mas a cobertura 100% tela por tela permanece pendente.

## Checklist

| Area | Status |
| --- | --- |
| Todas as skins da main importadas | Sim |
| Todos os assets de skins vinculados | Sim |
| Skins bloqueadas/desbloqueadas funcionando | Sim |
| Equipar skin funcionando | Sim |
| Skin equipada aparece na gameplay | Sim |
| Efeitos de skins funcionando | Sim |
| Todos os upgrades temporarios da main importados | Sim |
| Custos/limites/desbloqueios de temporarios portados | Sim |
| Compra/evolucao de permanentes funcionando | Sim |
| Efeitos aplicados na gameplay | Parcial avancado |
| Ingles como padrao | Sim |
| Portugues disponivel | Sim |
| Troca de idioma salva/carrega | Sim |
| Todas as telas 100% traduzidas | Parcial |
| Liga Neon analisada na main | Sim |
| Liga Neon refeita como batalha contra oponente | Sim |
| Duas arenas menores implementadas | Sim |
| Oponente automatico funcionando | Sim |
| Upgrades temporarios do oponente automaticos | Sim |
| Jogador escolhe upgrades temporarios | Sim |
| Primeiro a morrer perde | Sim |
| Recompensa por vitoria/derrota/saida | Sim |
| Trofeus ganhos/perdidos | Sim |
| Temporada mensal | Sim |
| Cerca de 200 oponentes por rank | Sim, gerados deterministicamente |
| Spawn seguro no modo normal | Sim |
| Spawn seguro no infinito | Sim |
| Spawn seguro na Liga Neon | Sim |
| Recompensa pequena ao sair/quitar | Sim para Liga e estrutura criada para modos |
