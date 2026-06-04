# Neon Idle Escape - Godot

Esta pasta foi reiniciada do zero na branch `godot-4-rebuild`. A branch `main` foi usada somente como referencia via `git show`, `git ls-tree` e `git archive`; nao foi feito checkout nem edicao nela.

## Estado atual da branch

Depois da auditoria de 2026-06-03, a branch `godot-4-rebuild` foi limpa para manter o projeto ativo focado em Godot. O runtime, os assets e a exportacao Web ficam dentro de `/godot`; as pastas legadas Expo/React Native/backend/Emergent foram removidas desta branch. A politica de privacidade antiga foi migrada para `docs/privacy-policy.html` dentro desta pasta. O relatorio completo esta em `docs/LEGACY_CLEANUP_AUDIT.md`.

## Build de teste atual

HTML/Web:

```bash
mkdir -p godot/build/web
/tmp/godot-cli/Godot_v4.3-stable_linux.x86_64 --headless --path godot --export-release Web build/web/index.html
cd godot/build/web
python3 -m http.server 8083 --bind 0.0.0.0
```

Teste local:

```text
http://127.0.0.1:8083/index.html
```

APK debug:

```bash
export ANDROID_SDK_ROOT=/home/codespace/android-sdk
export ANDROID_HOME=/home/codespace/android-sdk
export JAVA_HOME=/usr/local/sdkman/candidates/java/current
mkdir -p godot/build/android
/tmp/godot-cli/Godot_v4.3-stable_linux.x86_64 --headless --path godot --export-debug Android build/android/neon-idle-escape-debug.apk
/home/codespace/android-sdk/build-tools/34.0.0/apksigner verify --verbose godot/build/android/neon-idle-escape-debug.apk
```

Arquivo gerado:

```text
godot/build/android/neon-idle-escape-debug.apk
```

O APK de teste foi gerado pelo export Android do Godot 4.3. Expo/EAS nao foi usado porque o projeto ativo desta branch nao e mais Expo/React Native.

Configuracoes Android adicionadas:

- preset `Android` em `export_presets.cfg`;
- icones Android em `assets/icons/android`;
- compressao ETC2/ASTC habilitada em `project.godot`;
- package debug `com.dmartef.neonidleescape`;
- orientacao retrato e modo imersivo.

## 1. O que foi limpo

- Removida completamente a tentativa Godot anterior em `/godot`.
- Removidos scripts, autoloads, cenas antigas, imports gerados, build web antigo e cache `.godot` antigos da branch.
- Criada uma base Godot 4 limpa com apenas:
  - `project.godot`
  - `export_presets.cfg`
  - `scenes/MainMenu.tscn`
  - `scenes/Placeholder.tscn`
  - `scripts/MainMenu.gd`
  - `scripts/Placeholder.gd`

## 2. Assets importados

Todos os assets rastreados na `main` foram copiados para `/godot/assets` e organizados assim:

| Pasta | Conteudo | Quantidade |
| --- | --- | ---: |
| `assets/images` | imagens do app Expo (`frontend/assets/images`) | 9 |
| `assets/sounds` | efeitos sonoros (`frontend/assets/audio/sfx`) | 19 |
| `assets/music` | musicas (`frontend/assets/audio/music`) | 6 |
| `assets/fonts` | fontes (`frontend/assets/fonts`) | 1 |
| `assets/ui` | icones e sprites de UI (`frontend/assets/ui`) | 51 |
| `assets/skins` | skins (`frontend/assets/skins`) | 92 |
| `assets/icons` | icone principal e icones de produto extraidos | 10 |
| `assets/backgrounds` | feature cover do app | 1 |
| `assets/original` | zips originais e pacote extraido de assets ambiguos | 22 |

Arquivos ambiguos mantidos em `assets/original`:

- `aptoide_product_icons_512_png.zip`
- `neon_missing_assets_pack_1024_png.zip`
- `neon_missing_assets_pack_1024_png/*`

## 3. Referencias da branch main

Arquivos usados como referencia direta para a tela inicial:

- `frontend/app/index.tsx`
- `frontend/src/components/UiIcon.tsx`
- `frontend/src/components/ProfileAvatar.tsx`
- `frontend/src/components/AudioController.tsx`
- `frontend/src/utils/audio.ts`
- `frontend/src/game/uiIcons.ts`
- `frontend/src/i18n/index.tsx`
- `frontend/src/i18n/locales/en.ts`
- `frontend/src/i18n/locales/pt-BR.ts`
- `frontend/src/game/retention.ts`
- `frontend/src/utils/time.ts`

Notas de fidelidade:

- A tela inicial da `main` nao usa uma imagem de logo separada; o "logo" visivel e o titulo textual `NEON` + subtitulo `IDLE ESCAPE`.
- O idioma padrao da `main` e `en`, entao a primeira abertura limpa mostra `PLAY`, `UPGRADES`, `SKINS` e `More`.
- O item `Event` usa a cor semanal calculada pela `main`. Em 2026-06-02, a semana cai no evento `chests`, cor `#00ff88`.

## 4. Checklist da tela inicial

| Elemento | Status |
| --- | --- |
| Fundo | OK |
| Logo | OK |
| Titulo/subtitulo | OK |
| Botao Jogar | OK |
| Botao Melhorias | OK |
| Botao Skins | OK |
| Botao Mais | OK |
| Icones | OK |
| Fonte | Pendente |
| Cores | OK |
| Bordas/brilho/sombras | Pendente |
| Espacamento | OK |
| Proporcao/enquadramento | OK |

Pendencias marcadas assim porque a `main` usa a fonte de sistema do React Native e sombras CSS/React Native; no Godot elas foram aproximadas com `SystemFont`, `StyleBoxFlat` e shader de gradiente. A comparacao visual pixel a pixel ainda deve ser feita no navegador.

## 5. Checklist de telas base

| Tela | Arquivo/fonte na branch main | Cena/script Godot | Status | Diferencas conhecidas |
| --- | --- | --- | --- | --- |
| Tela inicial | `frontend/app/index.tsx`, `frontend/src/components/ProfileAvatar.tsx`, `frontend/src/components/UiIcon.tsx` | `scenes/MainMenu.tscn`, `scripts/MainMenu.gd` | Concluida/ajustada | Congelada por etapa; sombras/fonte sao aproximacoes Godot. |
| Jogar / selecao de fases | `frontend/app/phase-select.tsx`, `frontend/src/game/phases.ts`, `assets/ui/ui_infinite.png`, `assets/ui/ui_locked.png` | `scenes/PhaseSelect.tscn`, `scripts/PhaseSelectScreen.gd` | Ajustado | Cards mostram fase, dificuldade e aneis, sem HP/descricao longa. Fase 1 abre a gameplay; demais fases e modo infinito seguem visuais/mockados. |
| Perfil | `frontend/app/profile.tsx`, `frontend/src/components/ProfileAvatar.tsx`, `frontend/src/components/SkinIcon.tsx`, `frontend/src/components/UiIcon.tsx`, `frontend/src/game/skins.ts`, `frontend/src/game/achievements.ts`, `frontend/src/game/upgrades.ts` | `scenes/Profile.tscn`, `scripts/ProfileScreen.gd` | Ajustado nesta etapa | Configuracoes, audio, idioma, FPS e Hz removidos do Perfil. Botao Back padronizado com Coming soon. Dados reais ainda mockados ate o save completo ser portado. |
| Configuracoes | Pedido desta etapa + estilo visual da tela inicial | `scenes/Settings.tscn`, `scripts/SettingsScreen.gd` | Concluida nesta etapa | Tela simples: audio ligado/mudo, idioma e sobre. Botao Back padronizado com Coming soon. Estado salvo em `user://settings.json`. |
| Skins | `frontend/app/transformations.tsx`, `frontend/src/game/skins.ts`, `frontend/src/components/SkinIcon.tsx`, `assets/skins/*` | `scenes/Skins.tscn`, `scripts/SkinsScreen.gd`, `scripts/MainPortData.gd` | Funcional | 92 skins da main importadas, com raridade, cores, passivas, bloqueio/equipar e efeito basico na gameplay. Alguns efeitos ultra-especificos seguem aproximados. |
| Upgrades/Melhorias | `frontend/app/upgrade-shop.tsx`, `frontend/src/game/upgrades.ts`, `frontend/src/game/balance.ts`, `frontend/src/components/UpgradeIcon.tsx` | `scenes/Upgrades.tscn`, `scripts/UpgradesScreen.gd`, `scripts/MainPortData.gd` | Funcional | Permanentes compraveis; 34 upgrades temporarios da main importados e usados em gameplay/Liga. |
| Loja | `frontend/app/store.tsx`, assets `assets/icons/products/*`, `assets/ui/ui_store.png` | `scenes/Shop.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Titulo simples, descricao longa removida e abas reenquadradas. Cards e botoes mockados; sem compra real. |
| Inventario | `frontend/app/inventory.tsx`, assets de baus/chaves em `assets/ui` | `scenes/Inventory.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Descricao longa removida; estado vazio discreto preparado. |
| Missoes | `frontend/app/daily.tsx`, `frontend/src/game/retention.ts`, `assets/ui/ui_missions.png` | `scenes/Missions.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Titulo simples; estado vazio discreto enquanto nao ha missoes reais. |
| Evento | `frontend/app/events.tsx`, `frontend/src/game/retention.ts`, `assets/ui/ui_event.png` | `scenes/Event.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Titulo simples; estado vazio discreto quando nao ha evento ativo. |
| Roleta | `frontend/app/wheel.tsx`, `assets/ui/ui_wheel.png` | `scenes/Wheel.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Titulo simples; roleta visual mantida e sorteio real pendente. |
| Recompensa diaria | `frontend/app/daily-reward.tsx`, `assets/ui/ui_daily_reward.png` | `scenes/DailyReward.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Calendario de 7 dias mockado; controle real de tempo/coleta pendente. |
| Boss | `frontend/app/boss.tsx`, `assets/ui/ui_boss.png` | `scenes/Boss.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Tela visual com estado vazio discreto; logica real de boss pendente. |
| Liga Neon | `frontend/app/league.tsx`, `frontend/src/game/league.ts`, `assets/ui/ui_league_neon.png` | `scenes/League.tscn`, `scripts/LeagueScreen.gd`, `scenes/LeagueBattle.tscn`, `scripts/LeagueBattleScreen.gd` | Funcional | Tela de ranking mensal, 30 competidores, batalha versus com duas arenas, trofeus, recompensas e anuncios mockados. |
| Conquistas | `frontend/app/achievements.tsx`, `frontend/src/game/achievements.ts`, `assets/ui/ui_achievements.png` | `scenes/Achievements.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Tela visual com estado vazio; lista/progresso real pendente. |

