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
