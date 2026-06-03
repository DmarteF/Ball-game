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
