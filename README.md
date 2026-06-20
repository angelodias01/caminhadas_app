# Caminhadas Odemira 🥾

O **Caminhadas Odemira** é uma aplicação móvel desenvolvida em Flutter projetada para incentivar a prática de atividade física e a exploração da natureza na região de Odemira. A aplicação monitoriza o progresso diário de passos do utilizador, converte o esforço em distância (quilómetros) e atribui pontos de mérito que podem ser trocados por cupões e recompensas em parceiros locais.

---

## ✨ Funcionalidades Principais

* **Painel de Atividade (Dashboard):** Visualização animada e fluida dos passos diários, quilómetros percorridos e pontos acumulados.
* **Trilhos & Desafios:** Listagem e filtragem de percursos pedestres da região divididos por estados (*A decorrer*, *Concluídos* e *Expirados*).
* **Loja de Recompensas:** Troca de pontos por vouchers comerciais e geração de códigos QR para validação nos estabelecimentos parceiros.
* **Histórico Consolidado:** Consulta detalhada de caminhadas passadas com filtros por Semana, Mês ou Ano.
* **Gestão de Perfil:** Atualização de dados cadastrais, alteração de avatar através da galeria e suporte nativo a **Modo Escuro**.

---

## 🛠️ Tecnologias Utilizadas

* **Framework:** [Flutter](https://flutter.dev) (v3.x ou superior)
* **Linguagem:** [Dart](https://dart.dev)
* **Persistência Local:** `shared_preferences` para o estado do tema visual.
* **Multimédia:** `image_picker` para captura/seleção de fotos de perfil.
* **Estilização:** Palete moderna baseada em Material Design 3 (Índigo e Âmbar).

---

## 📂 Estrutura do Código (`lib/`)

O projeto segue uma arquitetura limpa separando responsabilidades:

```text
lib/
├── controllers/       # Lógica de negócio e regras de conversão
├── models/            # Estruturas de dados e modelos imutáveis
├── views/             # Ecrãs e componentes visuais da interface
└── main.dart          # Inicialização e controlo global do tema
🚀 Como Começar
Pré-requisitos
Antes de começar, garante que tens o ambiente Flutter configurado na tua máquina.

Instalação
Clona o repositório para a tua máquina local:

Bash
git clone [https://github.com/teu-utilizador/caminhadas_odemira.git](https://github.com/teu-utilizador/caminhadas_odemira.git)
Navega para a pasta do projeto:

Bash
cd caminhadas_odemira
Instala as dependências necessárias:

Bash
flutter pub get
Executa a aplicação no teu emulador ou dispositivo físico:

Bash
flutter run
🧪 Testes Automatizados
O projeto inclui uma suite de testes unitários para garantir a precisão dos cálculos de pontos e quilómetros dos controladores. Para rodar os testes, executa:

Bash
flutter test
