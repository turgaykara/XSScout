## XSScout

XSScout is an automated recon tool for:

- Subdomain enumeration
- Parameter discovery
- JavaScript endpoint extraction

Useful for bug bounty hunters and penetration testers.
  
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

dos2unix xsscout.sh
bash setup.sh
```

---

RUN: 
```
bash xsscout.sh
```
