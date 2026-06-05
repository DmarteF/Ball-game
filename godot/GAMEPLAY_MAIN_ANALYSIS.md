# Gameplay Main Analysis - Fase 1

Este documento registra a analise da gameplay da branch `main` antes dos ajustes da Fase 1 no projeto Godot 4.

## Arquivos analisados na branch main

| Area | Arquivo main | Uso no port Godot |
| --- | --- | --- |
| Gameplay principal | `frontend/app/game.tsx` | Loop da partida, HUD, recompensas, pausa, vitoria, derrota, upgrades de rodada. |
| Aneis/fisica | `frontend/src/game/rings.ts` | Geracao, rotacao, gaps, colisao, perfect escape, esmagamento e clamp de espacamento. |
| Fases | `frontend/src/game/phases.ts` | Dados da Fase 1, dificuldade, HP, velocidades, rewards e chances futuras. |
| Balanceamento | `frontend/src/game/balance.ts` | Velocidade da bolinha, escalas de fechamento/rotacao e limites de upgrades permanentes. |
| Economia | `frontend/src/game/economy.ts` | Multiplicadores de combo, conversao de moedas da run e XP de perfil. |
| Atributos | `frontend/src/game/playerAttributes.ts` | Como upgrades permanentes, skin e upgrades de rodada afetam dano, velocidade, moedas, XP e critico. |
| Upgrades temporarios | `frontend/src/game/upgrades.ts` | Lista de upgrades de level-up e efeitos disponiveis. |
| Skins | `frontend/src/game/skins.ts` | Skin inicial, cores, trail, passivas e efeitos especiais. |
| Save/progresso | `frontend/src/contexts/GameContext.tsx` | Valores iniciais, purchaseUpgrade, recordRunRewards e unlockPhase. |

## Comportamento original da Fase 1

1. **Movimento da bolinha**
   - A bolinha nasce no centro da arena com angulo aleatorio.
   - A velocidade base solo vem de `GAMEPLAY_TUNING.solo.ballSpeed`, valor `2.2`.
   - A velocidade e limitada por `clampBallSpeed` entre `targetSpeed * 0.78` e `targetSpeed * 1.42`.
   - Ao bater na borda externa da arena, a velocidade reflete pelo vetor normal.
   - Ao bater em anel fechado, a bolinha e separada para uma distancia segura e reflete com pequeno impulso.

2. **Geracao dos aneis**
   - A Fase 1 usa `getPhaseConfig(1)` e `createProceduralPhaseConfig`.
   - `phases.ts` define tier inicial com `ringMin=8`, `ringMax=16`, `baseHp` do tier `12`, fechamento baixo e gaps grandes.
   - Para Fase 1 e jogador nivel 1, a configuracao procedural gera aproximadamente 9 aneis antes do clamp por tamanho de arena.
   - Os aneis sao concentricos, do raio interno `35` ate o raio externo da arena.

3. **Gaps e rotacao**
   - Cada anel normal tem uma abertura calculada por `gapStart`, `gapSize` e `rotation`.
   - O centro do gap e `gapStart + rotation`.
   - Aneis alternam direcao de rotacao por indice.
   - O ultimo anel da fase e solido, sem gap, para fechar a etapa com quebra por dano.

4. **Interacao bolinha/aneis**
   - Se a bolinha cruza o raio do anel dentro do gap, o anel normal recebe `status='cleared'` e desaparece.
   - Se a bolinha colide com parte fechada, causa dano baseado nos atributos finais.
   - Se o HP interno chega a zero, o anel recebe `status='broken'` e deixa de ser ativo.
   - O HP existe na logica, mas nao aparece no HUD.

5. **Vitoria e derrota**
   - A vitoria acontece quando nao existem aneis ativos com HP maior que zero.
   - A derrota acontece quando a bolinha e esmagada por um anel ativo fora do gap.
   - Na vitoria, a main abre modal neon com resumo da rodada e botoes de coletar/sair, proxima fase e jogar novamente.
   - Ao coletar com vitoria, a proxima fase e liberada.

6. **Moedas, XP, diamantes e combo**
   - Perfect concede moedas e XP de run.
   - Quebra de anel concede moedas e XP, com valor maior para anel solido.
   - Hits tambem geram moedas e XP pequenos.
   - Combo dura `2600ms`; combos altos aumentam moedas e XP.
   - Diamante pode cair em Perfect com chance base `0.03`, mais bonus de atributos/skin.
   - Moedas da run viram moedas globais por `getGlobalCoinsFromRun`.
   - XP de perfil vem de `getRunProfileXp`.

7. **Upgrades permanentes**
   - `baseDamage` altera `stats.baseDamage = 10 * 1.1^nivel`.
   - `baseSpeed` altera `stats.baseSpeed = 100 * 1.08^nivel`.
   - `coinMultiplier` soma `0.15` por nivel.
   - `critChance` soma `2%` por nivel.
   - `xpBoost` soma `0.2` ao multiplicador de XP por nivel.
   - `slowRings` reduz fechamento dos aneis.

