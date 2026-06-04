# Neon Idle Escape - Godot 4

Esta branch (`godot-4-rebuild`) agora esta focada no projeto Godot 4. A versao antiga Expo/React Native/backend continua como referencia historica na branch `main`, mas nao faz parte do projeto ativo desta branch.

## Projeto atual

- Projeto Godot: `godot/`
- Cena principal: `godot/scenes/MainMenu.tscn`
- Configuracao Godot: `godot/project.godot`
- Preset Web/HTML: `godot/export_presets.cfg`
- Workflow GitHub Pages: `.github/workflows/godot-web.yml`
- Documentacao detalhada: `godot/README.md`
- Auditoria de limpeza: `godot/docs/LEGACY_CLEANUP_AUDIT.md`
- Politica de privacidade migrada: `godot/docs/privacy-policy.html`

## Como abrir no Godot 4

Abra a pasta `godot/` no Godot 4.3 ou superior.

Com CLI:

```bash
godot --path godot
```

## Como gerar HTML/Web

Com templates de exportacao do Godot instalados:

```bash
mkdir -p godot/build/web
godot --headless --path godot --export-release Web build/web/index.html
```

Para servir localmente:

```bash
cd godot
python3 serve_web.py --port 8083
```

Depois abra:

```text
http://127.0.0.1:8083/index.html
```

## GitHub Pages

O workflow `.github/workflows/godot-web.yml` exporta apenas o projeto em `godot/` e publica `godot/build/web` no GitHub Pages quando houver push na branch `godot-4-rebuild`.

## Android futuro

A estrutura do projeto Godot e os assets ja estao dentro de `godot/`. O preset Android fica em `godot/export_presets.cfg`, sem depender de `frontend/` ou `backend/`.

APK debug local gerado nesta branch:

```text
godot/build/android/neon-idle-escape-debug.apk
```

Ele foi gerado pelo export Android do Godot, nao por Expo, porque esta branch agora e Godot-only.

## Legado removido desta branch

Arquivos e pastas Expo/React Native/backend/Emergent foram removidos desta branch depois da auditoria. A referencia antiga deve ser consultada pela branch `main`.
