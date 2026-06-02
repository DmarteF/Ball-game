# Neon Idle Escape - Godot 4

Esta pasta contem a versao Godot 4 de Neon Idle Escape, mantendo o projeto Expo/React Native antigo intacto fora de `/godot`.

## Como abrir

1. Instale Godot 4.3 ou superior.
2. Abra o Godot Project Manager.
3. Importe `godot/project.godot`.
4. Rode a cena principal `res://scenes/Main.tscn`.

O jogo usa GDScript, cenas `.tscn`, autoloads e assets nativos do Godot. Nao usa TypeScript, React Native, Expo ou codigo web como base principal.

## Como jogar/testar

- Menu principal: deve seguir a tela `frontend/app/index.tsx` da branch `main`, com `Jogar`, `Melhorias`, `Skins` e o menu flutuante `Mais`.
- Jogar: seletor com 50 fases e modo infinito liberado apos progresso inicial.
- Arena: a bolinha se move continuamente; toque ou clique na arena para aplicar impulso na direcao tocada.
- Objetivo: sobreviver aos aneis, atravessar o centro da abertura para Perfect, quebrar aneis no impacto e completar a fase.

## Checklist de fidelidade com a branch main

Fonte obrigatoria: branch `main`. A versao Godot nao deve criar layout, texto, valores ou comportamento novo quando ja existir referencia na `main`.

| Tela / sistema | Arquivo/fonte na branch main | Arquivo equivalente no Godot | Status | Diferencas pendentes |
|---|---|---|---|---|
| Tela inicial | `frontend/app/index.tsx`, `ProfileAvatar`, `UiIcon`, `retention.ts` | `scenes/MainMenu.tscn`, `scripts/screens/MainMenu.gd` | Em progresso | Copiar exatamente ordem visual, botao flutuante `Mais`, modal, toast de conquista e modal AFK. Remover textos extras. |
| Jogar / selecao de fases | `frontend/app/phase-select.tsx`, `src/game/phases.ts` | `scenes/PhaseSelect.tscn`, `scripts/screens/PhaseSelect.gd` | Em progresso | Trocar grid compacto por lista vertical de cards de 140px com descricao, dificuldade, HP e overlay bloqueado. |
| Gameplay solo | `frontend/app/game.tsx`, `src/game/rings.ts`, `src/game/playerAttributes.ts`, `src/game/balance.ts`, `src/game/economy.ts` | `scenes/Game.tscn`, `scripts/screens/GameScreen.gd`, `scripts/game/RingLogic.gd`, `scripts/game/ArenaView.gd` | Em progresso | Remover controles inventados, portar HUD/pausa/level-up/revive/recompensas e comparar fisica 1:1. |
| Modo infinito | `frontend/app/infinite.tsx`, `src/game/dualArena.ts`, `src/game/balance.ts` | `scenes/Game.tscn` por enquanto | Pendente | Criar tela/fluxo proprio; modo atual por ondas nao equivale ao da main. |
| Melhorias | `frontend/app/upgrade-shop.tsx`, `src/game/upgrades.ts`, `src/game/balance.ts` | `scenes/Upgrades.tscn`, `scripts/screens/UpgradeScreen.gd`, `autoload/GameData.gd` | Em progresso | Portar todos upgrades temporarios/secretos, nomes, textos, unlocks, custos e cards. |
| Skins | `frontend/app/transformations.tsx`, `src/game/skins.ts`, `src/game/skinImages.ts`, `SkinIcon` | `scenes/Skins.tscn`, `scripts/screens/SkinScreen.gd`, `autoload/GameData.gd` | Em progresso | Substituir heuristicas por lista literal de skins, passivas, efeitos especiais, raridades e custos. |
| Loja | `frontend/app/store.tsx`, `src/services/billingConfig.ts`, `src/services/billingService.ts`, `src/game/chests.ts` | `scenes/Shop.tscn`, `scripts/screens/ShopScreen.gd` | Em progresso | Recriar abas `chests/gems/keys/specials/free`, produtos, confirm modal e recompensas mockadas. |
| Inventario / baus | `frontend/app/inventory.tsx`, `src/game/chests.ts`, `SkinIcon`, `UiIcon` | `scenes/Chests.tscn`, `scripts/screens/ChestScreen.gd`, `FeatureScreen.gd` | Em progresso | Tela precisa mostrar bau gratis, lista de baus, itens guardados, delay/animacao e modal de recompensa. |
| Missoes | `frontend/app/daily.tsx`, `src/game/retention.ts` | `FeatureScreen.gd` por enquanto | Pendente | Portar 25 missoes, selecao diaria seeded, progresso, coletar, reroll e boost por anuncio. |
| Evento | `frontend/app/events.tsx`, `src/game/retention.ts` | `FeatureScreen.gd` por enquanto | Pendente | Portar eventos semanais, cores, missoes, progresso e recompensa final. |
| Roleta | `frontend/app/wheel.tsx`, `src/game/retention.ts` | `FeatureScreen.gd` por enquanto | Pendente | Criar roleta visual com 10 segmentos, ponteiro, animacao de 3600ms e modal de premio. |
| Recompensa diaria | `frontend/app/daily-reward.tsx`, `GameContext.tsx` | `FeatureScreen.gd` por enquanto | Em progresso | Ajustar tela e storage/logica para bater exatamente com a main. |
| Boss | `frontend/app/boss.tsx`, `src/game/boss.ts`, `src/game/dualArena.ts`, `DualArenaView` | `FeatureScreen.gd` por enquanto | Pendente | Portar boss mensal, niveis, reset diario/mensal, duas arenas e recompensas. |
| Liga Neon | `frontend/app/league.tsx`, `frontend/app/compete.tsx`, `src/game/league.ts`, `src/game/dualArena.ts` | `FeatureScreen.gd` por enquanto | Pendente | Portar ranking com 201 participantes, divisoes, podium, competir e recompensas. |
| Conquistas | `frontend/app/achievements.tsx`, `src/game/achievements.ts`, `GameContext.tsx` | `FeatureScreen.gd` por enquanto | Pendente | Portar todas conquistas, categorias, progresso e coleta de recompensas. |
| Configuracoes / perfil | `frontend/app/profile.tsx`, `AudioController`, `GameContext.tsx`, i18n/performance | `FeatureScreen.gd` por enquanto | Pendente | Portar perfil, avatar, nickname, idioma, audio, performance, stats e progresso. |
| Save / progresso | `src/contexts/GameContext.tsx` | `autoload/SaveSystem.gd` | Em progresso | Espelhar schema completo da main: achievements, league, boss, dailyMissions, weeklyEvent, wheel, adLimits e inventoryItems. |
| Assets | `frontend/assets/**` | `godot/assets/**` | Quase fiel | Skins, UI icons, audio e fonte foram copiados; logos React de template nao sao usados no jogo final. |

