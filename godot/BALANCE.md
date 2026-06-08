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

Os primeiros upgrades custam 70-135 moedas, entao a primeira sessao deve liberar compras rapidamente. Custos agora usam crescimento por raridade entre `1.12` e `1.21`, com taxa por progresso do cap. Isso permite upgrades basicos chegarem ao nivel 40-50 sem explodir o custo no meio do caminho.

## Upgrades Permanentes

| Upgrade | Custo inicial | Max permanente | Max durante run | Desbloqueio |
| --- | ---: | ---: | ---: | --- |
| Dano base / damage | 104 | 50 | 70 | Fase 1 / nivel 1 |
| Velocidade / speed | 104 | 40 | 60 | Fase 1 / nivel 1 |
| Ganho de moeda / coinBoost | 104 | 50 | 70 | Fase 1 / nivel 1 |
| Critico / critical | 104 | 40 | 60 | Fase 1 / nivel 1 |
| XP Boost | 152 | 45 | 65 | Fase 3 / nivel 3 |
| Perfect Chance | 200 | 30 | 45 | Fase 5 / nivel 5 |
| Magnet Coins | 224 | 35 | 50 | Fase 6 / nivel 6 |
| Ricochete / Repulse / Fire / Poison | variavel | 25-30 | +12 a +15 niveis temporarios | Fases 5-8 / conquistas |
| Gelo e efeitos epicos | variavel | 20-30 | +8 a +12 niveis temporarios | Fases 8-15 / conquistas |
| Lendarios e secretos | alto | 5-18 | +2 a +8 niveis temporarios | Boss, Liga, infinito, conquistas |

Upgrade bloqueado fica escondido da lista de upavel. Quando uma conquista/fase/rank/boss libera o upgrade, ele aparece nas melhorias permanentes e automaticamente tambem entra na pool temporaria da gameplay.

Regra nova:
- O nivel permanente e a base da partida.
- O upgrade temporario da gameplay soma por cima desse nivel, mas apenas durante a run.
- Exemplo: Dano permanente 30 aparece na escolha de gameplay como `Lv.30 > Lv.31`.
- Se Dano permanente chegar ao maximo 50, a gameplay ainda pode subir temporariamente ate `Lv.70`.
- Os efeitos usam curva de retorno decrescente e caps por tipo. Dano, moeda, XP e velocidade escalam mais; gelo, repulse, time freeze, escudos e efeitos lendarios tem caps menores.

## Upgrades Temporarios

So aparecem os upgrades realmente liberados em `GameState.available_run_upgrades()`. A pool inicial segue a main: dano, velocidade, moedas e critico. Quando XP, perfect, gelo, fogo ou qualquer outro upgrade e liberado, a tela de Melhorias e a selecao de level-up usam a mesma fonte de verdade.

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

## Recompensas AFK/Offline

Janela:
- Minimo para aparecer: 5 minutos offline.
- Cap padrao: 8 horas.
- Eventos futuros podem aumentar o cap com `afk_limit`, limitado internamente a 12 horas.

Formula:
- `coins_per_minute = 4.0 + level * 0.85 + max_phase * 0.22`
- `xp_per_minute = 1.6 + level * 0.34 + max_phase * 0.09`
- Moedas usam multiplicadores moderados de `coinBoost`, `secretMagnet`, skin equipada e evento ativo.
- XP usa multiplicadores moderados de `xpBoost`, skin equipada e evento ativo.

Extras:
- Diamantes: chance baixa a partir de 30 minutos.
- Chaves: chance baixa a partir de 2 horas.
- Bau comum/rare: chance baixa a partir de 4 horas.

Protecoes:
- Tempo negativo nao gera recompensa.
- Tempo acima do cap e truncado.
- Coleta limpa `pending_afk_rewards` e atualiza `last_exit_at`.
- Dobro por anuncio so acontece quando o callback mockado retorna sucesso.

Checklist:
- AFK minimo 5 min: sim
- Cap 8h: sim
- Moedas e XP balanceados: sim
- Diamantes raros: sim
- Chave/bau apenas tempo longo: sim
- Dobrar com anuncio mockado: sim

## Conquistas de Skins e Colecao

As conquistas de colecao usam o banco real de skins em `MainPortData.SKINS`, entao os totais por raridade/efeito acompanham a colecao atual do projeto.

Metas de total:
- 5 skins: moedas iniciais.
- 10 skins: diamantes.
- 25 skins: chaves.
- 50 skins: diamantes altos.
- 75 skins: bau epico.
- 100 skins: skin especial.
- Todas as skins disponiveis: skin ultimate especial.

Metas por raridade:
- Common: 10, 20 e todas.
- Rare: 10, 20 e todas.
- Epic: 5, 15 e todas.
- Legendary: 3, 10 e todas.
- Mythic: 1, 5 e 10.
- Ultimate: 1, 3 e 5.

Metas por efeito:
- Control: 3 skins.
- Fire, Ice, Critical, Coins, XP, Speed, Chain e Area: 5 skins.
- Phase e Gravity: 3 skins.

Metas de evolucao:
- Uma skin no nivel 2.
- Uma skin no nivel maximo.
- 5 e 10 skins evoluidas.
- Uma skin maximizada por raridade.

Metas de uso:
- 10 vitorias de fase com common, rare e epic.
- 5 minutos no infinito com Control.
- Boss vencido com Fire.
- Liga Neon vencida com Ultimate.
- 50 perfects com Ice ou Control.
- 1000 aneis com Legendary ou superior.

