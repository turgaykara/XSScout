# SCRIPT:
# -------------------------------------------------------------------------------------------------------------------
mv xsscout.sh paramspider
cd paramspider

subfinder -d atilsamancioglu.com -silent -o subdomains.txt

cat subdomains.txt | httpx -silent -o live_subdomains.txt

cat live_subdomains.txt | while read url; do
    domain=$(echo $url | sed 's~http[s]*://~~' | sed 's~/.*~~')
    echo "[*] Scanning $domain"
    
    # Paramspider'ı çalıştır
    python3 paramspider.py -d $domain --exclude woff,css,png,jpg,jpeg,gif,svg --level high | while read result; do
        # Eğer sonuç .js içeriyorsa resultjs.txt'ye kaydet
        if [[ $result == *.js* ]]; then
            echo "$result" >> dresultjs.txt
        else
            # Diğer sonuçları dresultq.txt'ye kaydet
            echo "$result" >> dresultq.txt
        fi
    done
done


# Sonuclari derle
mkdir -p results
mv dresultjs.txt results/
mv dresultq.txt results/
mv subdomains.txt results/
mv live_subdomains.txt results/


# Sonuclari temizle
cd results/
cat dresultjs.txt | sed 's/?ver=FUZZ$//' > resultjs.txt
sed -n '/^http/p' dresultq.txt > resultq.txt
rm -rf dresultjs.txt
rm -rf dresultq.txt


mv resultjs.txt ../../LinkFinder/
cd ../../LinkFinder/
> dlinkfinder.txt && while read url; do python3 linkfinder.py -i "$url" -o cli | grep -v -e "Error" -e "Usage"; done < resultjs.txt > dlinkfinder.txt
> linkfinder2.txt && while read url; do [[ "$url" == https://* ]] && echo "$url" || echo "https://atilsamancioglu.com/$url"; done < dlinkfinder.txt >> linkfinder2.txt
mv linkfinder2.txt ../paramspider/results
cd ../paramspider/results

# .js uzantili urllerden cikan domainler
httpx -l linkfinder2.txt -silent -mc 200,401,403,500 -status-code -o filtered_links.txt
grep -v ' \[\]$' filtered_links.txt > cleaned_links.txt
sed 's/ \[.*\]//' cleaned_links.txt > linkfinder.txt

rm -rf cleaned_links.txt
rm -rf filtered_links.txt
rm -rf linkfinder2.txt
rm -rf resultjs.txt
rm -rf dlinkfinder.txt

cd ..
mv results ../
mv xsscout.sh ../
cd ..

# --------------------------------------------------------------------

# *SONUC:
# subdomains.txt	       -> Subdomain listesi.
# live_subdomains.txt    -> Aktif olan subdomain listesi.
# resultq.txt	       -> Manuel XSS payload denemesi yapilabilir.
# linkfinder.txt         -> Test edilebilecek ekstra sayfalar.

# --------------------------------------------------------------------