8. **Upgrades de rodada/temporarios**
   - A gameplay da main tem barra fixa inferior com dois upgrades compraveis com moedas da run: `ATK` e `Gold`.
   - Custo de `ATK` inicia em `20`; custo de `Gold` inicia em `18`.
   - Cada compra usa `floor(base * 1.35^nivel)`.
   - A main tambem possui modal de level-up com 3 upgrades temporarios escolhiveis e reroll.
   - No Godot, a Fase 1 ja abre um modal neon com 3 opcoes reais de upgrade quando a run sobe de nivel; reroll por anuncio/gemas ainda nao foi portado.

9. **Skin equipada**
   - A skin inicial e `neon_blue`.
   - A skin fornece cores primaria/secundaria, trail e passiva.
   - `neon_blue` tem bonus pequeno de chance de diamante em Perfect.
   - Skins mais avancadas podem alterar dano, moedas, XP, velocidade, critico ou efeitos em aneis.

10. **HUD original**
    - Linha superior: moedas da run, diamantes da run, moedas da conta, mute e pausa.
    - Linha de XP: `Lv.{level}` e barra/progresso `xp/xpToNextLevel`.
    - Progresso: aneis restantes/total, ATK, DPS e Combo.
    - Rodape: upgrades de rodada `ATK` e `Gold`.

11. **Tela de vitoria original**
    - Modal neon escuro/roxo.
    - Titulo `VITORIA`.
    - Linhas: fase, resultado, moedas da rodada, moedas gerais, diamantes, XP de perfil, XP ganho, quebrados, perfects, maior combo, chaves/baus, level e score.
    - Botoes: dobrar recompensa por ad, coletar e sair, proxima fase, jogar novamente.

## Implementado agora no Godot

- `MainPortData.gd` importa os dados centrais da branch `main`: 92 skins, 34 upgrades temporarios, ranks/recompensas da Liga Neon e geracao de oponente.
- Fases 1-50 usam `LevelData.gd` com dados derivados da branch `main`; a selecao abre qualquer fase desbloqueada.
- Geracao/rotacao/gaps/colisao seguem `rings.ts` e `game.tsx`.
- HUD sem HP visivel e sem debug.
- Arena sem circulo central decorativo e sem base extra.
- Bolinha com skin real, brilho e trail.
- Recompensas de hit, break e perfect usam multiplicadores de moedas/XP.
- Combo, maior combo, score e DPS existem internamente, mas DPS/ATK/skin/aneis restantes foram removidos do HUD conforme pedido.
- Upgrades de rodada `ATK` e `Gold` foram adicionados no rodape.
- Modal de level-up com 3 upgrades temporarios reais foi adicionado para a Fase 1.
- HUD agora usa ResourceBadge com assets reais para moedas, diamantes, conta e chaves.
- HUD mantem pausa, fase, dificuldade, XP/nivel, barra de XP e upgrade temporario ativo.
- Cards e HUD de upgrades temporarios usam icones reais de `assets/ui`.
- Feedbacks de moeda, XP, diamante e level-up foram reforcados com texto flutuante, particulas e SFX.
- Upgrades permanentes basicos afetam dano, velocidade, moedas, XP, critico e slow rings.
- Tela `Upgrades/Melhorias` agora compra upgrades permanentes reais com moedas globais.
- Custos/limites portados da main:
  - `baseDamage`: custo base 100, max 30, +10% dano por nivel.
  - `baseSpeed`: custo base 120, max 18, +8% velocidade por nivel.
  - `coinMultiplier`: custo base 200, max 25, +15% moedas por nivel.
  - `critChance`: custo base 150, max 20, +2% critico por nivel.
  - `xpBoost`: custo base 180, max 25, +20% XP por nivel.
  - `perfectChance`: custo base 450, max 12, +1% perfect/diamante por nivel.
  - `slowRings`: custo base 600, max 10, reduz fechamento dos aneis.