## 6. Save, progresso e tempo

Autoloads criados em `project.godot`:

- `scripts/SaveManager.gd`: le e grava o JSON local em `user://neon_idle_escape_save.json`.
- `scripts/GameState.gd`: estado global do jogador e funcoes simples de economia/progresso.
- `scripts/TimeManager.gd`: relogio interno, login/saida, offline, daily, eventos e boss.

Dados salvos atualmente:

- moedas, diamantes, chaves e chaves lendarias;
- XP, nivel, fase atual, fases desbloqueadas e maior fase;
- skins desbloqueadas, skin equipada, skin favorita, fragmentos e niveis de skin;
- upgrades desbloqueados e niveis de upgrades permanentes;
- audio/idioma;
- ultimo login, ultima saida, ultima recompensa diaria e streak diario;
- estado base de eventos, boss e recompensas AFK pendentes;
- estatisticas basicas como partidas, aneis, perfects, diamantes, baus e boss.

Funcoes principais disponiveis no `GameState`:

- `add_coins`, `spend_coins`, `add_diamonds`, `spend_diamonds`, `add_keys`, `spend_keys`;
- `unlock_skin`, `equip_skin`, `upgrade_permanent`, `unlock_level`;
- `refresh_unlocks`, `get_upgrade_cost`, `get_upgrade_max_level`, `is_upgrade_unlocked`, `purchase_permanent_upgrade`;
- `apply_reward`, `shop_claim`, `spin_wheel`, `claim_daily_reward`, `open_chest`;
- `claim_daily_mission`, `claim_achievement`, progresso de missoes/conquistas por metricas salvas;
- `save_game`, `load_game`, `set_audio_muted`, `set_language`.

Funcoes principais disponiveis no `TimeManager`:

- `get_now_timestamp`, `get_last_login_timestamp`, `get_last_exit_timestamp`;
- `get_offline_seconds`, `get_offline_minutes`, `get_offline_hours`;
- `is_new_day`, `can_claim_daily_reward`, `mark_daily_reward_claimed`, `get_daily_streak`, `update_daily_streak`;
- `calculate_afk_rewards`, `get_pending_afk_rewards`, `claim_afk_rewards`;
- `get_event_time_remaining`, `is_event_active`, `is_boss_available`, `mark_boss_attempt`, `save_time_state`.

Telas que ja leem dados reais:

- Menu inicial: nome, nivel e recursos.
- Perfil: nome, nivel, XP, recursos e estatisticas basicas.
- Configuracoes: audio/idioma salvos no `GameState`.
- Loja: recursos do jogador, compras simuladas, resgates por anuncio mockado, baus/chaves e validacao de saldo.
- Skins: recursos, desbloqueios reais e skin equipada.
- Upgrades: recursos, desbloqueios reais, custos, limites, compra e niveis permanentes.
- Inventario: itens/baus salvos, estado vazio real e abertura de baus com recompensa.
- Missoes: missoes diarias reais, progresso salvo e coleta de recompensa.
- Roleta: giro gratis diario, giro extra mockado por anuncio e entrega real de recompensa.
- Recompensa diaria: streak de 7 dias, TimeManager, coleta uma vez por dia e recompensas reais.
- Conquistas: progresso por estatisticas, bloqueado/concluido/coletado e recompensa real.
- Jogar: fases desbloqueadas e Modo Infinito baseado na maior fase.
- Boss: disponibilidade visual baseada no cooldown do `TimeManager`.

Ainda mockado/pendente:

- boss real, eventos reais e integracao com pagamento/anuncio real.
- Liga Neon tem tela mensal e duelo jogavel; balanceamento fino e comparacao visual contra a main seguem em evolucao.
- Recompensas AFK sao calculadas e armazenadas como pendentes, mas nao sao concedidas automaticamente.

Observacao de seguranca: o relogio atual usa horario local do aparelho. Em Android/APK isso pode ser manipulado alterando o relogio do celular. A estrutura ficou preparada para futura validacao online, mas essa validacao ainda nao foi implementada.

## 7. Gameplay - Fase 1

Referencias analisadas na branch `main`:

- `frontend/app/game.tsx`
- `frontend/app/phase-select.tsx`
- `frontend/src/game/phases.ts`
- `frontend/src/game/rings.ts`
- `frontend/src/game/balance.ts`
- `frontend/src/game/playerAttributes.ts`
- `frontend/src/game/economy.ts`

Arquivos Godot criados/alterados:

- `GAMEPLAY_MAIN_ANALYSIS.md`
- `scenes/GameScene.tscn`
- `scripts/GameplayManager.gd`
- `scripts/LevelData.gd`
- `scripts/PhaseSelectScreen.gd`
- `scripts/GameState.gd`

Checklist da etapa:

