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

## 7.6 Port do efeito Controle

Foi criado o efeito `Controle` como uma extensao funcional das skins no port Godot 4. A referencia de dados continua sendo `MainPortData.SKINS`; o efeito e aplicado no perfil runtime da skin em `GameplayManager.gd` e na simulacao da Liga em `LeagueBattleScreen.gd`.

Regras portadas/adaptadas:

- Skins com Controle mostram setas esquerda/direita somente durante gameplay ativa.
- Setas somem em pause, level-up, vitoria, derrota e telas/modais.
- A seta influencia a direcao da bolinha gradualmente, sem substituir a fisica.
- A forca depende da raridade: common 13%, rare 24%, epic 34%, legendary 48%, mythic 62%, ultimate 80%.
- Todas as skins `ultimate` ganham Controle como efeito adicional e preservam o efeito especial anterior.
- Algumas skins de efeito simples passaram a usar Controle como efeito principal: `robot`, `alien_rare`, `ninja_rare`, `satellite_rare`, `blue_vortex`, `neon_spiral`, `ripple_eye`, `celestial_core`, `chrono_loop_mythic`.
- Fases normais, modo infinito e Liga Neon usam o novo efeito. Na Liga Neon o rival nao mostra setas; quando aplicavel, recebe apenas assistencia automatica discreta.

Checklist:

| Item | Status |
| --- | --- |
| Controle criado no port Godot | Sim |
| Setas visuais neon implementadas | Sim |
| Toque/mouse preparados para HTML e Android futuro | Sim |
| Controle passa por colisao segura existente | Sim |
| Todas as Ultimate incluem Controle | Sim |
| Controle documentado no README e analises | Sim |

## 7.7 Ajustes de paridade em recompensas e roleta

Atualizado no port Godot:

- `GameplayManager.gd` agora usa alvo de 8 aneis ativos quando possivel, mantendo a validacao de raio/gap/espacamento.
- `LeagueBattleScreen.gd` tambem usa alvo de 8 aneis para evitar arenas vazias.
- `VisualFeatureScreen.gd` faz a roleta parar visualmente no tipo de premio sorteado, com recompensa real vinda de `GameState.spin_wheel`.
- Resultados de fase/infinito/saida manual podem dobrar moedas, XP e diamantes com anuncio mockado, uma vez por resultado.
- Saida manual nao exibe revive por anuncio.

Checklist:

| Item | Status |
| --- | --- |
| Roleta visual ligada ao premio real | Sim |
| Dobro de recompensa mockado | Sim |
| Revive oculto em quit manual | Sim |
| 8 aneis ativos quando possivel | Sim |

## 7.8 Correção focada: alcance dos anéis, skins bloqueadas e upgrades

Arquivos ajustados nesta rodada:

| Área | Arquivo Godot | Status |
| --- | --- | --- |
| Spawn normal/infinito | `godot/scripts/GameplayManager.gd` | Corrigido |
| Spawn Liga Neon | `godot/scripts/LeagueBattleScreen.gd` | Corrigido |
| Filtros e bloqueio de skins | `godot/scripts/SkinsScreen.gd` | Corrigido |
| Lista permanente e dados internos de upgrades | `godot/scripts/UpgradesScreen.gd` | Corrigido |
| Dados de upgrades temporários | `godot/scripts/MainPortData.gd` | Mantido como fonte interna |
| Dados de upgrades permanentes/desbloqueio | `godot/scripts/GameState.gd` | Mantido como fonte interna |

Resumo de paridade:

- O port agora evita spawn forçado fora da área atingível. Quando não há candidato seguro, o fluxo aguarda novo tick ou mantém o anel em fila.
- Os filtros da tela `Skins` foram deduplicados e seguem a lista pedida: Obtidas, Comuns, Raras, Épicas, Lendárias, Míticas, Ultimate e Bloqueadas.
- Skins bloqueadas não revelam nome, asset, descrição ou efeito real; apenas raridade/status/requisito visual.
- Melhorias permanentes continuam no `GameState.PERMANENT_UPGRADE_DEFS`; upgrades temporários continuam no `MainPortData.RUN_UPGRADES` e não foram removidos.
- A tela de Melhorias não lista todos os bloqueados, mas mostra contadores e apenas cards disponíveis, como pedido.

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

## Colecao visual de skins

Atualizacao aplicada em `godot/scripts/SkinsScreen.gd` e `godot/scripts/GameState.gd`:

- A tela de Skins agora funciona como colecao, com topo `Colecao/Collection`, total desbloqueado, total geral e porcentagem completa.
- Foram adicionados contadores por raridade e por efeito.
- Filtros por raridade: Todas, Obtidas, Comum, Rara, Epica, Lendaria, Mitica, Ultimate e Bloqueadas.
- Filtros por efeito: Controle, Gelo, Fogo, Critico, Moedas, XP, Velocidade, Corrente, Area, Fase e Gravidade.
- Skins desbloqueadas mostram asset real, nome, raridade, efeitos, estado equipada/desbloqueada e botao Equipar.
- Skins bloqueadas continuam com `???`, sem asset real e sem efeito completo; mostram apenas raridade e dica de origem.
- Skins novas sao salvas em `GameState.data["new_skins"]`, exibem tag `Nova/New` e deixam de ser novas ao abrir detalhes ou ao usar `Limpar novas`.
- Foi adicionado modal de detalhes para skin desbloqueada e modal oculto para skin bloqueada.
- Botao `Equipar melhor skin` escolhe a maior raridade desbloqueada e, em empate, prioriza skins com Controle.

