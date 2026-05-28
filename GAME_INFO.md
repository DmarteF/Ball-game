# 🎮 NEON IDLE ESCAPE - Jogo Mobile Arcade

## 📱 Sobre o Jogo

Neon Idle Escape é um jogo mobile idle incremental arcade com visual neon futurista minimalista. O jogador controla uma bolinha energética que quica automaticamente dentro de arenas geométricas, causando dano, ganhando moedas, XP e evoluindo constantemente.

## ✨ Recursos Implementados (MVP)

### 🎯 Gameplay Core
- ✅ Física customizada da bolinha com rebote automático
- ✅ Sistema de dano com crítico (5% de chance de 2x dano)
- ✅ Ganho automático de moedas e XP
- ✅ Sistema de level up durante a partida
- ✅ Controles de pausa e sair

### 🗺️ Sistema de Fases (5 Fases)
1. **Arena Circular Neon** - Fácil (HP: 100) - Cor: Ciano
2. **Labirinto Hexagonal** - Médio (HP: 250) - Cor: Roxo
3. **Núcleo Tecnológico** - Médio-Difícil (HP: 500) - Cor: Verde
4. **Dimensão Glitch** - Difícil (HP: 1000) - Cor: Vermelho
5. **Reactor Cósmico** - Muito Difícil (HP: 2000) - Cor: Dourado

### ⬆️ Sistema de Upgrades
**Upgrades Temporários (Durante a Partida):**
- +10% Dano
- +15% Velocidade
- +100 Moedas extras

**Upgrades Permanentes (Loja):**
- Dano Base (+10% por nível)
- Velocidade (+8% por nível)
- Chance Crítica (+2% por nível)
- Multiplicador de Moedas (+15% por nível)
- XP Boost (+20% por nível)
- Moedas Iniciais (+50 por nível)

### 🎨 Transformações da Bolinha (10)
1. Neon Azul (Desbloqueada)
2. Plasma Roxo (500 gemas)
3. Infernal Vermelho (1000 gemas)
4. Elétrica (1500 gemas)
5. Glitch (2000 gemas)
6. Dourada (3000 gemas)
7. Cristalina (3500 gemas)
8. Sombria (4000 gemas)
9. Radioativa (5000 gemas)
10. Cósmica (10000 gemas)

### 💎 Sistema de Economia
- Moedas (ganho durante gameplay)
- Gemas (moeda premium)
- Sistema de save local persistente

### 🎨 Visual e UI
- Design neon futurista minimalista
- Gradientes e efeitos de glow
- Interface limpa e moderna
- Animações suaves
- Feedback visual forte

## 🛠️ Tecnologias Utilizadas

### Frontend
- **Expo** (React Native)
- **expo-router** - Navegação file-based
- **expo-linear-gradient** - Gradientes neon
- **react-native-reanimated** - Animações performáticas
- **axios** - Comunicação com API
- **TypeScript** - Type safety

### Backend
- **FastAPI** - API REST rápida e moderna
- **MongoDB** - Banco de dados NoSQL
- **Motor** - Driver async para MongoDB
- **Pydantic** - Validação de dados

## 📂 Estrutura do Projeto

```
/app
├── backend/
│   ├── server.py          # API FastAPI completa
│   └── requirements.txt   # Dependências Python
│
└── frontend/
    ├── app/
    │   ├── index.tsx              # Tela inicial
    │   ├── phase-select.tsx       # Seleção de fases
    │   ├── game.tsx               # Tela de gameplay
    │   ├── upgrade-shop.tsx       # Loja de upgrades
    │   └── transformations.tsx    # Transformações
    ├── babel.config.js
    └── package.json
```

## 🚀 Endpoints da API

### Player
- `POST /api/player/create` - Criar jogador
- `GET /api/player/{player_id}` - Buscar jogador
- `PUT /api/player/{player_id}/update` - Atualizar jogador
- `POST /api/player/{player_id}/unlock-phase` - Desbloquear fase
- `POST /api/player/{player_id}/purchase-upgrade` - Comprar upgrade

### Game
- `GET /api/phases` - Listar fases
- `POST /api/session/start` - Iniciar sessão de jogo
- `PUT /api/session/{session_id}/update` - Atualizar sessão