- Desbloqueios reais estao centralizados em `GameState.refresh_unlocks`, usando fase maxima e nivel do perfil; baus/eventos/missoes/conquistas ficaram como fontes futuras documentadas.
- Upgrades temporarios de level-up so entram no sorteio se estiverem desbloqueados no save. O fallback que completava a lista com upgrades bloqueados foi removido.
- Efeitos basicos de skins foram portados para a gameplay: freeze, burn, chain, area, phase, repulse, coin, XP, speed e crit.
- Os 92 sprites de skins existentes em `frontend/assets/skins` estao importados em `godot/assets/skins`; skins sem entrada manual recebem metadados e efeito basico por familia visual em `SkinsScreen.gd`.
- Efeitos de upgrades temporarios foram conectados a calculos reais: frost desacelera e colore o anel, burn soma dano, ringRepulse empurra o raio e chainLightning danifica um anel vizinho.
- Colisao agora usa substeps e checagem de segmento entre posicao anterior/nova para reduzir tunneling em alta velocidade.
- Movimento da bolinha foi estabilizado com angulo minimo e pequena variacao controlada em reflexoes, evitando trajetorias longas quase horizontais.
- Espacamento de aneis usa `MIN_RING_SPACING`, `MAX_VISIBLE_RINGS` e clamp de raios para permitir arena mais cheia sem sobreposicao confusa.
- SFX foi remapeado por evento: `ring_hit`, `ring_crit`, `ring_break`, `ring_clear`, `reward_coin`, `xp`, `diamond`, `click`, `victory` e `defeat`.
- Modo infinito foi conectado ao card `Modo Infinito`: gera aneis sem fim, escala dificuldade, salva recordes e mostra resumo de resultado.
- Liga Neon foi convertida de tela visual para batalha versus: arena rival no topo, arena do jogador embaixo, bot, escolhas de upgrades temporarios, trofeus, temporada mensal e recompensas para vitoria/derrota/saida.
- O infinito tambem usa pressao dinamica: limpezas rapidas aumentam `infinite_clear_pressure`, que fecha gaps, acelera rotacao/fechamento e aumenta densidade de aneis com clamp para nao sobrepor nem ficar injusto cedo demais.
- Conquistas/missoes recebem eventos reais de fase, infinito, aneis, perfects, compras, skins, diaria, roleta e recursos.
- Conquistas adicionais da main foram vinculadas a perfects, diamantes, infinito por tempo/aneis/nivel, combo, criticos, efeitos de skin, colecao por raridade e abertura de baus. `GameState.gd` agora tem hooks publicos para conectar futuros sistemas sem duplicar logica.
- Ritmo adaptativo dos aneis adicionado: `ring_spawn_delay`, streak de limpeza rapida e bonus por muitos aneis restantes aumentam o ritmo com clamp, e o estado reseta em restart/vitoria/proxima fase.
- Fundos variaveis por partida/fase adicionados com paletas escuras em roxo, azul, vinho e preto arroxeado. As paletas dos aneis tambem variam em neon.
- Gaps/aberturas foram reduzidos para evitar fases faceis demais. `LevelData.gd` agora usa clamp menor e `GameplayManager.gd` evita reabrir gaps grandes no desenho/colisao.
- Arena foi reenquadrada para uma area logica invisivel abaixo do HUD, sem circulo, borda, base ou debug visual.
- XP foi aumentado: hit simples gera cerca de 5 XP, critico cerca de 8 XP, break/perfect escalam com fase/dificuldade e conclusao de fase concede bonus maior ao perfil.
- Skins agora sao funcionais: `SkinsScreen.gd` mostra todas as skins, filtra por estado real, permite equipar somente desbloqueadas, salva `equipped_skin` e a gameplay usa o sprite equipado com fallback `neon_blue`.
- Sistemas funcionais adicionados em `GameState.gd`: conquistas, loja simulada, inventario/baus, recompensa diaria, roleta e missoes diarias com save local.
- `AudioManager.gd` centraliza musica/SFX por contexto: menu persiste entre subtelas, gameplay troca de contexto sem duplicar player, loop e mute/unmute respeitam o save.
- Vitoria salva moedas globais e XP de perfil convertidos como na main.
- Tela de vitoria foi refeita como resumo limpo com icones/assets, sem scroll interno apertado.
- `AudioManager.gd` centraliza musica/SFX, respeita audio mudo e evita duplicar musica.

## Pendencias conhecidas

- Comparacao visual pixel-perfect com a branch `main` ainda nao foi feita.
- Reroll de upgrades temporarios por anuncio/gemas ainda nao foi portado.
- Alguns efeitos ultra-especificos da branch `main` ainda estao aproximados por familia funcional. Exemplo: skins cosmicas usam area/crit/trilha quando o comportamento exato ainda nao existe.
- Efeitos como bomba, laser, multihit avancado e revive/anuncio ainda nao foram portados.
- Revive por anuncio, dobrar recompensa por anuncio e coleta/sair separada ainda estao preparados apenas como estrutura.
- Chaves e baus aparecem no resumo como `0/0`, igual ao estado atual observado da gameplay base, mas drops reais ainda nao foram conectados.
- Barras visuais de XP foram adicionadas, mas ainda nao estao pixel-perfect em relacao ao React Native.
- As 50 fases usam a mesma formula/dados da branch `main`, mas ainda precisam de comparacao visual fase a fase.
- A Liga Neon precisa de comparacao visual fina com `frontend/app/league.tsx`, `frontend/app/compete.tsx` e `frontend/src/game/dualArena.ts`.

## Checklist obrigatoria

