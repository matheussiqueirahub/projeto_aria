#!/bin/bash
# instalar_retropie_aria.sh
# Instalação otimizada RetroPie + serviço de cópia de ROMs
# NÃO contém senha. Execute com sudo (digite a senha do usuário quando solicitado).

set -euo pipefail
IFS=$'\n\t'

log(){ echo -e "\n[INFO] $*"; }
warn(){ echo -e "\n[WARN] $*" >&2; }
err(){ echo -e "\n[ERROR] $*" >&2; exit 1; }

if [ "$(id -u)" -ne 0 ]; then
  err "Execute com sudo: sudo bash instalar_retropie_aria.sh"
fi

log "Iniciando processo otimizado RetroPie (Projeto Ária)."

# 1. Finaliza processos travados (não falha se não existirem)
log "Encerrando processos de compilação..."
pkill -9 cc1plus 2>/dev/null || true
pkill -9 make 2>/dev/null || true

# 2. Limpeza rápida
log "Limpando caches e temporários..."
apt-get -y --allow-releaseinfo-change update || true
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade || true
apt-get -y autoclean || true
rm -rf /home/pi/RetroPie-Setup/tmp 2>/dev/null || true
rm -rf /var/cache/apt/archives/* 2>/dev/null || true
rm -rf /tmp/* 2>/dev/null || true

# 3. Dependências essenciais
log "Instalando dependências essenciais (git, dialog, unzip, xmlstarlet, dos2unix)..."
DEBIAN_FRONTEND=noninteractive apt-get install -y git dialog unzip xmlstarlet dos2unix rsync || true

# 4. Detecta pendrive montado (prioriza label "Volume de 16 GB")
LABEL="Volume de 16 GB"
MOUNT=""
if [ -d "/media/pi/${LABEL}" ]; then
  MOUNT="/media/pi/${LABEL}"
else
  # primeiro diretório em /media/pi
  for p in /media/pi/*; do
    [ -d "$p" ] || continue
    if [ "$p" != "/media/pi" ]; then
      MOUNT="$p"
      break
    fi
  done
fi

if [ -z "${MOUNT}" ]; then
  warn "Nenhum pendrive detectado em /media/pi. O script continuará; a cópia de ROMs só ocorrerá quando houver pendrive."
else
  log "Pendrive detectado em: ${MOUNT}"
fi

# 5. Clone limpo do RetroPie-Setup
log "Baixando RetroPie-Setup (clone limpo)..."
cd /home/pi || err "Não foi possível acessar /home/pi"
rm -rf RetroPie-Setup || true
git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git || warn "Clone falhou"
cd RetroPie-Setup || warn "Pasta RetroPie-Setup não encontrada; execute sudo ./retropie_setup.sh manualmente depois."

# 6. Instalação rápida via precompiled binaries (quando possível)
log "Tentando instalação rápida (precompiled binaries)..."
if [ -f "./retropie_packages.sh" ]; then
  bash ./retropie_packages.sh setup basic_install || warn "Instalação via retropie_packages.sh falhou; é recomendado executar sudo ./retropie_setup.sh e escolher 'install from precompiled binary'."
else
  warn "Script retropie_packages.sh não encontrado; abra sudo ./retropie_setup.sh manualmente."
fi

# 7. Cria script de cópia de ROMs (com path detectado)
log "Criando script de cópia de ROMs em /home/pi/scripts/copia_roms.sh..."
mkdir -p /home/pi/scripts
ROMSCRIPT="/home/pi/scripts/copia_roms.sh"

if [ -n "${MOUNT}" ]; then
  ORIG="${MOUNT}/roms"
else
  ORIG="/media/pi/Volume de 16 GB/roms"
fi

cat > "${ROMSCRIPT}" <<EOF
#!/bin/bash
ORIG="${ORIG}"
DEST="/home/pi/RetroPie/roms"

echo "[copia_roms] Origem: \$ORIG"
if [ -d "\$ORIG" ]; then
  mkdir -p "\$DEST"
  echo "[copia_roms] Copiando (rsync) de \$ORIG -> \$DEST"
  rsync -av --ignore-existing --no-perms --chmod=Du=rwx,Dg=rwx,Do=rx,Fu=rw,Fg=rw,Fo=r "\$ORIG"/ "\$DEST"/ || echo "[copia_roms] rsync retornou erro, verifique permissões"
  chown -R pi:pi "\$DEST"
  echo "[copia_roms] Cópia finalizada."
else
  echo "[copia_roms] Pasta de ROMs não encontrada em \$ORIG."
fi
EOF

dos2unix "${ROMSCRIPT}" >/dev/null 2>&1 || true
chmod +x "${ROMSCRIPT}"
chown pi:pi "${ROMSCRIPT}" || true

# 8. Cria e habilita serviço systemd para rodar a cópia no boot
log "Criando serviço systemd copia-roms.service..."
SERVICE="/etc/systemd/system/copia-roms.service"
cat > "${SERVICE}" <<EOF
[Unit]
Description=Copia ROMs do pendrive para RetroPie
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/home/pi/scripts/copia_roms.sh
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload || true
systemctl enable copia-roms.service || warn "Não foi possível habilitar o serviço, habilite manualmente com: sudo systemctl enable copia-roms.service"

# 9. Permissões do diretório de ROMs e dono
log "Ajustando diretório /home/pi/RetroPie/roms..."
mkdir -p /home/pi/RetroPie/roms
chmod -R 775 /home/pi/RetroPie/roms || true
chown -R pi:pi /home/pi/RetroPie/roms || true

# 10. Converte eventuais scripts no pendrive (opcional)
if [ -n "${MOUNT}" ]; then
  log "Convertendo arquivos .sh no pendrive para formato Unix (se existirem)..."
  find "${MOUNT}" -maxdepth 2 -type f -iname "*.sh" -exec dos2unix {} \; 2>/dev/null || true
fi

# 11. Executa teste de cópia agora (se houver pendrive)
log "Executando cópia de ROMs agora (teste imediato)..."
bash "${ROMSCRIPT}" || warn "Execução do copia_roms.sh retornou erro (ok se não houver pendrive)."

# 12. Mensagem final e reboot
log "Processo concluído. Reiniciando em 10 segundos para aplicar todas as mudanças..."
sleep 10
reboot