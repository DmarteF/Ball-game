# Neon Idle Escape - Balanceamento

Este documento registra a curva ativa de balanceamento da versao Godot. A intencao e deixar o inicio recompensador, liberar melhorias cedo e transformar as fases finais, Boss e Liga Neon em objetivos de longo prazo.

## XP por Acao

| Acao | XP de run | XP global aproximado |
| --- | ---: | ---: |
| Hit normal em anel | 17 x multiplicador | Entra no total da run |
| Hit critico | 26 x multiplicador | Entra no total da run |
| Quebrar anel normal | 20 + fase x 0.9 + variacao | Entra no total da run |
| Quebrar anel solido | 32 + fase x 0.9 + variacao | Entra no total da run |
| Perfect pelo centro/gap | 64 + fase x 1.8 + run level x 3.4 | Entra no total da run |
| Concluir fase | Bonus da tabela de fase | Direto no perfil |
| Modo infinito | Total da run x 0.66 + aneis x 7.5 + perfects x 13 | Multiplicador global 1.08 |
| Liga/Boss | Total da arena x 1.08 + recompensa do modo | Direto no perfil |

Nivel do jogador usa `130 * nivel^1.50`, para evoluir rapido no inicio e desacelerar naturalmente depois.

## Fases 1-100

| Faixa | Objetivo | Aneis totais | HP base | Ritmo | Recompensas |
| --- | --- | ---: | ---: | --- | --- |
| 1-5 | Tutorial rapido e facil | 6-12 | Baixo | Lento, gaps grandes | Moedas/XP generosos, diamantes raros |
| 6-15 | Leve/medio | 10-22 | Baixo/medio | Comeca rotacao real | Primeiros recursos, chaves/baus baixos |
| 16-30 | Medio | 20-40 | Medio | Exige upgrades e skins | Diamantes/chaves moderados |
| 31-45 | Alto | 34-58 | Alto | Pressao maior | Baus e XP melhores |
| 46-50 | Dificil | 46-70 | Alto | Marco de fase 50 | Recompensa especial e chance alta de recursos |
| 51-75 | Elite | 56-86 | Muito alto | Desafio longo | Skin/recompensa especial na fase 75 |
| 76-100 | Final | 70-106 | Final | Pressao maxima justa | Skin/recompensa especial na fase 100 |

Curva atualizada:
- A velocidade de fechamento tem teto jogavel e cresce devagar: fase 1 fica perto de `0.0076`, fase 50 perto de `0.0317` e fase 100 perto de `0.0442`.
- Fases altas ficam dificeis principalmente por HP/resistencia, total de aneis e quantidade de aneis solidos, nao por fechamento instantaneo.
- Fases normais mantem 12 aneis ativos na tela e usam fila interna para o restante. Quando um anel quebra, outro entra por fora ate acabar a fase.
- O ultimo anel de toda fase normal continua sempre solido/sem abertura.
- Aneis solidos extras sao distribuidos pela fase: fases 1-5 usam apenas o anel final solido, enquanto fases 50+ e 75+ adicionam mais solidos em pontos espalhados.

Cada fase concluida concede o ganho da run mais bonus fixo calculado por `LevelData.get_phase_config()`. As chances de drop crescem com a fase:

| Faixa | Diamante | Chave | Bau |
| --- | ---: | ---: | ---: |
| 1-5 | ate 3% | ate 1.5% | ate 1.2% |
| 6-15 | ate 5.5% | ate 3.5% | ate 3% |
| 16-30 | ate 9% | ate 7% | ate 7% |
| 31-45 | ate 13% | ate 11% | ate 12% |
| 46-50 | ate 17% | ate 15% | ate 17% |
| 51-75 | ate 22% | ate 20% | ate 22% |
| 76-100 | ate 28% | ate 26% | ate 28% |

Baus de fase escolhem tipo por progresso: comum no inicio, raro a partir do meio, epico mais comum no late game e lendario com chance baixa perto do fim.

## Moedas

| Fonte | Valor base |
| --- | ---: |
| Hit normal | dano x 0.98 |
| Quebrar anel normal | 24 |
| Quebrar anel solido | 34 |
| Perfect | 32 + run level x 2.2 + combo |
| Conversao de run para carteira | 82% com bonus de combo/vitoria |
| Missao diaria simples | 380-420 moedas ou XP/diamantes |
| Liga Neon vitoria | run + 360 moedas |
| Liga Neon derrota | run + 95 moedas |
| Boss normal | run + 520 moedas |

Os primeiros upgrades custam 70-135 moedas, entao a primeira sessao deve liberar compras rapidamente. Custos usam `base * 1.32^nivel` com uma taxa extra leve depois do nivel 10.

## Upgrades Permanentes

| Upgrade | Custo inicial | Max | Desbloqueio |
| --- | ---: | ---: | --- |
| Dano base | 70 | 40 | Fase 1 / nivel 1 |
| Velocidade base | 85 | 28 | Fase 1 / nivel 1 |
| Ganho de moeda | 120 | 34 | Fase 1 / nivel 1 |
| Critico | 110 | 28 | Fase 1 / nivel 1 |
| XP Boost | 135 | 32 | Fase 3 / nivel 3 |
| Perfect Chance | 320 | 18 | Fase 5 / nivel 5 |
| Slow Rings | 440 | 18 | Fase 8 / nivel 9 |

