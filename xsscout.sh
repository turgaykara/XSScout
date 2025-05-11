#!/bin/bash
#xsscout.v2 {cleaner and faster}

clear
toilet -F metal -f standard -w 80 "XSS Scout"
echo "-------------------------------------------------------"
echo "🕵️   Hedefin subdomainlerini tarar ve"
echo "🎯 XSS test edilebilecek sayfaları çıkarır."
echo "-------------------------------------------------------"
echo ""
echo "                                 🔧 Created by Neon"
echo ""

read -p "Type domain (eg. test.com) ==> " TARGET

# Kullanıcıdan thread sayısını al
read -p "Max thread (eg. 1000) ==> " THREADS

# Varsayılan thread değeri
if [ -z "$THREADS" ]; then
    THREADS=20
fi

# Dizinleri oluştur
mkdir -p results

# 1. Subdomain bul
echo "[*] Subdomain taranıyor..."
subfinder -d "$TARGET" -silent -o results/subdomains.txt

# 2. Canlı subdomainleri bul
echo "[*] Canlı subdomainler aranıyor..."
httpx -l results/subdomains.txt -silent -threads "$THREADS" -o results/live_subdomains.txt

# 3. ParamSpider ile parametreli sayfaları bul
echo "[*] Parametreli endpointler aranıyor..."
> results/resultq.txt
cat results/live_subdomains.txt | xargs -P "$THREADS" -I {} bash -c '
    domain=$(echo {} | sed "s~http[s]*://~~" | sed "s~/.*~~")
    python3 paramspider/paramspider.py -d $domain --exclude woff,css,png,jpg,jpeg,gif,svg --level high 2>/dev/null
' | grep -Eo 'https?://[^ ]+' >> results/resultq.txt

# 4. JS dosyaları üzerinden endpoint çıkart
echo "[*] JS içinden endpointler çıkartılıyor..."
> results/js_links.txt
cat results/live_subdomains.txt | xargs -P "$THREADS" -I {} bash -c '
    domain=$(echo {} | sed "s~http[s]*://~~" | sed "s~/.*~~")
    python3 paramspider/paramspider.py -d $domain --exclude woff,css,png,jpg,jpeg,gif,svg --level high
' | grep ".js" | sed 's/?ver=FUZZ$//' | sort -u > results/js_raw.txt

# LinkFinder ile endpoint çıkar
> results/js_links.txt
cat results/js_raw.txt | xargs -P "$THREADS" -I {} python3 LinkFinder/linkfinder.py -i {} -o cli | grep -v -e "Error" -e "Usage" >> results/js_links.txt

# Full link haline getir
> results/linkfinder.txt
cat results/js_links.txt | while read url; do
    [[ "$url" == http* ]] && echo "$url" || echo "https://$TARGET/$url"
done >> results/linkfinder.txt

# Geçersizleri ele
httpx -l results/linkfinder.txt -silent -mc 200,401,403 -threads "$THREADS" -o results/live_endpoints.txt
grep -v ' \[\]$' results/live_endpoints.txt | sed 's/ \[.*\]//' > results/linkfinder.txt
rm -f results/live_endpoints.txt results/js_links.txt results/js_raw.txt
cd results/

# Tamamlandı
clear
echo "-------------------------------------------------------"
echo "[+] Tarama tamamlandı!"
echo "[*] Sonuçlar results/ klasörüne kaydedildi!"
echo "-------------------------------------------------------"
