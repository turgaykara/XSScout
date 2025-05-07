#!/bin/bash

# Paramspider'ı yükle
cd ~/Desktop/
git clone https://github.com/0xKayala/paramspider.git
cd paramspider
pip install -r requirements.txt
cd ..

# LinkFinder'ı yükle
git clone https://github.com/GerbenJavado/LinkFinder.git
cd LinkFinder
pip install -r requirements.txt
cd ..

# Go yükle (Subfinder ve httpx için)
sudo apt install golang -y

# Subfinder'ı yükle
GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# httpx'i yükle
GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest




#!/bin/bash

# Paramspider'ı yükle
echo "[*] Cloning Paramspider repository..."
cd ~/Desktop/
git clone https://github.com/0xKayala/paramspider.git
cd paramspider
echo "[*] Installing Python dependencies for Paramspider..."
pip install -r requirements.txt
cd ..

# LinkFinder'ı yükle
echo "[*] Cloning LinkFinder repository..."
git clone https://github.com/GerbenJavado/LinkFinder.git
cd LinkFinder
echo "[*] Installing Python dependencies for LinkFinder..."
pip install -r requirements.txt
cd ..

# Go yükle (Subfinder ve httpx için)
echo "[*] Installing Go (required for Subfinder and httpx)..."
sudo apt update
sudo apt install golang -y

# Subfinder'ı yükle
echo "[*] Installing Subfinder..."
GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# httpx'i yükle
echo "[*] Installing httpx..."
GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

echo "[*] Setup complete! All dependencies are installed."
