# Make Python Great Again: Enviroment and Workflow

## Run

### Docker

```shell
docker-compose build --compress --pull
docker-compose up
```

### Local VirtualEnv

```shell
pipenv install --skip-lock
pipenv run jupyter-notebook
```

