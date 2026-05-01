# ⚡ LIFE RESET

**Life Reset** é um aplicativo de produtividade e rastreamento de hábitos totalmente gamificado, construído com Flutter. Com uma interface estilo *Cyber-Tech* e *Glassmorphism*, o aplicativo transforma o seu autodesenvolvimento diário em um verdadeiro RPG da vida real.

Suba de nível, ganhe XP e melhore seus "Atributos de Sistema" (como Inteligência, Físico e Carreira) completando protocolos diários.

---

## 🚀 Funcionalidades Principais

* **🕹️ Sistema de RPG e Gamificação:**
    * Ganhe **XP** ao completar sub-tarefas e suba de nível global.
    * Evolua **9 Atributos de Status**: Físico, Estamina, Inteligência, Sanidade, Saúde, Aparência, Autoestima, Carreira e Social.
* **⚙️ Protocolos Dinâmicos e Inteligentes:**
    * **Treino Híbrido:** As tarefas de treino mudam automaticamente de acordo com o dia da semana (ex: Push, Pull, Legs, Cardio).
    * **Cronograma AWS:** Injeção diária do tópico de estudo correto para a certificação Developer Associate (cronograma de 30 dias).
* **📊 Body Stats & Gráficos de Evolução:**
    * Acompanhe seu Peso, Cintura, Coxas e Peito.
    * Histórico salvo automaticamente com visualização em gráficos de linha interativos (via `fl_chart`).
* **🔄 Reset Automático:**
    * O sistema identifica a virada do dia (00:00) e reseta o checklist visual, mantendo todo o seu histórico de progresso de longo prazo intacto no banco de dados local.
* **💾 Offline First:**
    * Todos os dados, históricos e progresso são salvos diretamente no dispositivo do usuário utilizando `SharedPreferences`.

---

## 🛠️ Tecnologias Utilizadas

* **[Flutter](https://flutter.dev/):** Framework principal para desenvolvimento mobile multiplataforma.
* **[Dart](https://dart.dev/):** Linguagem de programação.
* **[SharedPreferences](https://pub.dev/packages/shared_preferences):** Para persistência de dados locais (XP, histórico de tarefas, atributos e medidas).
* **[FL Chart](https://pub.dev/packages/fl_chart):** Biblioteca para renderização dos gráficos de evolução temporal.

---

## 🎨 Identidade Visual (Cyber-Tech)

O design foi pensado para simular um "Sistema Operacional" pessoal, utilizando a seguinte paleta de cores base:
* **Background:** `#0A0A0A` (Preto Profundo)
* **Surface:** `#121212` (Cinza Escuro com opacidade para efeito Glass)
* **Accent (Verde Neon):** `#D0FF00` (Foco primário, sucesso e XP)
* **Primary (Roxo Escuro):** `#8116E0` (Elementos de contraste e atributos mentais)

---

## 📱 Como executar o projeto

Pré-requisitos: Você precisará ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado na sua máquina.

1. Clone este repositório:
   ```bash
   git clone [https://github.com/taina-coder/lifereset.git](https://github.com/taina-coder/lifereset.git)