| Item | Status | Observacao |
| --- | --- | --- |
| Gaps reduzidos | Sim | `LevelData.gd` e `GameplayManager.gd` usam aberturas menores, mantendo clamp por fase/dificuldade. |
| Arena abaixo do HUD | Sim | Area logica invisivel reposicionada com margem superior; sem borda/base/debug visual. |
| XP ajustado | Sim | Hit simples, critico, break, perfect e bonus de conclusao geram XP maior. |
| Card da Fase 1 sem HP | Sim | HP removido dos cards de fase. |
| Card da Fase 1 sem descricao longa | Sim | Cards mostram somente nome, dificuldade e aneis. |
| Cards mostram fase/dificuldade/aneis | Sim | Aplicado para as fases visuais 1-50. |
| Fases jogaveis | Sim | `PhaseSelect` abre qualquer fase desbloqueada e `GameScene` usa `selected_phase`. |
| Bolinha com sprite real | Sim | Usa `equipped_skin` do `GameState`; fallback `neon_blue.png`. |
| Aneis visuais | Sim | Aneis neon desenhados por `_draw`, com gaps e anel solido final seguindo a base de `rings.ts`. |
| HP visual removido | Sim | HUD e aneis nao exibem HP; o HP segue interno para colisao/quebra. |
| Visual tecnico removido | Sim | Circulo/base extra de arena e circulo central foram removidos. |
| Colisao funcionando | Sim | Porta a checagem de gap/parte solida, reflexao e separacao da bolinha. |
| HUD de partida | Sim | HUD limpo com pausa, fase, dificuldade, recursos com icones, nivel, XP, barra de XP e upgrade temporario ativo. |
| ResourceBadge | Sim | Badges com assets reais para moedas, diamantes, conta e chaves foram adicionados ao HUD. |
| Upgrades de rodada | Sim | Barra inferior com ATK e GOLD, custos e compra com moedas da run como na `main`. |
| Upgrade temporario no HUD | Sim | Level-up abre modal neon com ate 3 upgrades desbloqueados reais; HUD mostra upgrade ativo com asset. |
| Upgrades temporarios respeitam desbloqueio | Sim | Opcoes de level-up so aparecem se o id estiver em `GameState.unlocked_upgrades`. |
| Upgrades permanentes funcionais | Sim | Tela compra com moedas reais, custo `baseCost * 1.5^nivel`, limites da main e salvamento. |
| Desbloqueio de upgrades | Sim | Marcos por fase/perfil em `GameState.refresh_unlocks`; baus/eventos/missoes ficam como estrutura futura. |
| Skins funcionais | Sim | Tela usa save real, impede equipar bloqueada, salva `equipped_skin` e gameplay usa o sprite equipado. |
| Ritmo adaptativo dos aneis | Sim | `ring_spawn_delay`, streak de clears rapidos e bonus por muitos aneis ajustam o fechamento com clamp. |
| Fundos e paletas variaveis | Sim | Fases escolhem gradientes escuros e paletas neon diferentes sem clarear o HUD. |
| Audio global persistente | Sim | `AudioManager.gd` controla contexto menu/gameplay, loop, mute e evita reiniciar a mesma musica. |
| Efeitos visuais | Sim | Brilho/trilha da bolinha, impacto, quebra de anel, textos de moeda/XP/level-up e efeito de vitoria. |
| Audio de gameplay | Sim | `AudioManager.gd` centraliza musica, clique, hit, hit critico, quebra, perfect, XP, level-up, diamante, derrota e vitoria respeitando audio mudo. |
| Vitoria funcionando | Sim | Ao limpar todos os aneis, mostra tela de vitoria/recompensa. |
| Tela de vitoria polida | Sim | Modal neon limpo, sem scroll apertado, com recompensas em linhas com icones/assets e botoes grandes. |
| Recompensas salvando | Sim | Moedas gerais e XP de perfil usam conversao baseada em `economy.ts`; diamantes, aneis e perfects entram no `GameState`. |
| Combo/DPS/score | Sim | Combo de 2600ms, melhor combo, DPS recente e score foram portados para a Fase 1. |
| Fase 2 liberada ao vencer | Sim | `record_phase_complete` chama `unlock_level(2)`. |
| 50 fases jogaveis | Sim | Desbloqueio sequencial ate a Fase 50 usando os dados de `LevelData.gd`. |
| Pausa funcionando | Sim | Menu com Continuar, Reiniciar e Sair para fases. |
| Analise da main | Sim | Ver `godot/GAMEPLAY_MAIN_ANALYSIS.md`. |

Pendencias da gameplay:

- Comparacao visual pixel a pixel com a `main` ainda pendente.
- Efeitos basicos de skins foram implementados por familias: gelo, fogo, eletrico/cadeia, sombra/fase, repulsao, moeda, XP, velocidade, critico e area. Alguns efeitos ultra-especificos da `main` ainda usam aproximacao funcional simples.
- Upgrades temporarios agora aplicam efeitos reais quando desbloqueados: `burn`, `frost`, `ringRepulse` e `chainLightning`.
- Recompensas de bau/chave por chance de fase estao documentadas em `LevelData.gd`, mas ainda nao sao concedidas.
- Modo infinito esta jogavel a partir do card `Modo Infinito` quando a Fase 5 estiver liberada. Ele gera aneis continuamente, escala dificuldade, salva recordes e mostra resultado ao perder.
- Fases 2-50 usam a estrutura da main e desbloqueio sequencial, mas ainda precisam de verificacao visual fase a fase.

## 7.2 Efeitos, fisica e infinito

Arquivos principais:

- `scripts/GameplayManager.gd`
- `scripts/GameState.gd`
- `scripts/PhaseSelectScreen.gd`

Skins/effects implementados:

- `freeze`: reduz temporariamente rotacao/fechamento do anel, aplica cor azul e particulas frias.
- `burn`: aplica dano extra e feedback laranja/vermelho.
- `chain`: aplica dano em um anel vizinho com cor ciano.
- `area`: aplica dano em aneis proximos.
- `phase`: chance de atravessar impacto sem dano.
- `repulse`: empurra o raio do anel para fora dentro da arena segura.
- `coin`, `xp`, `speed`, `crit`: alteram ganhos, velocidade ou dano real da rodada.
- Skins sem efeito especifico recebem brilho/trilha propria por familia visual.

Upgrades de gameplay implementados:

- Permanentes: dano, velocidade, moedas, XP, critico, perfect chance e slow rings.
- Temporarios: dano, velocidade, moedas, critico, XP, perfect chance, burn, frost, ring repulse e chain lightning.
- Temporarios aparecem apenas quando desbloqueados no `GameState.unlocked_upgrades`.
- Os 92 sprites de skins importados da branch `main` estao em `godot/assets/skins`.
- `SkinsScreen.gd` varre essa pasta e cria metadados/efeitos por familia visual para qualquer skin que ainda nao tenha uma entrada manual, evitando skins importadas sem comportamento basico.

Fisica/aneis:

- A bolinha usa substeps quando viaja rapido no frame, reduzindo tunneling em Web/HTML.
- A colisao avalia o segmento entre posicao anterior e nova posicao, nao apenas overlap no ponto final.
- A velocidade e clampada e a direcao e estabilizada para evitar trajetorias quase horizontais por muito tempo.
- Reflexoes recebem pequena variacao angular controlada para a bolinha parecer mais ativa sem ficar aleatoria.
- A arena de spawn/enquadramento e invisivel, respeita HUD e limita raios minimo/maximo.
- `MIN_RING_SPACING`, `MAX_VISIBLE_RINGS` e `_clamp_ring_spacing()` impedem sobreposicao confusa entre aneis.

Audio/SFX:

- `ring_hit` toca apenas quando a bolinha bate na parte fechada e o anel continua ativo.
- `ring_crit` toca apenas em impacto critico.
- `ring_break` toca quando o anel e quebrado por dano.
- `ring_clear` toca quando a bolinha passa pelo gap/perfect e o anel e limpo.
- `reward_coin`, `xp`, `diamond`, `click`, `victory` e `defeat` ficam separados por evento.
- A musica de gameplay continua sob `AudioManager.play_context("gameplay")`, respeitando mute e loop.

Modo infinito:

- Abre pelo card `Modo Infinito` na tela Jogar/Selecao de Fases.
- Requer Fase 5 liberada, seguindo a regra visual ja existente.
- Gera aneis continuamente enquanto o jogador estiver vivo.
- A dificuldade escala por tempo sobrevivido e aneis quebrados.
- Escala HP, velocidade de fechamento, rotacao, tamanho do gap, densidade e padroes solidos.
- Quando o jogador limpa aneis rapido demais, `infinite_clear_pressure` aumenta e acelera fechamento/rotacao, reduz gaps e eleva densidade dentro de limites seguros; a pressao decai com o tempo.
- Salva `infiniteRuns`, `bestInfiniteSeconds`, `bestInfiniteRings`, `bestInfiniteScore`, `bestCombo` e recursos ganhos.
- Tela de resultado mostra tempo, aneis quebrados, moedas, XP, diamantes e novo recorde.

Conquistas/missoes/desbloqueios:

