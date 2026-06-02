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
| Skins | `frontend/app/transformations.tsx`, `frontend/src/game/skins.ts`, `frontend/src/components/SkinIcon.tsx`, `assets/skins/*` | `scenes/Skins.tscn`, `scripts/SkinsScreen.gd` | Visual ajustado | Grid e filtros reenquadrados para HTML/Web. Equipar/evoluir/desbloquear ainda nao funcionam. |
| Upgrades/Melhorias | `frontend/app/upgrade-shop.tsx`, `frontend/src/game/upgrades.ts`, `frontend/src/game/balance.ts`, `frontend/src/components/UpgradeIcon.tsx` | `scenes/Upgrades.tscn`, `scripts/UpgradesScreen.gd` | Visual ajustado | Recursos no topo corrigidos em linha com icones/numeros sem quebra vertical. Compra/aplicacao real ainda pendente. |
| Loja | `frontend/app/store.tsx`, assets `assets/icons/products/*`, `assets/ui/ui_store.png` | `scenes/Shop.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Titulo simples, descricao longa removida e abas reenquadradas. Cards e botoes mockados; sem compra real. |
| Inventario | `frontend/app/inventory.tsx`, assets de baus/chaves em `assets/ui` | `scenes/Inventory.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Descricao longa removida; estado vazio discreto preparado. |
| Missoes | `frontend/app/daily.tsx`, `frontend/src/game/retention.ts`, `assets/ui/ui_missions.png` | `scenes/Missions.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Titulo simples; estado vazio discreto enquanto nao ha missoes reais. |
| Evento | `frontend/app/events.tsx`, `frontend/src/game/retention.ts`, `assets/ui/ui_event.png` | `scenes/Event.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Titulo simples; estado vazio discreto quando nao ha evento ativo. |
| Roleta | `frontend/app/wheel.tsx`, `assets/ui/ui_wheel.png` | `scenes/Wheel.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Titulo simples; roleta visual mantida e sorteio real pendente. |
| Recompensa diaria | `frontend/app/daily-reward.tsx`, `assets/ui/ui_daily_reward.png` | `scenes/DailyReward.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Calendario de 7 dias mockado; controle real de tempo/coleta pendente. |
| Boss | `frontend/app/boss.tsx`, `assets/ui/ui_boss.png` | `scenes/Boss.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Tela visual com estado vazio discreto; logica real de boss pendente. |
| Liga Neon | `frontend/app/league.tsx`, `frontend/app/compete.tsx`, `assets/ui/ui_league_neon.png` | `scenes/League.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Tela visual com estado indisponivel; ranking/liga real pendente. |
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
- Loja, Skins e Upgrades: recursos do jogador.
- Jogar: fases desbloqueadas e Modo Infinito baseado na maior fase.
- Boss: disponibilidade visual baseada no cooldown do `TimeManager`.

Ainda mockado/pendente:

- compras, roleta, recompensas reais, missoes reais, boss real, eventos reais, conquistas reais e gameplay.
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
| Upgrade temporario no HUD | Sim | Level-up abre modal neon com 3 upgrades iniciais reais e icones; HUD mostra upgrade ativo com asset. |
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
- Efeitos de skins avancados, revive/anuncio, dobrar recompensa por anuncio e reroll de upgrades temporarios ainda nao foram portados.
- Recompensas de bau/chave por chance de fase estao documentadas em `LevelData.gd`, mas ainda nao sao concedidas.
- Modo infinito ainda nao e jogavel nesta etapa.
- Fases 2-50 usam a estrutura da main e desbloqueio sequencial, mas ainda precisam de verificacao visual fase a fase.

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