| Item | Status |
| --- | --- |
| Arquivos da gameplay main analisados | Sim |
| Movimento da bolinha documentado | Sim |
| Geracao de aneis documentada | Sim |
| Rotacao/gaps documentados | Sim |
| Colisao documentada | Sim |
| Recompensas documentadas | Sim |
| Upgrades permanentes documentados | Sim |
| Upgrades temporarios documentados | Sim |
| XP documentado | Sim |
| HUD original documentado | Sim |
| Tela de vitoria original documentada | Sim |
| ResourceBadge com assets criado | Sim |
| Moedas com icone no HUD | Sim |
| Diamantes com icone no HUD | Sim |
| Conta com icone no HUD | Sim |
| Chaves com icone no HUD | Sim |
| ANEIS RESTANTES removido do HUD | Sim |
| DPS removido do HUD | Sim |
| Skin atual removida do HUD | Sim |
| ATK removido do HUD | Sim |
| Upgrades temporarios com icones/assets | Sim |
| Level Up visual polido | Sim |
| AudioManager criado/ajustado | Sim |
| Musica de gameplay tocando | Sim |
| SFX funcionando | Sim |
| Audio mudo/ligado respeitado | Sim |
| Tela de vitoria refeita e legivel | Sim |
| Tela de vitoria com icones/assets | Sim |
| Tela de vitoria sem texto ilegivel | Sim |
| 50 fases criadas em LevelData | Sim |
| Selecao de fases usa progresso real | Sim |
| Desbloqueio sequencial funcionando | Sim |
| Fase 1 ajustada conforme main | Sim |
| HP removido do HUD | Sim |
| Circulo central removido | Sim |
| Area visual extra removida | Sim |
| Debug removido | Sim |
| Bolinha com sprite real | Sim |
| Efeitos visuais adicionados | Sim |
| Musica integrada | Sim |
| SFX integrados | Sim |
| Audio mudo/ligado respeitado | Sim |
| Audio integrado | Sim |
| Gaps dos aneis reduzidos | Sim |
| Arena centralizada abaixo do HUD | Sim |
| Area de spawn/enquadramento invisivel | Sim |
| XP por hit/recompensa ajustado | Sim |
| Conquistas funcionais | Sim |
| Loja funcional/mockada | Sim |
| Recompensa diaria funcional | Sim |
| Roleta funcional | Sim |
| Inventario funcional | Sim |
| Missoes funcionais | Sim |
| Jogo padrao em ingles | Sim |
| Traducao PT-BR base implementada | Sim |
| Configuracao de idioma funcionando | Sim |
| Mute funcionando | Sim |
| Musica persiste no mesmo contexto | Sim |
| Musica em loop | Sim |
| SFX sincronizados com eventos principais | Sim |
| XP aparecendo corretamente | Sim |
| Level up funcionando | Sim |
| Upgrade temporario aparecendo corretamente | Sim |
| Upgrades temporarios funcionam | Sim |
| Upgrades permanentes aplicados | Sim |
| Upgrades permanentes compraveis | Sim |
| Desbloqueio real de upgrades por fase/perfil | Sim |
| Temporarios respeitam desbloqueio | Sim |
| Skins equipaveis e persistentes | Sim |
| Skin equipada usada na gameplay | Sim |
| Efeitos basicos de skins implementados | Sim |
| 92 sprites de skins da main importados | Sim |
| Skins importadas recebem efeitos basicos | Sim |
| Efeito de gelo reduz velocidade do anel | Sim |
| Efeito de gelo aplica visual azul/congelado | Sim |
| Bolinha rapida protegida por substeps/segmento | Sim |
| Bolinha mais ativa e menos horizontal | Sim |
| SFX de bater/limpar anel corrigido | Sim |
| Modo infinito funcional | Sim |
| Modo infinito salva recordes | Sim |
| Modo infinito aumenta pressao ao limpar aneis rapido | Sim |
| Liga Neon versus jogavel | Sim |
| Liga Neon usa bot e upgrades temporarios | Sim |
| Liga Neon salva trofeus/temporada/recompensas | Sim |
| Conquistas vinculadas ao modo infinito | Sim |
| Hooks internos de progresso/criacao de eventos | Sim |
| Missoes recebem progresso da jogatina real | Sim |
| Ritmo adaptativo dos aneis | Sim |
| Fundos escuros variaveis por fase/partida | Sim |
| Vitoria fiel a main | Em progresso |
| Tela de vitoria refeita/fiel | Sim |
| Recompensas salvam | Sim |
| Fase 2 libera | Sim |

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

## 7.6 Efeito Controle em skins

O efeito `Controle` foi adicionado como uma assistencia real de direcao. Quando a skin equipada possui esse efeito, a gameplay exibe duas setas neon no rodape acima dos upgrades temporarios. As setas ficam ocultas durante pause, derrota, vitoria e level-up para nao cobrir modais ou botoes.

A direcao da bolinha e influenciada gradualmente pela seta pressionada. A implementacao altera a velocidade por interpolacao suave, preserva velocidade minima/maxima e continua usando substeps, separacao/reflexao e colisao por segmento. O Controle nao teleporta a bolinha e nao ignora aneis fechados.

Forca por raridade:

| Raridade | Forca |
| --- | --- |
| common | 13% |
| rare | 24% |
| epic | 34% |
| legendary | 48% |
| mythic | 62% |
| ultimate | 80% |

Skins que receberam Controle como efeito principal: `robot`, `alien_rare`, `ninja_rare`, `satellite_rare`, `blue_vortex`, `neon_spiral`, `ripple_eye`, `celestial_core`, `chrono_loop_mythic`.

Todas as skins `ultimate` recebem Controle como efeito adicional, mantendo o efeito especial anterior. O Controle funciona em fases normais, modo infinito e Liga Neon; na Liga, o rival usa apenas assistencia automatica discreta sem setas visiveis.

Checklist:

| Item | Status |
| --- | --- |
| Efeito Controle criado | Sim |
| Setas aparecem apenas com skin de Controle | Sim |
| Controle influencia direcao real | Sim |
| Controle respeita colisao/substeps | Sim |
| Forca escala por raridade | Sim |
| Todas as Ultimate tem Controle | Sim |
| Ultimates mantem efeitos existentes | Sim |
| Controle funciona em fase normal/infinito/Liga | Sim |

## 7.7 Correcoes de resultado, roleta e spawn ativo

Nesta etapa foram reforcados pontos observados no teste:

- Gameplay normal, infinito e Liga Neon agora miram 8 aneis ativos quando a fase/modo permite.
- A roleta escolhe a recompensa real antes da animacao e calcula a rotacao final para parar na fatia do tipo de premio sorteado.
- Resultado de fase, infinito/derrota e saida manual ganharam botao de dobrar recompensa por anuncio mockado.
- O dobro aplica somente o adicional de moedas/XP/diamantes e desativa o botao depois do uso.
- Saida manual exibe recompensa proporcional, salva progresso e nao mostra revive por anuncio.