## Export Web / HTML5

Pelo editor:

1. Abra o projeto no Godot.
2. Instale os export templates da mesma versao do Godot.
3. Va em `Project > Export`.
4. Selecione o preset `Web`.
5. Exporte para `godot/build/web/index.html`.

Via CLI/headless:

```bash
godot --headless --path godot --export-release "Web" build/web/index.html
```

Para servir localmente depois da exportacao:

```bash
python3 -m http.server 8080 -d godot/build/web
```

Depois abra `http://localhost:8080`.

## GitHub Pages

Foi adicionado o workflow `.github/workflows/godot-web.yml`.

Ele roda em push para a branch `godot-4-rebuild` ou manualmente via `workflow_dispatch`, baixa Godot 4.3, instala os export templates, exporta o preset `Web` e publica o conteudo de `godot/build/web` no GitHub Pages.

Para usar:

1. No GitHub, ative Pages com `GitHub Actions` como source.
2. Faça push da branch `godot-4-rebuild`.
3. Abra a URL gerada pelo job `deploy-pages`.

## Android / APK futuro

Existe um preset `Android` em `godot/export_presets.cfg` com package base `com.dmartef.neonidleescape`, orientacao retrato, modo imersivo e permissoes de internet/vibrate.

Ainda pendente para APK real:

- configurar Android SDK/JDK no ambiente de build;
- instalar export templates Android;
- configurar keystore de release;
- decidir se anuncios reais entram por plugin Godot/Android;
- testar performance em device fisico.

Com ambiente Android pronto, o comando esperado sera:

```bash
godot --headless --path godot --export-release "Android" build/android/neon-idle-escape.apk
```

## Assets reaproveitados

Copiados do projeto atual para `/godot/assets`:

- 92 skins PNG em `assets/images/skins`;
- 51 icones e imagens de UI em `assets/ui`;
- 19 efeitos sonoros MP3 em `assets/sounds`;
- 6 musicas MP3/WAV em `assets/music`;
- 1 fonte TTF em `assets/fonts`;
- imagens de app/icon/splash em `assets/images/app`.

