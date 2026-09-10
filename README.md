<div align="center">

# DiscordGoLiveBypass — Linux Edition

**Abre o Discord por um IP fora do Brasil, devolvendo o Go Live, a câmera e a transmissão de tela no Linux.**

[![Versão](https://img.shields.io/github/v/release/SamuelSouzaccm/DiscordGoLiveBypass-Linux?include_prereleases&style=flat-square&label=vers%C3%A3o&color=5865F2)](../../releases)
[![Downloads](https://img.shields.io/github/downloads/SamuelSouzaccm/DiscordGoLiveBypass-Linux/total?style=flat-square&label=downloads&color=5865F2)](../../releases)
[![Licença](https://img.shields.io/github/license/SamuelSouzaccm/DiscordGoLiveBypass-Linux?style=flat-square&label=licen%C3%A7a)](LICENSE)
![Linux](https://img.shields.io/badge/plataforma-Linux-FCC624?style=flat-square&logo=linux&logoColor=black)

[**Baixar AppImage**](../../releases) · [Como usar](#como-usar) · [FAQ](#faq) · [Compilar](#compilar-do-código-fonte)


Este é um fork adaptado para **Linux** do projeto original criado por [thomassolcia](https://github.com/thomassolcia/DiscordGoLiveBypass).
</div>

É um executável portátil em **AppImage**, sem instalação obrigatória, sem plugin e sem tocar nos arquivos do Discord. Você roda, ele procura um servidor no exterior, confere se funciona e abre o Discord já conectado por ele.

> **Linux apenas (Formato AppImage).** Não é VPN: só o Discord muda de rota, o resto do computador continua igual. Também não é ferramenta de privacidade: o tráfego passa por um servidor público de terceiros.

---

## Por que o Go Live parou de funcionar

Em 17 de agosto de 2026, a ANPD determinou, em [medida preventiva](https://www.gov.br/anpd/pt-br/assuntos/noticias/em-medida-preventiva-anpd-determina-que-discord-suspenda-transmissoes-ao-vivo-no-brasil) [cite: 1], que o Discord suspendesse transmissão de tela e vídeo no Brasil [cite: 1]. A decisão veio depois de um caso grave, envolvendo a morte de uma adolescente alvo de uma campanha coordenada de assédio em várias plataformas. O Discord cumpriu a ordem e publicou uma [carta à comunidade brasileira](https://discord.com/blog/a-letter-to-the-discord-community-in-brazil) dizendo que trabalha para restaurar os recursos.

Na prática, para quem está no Brasil:

| parou | continua |
| --- | --- |
| Go Live, transmissão de tela, chamadas de vídeo | mensagens, servidores, canais de voz sem vídeo |

O bloqueio é aplicado por região, e é por isso que sair por um IP de fora o desfaz. Este projeto não opina sobre a decisão da ANPD nem sobre o caso que a motivou: ele muda a rota da sua conexão, como uma VPN faria.

---

## Como usar

1. Baixe o arquivo `DiscordGoLiveBypass-x86_64.AppImage` na aba [Releases](../../releases).
2. Feche o Discord completamente (certifique-se de encerrar o processo na bandeja do sistema).
3. Dê permissão de execução e execute o AppImage:

```bash
# Permissão de execução
chmod +x DiscordGoLiveBypass-x86_64.AppImage

# Executar
./DiscordGoLiveBypass-x86_64.AppImage
```

*(Você também pode dar permissão clicando com o botão direito no arquivo > Propriedades > Permissões > "Permitir execução como programa").*

O terminal mostrará o progresso e iniciará o Discord:

```
 ╭────────────────────────────────────────────────────────╮
 │  DiscordGoLiveBypass (Linux)                           │
 │  abre o Discord por um IP de fora, sem VPN no sistema  │
 ╰────────────────────────────────────────────────────────╯

 ▸ 1/4  Procurando a instalacao do Discord
   ✔  Discord encontrado
      /usr/bin/discord

 ▸ 2/4  Procurando uma saida fora de Brasil (BR)
   ⠹  ██████████░░░░░░░░░░░░░░  18/40  3 responderam ate agora

 ▸ 3/4  Confirmando por onde a conexao vai sair
   ✔  a saida esta em Alemanha (DE)

 ▸ 4/4  Abrindo o Discord
   ✔  Discord aberto, pid 14240

 ╭─ tudo pronto ──────────────────────────────────╮
 │  saida     Alemanha (DE)                       │
 │  servidor  socks5://213.136.92.91:1080         │
 │  resposta  1542 ms                             │
 │  discord   Discord, pid 14240                  │
 │  tempo     14s                                 │
 ╰────────────────────────────────────────────────╯
```

A barra da etapa 2 é a parte demorada: cada servidor é testado contra o Discord. **A primeira inicialização pode demorar um pouco mais**, pois tudo é roteado pelo exterior. Depois que carrega, o uso é normal.

---

## Antes de confiar no arquivo

Desconfiar de binários baixados da internet é a atitude correta. Para checar a integridade do arquivo baixado via terminal:

```bash
sha256sum DiscordGoLiveBypass-x86_64.AppImage
```

Você também pode auditar o código-fonte por completo e [compilar na sua própria máquina](#compilar-do-código-fonte) com comandos simples.

---

## FAQ

### No dia a dia

<details>
<summary><strong>Preciso rodar toda vez que for usar o Discord?</strong></summary>
<br>

Sim. A configuração vale só para a sessão aberta por este executável. Se você abrir pelo atalho padrão do sistema, o Discord volta ao normal (sem bypass).
</details>

<details>
<summary><strong>Vai ficar lento?</strong></summary>
<br>

As mensagens e o carregamento inicial, um pouco. A transmissão em si não: vídeo, voz e imagens vão direto, sem passar pelo proxy, mantendo o desempenho.
</details>

<details>
<summary><strong>Funciona em qual distro?</strong></summary>
<br>

Por ser empacotado em AppImage, funciona na grande maioria das distribuições Linux (Ubuntu, Fedora, Nobara, Arch Linux, Debian, Pop!_OS, etc.). Foi testado ativamente no **Nobara Linux (KDE)**.
</details>

<details>
<summary><strong>Isso é uma VPN?</strong></summary>
<br>

Não. Apenas o processo do Discord muda de rota. Seu navegador, jogos e demais aplicativos continuam na conexão normal.
</details>

---

### Quando dá errado

<details>
<summary><strong>Apareceu "nao achei nenhum Discord instalado"</strong></summary>
<br>

O programa procurou nos locais usuais (`/usr/bin/discord`, `/opt/discord`, etc.) e não encontrou. Você pode forçar o caminho manualmente:

```bash
./DiscordGoLiveBypass-x86_64.AppImage -force -exe "/caminho/para/seu/discord"
```
</details>

<details>
<summary><strong>Apareceu "nenhuma proxy da lista passou nos testes"</strong></summary>
<br>

Todos os servidores testados falharam ou estão lentos. Como são proxies públicos, tente rodar novamente. Se persistir, aumente o tempo de timeout:

```bash
./DiscordGoLiveBypass-x86_64.AppImage -force -timeout 5m
```
</details>

<details>
<summary><strong>O Discord abre mas fica travado em "Connecting"</strong></summary>
<br>

O proxy sorteado caiu logo após a conexão. Feche o Discord e execute o AppImage novamente para ele sortear outro servidor.
</details>

---

## Opções via Terminal

Você pode passar flags diretamente ao executar o AppImage:

| opção | para que serve |
| --- | --- |
| `-force` | fecha instâncias já abertas do Discord antes de iniciar |
| `-check` | apenas testa os proxies sem abrir o Discord |
| `-exclude BR,AR` | países recusados na saída (padrão: `BR`) |
| `-channel canary` | força canal: `auto`, `stable`, `ptb` ou `canary` |
| `-exe "/caminho/discord"` | define o caminho do binário do Discord manualmente |
| `-proxy socks5://ip:porta` | força um servidor proxy específico |
| `-timeout 5m` | tempo limite de busca |
| `-fallback` | permite conexão direta caso o proxy caia |
| `-no-cache` / `-no-tor` | ignora cache / ignora detecção de Tor local |
| `-no-update` | desativa a checagem de atualizações no GitHub |

---

## Como funciona por dentro

O Discord é um aplicativo baseado em Electron (Chromium), que aceita flags de linha de comando para direcionar conexões de rede (`--proxy-server=socks5://ip:porta`).

O binário localiza a instalação do Discord no seu ambiente Linux, testa proxies SOCKS5/HTTP válidos fora do Brasil contra os endpoints da API do Discord e inicia o processo com a rota configurada. Todo o tráfego pesado de mídia é configurado para contornar o proxy via flags de bypass, preservando a largura de banda.

---

## Compilar do código-fonte

Requer **Go** instalado no sistema:

```bash
# Clone o repositório
git clone https://github.com/SamuelSouzaccm/DiscordGoLiveBypass-Linux.git
cd DiscordGoLiveBypass-Linux

# Compile o binário nativo
go build -o DiscordGoLiveBypass .
```

---

## Créditos

- Projeto adaptado a partir do repositório original de **[@thomassolcia](https://github.com/thomassolcia/DiscordGoLiveBypass)**.
- Lógica de ranqueamento inspirada no plugin **GoLiveBypass** (Vencord) por **[@thomassolcia](https://github.com/thomassolcia/DiscordGoLiveBypass)**.
- Distribuído sob a licença **GPL-3.0**.
