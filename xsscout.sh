#!/bin/bash
#xsscout.v2 {cleaner and faster}
start_time=$(date +%s)

clear
toilet -F metal "XSS Scout"
echo "-------------------------------------------------------"
echo "🕵️   Hedefin subdomainlerini tarar ve"
echo "🎯 XSS test edilebilecek sayfaları çıkarır."
echo "-------------------------------------------------------"
echo ""
echo "                                 🔧 Created by Neon"
echo ""

read -p "Type domain (eg. test.com) ==> " TARGET
read -p "Max thread (eg. 1000) ==> " THREADS

[ -z "$THREADS" ] && THREADS=20

mkdir -p results

echo "[*] Subdomain taranıyor..."
subfinder -d "$TARGET" -silent -o results/subdomains.txt

echo "[*] Canlı subdomainler aranıyor..."
httpx -l results/subdomains.txt -silent -threads "$THREADS" -o results/live_subdomains.txt

# Paramspider sadece bir kez çalıştırılır
echo "[*] Parametreli endpointler ve JS linkler çıkartılıyor..."
> results/resultq.txt
> results/js_tmp.txt

cat results/live_subdomains.txt | xargs -P "$THREADS" -I {} bash -c '
    domain=$(echo {} | sed "s~http[s]*://~~" | sed "s~/.*~~")
    python3 paramspider/paramspider.py -d $domain --exclude woff,css,png,jpg,jpeg,gif,svg --level high 2>/dev/null
' | tee results/all_paramspider_output.txt \
  | grep -Eo 'https?://[^ ]+' >> results/resultq.txt

# Sadece .js linkleri ayıkla
cat results/all_paramspider_output.txt | grep ".js" | sed 's/?ver=FUZZ$//' | sort -u > results/js_tmp.txt
rm -f results/all_paramspider_output.txt  # geçici dosya silinsin

echo "[*] Input içeren sayfalar kontrol ediliyor..."
> results/urlswinput.txt
cat results/resultq.txt | xargs -P "$THREADS" -I {} bash -c '
    curl -s --max-time 10 "{}" | grep -Eqi "<input|<textarea" && echo "{}" >> results/urlswinput.txt
'

echo "[*] LinkFinder ile endpointler toplanıyor..."
> results/linkfinder_raw.txt
cat results/js_tmp.txt | xargs -P "$THREADS" -I {} python3 LinkFinder/linkfinder.py -i {} -o cli | grep -v -e "Error" -e "Usage" >> results/linkfinder_raw.txt
rm -f results/js_tmp.txt

echo "[*] Full link haline getiriliyor..."
> results/linkfinder.txt
cat results/linkfinder_raw.txt | while read url; do
    [[ "$url" == http* ]] && echo "$url" || echo "https://$TARGET/$url"
done >> results/linkfinder.txt
rm -f results/linkfinder_raw.txt

echo "[*] Link doğrulama yapılıyor..."
httpx -l results/linkfinder.txt -silent -mc 200,401,403 -threads "$THREADS" -o results/live_endpoints.txt
grep -v ' \[\]$' results/live_endpoints.txt | sed 's/ \[.*\]//' > results/linkfinder.txt
rm -f results/live_endpoints.txt

clear
cd results/

echo "-------------------------------------------------------"
echo ""
echo "[+] Tarama tamamlandı!"
echo "[*] Sonuçlar results/ klasörüne kaydedildi!"
echo ""
echo "[*] Bulunan Subdomain sayısı      : $(wc -l < subdomains.txt)"
echo "[*] Aktif    Subdomain sayısı     : $(wc -l < live_subdomains.txt)"
echo "[*] Sorgu parametreli URL sayısı  :  $(wc -l < resultq.txt)"
echo "[*] .js ile bulunan URL sayısı    : $(wc -l < linkfinder.txt)"
echo "[*] Input içeren URL sayısı       : $(wc -l < urlswinput.txt)"
echo ""

end_time=$(date +%s)
duration=$(( end_time - start_time ))
minutes=$(( duration / 60 ))
seconds=$(( duration % 60 ))

echo "[⏱️]: ${minutes} dakika ${seconds} saniye"
echo "-------------------------------------------------------"