Nao foram copiados os logos padrao do React (`react-logo*.png`, `partial-react-logo.png`) porque sao placeholders do template e nao fazem parte do estilo final do jogo.

## Sistemas recriados em Godot 4

- projeto Godot real com `project.godot`, cenas e scripts separados;
- autoloads `GameData`, `SaveSystem`, `AudioManager`, `AdsService`;
- autoload `TimeSystem` com relogio local, chave diaria/semanal, reset diario, reset semanal e timers;
- progresso local em `user://neon_idle_escape_godot_save.json`;
- coleta AFK/offline ao abrir o jogo, com opcao 2x via anuncio mock;
- fases 1-50 com dificuldade procedural baseada no projeto atual;
- modo infinito jogavel com ondas crescentes reaproveitando a arena;
- aneis concentricos com rotacao alternada, gaps, aneis solidos, HP, fechamento e spacing;
- fisica da bolinha com colisao radial, reflexao, parede externa e impulso por toque;
- Perfect Escape ao cruzar o vao do anel, com chance pequena de diamante;
- dano, critico, quebra de aneis, moedas, XP, combo e recompensas por rodada;
- level-up durante a run com upgrades temporarios;
- upgrades permanentes bloqueados/desbloqueaveis e compraveis;
- loja funcional com recompensas por anuncios mock e pacotes com diamantes;
- baus por raridade com skins, fragmentos, moedas, diamantes, chaves, efeitos e upgrades;
- tela de skins com filtros, equipar, evoluir e criar com fragmentos;
- tela de game over/recompensas com dobrar recompensa via anuncio mock;
- menu inicial polido com identidade Neon Idle Escape, visual escuro/roxo, brilho ciano, cards arredondados e botoes mobile;
- menu completo com telas polidas para Inventario, Missoes, Evento, Roleta, Recompensa diaria, Boss, Liga Neon, Conquistas e Configuracoes;
- recompensa diaria funcional: moedas, diamantes e chave uma vez por dia;
- roleta funcional com giro gratis diario e giros por anuncio mock;
- inventario com resumo de baus, skins, efeitos e atalhos;
- missoes, eventos, boss, liga e conquistas estruturados com progresso local/mock para expansao;
- configuracoes de som, musica e haptics salvas localmente;
- musica/SFX usando assets originais;
- UI vertical pensada para celular e Web mobile.

## Pendencias conhecidas

- Boss ainda usa tela/estrutura local e precisa de combate dedicado.
- Liga Neon ainda usa ranking local/mock; ranking online depende de backend futuro.
- Missoes, eventos e conquistas exibem progresso real/local, mas coleta completa de recompensas e calendario sazonal ainda precisam ser finalizados.
- Inventario esta funcional como hub de baus/skins/efeitos, mas ainda pode ganhar lista detalhada de todos os itens.
- Billing real nao foi migrado; loja usa fluxo funcional local/mock.
- Ads reais nao foram integrados; `AdsService.gd` e um stub recompensado.
- APK Android esta apenas estruturado.
- O balanceamento visual/fisico deve ser refinado apos testes em Godot real e mobile.
- Caso algum MP3/WAV precise reimportacao manual, abra o projeto no editor uma vez para gerar `.import`.

## Validacao local realizada

Esta versao foi validada no container com Godot 4.3 headless:

```bash
godot --headless --path godot --quit
godot --headless --path godot --scene res://scenes/Main.tscn --quit-after 1
godot --headless --path godot --scene res://scenes/Game.tscn --quit-after 1
godot --headless --path godot --scene res://scenes/MainMenu.tscn --quit-after 1
godot --headless --path godot --scene res://scenes/PhaseSelect.tscn --quit-after 1
godot --headless --path godot --scene res://scenes/Feature.tscn --quit-after 1
godot --headless --path godot --export-release "Web" build/web/index.html
```

Resultados:

- scripts GDScript parsearam sem erros;
- cena principal e cena de gameplay inicializaram em headless;
- recursos foram importados pelo Godot;
- export Web gerou `index.html`, `index.js`, `index.pck`, `index.wasm` e icones em `godot/build/web`;
- servidor local temporario respondeu 200 para `/`, `index.js`, `index.pck`, `index.wasm` e icones.

Observacao: no container, o Godot headless emitiu avisos de socket/TCP e, ao sair de algumas cenas, um aviso nao fatal de recurso ainda em uso. A exportacao Web concluiu com exit code 0.