Balanceamento:
- Recompensas baixas usam moedas/diamantes para acelerar o inicio.
- Recompensas medias usam chaves e baus para incentivar retorno.
- Recompensas altas podem dar skins especiais, mantendo duplicatas protegidas pela conversao de `apply_reward()`.
- As metas de uso exigem modos diferentes para valorizar skins sem transformar colecao em requisito obrigatorio de progressao.

Checklist:
- Conquistas por total de skins: sim
- Conquistas por raridade: sim
- Conquistas por efeito: sim
- Conquistas por evolucao: sim
- Conquistas por uso em modos: sim
- Recompensas balanceadas por marco: sim

## Passe Neon

Estrutura:
- 3 temporadas planejadas.
- 40 niveis por temporada.
- 4 semanas por temporada.
- 10 niveis liberados por semana.

Temporadas:
- `neon_pass_s1`: Neon Awakening / Despertar Neon.
- `neon_pass_s2`: Circuit Break / Ruptura de Circuito.
- `neon_pass_s3`: Cosmic Pulse / Pulso Cosmico.

XP por nivel:
- Niveis 1-10: 100 XP por nivel.
- Niveis 11-20: 150 XP por nivel.
- Niveis 21-30: 220 XP por nivel.
- Niveis 31-40: 300 XP por nivel.

XP por fonte:
- Participar de fase normal: 20 XP.
- Vencer fase normal: +50 XP.
- Modo infinito jogado: 20 XP base.
- Modo infinito por tempo/aneis: 10 XP por minuto + 2 XP por anel, limitado a 120 XP extras.
- Boss tentativa: 40 XP.
- Boss vitoria: +100 XP.
- Liga Neon batalha: 40 XP.
- Liga Neon vitoria: +80 XP.
- Desafio diario: 60 XP.
- Evento semanal: 75 XP por tarefa, 150 XP no premio final.
- Primeira vitoria do dia: +100 XP.

Limite semanal:
- Semana 1: maximo nivel 10.
- Semana 2: maximo nivel 20.
- Semana 3: maximo nivel 30.
- Semana 4: maximo nivel 40.
- Quando o cap e atingido, XP extra do Passe nao acumula acima do limite. Isso evita overflow e exploits enquanto as recompensas detalhadas ainda nao existem.

Save:
- O Passe usa campos `neon_pass_*` no save principal.
- `neon_pass_season_progress` guarda um snapshot por temporada.
- Migracoes de save antigo criam o Passe com nivel 1, XP 0 e temporada atual.

Checklist:
- 3 temporadas cadastradas: sim
- 40 niveis por temporada: sim
- Limite de 10 niveis por semana: sim
- XP separado do XP normal: sim
- Fontes de XP conectadas: sim
- Save documentado: sim

## Passe Neon - Recompensas

Distribuicao:
- Niveis 1-10: moedas, XP, chaves, baus comuns/raros leves, diamantes pequenos e primeira skin exclusiva no nivel 10.
- Niveis 11-20: moedas maiores, XP maior, diamantes, baus raros e marco de bau raro no nivel 20.
- Niveis 21-30: chaves, fragmentos, diamantes maiores, baus raros/epicos e bau epico no nivel 30.
- Niveis 31-40: chave lendaria, bau epico/lendario, diamantes altos e skin final da temporada no nivel 40.

Skins exclusivas:
- S1 nivel 10: `neon_pass_initial`, rara, bonus de moedas.
- S1 nivel 40: `neon_pass_guardian`, lendaria, repulsao leve e controle.
- S2 nivel 10: `weekly_circuit`, epica, corrente e velocidade.
- S2 nivel 40: `neon_commander`, lendaria, moedas, critico e controle.
- S3 nivel 10: `pass_avatar`, mitica, XP e controle.
- S3 nivel 40: `neon_sovereign`, mitica, area e controle.

Regras de coleta:
- Recompensa so pode ser coletada se o nivel foi alcancado.
- Cada recompensa e coletada apenas uma vez por temporada.
- `Claim All` soma todas as recompensas disponiveis e usa a mesma conversao de duplicatas de skins.
- Ultimate nao entra no Passe atual; deve ficar para evento especial, conquista extrema ou temporada futura.

Save:
- `neon_pass_claimed_rewards` guarda ids coletados por temporada.
- Historico curto fica em `neon_pass_reward_history`.

Checklist:
- 40 recompensas por temporada: sim
- 3 temporadas com recompensas: sim
- Skins exclusivas sem Ultimate facil: sim
- Baús comuns/raros/epicos/lendarios distribuidos: sim
- Claim individual/Claim All balanceados: sim

## Primeira Vitoria do Dia

Regra:
- O jogador recebe o bonus uma vez por dia ao vencer um modo elegivel.
- O reset usa o dia local salvo por `TimeManager.get_day_key()`.
- O bonus e separado do streak da Recompensa Diaria.

Modos elegiveis:
- Vitoria em fase normal.
- Resultado valido no modo infinito.
- Vitoria contra Boss.
- Vitoria na Liga Neon.
- Desafio diario concluido.

Formula inicial:
- Moedas: `260 + nivel_do_jogador * 55`.
- XP normal: `120 + nivel_do_jogador * 22`.
- XP do Passe Neon: `+100`.
- Diamantes: 1 base, +1 no nivel 10, +1 no nivel 25.
- Chave: 10% de chance, 16% a partir do nivel 20.

Protecoes:
- `first_win_claimed_date` impede duplicacao no mesmo dia.
- `last_first_win_reward` guarda a recompensa exibida/recebida.
- Saves antigos com `neon_pass_last_first_win_day_key` sao tratados para evitar receber o bonus duas vezes no dia da migracao.

Checklist:
- Balanceamento inicial definido: sim
- XP do Passe integrado: sim
- Chance baixa de chave: sim
- Recompensa escala com nivel: sim
- Duplicacao protegida: sim
