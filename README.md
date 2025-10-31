# Projeto Ária

Automação de provisionamento do ambiente RetroPie para o Projeto Ária. Reúne os scripts operacionais utilizados na preparação das máquinas, com foco em reprodutibilidade, segurança e facilidade de manutenção.

## Artigo Técnico (A3)

**Instalação e Execução de Jogos no Raspberry Pi para Ambiente Educacional e de Entretenimento**

- Alex Cabral Moreira da Silva – RA 13525120097
- Alexsander Farias Da Silva – RA 13525123053
- Geovanny Fernando da Penha Valentim – RA 1352221733
- Higor Paiva de Brito – RA 13524123018
- Matheus Henrique Dias Siqueira – RA 1352526420
- Paulo Victor Nunes Saatmam – RA 1352511470

O artigo documenta tecnicamente o processo de instalação e execução de jogos no Raspberry Pi, avaliando o uso em cenários educacionais e de entretenimento. O conteúdo completo está em `artigo/Projeto_Aria_A3.md`, que também indica a versão `.docx` a ser distribuída.

### Jogos Instalados

- SuperTux (Plataforma 2D)
- SuperTuxKart (Corrida 3D)
- Njam (Arcade)
- Extreme Tux Racer (Corrida/Simulação)
- OpenArena (FPS 3D)
- Frozen-Bubble (Puzzle)
- LBreakout2 (Arcade)
- Chromium B.S.U. (Shooter vertical)
- Snake4 (Clássico da cobrinha)

## Visão Geral

O objetivo principal é entregar um setup de Raspberry Pi otimizado para o RetroPie, reduzindo o tempo manual de configuração e eliminando erros comuns. Os scripts atualmente disponíveis incluem:

- `scripts/instalar_retropie_aria.sh`: instalação completa do RetroPie com automações adicionais (detalhes abaixo).
- `scripts/instalar_jogos_apt.sh`: instala rapidamente os títulos adotados no artigo A3 via repositórios APT oficiais.

O instalador principal (`instalar_retropie_aria.sh`) é responsável por:

- Executar limpeza preventiva de caches/processos que atrapalham a compilação do RetroPie.
- Forçar a instalação/coleta de binários pré-compilados para agilizar o deploy.
- Configurar um serviço systemd que copia ROMs automaticamente de um pendrive durante o boot.
- Garantir permissões e ownership corretos no diretório de `roms`.

À medida que novos utilitários forem criados, eles deverão ser versionados na pasta `scripts/` com documentação correspondente.

## Estrutura do Repositório

```
.
├── README.md              # Este documento
├── scripts/
│   ├── instalar_jogos_apt.sh      # Instalação dos jogos via apt (lista do artigo A3)
│   └── instalar_retropie_aria.sh  # Script completo de instalação e automação
└── .gitignore             # Regras para evitar arquivos temporários no versionamento
```

## Pré-requisitos

- Raspberry Pi com Raspberry Pi OS (ou distribuição compatível baseada em Debian).
- Acesso à internet para baixar dependências e repositórios.
- Usuário com privilégios de sudo (o script valida se está rodando como root).
- Pendrive com ROMs organizado em `/roms` (opcional, mas recomendado).

## Como Executar

1. Transfira o script para o Raspberry Pi (ex.: `scp scripts/instalar_retropie_aria.sh pi@<ip>:/home/pi/`).
2. Torne o script executável: `chmod +x instalar_retropie_aria.sh`.
3. Rode com privilégios: `sudo bash instalar_retropie_aria.sh`.
4. Acompanhe a saída para identificar possíveis avisos. Ao final o dispositivo será reiniciado automaticamente.

> **Importante:** O script não contém senhas embutidas. Quando solicitado, informe a senha do usuário `pi` (ou o usuário administrador que estiver utilizando).

## O que o Script Faz

- Mata processos travados de compilação (`cc1plus`, `make`).
- Limpa caches temporários (`apt`, `/tmp`) para liberar espaço.
- Confirma e instala dependências críticas (`git`, `dialog`, `unzip`, `xmlstarlet`, `dos2unix`, `rsync`).
- Garante um clone fresco do `RetroPie-Setup` e tenta a instalação por binários pré-compilados.
- Detecta pendrive em `/media/pi` e gera automaticamente o script de cópia de ROMs.
- Cria e habilita o serviço `copia-roms.service` no `systemd`.
- Ajusta permissões do diretório `/home/pi/RetroPie/roms`.
- Executa uma cópia inicial de ROMs (ignora erros se o pendrive não estiver presente).

## Manutenção e Customizações

- Para alterar a label padrão do pendrive, edite a variável `LABEL` dentro do script.
- Caso precise reinstalar apenas o serviço de cópia, remova `/etc/systemd/system/copia-roms.service` e rerode o script.
- Atualizações futuras nos scripts devem manter `set -euo pipefail` e logs padronizados (`log/warn/err`).
- Antes de commitar novos scripts, valide em um Raspberry Pi real ou emulado.

## Próximos Passos

- Documentar fluxos adicionais (ex.: configuração de rede, overclock, temas personalizados).
- Adicionar testes automatizados (lint/shellcheck) para garantir a qualidade dos scripts.

## Contribuição

1. Abra uma branch descritiva (`feature/<resumo>`).
2. Garanta que o script esteja legível, com comentários apenas quando necessários.
3. Descreva claramente no pull request o objetivo e os cenários de validação.

## Licença

Definir conforme orientação do time. Enquanto não houver decisão, mantenha o uso restrito ao Projeto Ária.
