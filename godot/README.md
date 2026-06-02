# Neon Idle Escape - Godot 4 rebuild

Esta pasta contem uma recriacao em Godot 4 do jogo atual, mantendo o projeto Expo/React Native antigo intacto fora de `/godot`.

## Como abrir

1. Instale Godot 4.3 ou superior.
2. Abra o Godot Project Manager.
3. Importe `godot/project.godot`.
4. Rode a cena principal `res://scenes/Main.tscn`.

O jogo usa GDScript, cenas `.tscn`, autoloads e assets nativos do Godot. Nao usa TypeScript, React Native, Expo ou codigo web como base principal.

## Como jogar/testar

- Menu principal: `Jogar`, `Upgrades`, `Skins`, `Loja`, `Baus`.
- Arena: a bolinha se move continuamente; toque ou clique na arena para aplicar impulso na direcao tocada.
- Controles: `GIRAR -`, `IMPULSO`, `GIRAR +`, upgrades de rodada por moedas e pausa.
- Objetivo: sobreviver aos aneis, atravessar o centro da abertura para Perfect, quebrar aneis no impacto e completar a fase.

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
- progresso local em `user://neon_idle_escape_godot_save.json`;
- fases 1-50 com dificuldade procedural baseada no projeto atual;
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
- musica/SFX usando assets originais;
- UI vertical pensada para celular e Web mobile.

## Pendencias conhecidas

- boss, liga, missoes diarias, eventos, roleta, inventario detalhado e conquistas ainda estao fora deste primeiro rebuild jogavel.
- Billing real nao foi migrado; loja usa fluxo funcional local/mock.
- Ads reais nao foram integrados; `AdsService.gd` e um stub recompensado.
- APK Android esta apenas estruturado.
- O balanceamento visual/fisico deve ser refinado apos testes em Godot real e mobile.
- Caso algum MP3/WAV precise reimportacao manual, abra o projeto no editor uma vez para gerar `.import`.

## Validacao local realizada

Neste rebuild foi validado no container com Godot 4.3 headless:

```bash
godot --headless --path godot --quit
godot --headless --path godot --scene res://scenes/Main.tscn --quit-after 1
godot --headless --path godot --scene res://scenes/Game.tscn --quit-after 1
godot --headless --path godot --export-release "Web" build/web/index.html
```

Resultados:

- scripts GDScript parsearam sem erros;
- cena principal e cena de gameplay inicializaram em headless;
- recursos foram importados pelo Godot;
- export Web gerou `index.html`, `index.js`, `index.pck`, `index.wasm` e icones em `godot/build/web`;
- servidor local temporario respondeu 200 para `/`, `index.js`, `index.pck`, `index.wasm` e icones.

Observacao: no container, o Godot headless emitiu avisos de socket/TCP e, ao sair de algumas cenas, um aviso nao fatal de recurso ainda em uso. A exportacao Web concluiu com exit code 0.
