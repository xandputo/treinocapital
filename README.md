# treinocapital

App HTML servida com Nginx via Docker / Dev Container.

## Estrutura

```
treinocapital/
├── .devcontainer/
│   └── devcontainer.json
├── app/
│   ├── Dockerfile
│   └── index.html
├── .gitignore
└── README.md
```

## Rodar com Docker

Na raiz do repositório:

```bash
docker build -t treinocapital ./app
docker run --rm -p 8080:80 treinocapital
```

Abra [http://localhost:8080](http://localhost:8080).

## Rodar no Cursor / VS Code

1. Instale a extensão **Dev Containers**.
2. Abra esta pasta.
3. Use **Reopen in Container**.

