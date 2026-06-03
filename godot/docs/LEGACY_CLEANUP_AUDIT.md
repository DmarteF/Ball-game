# Auditoria de limpeza da branch Godot

Data: 2026-06-03  
Branch auditada: `godot-4-rebuild`

## Resultado

O projeto Godot esta independente das pastas legadas Expo/React Native/backend/Emergent. A build Web usa apenas `godot/` e o workflow de GitHub Pages tambem exporta apenas o projeto Godot.

## Checagens feitas

| Item | Resultado |
| --- | --- |
| Branch ativa | `godot-4-rebuild` |
| Estado inicial do git | Limpo antes da auditoria |
| Dependencia runtime fora de `/godot` | Nenhuma encontrada |
| Assets usados pelo Godot | Copiados para `godot/assets` |
| Scripts/cenas com caminhos fora de `/godot` | Nenhum caminho funcional encontrado |
| Referencias `frontend/...` em `/godot` | Apenas documentacao de origem/portabilidade |
| Workflow GitHub Actions | `.github/workflows/godot-web.yml` usa somente Godot |
| Build Web/HTML | Preset `Web` exporta `godot/build/web/index.html` |
| Android futuro | Preparado para ser configurado no Godot; sem dependencia Expo/backend |
| Docs necessarios | `godot/README.md`, `godot/GAMEPLAY_MAIN_ANALYSIS.md`, `godot/MAIN_PORT_ANALYSIS.md` e esta auditoria |

## Dependencias confirmadas dentro de `/godot`

- `godot/project.godot`
- `godot/export_presets.cfg`
- `godot/scenes/*.tscn`
- `godot/scripts/*.gd`
- `godot/assets/images`
- `godot/assets/sounds`
- `godot/assets/music`
- `godot/assets/fonts`
- `godot/assets/ui`
- `godot/assets/skins`
- `godot/assets/icons`
- `godot/assets/backgrounds`

As referencias `user://` sao saves/configuracoes locais gerados pelo Godot em runtime.

## Documentacao migrada

- `docs/privacy-policy.html` foi movido para `godot/docs/privacy-policy.html`, pois ainda e util para publicacao futura/mobile.
- O conteudo antigo de `GAME_INFO.md` era uma descricao do MVP Expo/backend e foi considerado legado. A branch `main` permanece como referencia historica completa.
- `docs/index.html` era uma landing page estatica antiga. O GitHub Pages desta branch agora deve publicar o export Web do Godot.

## Remocoes seguras

Removidos da branch `godot-4-rebuild` por nao serem usados pela build Godot:

- `frontend/`
- `backend/`
- `.emergent/`
- `memory/`
- `test_reports/`
- `tests/`
- `docs/`
- `GAME_INFO.md`
- `backend_test.py`
- `test_result.md`
- `.gitconfig`

## Mantidos

- `godot/`: projeto principal.
- `.github/workflows/godot-web.yml`: export Web e deploy GitHub Pages do Godot.
- `.gitignore`: ignora caches/builds locais, incluindo `godot/.godot/` e `godot/build/`.
- `README.md`: entrada curta apontando para `godot/`.

## Cache Godot

Os arquivos rastreados dentro de `godot/.godot/` tambem foram removidos do git. Essa pasta e cache/editor state local, e o Godot recria automaticamente ao abrir/importar o projeto.

## Como validar

Abrir/importar o projeto:

```bash
godot --headless --path godot --quit
```

Exportar Web:

```bash
mkdir -p godot/build/web
godot --headless --path godot --export-release Web build/web/index.html
```

Servir localmente:

```bash
cd godot
python3 serve_web.py --port 8083
```

## Observacoes

- As referencias a `frontend/...` mantidas dentro dos arquivos Markdown em `godot/` sao historico de portabilidade e nao dependencias de runtime.
- O uso de horario local para sistemas temporais continua sujeito a manipulacao pelo relogio do dispositivo ate existir validacao online.