Upgrade bloqueado fica escondido da lista de upavel. Quando uma conquista/fase/rank/boss libera o upgrade, ele aparece nas melhorias permanentes ou na lista de melhorias temporarias, conforme o tipo.

## Upgrades Temporarios

So aparecem os upgrades realmente liberados em `GameState.available_run_upgrades()`. A pool inicial e dano, velocidade, moedas, critico, XP e perfect; efeitos avancados entram por fase, infinito, Liga Neon, Boss e conquistas.

Diretriz de poder:
- comum: ganho simples e confiavel;
- raro: melhora uma area clara, como burn/ricochet;
- epico: efeitos de arena como frost, shockwave, chain lightning;
- lendario: protecoes/efeitos de fim de run;
- ultimate: efeitos especiais atrelados a marcos altos.

## Skins

Skins comuns e raras aparecem cedo por fase, bau comum/raro e roleta. Epicas entram no meio do jogo. Lendarias, miticas e ultimates sao objetivos de conquista, evento, Boss, Liga Neon, modo infinito e baus melhores.

Skins com Controle sao balanceadas por raridade:

| Raridade | Forca de controle |
| --- | ---: |
| Comum | 13% |
| Rara | 24% |
| Epica | 34% |
| Lendaria | 48% |
| Mitica | 62% |
| Ultimate | 80% |

## Baus

Todas as skins podem sair de qualquer bau, mas raridades altas tem chances muito baixas nos baus baixos.

| Bau | Chance de skin | Peso principal | Ultimate |
| --- | ---: | --- | ---: |
| Comum | 14% | comum/rara | 0.02 no peso interno |
| Raro | 20% | rara | 0.2 no peso interno |
| Epico | 30% | epica | 0.4 no peso interno |
| Lendario | 42% | lendaria/mitica | 2.0 no peso interno |

Duplicata de skin vira diamantes para evitar recompensa morta.

## Roleta

Roleta tem moedas, diamantes, chaves, XP, baus e skins rotativas semanal/mensal. Valores base revisados:

| Recompensa | Valor |
| --- | ---: |
| Moedas baixa | 280 |
| Moedas alta | 650 |
| Diamantes baixa | 8 |
| Diamantes alta | 18 |
| XP | 250 |
| Chaves | 1 |
| Baus | comum, raro, epico |
| Skins | comum, rara, epica, lendaria e mitica ocasional |

## Recompensa Diaria

| Dia | Recompensa |
| ---: | --- |
| 1 | 300 moedas |
| 2 | 18 diamantes |
| 3 | 1 chave |
| 4 | 1 bau comum |
| 5 | 1 bau raro |
| 6 | 55 diamantes |
| 7 | 1 bau epico |

## Modo Infinito

O modo infinito escala por tempo, aneis quebrados e pressao de clears rapidos. A curva foi suavizada:

| Item | Regra |
| --- | --- |
| Nivel infinito | +1 a cada 28s, +1 a cada 14 aneis, +pressao leve |
| Aneis alvo | 12-18 |
| HP | 18 + nivel x 2.35 + pressao |
| Fechamento | comeca em 0.0062 e sobe devagar |
| Rotacao | comeca em 0.0042 e sobe devagar |
| Recompensa | moedas/XP por hit, break, perfect, tempo e recorde |

Objetivo: recompensar tempo sobrevivido e aneis quebrados sem criar aneis impossiveis cedo.

## Boss

Boss usa a mesma base visual da Liga Neon, mas com tentativa diaria por dificuldade.

| Dificuldade | XP | Recompensa | Diamantes extras |
| --- | ---: | --- | ---: |
| Normal | 160 | 520 moedas | 2 |
| Forte | 240 | 10 diamantes | 8 |
| Elite | 340 | 1 chave | 12 |
| Lendario | 480 | 1 bau raro | 18 |
| Impossivel | 680 | 1 bau epico | 28 |

Derrota concede cerca de 35% da recompensa base para nao zerar progresso, mas vitoria sempre vale mais.

## Liga Neon

| Resultado | Trofeus | Recompensa |
| --- | ---: | --- |
| Vitoria | +34 base + bonus por aneis/tempo | run + 360 moedas, +180 XP, 35% de +4 diamantes, 8% bau raro |
| Derrota | -14 base com pequeno alivio por aneis | run + 95 moedas, +65 XP |
| Quit/sair | -10 | run + 25 moedas, +12 XP |

Temporada dura um mes via `TimeManager.get_month_key()`. No reset mensal, o jogador cai uma liga. A promocao saindo do Bronze entrega a skin especial inicial da Liga.

## Missoes e Conquistas

Missoes diarias foram ajustadas para dar progresso util: XP, moedas e diamantes. Conquistas seguem 100 entradas combinando fase, infinito, Boss, Liga, skins, upgrades, baus, perfects e recursos. Marcos importantes:

