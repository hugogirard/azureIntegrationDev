# 
All in Powershell in admin mode

Install-Script winget-install -Force
winget-install


code --list-extensions > extensions.list
cat extensions.list |% { code --install-extension $_}