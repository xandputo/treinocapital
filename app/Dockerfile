# Imagem oficial do nginx que roda SEM root, com tag fixa
FROM nginxinc/nginx-unprivileged:1.27-alpine

COPY index.html /usr/share/nginx/html/index.html

# A versão unprivileged escuta na 8080 (porta abaixo de 1024 exige root)
EXPOSE 8080