- fase 50: skin ultimate `eclipse_god`;
- fase 75: skin ultimate `genesis_core`;
- fase 100: skin ultimate `prismatic_omega`;
- infinito 60s/180s/300s+ libera recompensas e upgrades;
- Liga Silver/Gold/Diamond/Legendary/Ultimate libera upgrades/skins;
- Boss normal/forte/elite/impossivel libera upgrades e baus.

## Evolucao de Skins

Cada skin desbloqueada comeca no nivel 1 e pode ser evoluida com moedas ou diamantes. Diamantes sao alternativa mais rapida, mas continuam raros.

| Raridade | Nivel maximo | Custo inicial moedas | Custo inicial diamantes | Crescimento |
| --- | ---: | ---: | ---: | ---: |
| Common | 5 | 150 | 2 | 1.82x |
| Rare | 6 | 400 | 5 | 1.68x |
| Epic | 7 | 900 | 10 | 1.55x |
| Legendary | 8 | 1800 | 20 | 1.48x |
| Mythic | 9 | 3600 | 40 | 1.42x |
| Ultimate | 10 | 8000 | 90 | 1.36x |

Formula central:
- `GameState.get_skin_upgrade_cost(rarity, current_level, currency)`.
- Moedas arredondam em blocos de 10.
- Diamantes arredondam para cima.

Escala de efeito:
- `GameState.get_skin_effect_value(skin_id, level)` retorna o efeito ja escalado.
- `GameState.apply_skin_level_scaling(base_effect, level, rarity)` aumenta chance/valor gradualmente ate o nivel maximo.
- O aumento total fica em torno de +55% para chance e +70% para valor no nivel maximo, antes dos caps.

Caps para nao desbalancear:
- critico/chance pesada: ate 35%.
- atravessar solido: ate 15%.
- bonus de diamante/perfect: ate 8%.
- slow/freeze: intensidade limitada e chance ate 34%.
- controle: maximo 78%, sempre por carga, nunca joystick livre.
- velocidade: ate 28%.
- moeda por hit: ate 34.
- multiplicador de moeda: ate 75%.
- multiplicador de XP: ate 80%.
- dano em area/corrente/queima/repulsao tem caps para evitar limpar a tela inteira sempre.

Justificativa:
- Skins comuns/raras podem ser evoluidas cedo com algumas partidas.
- Epicas/lendarias exigem progresso real.
- Miticas/ultimates sao investimento longo e cada nivel deve ser perceptivel, mas sem quebrar modos como infinito, Boss ou Liga Neon.

## Checklist

- Balanceamento das 100 fases revisado: sim
- XP revisado: sim
- Moedas revisadas: sim
- Diamantes revisados: sim
- Upgrades revisados: sim
- Skins revisadas: sim
- Baús revisados: sim
- Roleta revisada: sim
- Modo infinito revisado: sim
- Boss revisado: sim
- Liga Neon revisada: sim
- BALANCE.md criado/atualizado: sim
- Evolucao de skins balanceada: sim
- Evolucao de melhorias permanentes balanceada: sim

## Evolucao de Melhorias Permanentes

As melhorias permanentes desbloqueadas podem ser evoluidas com moedas ou diamantes. A mesma fonte (`GameState.upgrade_levels`) alimenta save, UI e calculos de gameplay.

Formula central:
- `GameState.get_upgrade_cost(upgrade_id, current_level, currency)`.
- Moedas escalam por raridade, nivel de desbloqueio e nivel atual.
- Diamantes usam o custo de moedas como base, com multiplicador por raridade para continuarem uma alternativa rapida, mas rara.

Raridade:
- Common: multiplicador 1.0.
- Rare: multiplicador 1.55.
- Epic: multiplicador 2.25.
- Legendary: multiplicador 3.25.

Escala de custo:
- Base: `80 + unlockLevel * 24`.
- Crescimento: `1.32 ^ current_level`.
- Taxa leve apos nivel 10 para upgrades longos.
- Moedas arredondam em blocos de 10.
- Diamantes arredondam para cima.

Efeitos e caps:
- dano: cap seguro para nao trivializar aneis.
- velocidade: cap para nao quebrar colisao.
- moedas: cap de multiplicador para evitar inflacao absurda.
- XP: cap de multiplicador para manter progressao.
- critico: chance limitada.
- perfect/diamante: chance baixa, diamante continua raro.
- gelo/lentidao: chance limitada, sem travar aneis para sempre.
- corrente/area/repulsao: cap para evitar limpar a tela inteira.

Funcoes:
- `get_upgrade_effect_value(upgrade_id, level)`.
- `apply_upgrade_level_scaling(upgrade_data, level)`.
- `clamp_upgrade_effect(upgrade_id, effect_value)`.

Justificativa:
- Os quatro upgrades iniciais podem ser evoluidos cedo.
- Upgrades raros/epicos/lendarios sobem mais devagar.
- Diamantes aceleram progresso, mas seguem caros o bastante para nao substituir moedas como caminho principal.