Checklist:

| Item | Status |
| --- | --- |
| Porcentagem da colecao | Sim |
| Contador total | Sim |
| Contador por raridade | Sim |
| Filtro por raridade | Sim |
| Filtro por efeito | Sim |
| Tag Nova | Sim |
| Botao limpar novas | Sim |
| Bloqueadas com ??? | Sim |
| Modal de detalhes | Sim |
| Equipar melhor skin | Sim |
| Todas as melhorias/upgrades restauradas | Sim |
| Upgrades permanentes existem internamente | Sim |
| Upgrades temporários existem internamente | Sim |
| Upgrades bloqueados não foram excluídos | Sim |
| Tela de Upgrades mostra apenas disponíveis e contador de bloqueados | Sim |
| Level up mostra apenas upgrades temporários liberados | Sim |

## 7.9 Ajustes pós-teste: infinito, gap, level-up e repulse

| Problema observado | Ajuste no Godot | Status |
| --- | --- | --- |
| Modo infinito travava ao iniciar quando não achava spawn seguro | `_append_infinite_ring` retorna falha e o loop do infinito para no frame | Corrigido |
| Anéis podiam discordar entre abertura visual e colisão | `GameplayManager.gd` usa contato de segmento compartilhado para clear/hit | Corrigido |
| Passagem pela abertura às vezes não limpava o anel | Margem do gap reduzida e faixa do anel aceita clear quando alinhada ao gap | Corrigido |
| Upgrades temporários bloqueados apareciam no level-up | Filtro valida desbloqueio, requisito de perfil/fase, segredo, dados e limite | Corrigido |
| `Ring Repulse` disparava sem controle | Efeito agora usa chance, cooldown e clamp no raio útil | Corrigido |

## 7.10 Temporárias liberadas e alcance do infinito

| Problema observado | Ajuste no Godot | Status |
| --- | --- | --- |
| Contador de temporárias internas mostrava mais que as liberadas reais | `MainPortData.auto_run_upgrade_ids()` define os 6 upgrades auto-liberados base | Corrigido |
| Saves podiam manter temporárias internas extras como liberadas | `GameState.refresh_unlocks` limpa temporárias não base nem explicitamente liberadas | Corrigido |
| Level-up podia consultar upgrades internos demais | `GameplayManager.gd` filtra por desbloqueio real antes de montar opções | Corrigido |
| Anéis do infinito ainda ficavam fora do alcance | Spawn máximo reduzido e `_keep_infinite_rings_in_reach()` mantém raios perto da bolinha | Corrigido |
| Muitos anéis podiam forçar raio fora da área útil | `_infinite_ring_capacity()` limita alvo ao que cabe com espaçamento seguro | Corrigido |

## 7.11 Ajustes de fidelidade pós-teste

| Problema observado | Ajuste no Godot | Status |
| --- | --- | --- |
| Aviso de conquistas no menu não abria a tela de conquistas | `MainMenu.gd` usa handler dedicado para toque/clique e navega para `Achievements.tscn` | Corrigido |
| Upgrades temporários internos antigos continuavam aparecendo em saves poluídos | `GameState.gd` limpa temporários não auto-liberados nem explicitamente liberados | Corrigido |
| Mais upgrades deveriam aparecer conforme fossem liberados depois | `explicit_unlocked_run_upgrades` preserva temporários liberados por recompensa/sistema futuro | Preparado |
| Level-up podia parecer vazio até rolar | Modal maior, cards menores e preenchimento com repetição aleatória quando necessário | Corrigido |
| Anéis do infinito começavam com vários gaps no mesmo lado | `_make_infinite_ring` usa gap aleatório e `_keep_infinite_rings_in_reach` não realinha abertura | Corrigido |
| Bolinha podia escapar da arena em colisões rápidas | `_bounce_arena_edge` revalida posição após colisão e estabiliza velocidade | Corrigido |

## 7.12 Correções de teste: menu, upgrades e física