- Fases concluidas, aneis quebrados, perfects, moedas, compras de upgrade, skins equipadas, diaria, roleta e modo infinito atualizam estatisticas reais.
- Conquistas novas: `infinite_first`, `infinite_survivor`, `infinite_breaker`, `combo_starter`, `skin_equipped`, `upgrade_stack`.
- Marcos adicionais da branch `main` foram portados para anel, perfect, diamantes, infinito por tempo/aneis/nivel de run, combo, criticos, efeitos de skin, colecao por raridade e abertura de baus.
- `GameState.gd` expoe hooks publicos para fases, modo infinito, moedas, skins, upgrades, diaria, roleta, baus e missoes, mantendo conquistas/missoes/desbloqueios conectaveis aos sistemas reais.
- Recompensas de conquistas continuam coletaveis pela tela de conquistas existente.
- Hooks de baus, roleta, loja, diaria e missoes ja chamam `GameState` e alimentam progresso.

## 7.3 Port completo de dados da main

Arquivos principais adicionados nesta etapa:

- `scripts/MainPortData.gd`: tabela central gerada a partir da `main`, com skins, upgrades temporarios, ranks/recompensas da Liga Neon e geracao de oponente.
- `scripts/LocalizationManager.gd`: base EN/PT compartilhada, ligada ao idioma salvo em Configuracoes.
- `scripts/LeagueScreen.gd`: Liga Neon visual baseada em `frontend/app/league.tsx`, com resumo, divisao, podium e ranking local mockado.
- `MAIN_PORT_ANALYSIS.md`: inventario da migracao fiel por sistema e pendencias.

Fontes da branch `main` usadas como verdade nesta etapa:

- `frontend/src/game/skins.ts`
- `frontend/src/game/upgrades.ts`
- `frontend/src/game/dualArena.ts`
- `frontend/src/game/rings.ts`
- `frontend/src/game/achievements.ts`
- `frontend/src/i18n/gameText.ts`

Regras de anel atualizadas:

- Partidas normais e modo infinito mantem alvo de 12 aneis ativos visiveis, com fila interna para fases finitas.
- Modo infinito mantem esse alvo com reposicao imediata e distancia minima entre raios.
- A area de spawn/enquadramento continua invisivel e respeita HUD, raio minimo/maximo e distancia segura da bolinha.

Liga Neon:

- Voltou a ser uma tela de ranking/progresso baseada em `frontend/app/league.tsx`.
- Mostra resumo do jogador, trofeus, dias de temporada, progresso de divisao, podium, recompensa estimada e lista de rivais ficticios.
- A sala atual usa 30 competidores por divisao: jogador + 29 bots com nomes e skins.
- Jogador novo com 0 trofeus aparece em `#30/30` na divisao Bronze.
- As divisoes atuais sao Bronze, Prata, Ouro, Diamante, Lendario e Ultimate.
- Vitorias futuras usam base de +36 trofeus; derrotas futuras usam base de -18 trofeus.
- A temporada usa o mes real/local via `TimeManager.get_month_key()`.
- Ao virar o mes, a Liga salva um resumo da temporada anterior, zera vitorias/derrotas da temporada e rebaixa uma divisao: Ouro volta para Prata, Prata volta para Bronze, e assim por diante.
- A primeira promocao saindo do Bronze libera a skin ultimate `initial_neon_champion` / Campeao Neon Inicial.
- A batalha versus feita no port anterior foi removida para a competicao ser recriada depois com fidelidade ao frontend/main.

Checklist desta etapa:

| Item | Status |
| --- | --- |
| Efeitos basicos de skins implementados | Sim |
| Todas as skins disponiveis equipaveis | Sim |
| 92 sprites de skins da main importados | Sim |
| Skins importadas recebem efeito basico automaticamente | Sim |
| Skins bloqueadas respeitam desbloqueio | Sim |
| Skin equipada aparece na gameplay | Sim |
| Efeitos de upgrades implementados | Sim |
| Efeito de gelo reduz velocidade do anel | Sim |
| Efeito de gelo aplica visual azul/congelado | Sim |
| Aneis podem ficar mais proximos | Sim |
| Aneis nunca sobrepoem/fecham um sobre o outro | Sim |
| Area invisivel de spawn/enquadramento funcionando | Sim |
| Bolinha rapida nao depende apenas de overlap final | Sim |
| Fisica polida com substeps/segmento/clamp | Sim |
| Bolinha muda mais de direcao sem quebrar fisica | Sim |
| Bolinha evita trajetorias retas/repetitivas demais | Sim |
| SFX de bater no anel corrigido | Sim |
| SFX de limpar/quebrar anel corrigido | Sim |
| SFX nao estao mais invertidos | Sim |
| SFX sincronizados com eventos | Sim |
| Modo infinito funcional | Sim |
| Modo infinito escala dificuldade | Sim |
| Modo infinito reage a limpeza rapida de aneis | Sim |
| Modo infinito salva recorde | Sim |
| Conquistas vinculadas as fases | Sim |
| Conquistas vinculadas ao modo infinito | Sim |
| Conquistas vinculadas a jogatina real | Sim |
| Hooks de eventos internos criados em GameState | Sim |
| Conquistas desbloqueiam upgrades/skins quando aplicavel | Parcial: recompensas coletaveis, unlocks diretos ja funcionam para skins por recompensa. |
| Missoes recebem progresso da jogatina real | Sim |
| Save atualizado corretamente | Sim |

## 7.1 Idioma e audio

- Idioma padrao de novo save: English (`settings.language = "en"`).
- Portugues disponivel em Configuracoes (`pt`) e salvo localmente.
- A camada de localizacao ja cobre Configuracoes, titulos principais das telas funcionais, missoes e conquistas; alguns textos visuais herdados das telas antigas ainda precisam de refinamento final para ficar 100% traduzidos.
- `AudioManager.gd` e o unico player persistente de musica. Menu, loja, upgrades, skins, inventario, missoes, roleta, diaria, perfil e configuracoes usam contexto `menu`; partida usa contexto `gameplay`.
- A mesma musica nao reinicia ao navegar entre telas do mesmo contexto. Mute para a musica/SFX e retoma o contexto atual ao desmutar.

## 8. HTML/Web

O preset `Web` foi configurado em `export_presets.cfg`.

Com Godot 4.3 e templates de exportacao instalados:

```bash
cd godot
mkdir -p build/web
godot --headless --export-release Web build/web/index.html
```

Para testar, nao abra `index.html` direto pelo navegador usando `file://`.
O export Web do Godot precisa ser servido por HTTP:

```bash
cd godot
python3 serve_web.py
```

URL local:

```text
http://127.0.0.1:8765/index.html
```

Em ambiente remoto/Codespaces, abra a porta `8765` pela aba/encaminhamento de portas e use a URL encaminhada.

O workflow `.github/workflows/godot-web.yml` da branch `godot-4-rebuild` tambem usa o preset `Web` e publica `godot/build/web`.

Verificacao local feita em 2026-06-02:

```bash
Godot_v4.3-stable_linux.x86_64 --headless --editor --path godot --quit
Godot_v4.3-stable_linux.x86_64 --headless --path godot --export-release Web build/web/index.html
python3 serve_web.py
```

Arquivos HTML/Web gerados localmente em `godot/build/web`:

- `index.html`
- `index.js`
- `index.wasm`
- `index.pck`
- icones e worklet de audio do export web

`godot/build/` e `godot/.godot/` ficam ignorados pelo Git.

## 7.4 Polimento de localizacao, recompensas e aneis

Atualizado nesta etapa:

- `LocalizationManager.gd` recebeu termos compartilhados para Back/Voltar, Close/Fechar, loja, inventario, missoes, roleta, conquistas, botoes de compra/coleta/abrir/anuncio e estados vazios.
- `NeonBackButton.gd` agora usa a traducao ativa em vez de texto fixo `Back`.
- `MainMenu.gd` traduz o modal `More/Menu`, itens internos e adiciona uma barra discreta de conquista pendente quando existe recompensa de conquista para coletar. Clicar nela abre `Achievements.tscn`.
- `VisualFeatureScreen.gd` recebeu loja com custo visual por icone de recurso, botoes diferenciados entre comprar, abrir, coletar, ver anuncio e usado, estados vazios traduzidos e modal de recompensa obtida.
- A roleta visual agora mostra premios ao redor, anima giro antes de entregar a recompensa e abre modal de resultado.
- Inventario, missoes e conquistas mostram recompensa/progresso de forma mais clara e usam o modal de recompensa ao coletar/abrir.
- `GameplayManager.gd` calcula o angulo de colisao no ponto real em que o segmento da bolinha cruza o raio do anel. Isso reduz falhas ao passar pelo gap em alta velocidade.
- Spawn de aneis foi ajustado para manter raios em distancia minima/maxima atingivel pela bolinha, inclusive quando ela esta perto da borda.
- `LeagueScreen.gd` substituiu a batalha custom da Liga por tela visual baseada no frontend.

