#!/usr/bin/env bash
set -e

echo "➡️ Atualizando listas de pacotes..."
sudo apt update

echo "➡️ Instalando jogos via APT..."
sudo apt install -y \
  supertux \
  supertuxkart \
  njam \
  extremetuxracer \
  openarena \
  frozen-bubble \
  lbreakout2 \
  chromium-bsu \
  snake4

echo "➡️ Links de download para versões ou consulta adicional:"
echo "  • SuperTux → https://www.supertux.org/download  [oai_citation:0‡SuperTux](https://www.supertux.org/download?utm_source=chatgpt.com)"
echo "  • SuperTuxKart → https://supertuxkart.net/Download  [oai_citation:1‡SuperTuxKart](https://supertuxkart.net/Download?utm_source=chatgpt.com)"
echo "  • Njam → https://sourceforge.net/projects/njam/  [oai_citation:2‡SourceForge](https://sourceforge.net/projects/njam/?utm_source=chatgpt.com)"
echo "  • OpenArena → https://openarena.ws/files.html  [oai_citation:3‡openarena.ws](https://openarena.ws/files.html?utm_source=chatgpt.com)"
echo "  • Frozen-Bubble, LBreakout2, Chromium B.S.U., Snake4 → verificar no apt ou no repositório de sua distro"

echo "✅ Instalação concluída. Verifique os links acima para versões alternativas ou arquivos específicos. Se desejar versão para ARM ou formato .tar/.zip, baixe manualmente."
