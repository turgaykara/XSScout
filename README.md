## XSScout

XSScout is an automated recon tool for:

- Subdomain enumeration
- Parameter discovery
- JavaScript endpoint extraction

Useful for bug bounty hunters and penetration testers.

---

**Türkçe Açıklama**  
XSScout, bug bounty avcıları için geliştirilmiş;  
subdomain, parametre ve JavaScript endpoint keşfi yapan otomatik bir araçtır.

---

INSTALLATION:  
```
git clone https://github.com/turgaykara/XSScout.git  
cd XSScout  

python3 -m venv myenv
source myenv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt

chmod +x setup.sh  
bash setup.sh

mv xsscout.sh paramspider/
cd paramspider

dos2unix xsscout.sh
bash xsscout.sh
```

---

RUN: 
```
dos2unix xsscout.sh  
bash xsscout.sh
```
