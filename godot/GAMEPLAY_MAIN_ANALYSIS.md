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

- Fase 1 mantida como unica fase jogavel nesta etapa.
- Geracao/rotacao/gaps/colisao seguem `rings.ts` e `game.tsx`.
- HUD sem HP visivel e sem debug.
- Arena sem circulo central decorativo e sem base extra.
- Bolinha com skin real, brilho e trail.
- Recompensas de hit, break e perfect usam multiplicadores de moedas/XP.
- Combo, maior combo, score e DPS foram adicionados.
- Upgrades de rodada `ATK` e `Gold` foram adicionados no rodape.
- Modal de level-up com 3 upgrades temporarios reais foi adicionado para a Fase 1.
- HUD agora possui barra de XP e barra de progresso dos aneis, seguindo a estrutura visual da main.
- Feedbacks de moeda, XP, diamante e level-up foram reforcados com texto flutuante, particulas e SFX.
- Upgrades permanentes basicos afetam dano, velocidade, moedas, XP, critico e slow rings.
- Vitoria salva moedas globais e XP de perfil convertidos como na main.
- Tela de vitoria mostra as mesmas linhas principais da main em area rolavel para manter botoes acessiveis.
- Musica e SFX usam assets reaproveitados, respeitam audio mudo e tentam retomar musica apos toque/clique no Web sem duplicar faixa.

## Pendencias conhecidas

- Comparacao visual pixel-perfect com a branch `main` ainda nao foi feita.
- Reroll de upgrades temporarios por anuncio/gemas ainda nao foi portado.
- Catalogo completo de upgrades temporarios avancados ainda nao foi portado; a Fase 1 ja usa os upgrades iniciais da main.
- Efeitos especiais completos de todas as skins ainda nao foram portados.
- Revive por anuncio, dobrar recompensa por anuncio e coleta/sair separada ainda estao preparados apenas como estrutura.
- Chaves e baus aparecem no resumo como `0/0`, igual ao estado atual observado da gameplay base, mas drops reais ainda nao foram conectados.
- Barras visuais de XP/progresso foram adicionadas, mas ainda nao estao pixel-perfect em relacao ao React Native.

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
| XP aparecendo corretamente | Sim |
| Level up funcionando | Sim |
| Upgrade temporario aparecendo corretamente | Sim |
| Upgrades temporarios funcionam | Sim |
| Upgrades permanentes aplicados | Sim |
| Vitoria fiel a main | Em progresso |
| Tela de vitoria refeita/fiel | Em progresso |
| Recompensas salvam | Sim |
| Fase 2 libera | Sim |
