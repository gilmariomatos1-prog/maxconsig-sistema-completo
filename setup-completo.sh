#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

clear

echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}║     🚀 MAXCONSIG - SETUP COMPLETO NA VPS 🚀                   ║${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar se é root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Execute como root: sudo bash${NC}"
    exit 1
fi

# ============================================
# PASSO 1: ATUALIZAR SISTEMA
# ============================================
echo -e "${CYAN}📋 PASSO 1/10: Atualizando sistema...${NC}"
apt update && apt upgrade -y
echo -e "${GREEN}✅ Sistema atualizado${NC}"
echo ""

# ============================================
# PASSO 2: INSTALAR DOCKER
# ============================================
echo -e "${CYAN}📋 PASSO 2/10: Instalando Docker...${NC}"

if command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker já instalado${NC}"
else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}✅ Docker instalado${NC}"
fi
echo ""

# ============================================
# PASSO 3: INSTALAR DOCKER COMPOSE
# ============================================
echo -e "${CYAN}📋 PASSO 3/10: Instalando Docker Compose...${NC}"

if command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose já instalado${NC}"
else
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose instalado${NC}"
fi
echo ""

# ============================================
# PASSO 4: INSTALAR GIT
# ============================================
echo -e "${CYAN}📋 PASSO 4/10: Instalando Git...${NC}"

if command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠️  Git já instalado${NC}"
else
    apt install git -y
    echo -e "${GREEN}✅ Git instalado${NC}"
fi
echo ""

# ============================================
# PASSO 5: CLONAR REPOSITÓRIO
# ============================================
echo -e "${CYAN}📋 PASSO 5/10: Clonando repositório...${NC}"

cd /var/www

if [ -d "maxconsig-sistema-completo" ]; then
    echo -e "${YELLOW}⚠️  Diretório já existe. Removendo...${NC}"
    rm -rf maxconsig-sistema-completo
fi

git clone https://github.com/gilmariomatos1-prog/maxconsig-sistema-completo.git

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Repositório clonado${NC}"
else
    echo -e "${RED}❌ Erro ao clonar repositório${NC}"
    exit 1
fi

cd maxconsig-sistema-completo
echo ""

# ============================================
# PASSO 6: CONFIGURAR .env
# ============================================
echo -e "${CYAN}📋 PASSO 6/10: Configurando variáveis de ambiente...${NC}"

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}✅ Arquivo .env criado${NC}"
else
    echo -e "${YELLOW}⚠️  Arquivo .env já existe${NC}"
fi
echo ""

# ============================================
# PASSO 7: BUILD E INICIAR
# ============================================
echo -e "${CYAN}📋 PASSO 7/10: Fazendo build dos containers...${NC}"
docker-compose build --no-cache
echo -e "${GREEN}✅ Build concluído${NC}"
echo ""

echo -e "${CYAN}📋 PASSO 8/10: Iniciando containers...${NC}"
docker-compose up -d
echo -e "${GREEN}✅ Containers iniciados${NC}"
echo ""

# ============================================
# PASSO 9: AGUARDAR E VERIFICAR
# ============================================
echo -e "${CYAN}📋 PASSO 9/10: Aguardando inicialização (30s)...${NC}"
sleep 30

echo ""
echo -e "${CYAN}📊 Status dos containers:${NC}"
docker-compose ps

echo ""
echo -e "${CYAN}🔍 Testando serviços:${NC}"

if curl -s http://localhost:3001/health | grep -q "OK"; then
    echo -e "${GREEN}✅ API Node.js: OK${NC}"
else
    echo -e "${YELLOW}⚠️  API Node.js: Ainda inicializando${NC}"
fi

if curl -s http://localhost:3000 | grep -q "MAXCONSIG"; then
    echo -e "${GREEN}✅ Frontend: OK${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend: Ainda inicializando${NC}"
fi

# ============================================
# PASSO 10: RESUMO FINAL
# ============================================
echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}║     ✅ SETUP CONCLUÍDO COM SUCESSO! ✅                         ║${NC}"
echo -e "${MAGENTA}║                                                                ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

VPS_IP=$(hostname -I | awk '{print $1}')

echo -e "${CYAN}🌐 URLs de Acesso:${NC}"
echo ""
echo -e "${BLUE}Frontend:${NC}      http://$VPS_IP:3000"
echo -e "${BLUE}API Node.js:${NC}   http://$VPS_IP:3001/health"
echo ""

echo -e "${CYAN}📝 Comandos Úteis:${NC}"
echo ""
echo -e "${YELLOW}Ver logs:${NC}        docker-compose logs -f"
echo -e "${YELLOW}Reiniciar:${NC}       docker-compose restart"
echo -e "${YELLOW}Parar:${NC}           docker-compose down"
echo ""

echo -e "${GREEN}✨ Sistema MAXCONSIG pronto! ✨$