Checklist desta etapa:

| Item | Status |
| --- | --- |
| Back traduzido para Voltar | Sim |
| Todas as abas da loja traduzidas | Sim |
| Loja mostra custo com icone correto | Sim |
| Loja diferencia Comprar/Abrir/Gratis/Ver anuncio | Sim |
| Roleta tem varios premios visiveis | Sim |
| Roleta gira com animacao real | Sim |
| Roleta mostra resultado bonito | Sim |
| Inventario traduzido | Sim |
| Inventario mostra recompensas obtidas claramente | Sim |
| Bau mostra modal bonito com itens ganhos | Sim |
| Missoes traduzidas e polidas | Sim |
| Missoes mostram recompensa claramente | Sim |
| Conquistas traduzidas e polidas | Sim |
| Conquista aparece como barra/notificacao na tela inicial | Sim |
| Clicar na barra leva para Conquistas | Sim |
| Gap dos aneis detecta passagem corretamente | Sim |
| Bolinha nao bate mais no vacuo por spawn fora de alcance | Sim, mitigado com spawn atingivel e colisao por segmento |
| Aneis do infinito sempre nascem acertaveis | Sim, mitigado por raio minimo/maximo em relacao a bolinha |
| Modo infinito mostra tempo de sobrevivencia | Sim |
| Modo infinito recompensa ao morrer/sair | Sim |
| Spawn justo implementado no normal | Sim |
| Spawn justo implementado no infinito | Sim |
| Liga Neon refeita como tela visual | Sim |
| Recompensas sempre tem feedback visual claro | Sim para loja, bau, roleta, diaria, missoes e conquistas; resultados de fase/Liga ja tinham modal/resumo proprio. |

Pendencias conhecidas:

- Ainda falta comparacao visual pixel a pixel contra os prints/main para cada card interno.
- Alguns textos de dados importados da `main` continuam com nomes originais de skin/upgrade em ingles porque sao nomes proprios do conteudo.
- A roleta entrega recompensa real e anima, mas ainda nao replica uma geometria circular perfeita com fatias desenhadas; usa segmentos visuais leves para Web.

## 7.5 Roleta com skins, anúncios mockados e ajustes de Liga/upgrades

Atualizado nesta etapa:

- A tela `Upgrades/Melhorias` agora esconde a seção `Temporários de rodada`; esses upgrades continuam existindo apenas internamente para level-up durante a partida e Liga.
- Roleta passa a usar recompensas dinâmicas com skins: uma comum semanal, uma rara semanal e uma lendária mensal, calculadas por `TimeManager.get_week_key()` e `TimeManager.get_month_key()`.
- Skin repetida agora vira diamantes automaticamente em `GameState.apply_reward`, com compensação por raridade.
- Ganhar skin acima de comum, diamantes ou conversão por skin repetida toca SFX/efeito visual de diamante no modal de recompensa.
- Inventário/baús podem sortear skins, além de moedas, diamantes e chaves.
- `GameState.show_mock_rewarded_ad(callback)` foi criado como anúncio recompensado fictício para fluxos de teste.
- Seleção de upgrades temporários ganhou reroll por anúncio mockado ou 10 diamantes, limitado a 3 rerolls por level-up.
- Game over ganhou revive por anúncio mockado, limitado a uma vez por partida.
- Notificação de conquista no menu inicial ficou menor, discreta, com resumo de pendências, clique para Conquistas e auto-ocultamento após alguns segundos.
- Liga Neon foi refeita como tela de ranking/progresso baseada no frontend; a batalha versus anterior foi removida.

Checklist desta etapa:

| Item | Status |
| --- | --- |
| Temporários de rodada ocultos da tela de upgrades | Sim |
| Liga Neon não está mais vazia | Sim, tela visual refeita |
| Liga Neon funciona como versus | Pendente, removido para refazer fielmente |
| Duas arenas da Liga Neon funcionando | Pendente |
| Oponente automático funcionando | Pendente |
| Notificação de conquista menor/discreta | Sim |
| Notificação de conquista some corretamente | Sim |
| Clicar na notificação abre Conquistas | Sim |
| Roleta visual melhorada | Sim |
| Roleta tem vários prêmios | Sim |
| Roleta tem 3 skins como prêmio | Sim |
| Skin comum/rara da roleta troca semanalmente | Sim |
| Skin lendária da roleta troca mensalmente | Sim |
| Skin repetida vira diamantes | Sim |
| Skin acima de comum toca efeito de diamante | Sim |
| Skin repetida convertida em diamantes toca efeito de diamante | Sim |
| Inventário mostra recompensa de baú claramente | Sim |
| Missões visualmente melhores | Sim |
| Conquistas visualmente melhores | Sim |
| Anéis do infinito sempre são acertáveis | Sim, mitigado por spawn justo e gap por segmento |
| Bolinha não bate mais em vácuo | Sim, mitigado |
| Fases normais iniciam com distância segura | Sim |
| Anéis não reaparecem grudados | Sim |
| Gap detecta passagem corretamente | Sim |
| Anúncio fictício de revive implementado | Sim |
| Anúncio fictício de dobrar ganhos implementado | Parcial; estrutura mock criada, dobra de resultado ainda pendente |
| Reroll de upgrades temporários por anúncio/diamante implementado | Sim |
| Limite de 3 rerolls funcionando | Sim |
| Recompensa por sair/quitar funcionando em todos os modos | Parcial; infinito/Liga têm recompensa proporcional, fase normal usa resultado atual |
| Modal de recompensa bonito implementado | Sim |
| Tradução completa revisada | Parcial; textos principais cobertos, nomes proprios/importados podem seguir em inglês |

Pendências:

- Implementar botão de dobrar recompensas no resultado de fase/infinito/Liga sem duplicar save.
- Revisar visual da Liga Neon contra prints/main depois de testar no navegador.
- Expandir tradução de nomes próprios de upgrades/skins somente se a branch main também traduzir esses nomes.

## 7.6 Ajustes de visuais bloqueados, reroll, roleta e spawn seguro

Atualizado nesta etapa:

- A notificacao de conquistas do menu inicial ficou mais curta, clicavel e sem overflow; mostra somente o resumo de recompensas pendentes e abre a tela de Conquistas.
- A tela `Melhorias` agora mostra somente upgrades desbloqueados na lista principal e exibe contador de melhorias disponiveis/bloqueadas sem remover os dados internos.
- A tela `Skins` abre por padrao apenas com skins obtidas/desbloqueadas, mostra contador de obtidas/bloqueadas e preserva o filtro de bloqueadas para consulta visual.
- O reroll de upgrades de level-up evita repetir imediatamente as mesmas opcoes quando houver pool suficiente, continua limitado a 3 e valida anuncio mockado/diamantes.
- A roleta ficou mais lenta e satisfatoria visualmente, com giro de 2.2s antes de aplicar a recompensa real.
- O spawn de aneis agora considera posicao, velocidade e direcao prevista da bolinha para alinhar melhor o gap e evitar aneis inalcancaveis.
- Sair de fase ou infinito com progresso concede recompensa proporcional, salva estatisticas, alimenta missoes/conquistas e mostra resumo de moedas/XP/diamantes.
- O modo infinito atualiza tambem melhores aneis, pontuacao, tempo e nivel ao registrar saida proporcional.

Checklist desta etapa:

| Item | Status |
| --- | --- |
| Notificacao de conquistas clicavel e discreta | Sim |
| Notificacao sem texto vazando | Sim |
| Upgrades bloqueados escondidos da lista principal | Sim |
| Contador de upgrades disponiveis/bloqueados | Sim |
| Skins bloqueadas escondidas por padrao | Sim |
| Contador de skins obtidas/bloqueadas | Sim |
| Reroll limitado a 3 | Sim |
| Reroll por anuncio mockado | Sim |
| Reroll por diamantes com validacao de saldo | Sim |
| Reroll evita repeticao imediata quando possivel | Sim |
| Roleta mais lenta | Sim |
| Spawn de aneis considera trajetoria da bolinha | Sim |
| Gap inicial/respawn alinhado de forma mais justa | Sim |
| Recompensa proporcional ao sair | Sim |
| Save/estatisticas/conquistas atualizados ao sair | Sim |

