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
| Perfil | `frontend/app/profile.tsx`, `frontend/src/components/ProfileAvatar.tsx`, `frontend/src/components/SkinIcon.tsx`, `frontend/src/components/UiIcon.tsx`, `frontend/src/game/skins.ts`, `frontend/src/game/achievements.ts`, `frontend/src/game/upgrades.ts` | `scenes/Profile.tscn`, `scripts/ProfileScreen.gd` | Ajustado nesta etapa | Configuracoes, audio, idioma, FPS e Hz removidos do Perfil. Botao Back padronizado com Coming soon. Dados reais ainda mockados ate o save completo ser portado. |
| Configuracoes | Pedido desta etapa + estilo visual da tela inicial | `scenes/Settings.tscn`, `scripts/SettingsScreen.gd` | Concluida nesta etapa | Tela simples: audio ligado/mudo, idioma e sobre. Botao Back padronizado com Coming soon. Estado salvo em `user://settings.json`. |
| Loja | `frontend/app/store.tsx`, assets `assets/icons/products/*`, `assets/ui/ui_store.png` | `scenes/Shop.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Estrutura com abas como a main: Baus, Diamantes, Chaves, Recompensas e Bau gratis. Cards e botoes mockados; sem compra real, anuncios reais ou entrega de recompensas. |
| Inventario | `frontend/app/inventory.tsx`, assets de baus/chaves em `assets/ui` | `scenes/Inventory.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Estado vazio quando nao ha itens: baus, chaves, skins e recompensas serao exibidos futuramente com dados reais. |
| Missoes | `frontend/app/daily.tsx`, `frontend/src/game/retention.ts`, `assets/ui/ui_missions.png` | `scenes/Missions.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Missoes e progresso mockados; logica real diaria/semanal pendente. |
| Evento | `frontend/app/events.tsx`, `frontend/src/game/retention.ts`, `assets/ui/ui_event.png` | `scenes/Event.tscn`, `scripts/VisualFeatureScreen.gd` | Visual ajustado | Estado vazio quando nao ha evento ativo; calendario/tempo real pendente. |
| Roleta | `frontend/app/wheel.tsx`, `assets/ui/ui_wheel.png` | `scenes/Wheel.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Roleta parada visual; botao mockado e sorteio real pendente. |
| Recompensa diaria | `frontend/app/daily-reward.tsx`, `assets/ui/ui_daily_reward.png` | `scenes/DailyReward.tscn`, `scripts/VisualFeatureScreen.gd` | Visual criado | Calendario de 7 dias mockado; controle real de tempo/coleta pendente. |

## 6. HTML/Web

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