### Monetização
- `POST /api/ads/reward` - Sistema de anúncios (simulado)

## 🎮 Como Jogar

1. **Tela Inicial**: Escolha entre Jogar, Upgrades ou Transformações
2. **Seleção de Fases**: Escolha uma fase desbloqueada
3. **Gameplay**: 
   - A bolinha se move automaticamente
   - Cada colisão causa dano e ganha moedas/XP
   - Ao subir de nível, escolha um upgrade
   - Derrote todos os alvos para vencer
4. **Upgrades**: Use moedas para melhorar estatísticas permanentes
5. **Transformações**: Use gemas para desbloquear visuais da bolinha

## 📊 Mecânicas de Progressão

### Sistema de Dano
- Dano base: 10
- Chance de crítico: 5% (2x dano)
- Moedas ganhas: Dano / 2
- XP ganho: Igual ao dano causado

### Level Up
- XP necessário: Level × 100
- A cada level: escolha 1 de 3 upgrades aleatórios
- Upgrades acumulam durante a partida

### Desbloqueio de Fases
- Fases desbloqueiam ao completar a anterior
- Dificuldade e HP aumentam progressivamente

## 🎯 Próximas Funcionalidades (Futuras)

### Visual e Efeitos
- [ ] Partículas avançadas
- [ ] Trail da bolinha
- [ ] Efeitos de impacto
- [ ] Screen shake
- [ ] Animações de números flutuantes

### Efeitos Especiais (10+)
- [ ] Choque elétrico
- [ ] Explosão
- [ ] Fogo
- [ ] Gelo
- [ ] Veneno
- [ ] Laser
- [ ] Onda de energia
- [ ] Fragmentação
- [ ] Dano em área
- [ ] Pulso gravitacional

### Sistema de Anúncios Real
- [ ] Integração AdMob Rewarded Ads
- [ ] Integração AdMob Interstitial Ads
- [ ] Dobrar recompensas
- [ ] Revive com anúncio
- [ ] Baú grátis com anúncio

### Áudio
- [ ] Sons de impacto
- [ ] Sons de level up
- [ ] Sons de vitória/derrota
- [ ] Música de fundo
- [ ] Sons de coleta

### Gameplay Avançado
- [ ] Mais upgrades temporários (20+)
- [ ] Sistema de combos
- [ ] Multiplicadores de streak
- [ ] Obstáculos móveis nas arenas
- [ ] Padrões de movimento variados
- [ ] Boss fights

### Progressão
- [ ] Sistema de conquistas
- [ ] Recompensas diárias
- [ ] Eventos especiais
- [ ] Ranking/Leaderboard
- [ ] Sistema de prestige

## 🔧 Status do Backend

✅ **Todos os endpoints funcionando (100% de sucesso)**
- Health check
- CRUD de jogadores
- Sistema de fases
- Sessões de jogo
- Anúncios simulados
- Unlock de fases
- Compra de upgrades
- MongoDB integrado
- CORS configurado

## 📱 Telas Implementadas

✅ **Todas as telas principais funcionando:**
1. Tela inicial com menu
2. Seleção de fases (5 fases)
3. Gameplay com física da bolinha
4. HUD com stats (moedas, XP, level, HP)
5. Modal de level up com 3 upgrades
6. Loja de upgrades permanentes (6 upgrades)
7. Galeria de transformações (10 skins)

## 🎨 Paleta de Cores Neon

- **Azul Ciano**: #00f0ff (Principal)
- **Roxo**: #b000ff
- **Rosa**: #ff0055
- **Verde**: #00ff88
- **Dourado**: #ffd700
- **Background**: #0a0a1a, #1a0a2e, #16003b

## 💡 Dicas de Desenvolvimento

1. O jogo usa física customizada (não um engine pesado)
2. Reanimated para animações performáticas
3. MongoDB para persistência
4. Sistema modular e expansível
5. Preparado para monetização futura

## 🐛 Debugging

- Backend logs: `/var/log/supervisor/backend.err.log`
- Frontend logs: `/var/log/supervisor/expo.out.log`
- Metro bundler: Expo Dev Tools

## 📄 Licença

MVP - Versão 1.0.0