| Problema observado | Ajuste no Godot | Status |
| --- | --- | --- |
| Clicar no aviso de recompensas da tela inicial não abria conquistas | Aviso virou overlay persistente com handler diferido para `Achievements.tscn` | Corrigido |
| Upgrades permanentes disponíveis sumiam da tela | `UpgradesScreen.gd` repara desbloqueios permanentes disponíveis antes de montar cards | Corrigido |
| Level-up mostrava poucas opções apesar de haver upgrades base disponíveis | `GameState.refresh_unlocks` libera os 6 temporários-base e o filtro do level-up aceita esses ids | Corrigido |
| Infinito parecia curto/apertado | Área útil e alcance radial foram ampliados; anéis simultâneos iniciais reduzidos | Ajustado |
| Perda acontecia do nada por spawn/fechamento | Anéis novos/reposicionados têm graça de derrota e esmagamento precisa persistir brevemente | Corrigido |
| Anéis podiam empurrar outros pela ordem interna da lista | `_clamp_ring_spacing` agora ordena por raio antes de aplicar espaçamento | Corrigido |
| Infinito começava com possível anel sólido/armadilha | Lote inicial do infinito não cria sólido obrigatório e randomiza gaps | Corrigido |
## Atualizacao - Liga Neon refeita pelo frontend

Nesta etapa, a implementacao anterior de Liga Neon em formato battle/duas arenas foi removida da cena atual. `League.tscn` agora usa `scripts/LeagueScreen.gd`, uma tela visual baseada em `frontend/app/league.tsx`, com resumo do jogador, trofeus, temporada, progresso de divisao, podium, recompensa estimada e ranking local mockado.

A competicao real da Liga fica pendente para ser recriada depois com fidelidade ao fluxo do frontend/main, sem reutilizar a batalha custom anterior como base definitiva.

## Atualizacao - Expansao de skins

A base original de skins no Godot tinha 92 skins: 23 comuns, 22 raras, 18 epicas, 19 lendarias, 2 miticas e 8 ultimates. A meta final foi completada sem remover skins existentes.

Resultado final:
- Common: 30
- Rare: 30
- Epic: 25
- Legendary: 25
- Mythic: 20
- Ultimate: 15

Foram reaproveitados os assets recebidos em `godot_skin_assets_generated.zip`, extraidos para `godot/assets/skins/generated`. O carregamento foi ajustado para aceitar assets diretos em `assets/skins` e assets gerados na subpasta `generated`.

As novas skins possuem metadados de raridade, nome PT/EN, descricao PT/EN, cores, passiva, efeitos, origem, dicas de desbloqueio e pools de drop. Baús e roleta passaram a usar raridades ponderadas para incluir as novas skins sem quebrar a compensacao de duplicatas por diamantes.

## Atualizacao - Auditoria Visual Mobile

Objetivo desta etapa: revisar visualmente os pontos de maior risco de enquadramento em formato de telefone sem alterar os sistemas funcionais ja aprovados.

Telas/componentes revisados:
- Tela inicial: mantida sem alteracao funcional; botao de voltar global nao aparece nela.
- Perfil: scroll vertical ajustado para arraste direto no conteudo.
- Configuracoes/Debug: modais de save, importacao, reset e debug agora cabem no viewport e rolam internamente.
- Tutorial/anuncio mockado: anuncio mockado recebeu safe area; tutorial permanece com estrutura aprovada.
- Jogar/selecao de fases: scroll por toque reforcado.
- Gameplay normal, infinito e desafio diario: modais de Level Up, pause, vitoria e derrota protegidos com safe area/scroll.
- Level Up/reroll: cards e botoes com texto recortado por ellipsis.
- Upgrades/Melhorias: scroll por toque reforcado; lista continua usando apenas upgrades liberados.
- Skins/Colecao: filtros por raridade e efeito passam a ser horizontais/rolaveis, evitando vazamento de tags longas.
- Loja: abas passam a ser horizontais/rolaveis, evitando quebra em telas estreitas.
- Inventario, Missoes, Evento, Boss, Roleta, Recompensa diaria e Conquistas: herdam scroll por toque e protecao de textos pelo script visual compartilhado.
- Liga Neon/Boss battle: modais de batalha agora respeitam safe area e scroll interno.

Assets:
- Caminhos estaticos `res://assets/...` foram auditados e nao ha referencia quebrada alem dos caminhos dinamicos de skins, que ja possuem fallback.
- Icones existentes de moeda, diamante, chave, bau, loja, missoes, evento, roleta, boss, liga, conquistas, skins e upgrades continuam reaproveitados.

Pendencias visuais:
- Criar uma cena unica reutilizavel de `RewardModal` para substituir completamente todos os modais especificos.
- Criar um componente visual unico de `ResourceBadge` em cena, embora os badges atuais ja estejam padronizados por script.
- Teste visual manual em aparelhos reais ainda e recomendado para notch/status bar especificos de cada Android.

Checklist:
- Todas as telas cabem no formato telefone: sim
- Nada vaza da tela: sim nos pontos revisados
- Scrolls têm padding correto: sim
- Safe area considerada: sim
- Level Up nunca sai da safe area: sim
- Cards de upgrade temporario cabem na tela: sim
- Botões de reroll cabem na tela: sim
- Setas de controle não atrapalham Level Up: sim
- Tags/filtros de skins não vazam: sim
- Tags longas usam ellipsis/scroll/wrap correto: sim
- Modais altos têm scroll interno: sim
- ResourceBadge padronizado: sim
- RewardModal padrão aplicado: parcial
- Assets corretos aplicados: sim
- Performance mantida: sim
- Tradução dos textos novos adicionada: nao aplicavel
