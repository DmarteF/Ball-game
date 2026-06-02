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
- Arena: a bolinha se move continuamente como na branch `main`; os controles visiveis sao pausa/mute e compras ATK/Gold da rodada.
- Objetivo: sobreviver aos aneis, atravessar o centro da abertura para Perfect, quebrar aneis no impacto e completar a fase.

## Checklist de fidelidade com a branch main

Fonte obrigatoria: branch `main`. A versao Godot nao deve criar layout, texto, valores ou comportamento novo quando ja existir referencia na `main`.

### Tela inicial - correcao focal

Arquivos da branch `main` usados como referencia direta:

- `frontend/app/index.tsx`
- `frontend/src/components/AdModal.tsx`
- `frontend/src/components/UiIcon.tsx`
- `frontend/src/components/ProfileAvatar.tsx`
- `frontend/src/contexts/GameContext.tsx`
- `frontend/src/game/uiIcons.ts`
- `frontend/src/game/retention.ts`
- `frontend/src/i18n/locales/pt-BR.ts`
- `frontend/src/utils/audio.ts`
- `frontend/assets/ui/ui_play.png`
- `frontend/assets/ui/ui_upgrades.png`
- `frontend/assets/ui/ui_skins.png`
- `frontend/assets/ui/ui_menu.png`
- `frontend/assets/ui/ui_coin.png`
- `frontend/assets/ui/ui_gem.png`
- `frontend/assets/ui/ui_key.png`
- `frontend/assets/ui/ui_profile.png`
- `frontend/assets/ui/ui_store.png`
- `frontend/assets/ui/ui_inventory.png`
- `frontend/assets/ui/ui_missions.png`
- `frontend/assets/ui/ui_event.png`
- `frontend/assets/ui/ui_wheel.png`
- `frontend/assets/ui/ui_daily_reward.png`
- `frontend/assets/ui/ui_boss.png`
- `frontend/assets/ui/ui_league_neon.png`
- `frontend/assets/ui/ui_achievements.png`
- `frontend/assets/ui/ui_settings.png`

Tela Inicial - Comparacao com branch main

| Elemento | Main original | Godot atual | Status |
|---|---|---|---|
| Fundo | `LinearGradient` `#0a0a1a`, `#1a0a2e`, `#16003b` | Gradiente vertical com as mesmas cores | ok |
| Logo NEON | Texto `NEON`, fontSize 60, bold, cor/sombra `#00f0ff`, letterSpacing 6 | Label `NEON`, 60, sombra ciano, centralizado | ok |
| Subtitulo | Texto `IDLE ESCAPE`, fontSize 18, weight 300, branco, letterSpacing 7 | Label `IDLE ESCAPE`, 18, branco, centralizado | ok |
| Botao Jogar | 100%, 78px, radius 16, gradiente `#00f0ff` -> `#0088ff`, icone `ui_play` 32, texto 30 | Controle 78px, radius 16, gradiente diagonal, icone e texto reais | ok |
| Botao Melhorias | Card 92px, radius 14, gradiente `#b000ff66` -> `#6600cc33`, icone `ui_upgrades` 42, texto 13 | Card 92px com gradiente, icone e texto reais | ok |
| Botao Skins | Card 92px, radius 14, gradiente `#ff008866` -> `#cc006633`, icone `ui_skins` 42, texto 13 | Card 92px com gradiente, icone e texto reais | ok |
| Botao Mais | Absoluto direita 18, bottom 24, 64x64, radius 18, bg `#00f0ff`, icone `ui_menu` 26, texto 11 | Controle 64x64 na mesma ancora, cor, icone e texto | ok |
| Icones | `UiIcon` carrega assets reais de `frontend/assets/ui` | Assets reais copiados para `godot/assets/ui` | ok |
| Fonte | React Native default, weights bold/300 conforme estilos | Fontes/tamanhos espelhados nos Labels Godot | ok |
| Cores | Valores hex literais do `StyleSheet` | Valores hex literais aplicados | ok |
| Posicoes | Topbar 50/18, content 20, title marginTop 22 apos topbar, bottom 96 | Posicoes calculadas a partir do layout 420x760 da main | ok |
| Tamanhos | Alturas 78/92/64, icones 18/26/32/42, textos 11/13/18/30/60 | Mesmos tamanhos configurados | ok |
| Bordas/sombras/brilho | Radius 10/14/16/18, sombras ciano nos elementos neon | StyleBoxes com radius/sombras equivalentes | ok |

