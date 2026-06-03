# Neon Idle Escape - Godot

Esta pasta foi reiniciada do zero na branch `godot-4-rebuild`. A branch `main` foi usada somente como referencia via `git show`, `git ls-tree` e `git archive`; nao foi feito checkout nem edicao nela.

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
| Liga Neon | `frontend/app/league.tsx`, `frontend/app/compete.tsx`, `frontend/src/game/dualArena.ts`, `assets/ui/ui_league_neon.png` | `scenes/League.tscn`, `scripts/LeagueBattleScreen.gd` | Jogavel | Batalha versus com arena rival no topo, arena do jogador embaixo, bot, upgrades temporarios, trofeus, temporada mensal e recompensas proporcionais. |
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
- Liga Neon ja esta jogavel em formato versus, mas ainda precisa de comparacao visual fina contra a branch main.
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

- `scripts/MainPortData.gd`: tabela central gerada a partir da `main`, com 92 skins, 34 upgrades temporarios, ranks/recompensas da Liga Neon e geracao de oponente.
- `scripts/LocalizationManager.gd`: base EN/PT compartilhada, ligada ao idioma salvo em Configuracoes.
- `scripts/LeagueBattleScreen.gd`: Liga Neon em batalha real, usando duas arenas simultaneas, bot, upgrades de rodada, trofeus e temporada mensal.
- `MAIN_PORT_ANALYSIS.md`: inventario da migracao fiel por sistema e pendencias.

Fontes da branch `main` usadas como verdade nesta etapa:

- `frontend/src/game/skins.ts`
- `frontend/src/game/upgrades.ts`
- `frontend/src/game/dualArena.ts`
- `frontend/src/game/rings.ts`
- `frontend/src/game/achievements.ts`
- `frontend/src/i18n/gameText.ts`

Regras de anel atualizadas:

- Partidas normais e Liga mantem alvo de 5 aneis ativos visiveis, com fila interna para fases finitas.
- Modo infinito escala esse alvo gradualmente, sempre com distancia minima entre raios.
- A area de spawn/enquadramento continua invisivel e respeita HUD, raio minimo/maximo e distancia segura da bolinha.

Liga Neon:

- Nao e mais tela passiva de ranking.
- Oponente fica no topo e jogador embaixo, seguindo a ideia de `dualArena.ts`.
- O bot escolhe upgrades automaticamente.
- O jogador escolhe entre upgrades temporarios reais desbloqueados.
- Vitoria, derrota e saida concedem moedas/XP proporcionais e ajustam trofeus.
- O ranking usa ranks mensais e salva `league.trophies`, vitorias, derrotas, saidas, melhor sequencia e temporada.

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
- `LeagueBattleScreen.gd` recebeu spawn mais justo nas duas arenas menores.

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
| Spawn justo implementado na Liga Neon | Sim |
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
- Liga Neon usa fallback de tamanho pelo viewport para evitar arenas invisíveis/vazias quando o Control ainda não recebeu layout.

Checklist desta etapa:

| Item | Status |
| --- | --- |
| Temporários de rodada ocultos da tela de upgrades | Sim |
| Liga Neon não está mais vazia | Sim, corrigido fallback de layout e mantém modo versus |
| Liga Neon funciona como versus | Sim |
| Duas arenas da Liga Neon funcionando | Sim |
| Oponente automático funcionando | Sim |
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
