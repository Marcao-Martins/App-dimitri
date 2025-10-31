
# Vet Anesthesia Helper

O Vet Anesthesia Helper é um aplicativo móvel completo, desenvolvido em Flutter, para auxiliar médicos veterinários e estudantes de veterinária em diversas tarefas relacionadas à anestesiologia. O aplicativo oferece um conjunto de ferramentas para cálculos de doses, guias de medicamentos, checklists pré-operatórios, e módulos especializados para RCP, fluidoterapia e transfusão.

## 🌟 Funcionalidades Principais

- **Calculadora de Doses:** Calcule rapidamente as doses de medicamentos com base no peso do animal.
- **Guia de Medicamentos (Bulário):** Um guia de referência rápida para diversos fármacos utilizados na anestesia veterinária.
- **Checklist Pré-Operatório:** Um checklist para garantir que todos os passos pré-operatórios foram seguidos.
- **Ficha Anestésica:** Gere e salve fichas anestésicas em formato PDF.
- **RCP Coach:** Um assistente para manobras de ressuscitação cardiopulmonar.
- **Calculadora de Fluidoterapia:** Calcule taxas de fluidoterapia de manutenção e reidratação.
- **Calculadora de Transfusão:** Calcule o volume de sangue necessário para transfusões.

---

## 🚀 Módulos em Destaque

### 🫀 RCP Coach

Módulo de auxílio para Ressuscitação Cardiopulmonar (RCP) com timer de 2 minutos, metrônomo de compressões e alertas sonoros.

- **Timer de Ciclos (2 minutos):** Contagem regressiva de 120 segundos com reinício automático.
- **Metrônomo de Compressões:** Beep a cada 500ms (120 BPM) para guiar o ritmo das compressões.
- **Sistema de Áudio:** Sons distintos para o metrônomo e para o final de cada ciclo.
- **Controles Interativos:** Botões para iniciar, pausar, reiniciar, mutar o som e manter a tela ativa (wake lock).
- **Contador de Ciclos:** Acompanhe o número de ciclos de 2 minutos completados.
- **Mensagens de Status:** Orientações em tempo real sobre o que fazer.

### 💧 Calculadora de Fluidoterapia

Módulo para cálculo de fluidoterapia para cães e gatos, incluindo volumes de manutenção e reidratação.

- **Cálculo de Manutenção:**
  - **Cães:** 60 mL/kg/dia
  - **Gatos:** 40 mL/kg/dia
- **Cálculo de Reidratação:** Calcula o volume necessário para corrigir a desidratação em 12 ou 24 horas.
- **Taxas de Infusão:** Fornece a taxa em mL/hora, gotas/minuto e o intervalo em segundos entre as gotas.

### 🩸 Calculadora de Transfusão Sanguínea

Módulo para cálculo do volume de sangue necessário para transfusão em cães e gatos, baseado em valores de hematócrito.

- **Fórmula:** `Volume (mL) = (Peso × Fator × (Ht_desejado - Ht_receptor)) / Ht_bolsa`
- **Fatores por Espécie:**
  - **Cães:** 80 ou 90
  - **Gatos:** 40 ou 60
- **Recomendações de Taxa de Infusão:** Fornece taxas seguras para a infusão do sangue.

---

## 🛠️ Tecnologias Utilizadas

- **Framework:** Flutter
- **Linguagem:** Dart
- **Gerenciamento de Estado:** Provider
- **Armazenamento Local:** Hive
- **Geração de PDF:** pdf, printing
- **Gráficos:** fl_chart
- **Áudio:** audioplayers
- **Manter Tela Ativa:** wakelock_plus
- **Preferências:** shared_preferences
- **Paths de Arquivos:** path_provider

---

## ⚙️ Instalação

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/seu-usuario/vet_anesthesia_helper.git
    ```
2.  **Entre no diretório do projeto:**
    ```bash
    cd vet_anesthesia_helper
    ```
3.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```
4.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

---

## 📜 Licença

Este projeto é licenciado sob a **Licença MIT**.

```
MIT License

Copyright (c) 2025 GDAV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## ⚠️ Medical Disclaimer

Este aplicativo é uma ferramenta auxiliar para profissionais de anestesia veterinária e não deve substituir o julgamento clínico profissional, a consulta à literatura atualizada ou os protocolos institucionais.

Os desenvolvedores e contribuidores deste software não se responsabilizam por quaisquer decisões clínicas tomadas com base nas informações fornecidas por este aplicativo.

Sempre verifique as dosagens e protocolos de medicamentos com a literatura veterinária atual e consulte especialistas veterinários qualificados em caso de dúvida.

Este software é fornecido apenas para fins educacionais e auxiliares. Use por sua conta e risco profissional.