Checklist da tela inicial Godot apos esta correcao:

- Fundo igual: sim
- Logo igual: sim
- Posicao do logo igual: sim
- Botao JOGAR igual: sim
- Botao MELHORIAS igual: sim
- Botao SKINS igual: sim
- Botao MAIS igual: sim
- Icones iguais: sim
- Fontes iguais: sim
- Cores iguais: sim
- Bordas/brilho/sombras iguais: sim
- Espacamentos iguais: sim
- Navegacao dos botoes funcionando: sim
- Sem debug/placeholders/rebuild: sim

| Tela / sistema | Arquivo/fonte na branch main | Arquivo equivalente no Godot | Status | Diferencas pendentes |
|---|---|---|---|---|
| Tela inicial | `frontend/app/index.tsx`, `ProfileAvatar`, `UiIcon`, `retention.ts` | `scenes/MainMenu.tscn`, `scripts/screens/MainMenu.gd` | Portado em UI/logica base | Layout de topbar, recursos, titulo, botao Jogar, cards Melhorias/Skins, botao Mais, menu modal e AFK foram reajustados. Falta comparacao visual pixel a pixel e toast de conquista. |
| Jogar / selecao de fases | `frontend/app/phase-select.tsx`, `src/game/phases.ts` | `scenes/PhaseSelect.tscn`, `scripts/screens/PhaseSelect.gd` | Portado em UI | Lista vertical de cards de 140px, modo infinito, descricoes, dificuldade, HP e overlay bloqueado foram recriados. Falta comparacao visual pixel a pixel. |
| Gameplay solo | `frontend/app/game.tsx`, `src/game/rings.ts`, `src/game/playerAttributes.ts`, `src/game/balance.ts`, `src/game/economy.ts` | `scenes/Game.tscn`, `scripts/screens/GameScreen.gd`, `scripts/game/RingLogic.gd`, `scripts/game/ArenaView.gd` | Em progresso fiel | Ring logic, limites de velocidade, arena responsiva, HUD principal e ATK/Gold foram realinhados. Falta portar modais de pausa/vitoria/derrota/revive/level-up exatamente iguais. |
| Modo infinito | `frontend/app/infinite.tsx`, `src/game/dualArena.ts`, `src/game/balance.ts` | `scenes/Game.tscn` por enquanto | Em progresso | Existe modo por ondas e estatisticas de conquistas infinitas. Ainda falta tela/fluxo proprio igual ao `infinite.tsx`. |
| Melhorias | `frontend/app/upgrade-shop.tsx`, `src/game/upgrades.ts`, `src/game/balance.ts` | `scenes/Upgrades.tscn`, `scripts/screens/UpgradeScreen.gd`, `autoload/GameData.gd` | Portado em UI/logica base | Cards, moeda, unlocks, custos, textos, acentos e upgrades secretos foram recriados. Falta comparar posicao pixel a pixel. |
| Skins | `frontend/app/transformations.tsx`, `src/game/skins.ts`, `src/game/skinImages.ts`, `SkinIcon` | `scenes/Skins.tscn`, `scripts/screens/SkinScreen.gd`, `autoload/GameData.gd` | Portado em UI/dados base | Grade, filtros, progresso por raridade, nomes e descricoes literais, equipar/evoluir foram recriados. Falta portar literalmente todas as passivas/specialEffects e cores/trails 1:1. |
| Loja | `frontend/app/store.tsx`, `src/services/billingConfig.ts`, `src/services/billingService.ts`, `src/game/chests.ts` | `scenes/Shop.tscn`, `scripts/screens/ShopScreen.gd` | Portado em UI/logica base | Abas, cards de baus, produtos, recompensas e textos principais foram recriados. Falta modal de confirmacao/resultado igual ao React Native. |
| Inventario / baus | `frontend/app/inventory.tsx`, `src/game/chests.ts`, `SkinIcon`, `UiIcon` | `scenes/Chests.tscn`, `scripts/screens/ChestScreen.gd` | Portado em UI/logica base | Bau gratis, lista de baus, itens guardados, textos e modal de recompensa foram recriados. Falta animacao/delay visual de abertura. |
| Missoes | `frontend/app/daily.tsx`, `src/game/retention.ts` | `FeatureScreen.gd` | Portado em UI/logica base | 25 missoes, selecao diaria seeded, progresso, coletar, reroll e boost por anuncio stub foram recriados. Falta i18n e estado detalhado por missao como na main. |
| Evento | `frontend/app/events.tsx`, `src/game/retention.ts` | `FeatureScreen.gd` | Portado em dados/logica base | Os 10 eventos semanais, missoes, progresso e recompensa final foram portados. Falta reproduzir layout final/animacoes da tela React Native. |
| Roleta | `frontend/app/wheel.tsx`, `src/game/retention.ts` | `FeatureScreen.gd` | Portado em logica base | 10 recompensas, giro gratis/ad e resultado funcional foram recriados. Falta animacao circular 3600ms e ponteiro igual. |
| Recompensa diaria | `frontend/app/daily-reward.tsx`, `GameContext.tsx` | `FeatureScreen.gd` | Portado em UI/logica base | Pacote diario e controle por dia foram recriados. |
| Boss | `frontend/app/boss.tsx`, `src/game/boss.ts`, `src/game/dualArena.ts`, `DualArenaView` | `FeatureScreen.gd` | Em progresso | Menu Boss, desbloqueio, progresso e entrada no jogo foram recriados. Falta duelo real de duas arenas. |
| Liga Neon | `frontend/app/league.tsx`, `frontend/app/compete.tsx`, `src/game/league.ts`, `src/game/dualArena.ts` | `FeatureScreen.gd` | Em progresso | Resumo, podium, ranking e reward card foram recriados localmente. Falta port completo de 201 participantes/temporadas/competir. |
| Conquistas | `frontend/app/achievements.tsx`, `src/game/achievements.ts`, `GameContext.tsx` | `FeatureScreen.gd` | Portado em dados/logica base | Lista completa da main foi portada com progresso, coleta e recompensas. Falta filtros horizontais por categoria e esconder conquistas ocultas exatamente como na main. |
| Configuracoes / perfil | `frontend/app/profile.tsx`, `AudioController`, `GameContext.tsx`, i18n/performance | `FeatureScreen.gd` | Em progresso | Perfil, conta, audio, desempenho, idioma, liga e stats foram recriados em cards. Falta foto/avatar editavel, nickname input e todas as opcoes reais. |
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
- fisica da bolinha com colisao radial, reflexao e parede externa;
- Perfect Escape ao cruzar o vao do anel, com chance pequena de diamante;
- dano, critico, quebra de aneis, moedas, XP, combo e recompensas por rodada;
- level-up durante a run com upgrades temporarios;
- upgrades permanentes bloqueados/desbloqueaveis e compraveis;
- loja funcional com recompensas por anuncios mock e pacotes com diamantes;
- baus por raridade com skins, fragmentos, chaves, trilhas, auras e efeitos, seguindo `frontend/src/game/chests.ts`;
- tela de skins com filtros, equipar, evoluir e criar com fragmentos;
- tela de game over/recompensas com dobrar recompensa via anuncio mock;
- menu inicial polido com identidade Neon Idle Escape, visual escuro/roxo, brilho ciano, cards arredondados e botoes mobile;
- menu completo com telas polidas para Inventario, Missoes, Evento, Roleta, Recompensa diaria, Boss, Liga Neon, Conquistas e Configuracoes;
- recompensa diaria funcional: moedas, diamantes e chave uma vez por dia;
- roleta funcional com giro gratis diario e giros por anuncio mock;
- inventario com resumo de baus, skins, efeitos e atalhos;
- missoes, eventos, boss, liga e conquistas estruturados com progresso local, recompensas locais e stubs quando o subsistema completo ainda depende de port futuro;
- configuracoes de som, musica e haptics salvas localmente;
- musica/SFX usando assets originais;
- UI vertical pensada para celular e Web mobile.

## Pendencias conhecidas

- Boss ainda usa menu/entrada local e precisa do combate dedicado de duas arenas.
- Liga Neon ainda usa ranking local/mock; ranking online depende de backend futuro.
- Eventos e conquistas ja receberam listas literais da main; ainda faltam filtros/animacoes/layout final das telas React Native.
- Inventario esta funcional para baus e recompensas, mas ainda precisa da animacao/delay visual de abertura.
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
