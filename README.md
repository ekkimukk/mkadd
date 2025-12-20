
```
███╗   ███╗██╗  ██╗ █████╗ ██████╗ ██████╗  
████╗ ████║██║ ██╔╝██╔══██╗██╔══██╗██╔══██╗
██╔████╔██║█████╔╝ ███████║██║  ██║██║  ██║
██║╚██╔╝██║██╔═██╗ ██╔══██║██║  ██║██║  ██║
██║ ╚═╝ ██║██║  ██╗██║  ██║██████╔╝██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═════╝ 
```
**MKADD** - это аббревиату́ра от *Миша*, *Костя*, *Алёна*, *Даня*, *Дима*. Альтернативным вариантом был **Paint 2**.
# Что делает это приложение? 
## <Тут GIF не забыть вставить> 

# Требования к выполнению работы  
- Для хранения кода используется Git (GitHub)
- Наличиствует два сервиса (backend и frontend)
- Используется PostgreSQL
- Для контейнеризации используется Docker
- CI/CD-конфигурация представлена в `.github/workflows/`
- Kubernetes забыт
- Про Helm charts и Terraform тут тоже не слышали
- Секреты хранятся посредством GitHub Secrets

# Этапы выполнения работы
## 1. Описание репозитория  
- Проект состоит из двух сервисов: бэкенда на Go и фронтенда на Flutter.
- Репозиторий имеет следующую структуру:
```
├── assets/          # тут я картинки для README.md храню
├── back/            # бэк (на Go)
│   ├── cmd/app/     # точка входа приложения
│   ├── internal/    # архитектура (по-хорошему нужно у Алены с Костей спросить):
│   │   ├── domain/  # сущности и логика
│   │   ├── app/     # use cases и сервисы
│   │   └── adapters/# http-хендлеры, репозитории, интеграции и прочее 
│   ├── pkg/         # переиспользуемые компоненты (ошибки, swagger, websocket)
│   ├── swagger/     # автогенерируемая OpenAPI-документация
│   └── ...          # Dockerfile, docker-compose, тесты
├── front/           # фронт (тут Flutter)
│   ├── lib/
│   │   ├── core/    # базовые компоненты (API-клиент, темизация)
│   │   ├── features/# фичи по модулям (лучше у Миши с Димой спросить):
│   │   │   ├── registration/ # аутентификация
│   │   │   └── whiteboard/   # интерактивная доска с инструментами рисования
│   │   └── ...      # сервисы, виджеты
│   └── ...          # конфиги для разных платформ, Dockerfile
├── .github/         # ci/cd непосредственно
└── README.md        # данная документация
```
- Вся база данных PostgreSQL описана в `./internal/adapters/repositories/*.go`. Мне очень не хочется здесь рисовать её схему, спасибо за понимание.

## 2. CI: сборка и проверка  
- Ни линтеров, ни unit-тестов не вставляли  
- Интеграционные тесты тоже не запускаем
- Про security scan (SAST, SCA) я даже не слышал, если честно  
- Docker-образы собираются и загружаются в реестр GitHub
- Запрещать пуш при критических уязвимостях мне представляется высшим пилотажем, поэтому я этого не добавял  

## 3. CD: развёртывание в Kubernetes  
![Kubernetes Meme](./assets/kube.jpg)

Всё работает на Docker Compose и с божьей помощью.

- Никаких helm-чартов для сервисов
- Никакой стратегии canary или blue-green
- Readiness/Liveness probes не настроены
- Автоматического rollback при ошибках не происходит
- Миграций БД нет  

## 4. Наблюдаемость и тестирование  
Мемов про Prometheus и Grafana у меня, к сожалению, нет

# Дополнительно

## Развертывание на localhost
![localhost Meme](./assets/localhost.jpg)

Если хотите увидеть процесс сборки и пуша, откройте Issue, я получу письмо и запущу процесс вручную на локальном сервере

## Исходные репозитории
Исходный код со всеми ветками и коммитами представлен в частных репозиториях [Tummix/LifeCickle_Back](https://github.com/Tummix/LifeCickle_Back) и [Tummix/LifeCickle_Front](https://github.com/Tummix/LifeCickle_Front). 
<details>

<summary>В качестве альтернативы мною здесь представлены ветки и коммиты в данных репозиториях посредством вывода `git log --oneline --graph --all --decorate`</summary>

  ```go
fmt.Println("Это пример кода внутри сворачиваемого блока")

```
* 205b503 (HEAD -> main, origin/main, origin/HEAD) qwe
* 7e121be fix board context
*   f0e76bf Merge pull request #4 from Tummix/misha
|\  
| * 55e1c76 (origin/misha) v0.6
| *   3534114 Merge pull request #3 from Tummix/main
| |\  
| |/  
|/|   
* | 1f985c2 api auth
* | a36f0a1 misha: remove generated files
|/  
* 16159d6 v0.51
* cb63ef1 v0.5 Fixed menu whiboard
* cac5dd3 v0.4 (whiteboard_test)
* ef0824f v0.4
* deff21f menu
* a9e833c repo
* 0616d07 work
*   d9400bf Merge pull request #1 from Tummix/misha
|\  
| * 4baacd0 Update README.md
| * 09c09cc v0.2beta
| * c81beaf registartion form
|/  
* e66cd8c tytyt
* d4c8f01 Initial commit
```
```

# Авторы: 
- [Alena Kharlova](https://github.com/Khrllw) (главная по бэку)
- [Danila Danenko](https://github.com/ekkimukk) (DevSecFinAIOps данного проекта)
- [Dmitry Lutsenko](https://github.com/LendorD) (фронтенд)
- [Mikhail Tumin](https://github.com/Tummix) (генеральный директор)
- [Konstantin Khaidarshin](https://github.com/MENGERSPONGEKNGLTYN) (просто лучший друг гендира)