Checklist:

| Item | Status |
| --- | --- |
| Spawn usa alvo minimo de 8 aneis | Sim |
| Roleta para no premio sorteado | Sim |
| Resultado pode dobrar recompensa | Sim |
| Dobro limitado a uma vez | Sim |
| Saida manual sem revive | Sim |

## 7.8 Spawn seguro e upgrades/skins sem exposição indevida

Correções desta etapa:

- O spawn dos anéis foi reforçado em `GameplayManager.gd` com cálculo de área útil central, distância mínima/máxima real da bolinha e validação de trajetória por posição atual, posição anterior e velocidade.
- `get_safe_ring_spawn_radius` retorna um estado `ok`; fases normais deixam anéis inseguros em fila e o modo infinito pula o spawn do tick quando não há candidato seguro.
- A Liga Neon recebeu gerador equivalente em `LeagueBattleScreen.gd`, com candidatos de raio próximos da bolinha, espaçamento mínimo e gap alinhado à direção prevista.
- A tela `Skins` deixa bloqueadas totalmente mascaradas: `???`, `?`, raridade/status e requisito genérico, sem asset real e sem badges de efeito real.
- A lista de filtros de Skins foi reduzida para categorias únicas, sem duplicar `Obtidas`.
- A tela `Melhorias` usa os upgrades permanentes do `GameState` e mantém os upgrades temporários de `MainPortData.RUN_UPGRADES` internos para level-up.
- A seleção de level-up já consulta `GameState.data.unlocked_upgrades`, requisitos e limite máximo antes de montar opções temporárias.

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

## 7.9 Correções de travamento, gap e upgrades temporários

Correções aplicadas:

- `_update_infinite_mode` ganhou limite de tentativas e `_append_infinite_ring` passou a retornar `true/false`; quando não há raio seguro o infinito não entra mais em loop infinito.
- O infinito tenta ativar anéis em fila antes de anexar novos anéis, mantendo o gerador seguro sem congelar o navegador.
- `_segment_contact_for_radius` centraliza o contato usado por `_check_perfect_escape` e `_check_ring_collision`, reduzindo casos em que o visual do gap e a colisão discordam.
- A margem da abertura foi reduzida; o clear agora também aceita a bolinha dentro da faixa do anel quando ela está no centro do gap.
- `_get_safe_upgrade_options` agora valida requisitos reais dos upgrades temporários e não exibe opções secretas/bloqueadas/sem efeito/fora do nível.
- `_select_level_up_upgrade` recusa seleção se o id não estiver nas opções válidas atuais.
- `ringRepulse` deixou de disparar em todo impacto; agora usa chance por nível e cooldown, e o efeito fica dentro da área útil dos anéis.

Checklist:

| Item | Status |
| --- | --- |
| Infinito inicia sem travar ao falhar spawn seguro | Sim |
| Loop de spawn do infinito tem limite de tentativas | Sim |
| Gap e hit usam o mesmo contato de colisão | Sim |
| Clear pela abertura ficou mais confiável | Sim |
| Upgrades bloqueados não aparecem no level-up | Sim |
| Upgrades sem dados válidos não aparecem no level-up | Sim |
| Ring Repulse com chance/cooldown | Sim |
| Ring Repulse não empurra além da área útil | Sim |

## 7.10 Temporárias reais e alcance do modo infinito

Correções aplicadas:

- O conjunto auto-liberado de upgrades temporários foi fechado em 6 ids: `damage`, `speed`, `coinBoost`, `critical`, `xpBoost` e `perfectChance`.
- `GameState.refresh_unlocks` não libera mais upgrades temporários internos só por `unlockLevel`; extras precisam estar explicitamente desbloqueados.
- Saves antigos com temporárias internas extras são limpos durante `refresh_unlocks`, mantendo permanentes, temporários-base válidos e temporários explicitamente liberados.
- O level-up usa `MainPortData.released_run_upgrades()` como banco não secreto, mas só mostra o que `GameState` considera desbloqueado e válido.
- O modo infinito reduziu `MAX_SPAWN_DISTANCE_FROM_BALL` e usa `_keep_infinite_rings_in_reach()` para manter anéis ativos perto da distância radial da bolinha.
- `_infinite_ring_capacity()` limita a quantidade alvo ao que cabe na área útil com espaçamento seguro, evitando empurrar anéis para fora do alcance.

Checklist:

| Item | Status |
| --- | --- |
| Temporárias auto-liberadas limitadas a 6 | Sim |
| Tela de melhorias conta liberadas reais | Sim |
| Level-up mostra temporárias desbloqueadas conforme progresso/recompensa | Sim |
| Temporárias internas extras continuam no banco de dados | Sim |
| Infinito mantém anéis ativos no alcance da bolinha | Sim |
| Infinito respeita capacidade real da arena útil | Sim |

## 7.11 Correções de navegação, sorteio e gap infinito

Correções aplicadas:

- O aviso de conquistas pendentes do menu principal chama a cena de conquistas diretamente, inclusive em toque mobile.
- `MainPortData.gd` separa os 6 temporários auto-liberados dos demais upgrades temporários não secretos.
- `GameState.gd` limpa desbloqueios temporários indevidos de saves antigos e mantém uma lista de temporários explicitamente liberados por recompensas futuras.
- `GameplayManager.gd` aceita temporários explicitamente liberados no level-up mesmo quando eles não pertencem ao conjunto auto-liberado.
- O sorteio de level-up agora pode repetir opções aleatórias quando há poucos upgrades disponíveis e usa cards menores em modal maior.
- Anéis do modo infinito recebem abertura aleatória no nascimento; o reposicionamento radial não altera mais a direção do gap.
- A bolinha é clampada novamente depois do tratamento de colisão para impedir fuga da arena em situações rápidas.

Checklist:

| Item | Status |
| --- | --- |
| Clique/toque no aviso de conquistas navega corretamente | Sim |
| Upgrades temporários bloqueados de saves antigos são removidos | Sim |
| Novos temporários liberados por recompensa podem aparecer | Sim |
| Level-up sempre tenta preencher cards visíveis | Sim |
| Level-up permite repetição aleatória | Sim |
| Infinito não alinha vários gaps no mesmo lado | Sim |
| Bolinha é mantida dentro da arena após colisão | Sim |

## 7.12 Ajustes de justiça de gameplay

Correções aplicadas:

- O botão/aviso de recompensas pendentes do menu principal foi convertido em overlay persistente e clicável, direcionando para a tela de conquistas.
- `UpgradesScreen.gd` repara os desbloqueios permanentes disponíveis antes de renderizar, então os cards de upgrade permanente não desaparecem por save antigo.
- `GameState.refresh_unlocks` libera sempre os 6 temporários-base usados no level-up; temporários extras continuam dependendo de desbloqueio explícito.
- A área jogável foi ampliada reduzindo margem, aumentando o fator de raio útil e baixando um pouco o topo reservado ao HUD.
- O infinito começa sem anel sólido obrigatório e a leva inicial também usa gaps aleatórios.
- O gerador infinito passa a usar menos anéis simultâneos no começo, maior espaçamento e fechamento mais gradual.
- Reposicionamento de anéis do infinito agora é gradual, com graça temporária de derrota quando o raio é ajustado.
- `_clamp_ring_spacing` foi refeito para ordenar por raio real antes de aplicar espaçamento, evitando que um anel novo empurre outro de forma injusta.
- A derrota por esmagamento agora exige contato contínuo por uma pequena janela, reduzindo perdas instantâneas por spawn/fechamento.

Checklist:

| Item | Status |
| --- | --- |
| Recompensas pendentes abrem conquistas | Sim |
| Permanentes disponíveis aparecem para compra/upgrade | Sim |
| Level-up sorteia os 6 temporários-base desbloqueados | Sim |
| Infinito com mais espaço útil | Sim |
| Infinito sem sólido inicial obrigatório | Sim |
| Anéis novos têm janela de segurança | Sim |
| Perda por esmagamento exige confirmação curta | Sim |
| Espaçamento corrigido por raio | Sim |
## Atualizacao - Liga Neon visual

A Liga Neon deixou de usar a gameplay custom de duas arenas criada no port Godot. A tela atual foi refeita como ranking/progresso visual baseado em `frontend/app/league.tsx`, preservando o botao no menu principal e preparando a competicao para ser reimplementada fielmente em outra etapa.

## Atualizacao - Evento Codex, Boss visual e mobile

Correcoes aplicadas:

- O evento semanal foi implementado como `Evento Codex Neon` dentro da aba Eventos, com duracao de uma semana baseada no relogio interno.
- O evento usa progresso real de fases concluidas, melhor tempo do Modo Infinito e vitorias na Liga Neon.
- As recompensas do evento sao aplicadas pelo `GameState`: moedas, diamantes, bau raro e a skin `infinite_vortex_mythic` como premio final.
- A tela de Boss foi portada visualmente da main, usando referencia de `frontend/app/boss.tsx` e `frontend/src/game/boss.ts`, mas sem gameplay de Boss ainda.
- A Liga Neon voltou a ter reroll no level-up: video mockado ou diamantes, com limite de 3 rerolls por luta.
- O reroll consulta apenas upgrades temporarios desbloqueados no save, mantendo bloqueados fora das opcoes.
- Configuracoes separa mute de musicas e mute de efeitos sonoros.
- Telas de listas receberam ajustes de margem, safe area e scroll por toque para mobile.

Checklist:

| Item | Status |
| --- | --- |
| Evento Codex dentro da aba Eventos | Sim |
| Evento dura uma semana | Sim |
| Evento usa relogio interno | Sim |
| Evento entrega recompensas reais | Sim |
| Evento entrega skin final | Sim |
| Boss visual portado da main | Sim |
| Boss gameplay pendente | Sim |
| Reroll da Liga por video mockado | Sim |
| Reroll da Liga por diamantes | Sim |
| Limite de 3 rerolls por luta | Sim |
| Reroll respeita upgrades bloqueados | Sim |
| Mute separado de musicas/SFX | Sim |
| Scroll mobile revisado | Sim |

## Atualizacao - Boss funcional, update seguro e aneis fechando

Correcoes aplicadas:

- Boss deixou de ser apenas interface visual: `Boss.tscn` inicia `LeagueBattle.tscn` com `pending_boss_battle`, usando duas arenas como a Liga Neon.
- Cada dificuldade do Boss e marcada em `GameState.data.boss.daily_attempts` pela chave de dia local, permitindo uma tentativa diaria por dificuldade.
- Recompensas do Boss sao aplicadas por `GameState.record_boss_match`, com moedas/XP sempre e premios de diamantes/chaves/baus conforme dificuldade.
- `SaveManager` mantem `user://neon_idle_escape_save.json` e backup `user://neon_idle_escape_save_backup.json`; o package Android segue `com.dmartef.neonidleescape`, entao update assinado por cima preserva dados.
- `GameState._sanitize_persistent_unlocks` valida upgrades e skins no carregamento, removendo ids invalidos/duplicados e garantindo skin equipada valida.
- Conquistas agora possuem acao de coleta em massa por `GameState.claim_all_achievements`, marcando apenas conquistas completas e nao coletadas.
- Moedas por hit foram aumentadas nas fases/infinito e tambem em Liga/Boss, mantendo a conversao global de recompensa final.
- A barreira invisivel das fases foi removida do fechamento: `_clamp_ring_spacing` agora permite que aneis fechem ate `min_radius` real do anel, enquanto o spawn ainda usa area jogavel segura.
- A derrota por esmagamento continua baseada em colisao real fora do gap e contato confirmado por `CRUSH_CONFIRM_MSEC`.
- SFX de hit nao recebe mais camada extra de XP/level-up no mesmo evento: impacto normal usa `hit_light`, critico usa `hit_heavy`, quebra usa `ring_break` e perfect/clear usa `perfect`.

Checklist:

| Item | Status |
| --- | --- |
| Boss batalha visualmente como Liga | Sim |
| Boss usa limite diario por dificuldade | Sim |
| Save preserva dados em update do APK | Sim |
| Save possui backup local | Sim |
| Desbloqueios de upgrades/skins sanitizados | Sim |
| Coletar todas conquistas | Sim |
| Moedas por hit melhoradas | Sim |
| Aneis fecham sobre a bolinha nas fases | Sim |
| Derrota por fechamento segue validacao real | Sim |
| SFX hit light/heavy sem som duplo de XP | Sim |

## Atualizacao - Upgrades desbloqueaveis por conquistas reais

Correcoes aplicadas:

- Foi criada uma trilha de conquistas para liberar todos os upgrades temporarios definidos no port.
- Os upgrades-base continuam disponiveis desde o inicio; os demais entram em `explicit_unlocked_run_upgrades` somente ao coletar a conquista que entrega o upgrade.
- A selecao de level-up de fases, Modo Infinito, Liga Neon e Boss consulta o mesmo pool desbloqueado do `GameState`, impedindo upgrade bloqueado aparecer por engano.
- Upgrades secretos ficam escondidos na tela de Melhorias ate serem liberados por conquista.
- Boss atualiza metricas de vitoria por dificuldade (`bossNormalWins`, `bossStrongWins`, `bossEliteWins`, `bossLegendaryWins`, `bossImpossibleWins`) e isso alimenta conquistas/desbloqueios.
- Liga atualiza metricas por rank alcancado (`leagueSilverReached`, `leagueGoldReached`, `leagueDiamondReached`, `leagueLegendaryReached`, `leagueUltimateReached`).
- Modo Infinito usa `infinite_elapsed` para HUD, resultado e `bestInfiniteSeconds`, garantindo conquistas de tempo coerentes.
- O HUD do Modo Infinito agora tem um badge visual `TEMPO mm:ss`.
- Boss/Liga continuam mostrando controle por setas apenas quando a skin equipada tem suporte de controle.

Desbloqueios principais:

| Origem | Upgrades liberados |
| --- | --- |
| Fases | `burn`, `ricochet`, `laser`, `lastShield`, `royalBreaker` |
| Modo Infinito | `frost`, `chainLightning`, `slowField`, `chainBreak`, `chronoBreak` |
| Boss | `shockwave`, `bomb`, `laserCut`, `shieldPulse`, `timeFreeze`, `bossHunter` |
| Liga Neon | `ringRepulse`, `multihit`, `criticalOverload`, `trophyInstinct`, `rivalCrusher` |
| Progresso geral | `magnetCoins`, `bounce`, `penetration`, `voidPulse`, `diamondInstinct`, `comboOverdrive`, `secretMagnet` |

Checklist:

| Item | Status |
| --- | --- |
| Todos os temporarios do port possuem conquista de unlock | Sim |
| Coletar conquista libera upgrade no save | Sim |
| Level-up respeita desbloqueio real | Sim |
| Boss alimenta conquistas/desbloqueios | Sim |
| Liga alimenta conquistas/desbloqueios | Sim |
| Tempo do infinito contabiliza conquistas | Sim |
| Timer visual no infinito | Sim |

## Atualizacao - Consistencia de upgrades e bonus de Perfect

Correcoes aplicadas:

- O bonus de Perfect Escape foi aumentado e agora concede gold/moedas de partida e XP de partida de forma perceptivel.
- Fases e Modo Infinito mostram feedback visual do bonus de perfect com valores de `GOLD` e `XP`.
- Liga Neon e Boss tambem recebem bonus de moedas/XP ao passar pelo gap corretamente.
- `GameState.available_run_upgrade_ids()` e `GameState.available_run_upgrades()` viraram a fonte unica de temporarias liberadas.
- A tela `Upgrades/Melhorias`, o level-up das fases/infinito e o level-up da Liga/Boss usam a mesma fonte, entao o que esta visivel como liberado e o que pode aparecer na partida ficam sincronizados.
- A notificacao de recompensas pendentes no menu principal passou a ter auto-ocultamento por tempo via `_process`.
- Foram adicionadas conquistas extras de Liga/Boss com moedas, diamantes, bau raro, chave lendaria e bau epico.

Checklist:

| Item | Status |
| --- | --- |
| Perfect gera gold/moedas extras | Sim |
| Perfect gera XP extra | Sim |
| Pool de temporarias unificado | Sim |
| Tela Melhorias mostra temporarias liberadas | Sim |
| Level-up respeita exatamente temporarias liberadas | Sim |
| Notificacao de rewards some apos alguns segundos | Sim |
| Conquistas extras de Liga/Boss | Sim |

## Atualizacao - Skins, drops e Controle

A colecao agora tem 145 skins no total e todas as ultimates habilitam Controle automaticamente. Skins miticas selecionadas tambem podem ter Controle via metadados de efeito.

Drops:
- Bau comum: common com chance alta e rare baixa.
- Bau raro: common/rare/epic com rare dominante.
- Bau epico: rare/epic/legendary com epic dominante.
- Bau lendario: epic/legendary/mythic/ultimate com ultimate muito baixa.
- Roleta: common/rare/epic semanal, legendary mensal e chance baixa de mythic mensal.

Conquistas:
- Novas recompensas de skins foram vinculadas a perfects, fases, combo, tempo no infinito e Liga Neon.
- Skins duplicadas continuam sendo convertidas em diamantes por `GameState.apply_reward()`.

## Atualizacao - Tutorial inicial

O menu principal ganhou um tutorial inicial curto com 5 telas: Welcome, Progress, Upgrades, Skins e Modes. O tutorial aparece apenas quando `GameState.should_show_tutorial()` retorna verdadeiro e salva o estado em `tutorial.seen` / `tutorial.dont_show_again` no save local.

As dicas de primeira experiencia usam progresso real do jogador:
- Fase 1 concluida: dica para Melhorias.
- Primeira melhoria comprada: dica para Skins.
- Primeira skin equipada: dica sobre Eventos, Desafios e Modo Infinito.

As dicas sao discretas, clicaveis, nao bloqueiam a tela inicial e sao marcadas como concluidas por `GameState.mark_guided_hint_done()`.

## Atualizacao - Impacto e satisfacao ao quebrar aneis

Melhorias aplicadas em `GameplayManager.gd`:

- Perfect Escape agora gera flash neon circular no raio do anel, particulas na cor do anel e brilho branco curto.
- Quebra de anel gera flash no anel, particulas neon, texto `QUEBRA!`, recompensas flutuantes de moedas/XP e screen shake leve.
- Critico gera texto `CRITICO`, particulas douradas, flash menor e shake um pouco mais forte.
- Diamante ganho em Perfect gera particulas roxas e texto `+1 DIAMANTE`.
- Combo continua usando a janela existente e exibe `Combo xN` sem criar spam excessivo.
- Screen shake afeta somente a arena jogavel, sem deslocar HUD, overlays ou botoes.
- Haptic/vibracao esta preparado para Android com `Input.vibrate_handheld()` quando o build roda em Android.

Melhorias aplicadas em `LeagueBattleScreen.gd`:

- Liga Neon e Boss usam o mesmo padrao visual: bursts neon, pontos radiais, textos flutuantes de moedas/XP, `PERFECT`, `CRITICO`, `QUEBRA!` e diamante.
- Cada arena competitiva tem shake proprio, entao o impacto do jogador nao desloca a arena do rival/boss de forma confusa.
- Boss usa intensidade um pouco maior em perfect/quebra para reforcar impacto sem exagerar.

SFX usados:

| Evento | SFX |
| --- | --- |
| Hit normal | `hit_light.mp3` |
| Critico | `hit_heavy.mp3` |
| Quebra/clear por dano | `ring_break.mp3` |
| Perfect/passagem correta | `perfect.mp3` |
| Diamante | `diamond_gain.mp3` |
| Level up/revive/vitoria | SFX ja existentes do modo |

Performance:

- Particulas da arena principal continuam em array desenhado no `_draw`, com limite de 90 particulas.
- Textos flutuantes foram limitados a 16 na arena principal e 10 por arena competitiva.
- Flashes de anel sao dados leves desenhados por `draw_arc`, limitados a 8.
- Liga/Boss usam bursts desenhados no canvas, sem instanciar novos nodes por impacto.
- Nenhum SFX novo foi duplicado; os sons continuam disparados somente nos eventos corretos.

Checklist:

| Item | Status |
| --- | --- |
| Particulas ao quebrar anel | Sim |
| Flash neon | Sim |
| Screen shake leve | Sim |
| Texto flutuante de recompensa | Sim |
| Perfect visual | Sim |
| Critical visual | Sim |
| Diamond visual | Sim |
| Combo visual | Sim |
| Funciona em fases | Sim |
| Funciona no infinito | Sim |
| Funciona no boss | Sim |
| Funciona na Liga Neon | Sim |
| Mantem performance | Sim |