Pendencias:

- A roleta ainda sorteia a recompensa no final do giro e nao trava matematicamente o ponteiro em uma fatia exata do premio; visualmente o giro foi melhorado para Web.
- O botao de dobrar recompensas por anuncio ainda esta pendente para a tela de resultado sem duplicar o save.

## 7.7 Efeito Controle para skins

Atualizado nesta etapa:

- Criado o efeito `Controle`, uma assistencia de direcao por skin que mostra duas setas neon na gameplay apenas quando a skin equipada possui esse efeito.
- As setas ficam no rodape superior aos upgrades temporarios da rodada, nao cobrem HUD/arena e somem ao pausar, perder, vencer ou abrir modal de level-up.
- Pressionar esquerda/direita influencia gradualmente a direcao da bolinha sem teleportar e continua passando pelo clamp de velocidade, substeps e colisao por segmento.
- A forca escala por raridade: common 13%, rare 24%, epic 34%, legendary 48%, mythic 62%, ultimate 80%.
- Todas as skins `ultimate` recebem Controle junto com o efeito especial que ja tinham.
- Skins simples que receberam Controle como efeito principal: `robot`, `alien_rare`, `ninja_rare`, `satellite_rare`, `blue_vortex`, `neon_spiral`, `ripple_eye`, `celestial_core`, `chrono_loop_mythic`.
- O Controle funciona em fases normais, modo infinito e Liga Neon. Na Liga, o jogador ve as setas; o rival recebe apenas uma assistencia automatica discreta se a skin dele tiver Controle.

Checklist:

| Item | Status |
| --- | --- |
| Efeito Controle criado | Sim |
| Setas esquerda/direita aparecem apenas com skin de Controle | Sim |
| Setas nao aparecem em skins sem Controle | Sim |
| Controle influencia direcao real da bolinha | Sim |
| Controle nao quebra colisao | Sim, passa pela fisica/substeps existentes |
| Controle nao permite atravessar aneis | Sim, nao ignora validacao de colisao |
| Forca escala por raridade | Sim |
| Todas as skins Ultimate tem Controle | Sim |
| Ultimates mantem outros efeitos junto com Controle | Sim |
| Algumas skins simples tiveram efeito trocado por Controle | Sim |
| Controle funciona em fases normais | Sim |
| Controle funciona no modo infinito | Sim |
| Controle funciona na Liga Neon | Sim |
| Setas somem/pausam em menus e modais quando necessario | Sim |

## 7.8 Correcoes de resultado, roleta e spawn ativo

Atualizado nesta etapa:

- O alvo minimo de aneis ativos passou para 12 na gameplay normal/infinita, respeitando o total disponivel da fase e o limite de seguranca.
- A roleta agora sorteia a recompensa real antes do giro e anima ate a fatia correspondente ao premio sorteado, com easing de aceleracao/desaceleracao e modal depois do giro.
- Resultados de vitoria, derrota/infinito e saida manual agora podem exibir `DOBRAR RECOMPENSA - AD` usando anuncio mockado, apenas uma vez por resultado.
- Dobrar recompensa adiciona somente o extra equivalente de moedas/XP/diamantes ao save, evitando duplicar a recompensa base.
- Saida manual continua mostrando recompensa proporcional, mas esconde `REVIVER COM ANUNCIO`.
- O botao de revive permanece disponivel apenas para derrota real, limitado pelo controle ja existente de uma vez por partida.

Checklist:

| Item | Status |
| --- | --- |
| Mínimo de 12 anéis ativos quando possível | Sim |
| Roleta para visualmente no prêmio sorteado | Sim |
| Roleta entrega recompensa real | Sim |
| Dobrar recompensa com anúncio mockado em resultados | Sim |
| Dobrar recompensa apenas uma vez | Sim |
| Dobro não duplica recompensa base no save | Sim |
| Recompensa ao sair de fase normal | Sim |
| Recompensa ao sair do modo infinito | Sim |
| Reviver com anúncio não aparece ao sair manualmente | Sim |
| Liga Neon usa alvo de aneis ativos | Sim, 6 aneis fixos por arena apenas na Liga |

## 7.9 Correções focadas de spawn, skins e upgrades

Atualizado nesta etapa:

- `GameplayManager.gd` agora usa uma validação real de spawn com `is_ring_reachable_by_ball`, `can_spawn_ring_safely`, `get_safe_ring_spawn_radius` e `clamp_ring_to_playable_area`.
- Fases normais e modo infinito só ativam/spawnam anéis quando existe raio seguro; se não houver posição válida, o anel fica em fila ou o spawn infinito aguarda outro tick.
- A área útil dos anéis foi reduzida para a parte central jogável, respeitando HUD/arena, distância da bolinha, velocidade, posição anterior, espaçamento mínimo e limite máximo de alcance.
- `LeagueBattleScreen.gd` passou a usar validação parecida para a Liga Neon, sem forçar anel fora de alcance quando não encontra candidato seguro.
- A tela `Skins` removeu filtros duplicados; agora mantém apenas Obtidas, Comuns, Raras, Épicas, Lendárias, Míticas, Ultimate e Bloqueadas.
- Todas as skins bloqueadas aparecem mascaradas com `???`, ícone `?`, status bloqueado e sem asset/efeito/nome real.
- A tela `Melhorias` foi religada aos dados permanentes de `GameState.PERMANENT_UPGRADE_DEFS` e aos temporários internos de `MainPortData.RUN_UPGRADES`.
- Upgrades temporários continuam existindo internamente para level-up, mas a tela permanente mostra só melhorias permanentes desbloqueadas e contadores.

Checklist:

| Item | Status |
| --- | --- |
| Anéis nascem mais ao centro da arena útil | Sim |
| Anéis nascem dentro do alcance de colisão da bolinha | Sim |
| Anéis não nascem fora da área acertável | Sim |
| Anéis não fazem a bolinha bater no vazio | Sim |
| Spawn seguro aplicado no modo infinito | Sim |
| Spawn seguro aplicado nas fases normais | Sim |
| Spawn seguro preparado para Liga Neon | Sim |
| Validação de alcance criada/corrigida | Sim |
| Filtros duplicados removidos da tela Skins | Sim |
| Skins bloqueadas aparecem com interrogação | Sim |
| Skins bloqueadas não mostram asset real | Sim |
| Skins bloqueadas não mostram efeito real | Sim |
| Todas as melhorias/upgrades restauradas | Sim |
| Upgrades permanentes existem internamente | Sim |
| Upgrades temporários existem internamente | Sim |
| Upgrades bloqueados não foram excluídos | Sim |
| Tela de Upgrades mostra apenas disponíveis e contador de bloqueados | Sim |
| Level up mostra apenas upgrades temporários liberados | Sim |

Pendência conhecida:

- A validação é local/offline e foi testada por abertura headless do Godot; a revisão visual fina ainda depende do teste manual no navegador.

## 7.10 Correções de gameplay após teste Web

Atualizado nesta etapa:

- Corrigido travamento do modo infinito quando o gerador não encontrava anel seguro: o loop agora para no frame e tenta novamente depois, sem congelar o HTML.
- O modo infinito também tenta ativar anéis em fila antes de criar novos anéis.
- A detecção de abertura do anel usa a mesma referência de contato para clear e hit, com margem menor para não encolher visualmente o gap.
- Quando a bolinha já está na faixa do anel e no centro da abertura, o clear pode disparar mesmo sem cruzamento radial perfeito no frame.
- A seleção de upgrades temporários ficou mais rígida: valida desbloqueio, requisito de nível/fase, segredo, dados de efeito e limite máximo.
- `Ring Repulse` agora tem chance real por nível, cooldown por rodada e não empurra o anel para fora da área útil jogável.

Checklist:

| Item | Status |
| --- | --- |
| Modo infinito não trava quando falta spawn seguro | Sim |
| Gap/clear usa contato consistente com hit | Sim |
| Passagem pela abertura ficou menos rígida | Sim |
| Upgrades temporários bloqueados filtrados | Sim |
| Seleção manual de upgrade bloqueado recusada | Sim |
| Ring Repulse com chance | Sim |
| Ring Repulse com cooldown | Sim |
| Ring Repulse limitado à área útil | Sim |

