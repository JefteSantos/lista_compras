# Não Esquece! — Notas da Versão 1.1.1

## O que há de novo

### Histórico de preços
Agora funciona de verdade! Ao finalizar uma lista de compras, os preços dos itens marcados como comprados são salvos automaticamente. Na próxima vez que você adicionar um item com o mesmo nome, o app exibe o último preço pago e um indicador de tendência (mais caro, mais barato ou igual).

### Código de compartilhamento muito mais curto
O código gerado para compartilhar listas ficou até 74% menor. Uma lista com 50 itens que antes gerava ~3.600 caracteres agora gera menos de 1.000, transmitindo com segurança por WhatsApp, SMS ou qualquer canal de texto, sem corrupção.

### Preços no compartilhamento como texto
Ao copiar a lista para o WhatsApp, os itens ja comprados agora exibem o preco unitario e, quando a quantidade for maior que 1, o total do item:
- 5x Leite - R$ 8,50 (total: R$ 42,50)
- 1x Arroz - R$ 25,90

### Tela de boas-vindas atualizada
A apresentacao inicial do app foi expandida para mostrar todas as funcionalidades: historico de precos, scanner OCR, compartilhamento por codigo e por texto, widget de tela inicial, backup no Google Drive e exportacao de arquivos (PDF, Excel, CSV).

## Correcoes

- Historico de precos nao aparecia: o botao Finalizar Compra chamava o metodo errado internamente e os precos nunca eram gravados. Corrigido.
- Codigo de compartilhamento marcado como invalido: uma validacao incorreta rejeitava codigos validos em determinados tamanhos. Corrigido.
- Texto de compartilhamento sem precos nos itens comprados: a secao Ja Peguei nao exibia valores. Corrigido.

## Texto curto para a Google Play

Corrigimos dois bugs importantes: o historico de precos agora funciona ao finalizar listas, e o codigo de compartilhamento ficou ate 74% menor, sem mais erros de codigo invalido. O texto compartilhado pelo WhatsApp agora tambem exibe os precos de cada item comprado.
