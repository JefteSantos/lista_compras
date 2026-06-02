# Não Esquece! — Notas da Versão 1.2.0

## Novidades

### 🌙 Modo Escuro
Agora você pode ativar o tema escuro em Configurações → Aparência. A preferência fica salva e é lembrada ao reabrir o app.

### 📋 Duplicar Listas
Toque no ícone 📋 em qualquer lista (ou segure pressionado) para criar uma cópia com todos os itens desmarcados. Ideal para listas semanais que você repete.

### 🏷️ Agrupar por Categoria
Novo botão na barra superior da lista permite agrupar os itens por corredor/categoria com headers visuais coloridos. Desligado por padrão — ative quando quiser organizar a compra por setor do mercado.

### 💡 Sugestão de Corredor
Ao adicionar um item que você já comprou antes, o app sugere automaticamente o corredor/categoria que você usou da última vez. Toque em "USAR" para aplicar.

### ✨ Animações e Feedback Háptico
Marcar itens como comprados agora tem animação suave e vibração tátil sutil, dando uma sensação mais responsiva.

## Correções

- Corrigido typo "apagarrá" na confirmação de exclusão de lista
- Corrigido tooltip "Colar do teclado" → "Colar da área de transferência"
- Removido campo não utilizado no serviço de compartilhamento
- Corrigido uso de API deprecated (activeColor → activeTrackColor)
- Corrigidos avisos de uso de BuildContext após operações assíncronas

## Segurança

- Senhas de assinatura movidas do build.gradle.kts para key.properties (fora do controle de versão)

## Texto curto para Firebase App Distribution

Novo: Modo Escuro, duplicação de listas, agrupamento por categoria, sugestão automática de corredor e animações com feedback háptico. Correções de bugs e melhorias de segurança na assinatura.