## 7.11 Temporárias liberadas e alcance do infinito

Atualizado nesta etapa:

- As temporárias auto-liberadas/base são 6: `damage`, `speed`, `coinBoost`, `critical`, `xpBoost` e `perfectChance`.
- `MainPortData.gd` mantém todos os upgrades temporários internos não secretos disponíveis para liberação futura, sem mostrar bloqueados antes da hora.
- `GameState.refresh_unlocks` limpa desbloqueios temporários antigos indevidos, preservando upgrades permanentes, os 6 base válidos e temporários explicitamente liberados.
- A tela `Melhorias` mostra quantas temporárias estão realmente liberadas e lista seus nomes.
- O level-up consulta apenas upgrades desbloqueados de verdade, mas aceita temporários extras quando forem liberados por recompensa/sistema.
- No modo infinito, a distância máxima de spawn dos anéis foi reduzida e os anéis ativos são mantidos dentro de uma faixa radial curta ao redor da bolinha.
- A quantidade alvo de anéis do infinito agora respeita a capacidade real da área útil, para não forçar anéis fora do alcance quando não cabem com espaçamento seguro.

Checklist:

| Item | Status |
| --- | --- |
| Temporárias auto-liberadas limitadas a 6 base | Sim |
| Tela mostra somente temporárias liberadas reais | Sim |
| Level-up usa temporárias desbloqueadas reais | Sim |
| Upgrades internos continuam existindo nos dados | Sim |
| Infinito reduz spawn distante demais | Sim |
| Anéis ativos do infinito ficam na faixa de colisão da bolinha | Sim |
| Quantidade de anéis respeita capacidade da área útil | Sim |

## 7.12 Ajustes de conquistas, upgrades e infinito

Atualizado nesta etapa:

- O aviso de conquistas pendentes na tela inicial agora abre `res://scenes/Achievements.tscn` ao clicar/tocar.
- A regra dos upgrades temporários foi refinada: os 6 upgrades-base continuam sendo os únicos auto-liberados, mas o banco de upgrades temporários não fica preso a 6 para sempre.
- Upgrades temporários extras agora podem aparecer quando forem explicitamente desbloqueados por recompensa, conquista, baú, roleta ou sistemas futuros.
- Saves antigos que tinham upgrades temporários internos liberados por engano são limpos, preservando permanentes, temporários-base válidos e temporários explicitamente liberados.
- O sorteio de level-up pode repetir opções quando o conjunto disponível é pequeno, mantendo sempre os cards visíveis sem depender de rolagem.
- O modal de level-up ficou mais alto e os cards mais compactos para evitar tela aparentemente vazia.
- No modo infinito, os gaps dos anéis novos são aleatórios e não são mais realinhados em sequência com a trajetória da bolinha.
- A bolinha é revalidada contra a borda da arena após colisões, reduzindo o risco de escapar para fora da área jogável.

Checklist:

| Item | Status |
| --- | --- |
| Aviso de conquistas abre a tela de conquistas | Sim |
| Apenas 6 temporários são auto-liberados | Sim |
| Temporários extras aparecem quando explicitamente liberados | Sim |
| Saves antigos com temporários internos indevidos são limpos | Sim |
| Level-up mostra opções sem precisar rolar | Sim |
| Level-up permite repetição aleatória de upgrades | Sim |
| Gaps do modo infinito são aleatórios | Sim |
| Bolinha não deve escapar da arena | Sim |

## 7.13 Correções de recompensas, upgrades e morte injusta

Atualizado nesta etapa:

- O aviso de recompensas/conquistas pendentes saiu do `VBox` apertado do topo e virou um overlay clicável fixo na tela inicial.
- O aviso não some automaticamente depois de alguns segundos; tocar/clicar nele abre `Achievements.tscn`.
- A tela `Upgrades` repara saves antigos antes de renderizar e mostra cards permanentes disponíveis/desbloqueados no topo da lista.
- Upgrades permanentes bloqueados continuam escondidos como cards, mas entram no contador de bloqueados/disponíveis para desbloqueio futuro.
- Os 6 upgrades temporários-base ficam realmente liberados para sorteio de level-up: `damage`, `speed`, `coinBoost`, `critical`, `xpBoost` e `perfectChance`.
- O modo infinito recebeu área útil maior, menos anéis simultâneos no começo e gaps aleatórios também na leva inicial.
- Anéis novos ou reposicionados têm uma janela curta de segurança antes de poder causar derrota.
- A derrota por esmagamento precisa persistir por alguns frames/milissegundos, evitando game over instantâneo por spawn/rearranjo.
- O espaçamento dos anéis agora é corrigido por ordem real de raio, não pela ordem interna da lista.

Checklist:

| Item | Status |
| --- | --- |
| Aviso de recompensas abre Conquistas | Sim |
| Aviso de recompensas não some sozinho | Sim |
| Upgrades permanentes disponíveis aparecem no topo | Sim |
| Upgrades permanentes bloqueados ficam sem card | Sim |
| Seis temporários-base entram no sorteio de level-up | Sim |
| Infinito com área útil maior | Sim |
| Infinito começa sem anel sólido obrigatório | Sim |
| Gaps iniciais do infinito aleatórios | Sim |
| Anéis novos não matam imediatamente | Sim |
| Clamp de anéis por raio real | Sim |

## 7.14 Progressão longa, 12 anéis e 100 conquistas

Atualizado nesta etapa:

- A progressão de fases foi expandida de 50 para 100 fases em `LevelData.gd`, `PhaseSelectScreen.gd`, `GameState.gd` e `GameplayManager.gd`.
- O alvo de anéis ativos foi fixado em 12 para fases e modo infinito, mantendo reposição imediata quando um anel quebra ou é limpo pelo gap.
- A curva de dificuldade das fases foi rebalanceada para 100 fases, com tiers Normal, Difícil, Avançado, Extremo, Insano, Ultimate, Mítico e Ômega.
- Upgrades permanentes receberam limites maiores e custos iniciais ajustados para sustentar a progressão longa.
- A tela de Upgrades e o level-up contam temporários apenas quando estão realmente no save: 7 temporárias base auto-liberadas ou extras explicitamente liberadas por recompensa/sistema.
- A lista de conquistas agora é gerada por `GameState.get_achievements()` e entrega 100 conquistas, preservando as especiais já existentes.
- As novas conquistas cobrem fases, vitórias, sobrevivência no infinito, anéis no infinito, nível de run infinita, anéis totais, perfects, moedas, upgrades, skins, baús, diárias, roleta e Liga Neon.

Checklist:

| Item | Status |
| --- | --- |
| 100 fases disponíveis na seleção | Sim |
| Gameplay aceita fases 1-100 | Sim |
| Próxima fase avança até 100 | Sim |
| 12 anéis ativos como alvo fixo | Sim |
| Temporários bloqueados não entram na contagem | Sim |
| 7 temporárias iniciais liberadas | Sim |
| Temporários extras só aparecem se explicitamente liberados | Sim |
| 100 conquistas geradas e exibidas | Sim |
| Recompensas variadas nas conquistas | Sim |

## 7.15 Liga Neon mensal

Atualizado nesta etapa:

- Removido o texto auxiliar abaixo de `LIGA NEON`, deixando a tela mais limpa.
- Ranking limitado a 30 competidores por divisao, com 29 bots gerados por temporada/mes e rank atual.
- Jogador com 0 trofeus inicia em `#30/30`, pois todos os bots da sala Bronze entram acima de 0 trofeus.
- `MainPortData.LEAGUE_RANKS` agora possui 6 ligas: Bronze, Prata, Ouro, Diamante, Lendario e Ultimate.
- `GameState.record_neon_league_match()` prepara ganho/perda de trofeus: vitoria parte de +36, derrota parte de -18 e saida parte de -24.
- A primeira promocao do Bronze para qualquer liga superior libera e salva a skin ultimate `initial_neon_champion`.
- `GameState._ensure_league_season()` usa o mes real/local do `TimeManager`; ao virar o mes, salva `last_season_summary`, reseta estatisticas de temporada e rebaixa uma liga.
- A partida real da Liga foi reativada depois desta etapa em `LeagueBattleScreen.gd`, usando duas arenas compactas e regras competitivas baseadas no modo infinito.

Checklist:

