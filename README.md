# niri-gap-toggle

Cria um **gap de 100px** entre os monitores no [Niri](https://niri-wm.github.io/) para evitar que o mouse passe para o segundo monitor enquanto joga, sem precisar rodar o jogo no Gamescope.

## Como funciona

O script detecta automaticamente os monitores, identifica o primário (maior área), e **move o secundário** 20px para longe do primário, criando um espaço que o mouse não consegue atravessar.

- **Modo Padrão**: monitores lado a lado (flush)
- **Modo Jogo**: gap de 100px entre os monitores

Funciona com monitores lado a lado (horizontal) ou empilhados (vertical), em qualquer posição.

## Requisitos

- [Niri](https://niri-wm.github.io/) rodando
- `bash`
- `notify-send` (geralmente do `libnotify`)

## Instalação

1. Copie o script para um local de sua preferência:

```bash
cp niri-gap-toggle.sh ~/scripts/
chmod +x ~/scripts/niri-gap-toggle.sh
```

2. Adicione o atalho no `~/.config/niri/config.kdl`, dentro do bloco `binds { }`:

```kdl
Mod+N { spawn "/home/seu-usuario/scripts/niri-gap-toggle.sh"; }
```

3. Recarregue o config:

```bash
niri msg action load-config-file
```

## Uso

Pressione `Mod+N` para alternar entre os modos.

Uma notificação aparecerá:
- **"Modo: Padrão"** — monitores sem gap
- **"Modo: Jogo"** — gap de 100px ativo

## Personalização

Para alterar o tamanho do gap, edite a variável `GAP` no script:

```bash
GAP=20   # altere para o valor desejado
```