| Item | Status |
| --- | --- |
| Texto "liga local" removido | Sim |
| 30 competidores por sala/rank | Sim |
| Jogador novo aparece #30/30 | Sim |
| 6 ligas configuradas | Sim |
| Trofeus iniciam em 0 | Sim |
| Vitoria/perda de trofeus preparada | Sim |
| Promocao Bronze libera skin ultimate inicial | Sim |
| Reset mensal usa relogio interno | Sim |
| Reset mensal rebaixa uma liga | Sim |

## 7.16 Liga Neon com duelo jogavel

Atualizado nesta etapa:

- `MainPortData.opponent_name()` nao gera mais nomes com numeros como `#001`; os bots usam nomes combinados mais naturais.
- `LeagueScreen.gd` trocou `COMPETIR EM BREVE` por `COMPETIR` e abre `scenes/LeagueBattle.tscn`.
- `LeagueBattleScreen.gd` cria duas arenas verticais: rival em cima e jogador embaixo.
- A luta usa comportamento de modo infinito competitivo: aneis fechando continuamente, reposicao constante, colisao por segmento/substeps, bola ativa, level up e upgrades temporarios de rodada.
- O jogador escolhe upgrades no level up e pode comprar ATK/GOLD com moedas da run.
- O bot joga a arena superior automaticamente, ganha XP/moedas, compra ATK/GOLD e escolhe upgrades de run sozinho.
- A partida tem limite de 90 segundos; se ninguem for preso, vence quem destruiu mais aneis, com score como desempate.
- Derrota do jogador oferece revive via anuncio mockado antes de registrar a perda.
- Resultado registra trofeus, moedas, XP e diamantes em `GameState.record_neon_league_match()`.
- O botao `DOBRAR RECOMPENSA - AD` dobra moedas/XP/diamantes depois do resultado, mas nao dobra trofeus para manter a Liga equilibrada.
- Vitoria/derrota/saida afetam a Liga, estatisticas, missoes, conquistas e progresso global.

Checklist:

| Item | Status |
| --- | --- |
| Nomes de bots sem numeros artificiais | Sim |
| Botao Competir abre batalha real | Sim |
| Duas arenas cabem na tela | Sim |
| Jogador sempre na arena inferior | Sim |
| Bot sempre na arena superior | Sim |
| Jogador escolhe upgrades | Sim |
| Bot escolhe upgrades automaticamente | Sim |
| ATK/GOLD de run funcionam no duelo | Sim |
| Timer de 90s evita duelo infinito | Sim |
| Vencedor por aneis/score no tempo limite | Sim |
| Revive por anuncio mockado antes da derrota | Sim |
| Dobrar recompensa por anuncio mockado | Sim |
| Trofeus alteram ranking/salvamento real | Sim |

## 7.17 Polimento visual/sonoro da Liga

Atualizado nesta etapa:

- Corrigida a causa provavel da tela preta da batalha: o fundo da cena `LeagueBattle` agora fica atras do canvas desenhado, permitindo que arenas, aneis, bolinhas, trilhas e efeitos aparecam corretamente.
- A batalha usa fallback de tamanho pelo viewport antes de posicionar as duas arenas, evitando que a luta nasca fora da area visivel quando a cena abre no Web.
- `LeagueScreen.gd` passa para a luta um rival real do ranking: normalmente o competidor imediatamente acima do jogador.
- Os 5 primeiros bots da Liga agora usam uma escala visual por raridade: top 1 ultimate (`league_king_neon`), top 2 mythic (`infinite_vortex_mythic`), top 3 legendary (`cosmic_fragment`), top 4 epic (`neon_eclipse`) e top 5 rare (`ice`).
- A luta da Liga usa musica propria de competicao via `AudioManager.play_context("league")`, tocando `assets/music/gameplay2.mp3`.
- A arena recebeu trilha visual da skin equipada e bursts leves para impacto, quebra, perfect/clear e repulse, usando cores da skin/anel.
- O HUD da luta foi aproximado do modo Infinito, com tempo, moedas, diamantes, XP, barra de XP, ATK/GOLD e controles separados na base da tela.
- As duas arenas foram reenquadradas para evitar interferencia entre aneis, HUD e controles.
- A bolinha da Liga agora usa desenho neon por cor secundaria/raridade da skin, evitando o bloco branco causado por texturas grandes em canvas pequeno.
- SFX existentes seguem sincronizados: impacto usa `hit_light`/`hit_heavy`, quebra usa `ring_break`, clear usa `perfect`, vitoria/derrota usam seus respectivos sons.
- Ajuste posterior: a Liga usa exatamente 6 aneis ativos por arena, sem alterar fases normais nem modo infinito.
- Ajuste posterior: as arenas da Liga ficaram menores e mais afastadas para impedir invasao visual entre jogador e rival.
- Ajuste posterior: as opcoes de level-up do jogador na Liga chamam `GameState.refresh_unlocks(false)` e respeitam apenas upgrades temporarios realmente liberados.
- Ajuste posterior: `ringRepulse` na Liga respeita chance e cooldown, evitando disparo continuo.
- Ajuste posterior: botoes/level-up da Liga usam assets reais de upgrade em `assets/ui`.

Checklist:

| Item | Status |
| --- | --- |
| Tela preta da luta corrigida | Sim |
| Arenas desenhadas acima do fundo | Sim |
| Rival real do ranking entra na luta | Sim |
| Top 5 bots usam skins por raridade crescente | Sim |
| Musica especifica da Liga | Sim |
| Liga usa 6 aneis fixos por arena | Sim |
| Upgrades bloqueados respeitados na Liga | Sim |
| Ring Repulse com chance e cooldown | Sim |
| APK debug Godot exportado e assinado | Sim |
| HUD da Liga alinhado ao modo Infinito | Sim |
| Arenas reenquadradas sem interferencia visual | Sim |
| Skins deixam de aparecer como quadrado branco | Sim |
| Efeitos visuais de trilha/impacto/quebra | Sim |
| SFX de luta mantidos por evento | Sim |

## 7.18 Evento Codex, Boss visual e ajustes mobile

Atualizado nesta etapa:

- Configuracoes agora separa musica e efeitos sonoros: o jogador pode mutar apenas musicas, apenas SFX ou ambos.
- Telas com listas receberam margem responsiva, `ScrollContainer` com toque/drag e padding inferior preservado pelo botao Voltar global.
- Skins, Loja, Missoes, Jogar/Selecao de fases, Upgrades e Configuracoes foram revisadas para caber melhor em telas verticais pequenas.
- A aba `Eventos` agora mostra o evento semanal `Evento Codex Neon`, com duracao de uma semana calculada pelo relogio interno.
- O evento Codex fica exclusivamente dentro da tela `Event.tscn` / aba Eventos.
- Objetivos do evento Codex: completar fases, sobreviver no Modo Infinito e vencer lutas da Liga Neon.
- Recompensas do evento Codex: moedas, diamantes, bau raro e skin `infinite_vortex_mythic` como recompensa final.
- A tela `Boss` foi recriada visualmente a partir da referencia da main (`frontend/app/boss.tsx` e `frontend/src/game/boss.ts`), sem iniciar gameplay ainda.
- Boss mensal mostra skin, descricao, passiva, reset diario/mensal e niveis Normal/Forte/Elite/Lendario/Impossivel com recompensas visuais.
- Liga Neon recebeu reroll de upgrades temporarios no level-up: video mockado ou 15 diamantes, limite de 3 rerolls por luta.
- O reroll da Liga continua respeitando apenas upgrades temporarios desbloqueados no `GameState`.

Checklist:

| Item | Status |
| --- | --- |
| Musica pode ser mutada separada de SFX | Sim |
| SFX pode ser mutado separado de musica | Sim |
| Scroll por toque em telas de lista | Sim, revisado em telas principais |
| Safe area/margens mobile revisadas | Sim |
| Evento Codex fica na aba Eventos | Sim |
| Evento semanal dura uma semana | Sim |
| Evento usa relogio interno | Sim |
| Evento tem recompensas reais no save | Sim |
| Evento pode dar skin final | Sim |
| Boss interface copiada/portada visualmente | Sim |
| Boss gameplay ainda pendente | Sim |
| Liga Neon reroll por video mockado | Sim |
| Liga Neon reroll por diamantes | Sim |
| Limite de 3 rerolls por luta | Sim |
| Reroll respeita upgrades bloqueados | Sim |
