
# Entorno de desarrollo en Docker con Docker Compose para Rails versión ^5.2.4 y Ruby ^2.5.8, Postgres 11 y Sqlite.

## Configuración e Instalación en Desarrollo

### Paso 1: Lectura de Requisitos Previos

- [x] Docker
- [x] Docker Compose
- [x] (Opcional según sea el caso) Tener una instancia de Postgres (Puede ser en Local o en algún Servidor externo) que posteriormente se deberá configurar.

#### Paso 2 (Opcional): Config. de Aliases, abreviaciones para docker compose

Si usas MacOS ó Linux, en tu archivo **.bashrc**, **.profile** o **.zshrc**, copia y pega al final del archivo lo siguiente:

Aliases:
```
alias dc='docker-compose'
alias dce='docker-compose exec'
alias dcr='docker-compose run'
alias dcl='docker-compose logs'
alias dclf='docker-compose logs -f'
alias dcup='docker-compose up'
alias dcdown='docker-compose down'
alias dcstop='docker-compose stop'
```

Para activarlos simplemente ejecuta el comando según el archivo que utilizas:

Solo escoge el comando del archivo que utilizas en tu terminal
```
source ~/.bashrc
source ~/.profile
source ~/.zshrc
```

### Paso 3: Configurar las variables de entorno

Crea un nuevo archivo de variables de entorno en el directorio deploy/local/ con el nombre .env con las siguientes variables (Puedes modificar las variables segun tu usuario, password y host de la base):

```
# En el caso de usar URL
DATABASE_URL=postgres://postgres:Postgres2020!@postgres:5432/pgrailsdb

# En el caso de usar variables de configuración
POSTGRES_DB=pgrailsdb
POSTGRES_USER=postgres
POSTGRES_PASS=Postgres2020!

# Descomentar y usar solo una según el caso

# Cuando tienes el motor corriendo en otra instancia por ip o servicio
# POSTGRES_HOST=hostorip

# Cuando usas la instalación con el motor en la misma instancia
# POSTGRES_HOST=postgres


SMTP_USER=
SMTP_DOMAIN=
SMTP_SECRET=
SMTP_PORT=25
SMTP_ADDRESS=
SMTP_FROM_EMAIL=

RAILS_LOG_TO_STDOUT=true
RAILS_LOG_LEVEL=debug
```


### Paso 4: Instalación y Ejecución en entorno Local (2 opciones), favor leer bien las instrucciones y elegir una de las opciones segun sea el caso (Opción 1 u Opción 2):

Revisa el archivo docker-compose.yml para que puedas identificar los contenedores que van a ser llamados en los pasos posteriores para que puedas comprender que servicio es el que se levanta en cada opción.

#### Opción 1: Levantar la aplicación rails en local y conectandola a postgres en un servidor externo.

Si deseas desplegar solo la aplicación y tienes el motor de base de datos de postgres ya corriendo en otra instancia o servidor ejecuta lo siguiente y luego sigue las instrucciones de los siguientes pasos:

Instalación de la imagen:
```
docker-compose up -d --build rails_local
```

Instalación de las Gemas: rails, sqlite y pg (Requiere que se haya hecho el Paso 3, ya que esto hace uso del archivo de variables de entorno).
```
docker-compose run --entrypoint='sh /usr/local/bin/install-rails' rails_local sh -c
```

Crear la aplicación:
```
docker-compose run --entrypoint='sh /usr/local/bin/craft-app' rails_local sh -c
```


En tu archivo Gemfile incorpora la gema pg para trabajar con Postgresql
```
...
gem 'rails', '~> 5.2.4', '>= 5.2.4.2'
gem 'sqlite3'
...
gem 'pg', '~> 1.2.3' # <-- THIS
...
gem 'puma', '~> 3.11'
...
```

Dentro de la carpeta app/config/ modifica el archivo database.yml y configura tu base de datos postgres, usaremos la siguiente configuración por defecto (basado en variables de entorno):
```
default: &default
  # adapter: sqlite3
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  encoding: unicode
  database: <%= ENV.fetch("POSTGRES_DB") %>
  username: <%= ENV.fetch("POSTGRES_USER") %>
  host: <%= ENV.fetch("POSTGRES_HOST") %>
  password: <%= ENV.fetch("POSTGRES_PASS") %>
```

En los demas ambientes, usaremos la siguiente configuración por defecto, ya que solo usaremos la local.
```
development:
  <<: *default
  # database: db/development.sqlite3
test:
  <<: *default
  # database: db/test.sqlite3
production:
  <<: *default
  # database: db/production.sqlite3
```

Luego debes eliminar el fichero Gemfile.lock, para incluir todas las nuevas dependencias en el bundle.

Para instalar dependencias que se hayan configurado de forma manual en el paso anterior (Opcional, pero si lo realizaste debes ejecutarlo de igual forma).
```
docker-compose run --entrypoint='sh /usr/local/bin/bundle-deps' rails_local sh -c
```

Ejecutamos la creación de la base de datos y corremos las migraciones:
```
docker-compose run --entrypoint='rails db:create' rails_local
docker-compose run --entrypoint='rails db:migrate' rails_local
docker-compose run --entrypoint='rails db:seed' rails_local
```

Finalmente levantar la aplicación:
```
docker-compose run --publish 3000:3000 --entrypoint='sh /usr/local/bin/init-app' rails_local sh -c
```

#### Opción 2:
Si deseas desplegar el contenedor de la app más la base de datos incluida en el build ejecuta lo siguiente y luego sigue las instrucciones de los siguientes pasos:

Instalación de la imagen:
```
docker-compose up -d --build railspg_local
```

Instalación de las Gemas: rails, sqlite y pg (Requiere que se haya hecho el Paso 3, ya que esto hace uso del archivo de variables de entorno).
```
docker-compose run --entrypoint='sh /usr/local/bin/install-rails' rails_local sh -c
```

Crear la aplicación:
```
docker-compose run --entrypoint='sh /usr/local/bin/craft-app' rails_local sh -c
```


En tu archivo Gemfile incorpora la gema pg para trabajar con Postgresql
```
...
gem 'rails', '~> 5.2.4', '>= 5.2.4.2'
gem 'sqlite3'
...
gem 'pg' # <-- THIS
...
gem 'puma', '~> 3.11'
...
```

Dentro de la carpeta app/config/ modifica el archivo database.yml y configura tu base de datos postgres, usaremos la siguiente configuración por defecto (basado en variables de entorno):
```
default: &default
  # adapter: sqlite3
  adapter: postgresql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000
  encoding: unicode
  database: <%= ENV.fetch("POSTGRES_DB") %>
  username: <%= ENV.fetch("POSTGRES_USER") %>
  host: <%= ENV.fetch("POSTGRES_HOST") %>
  password: <%= ENV.fetch("POSTGRES_PASS") %>
```

En los demas ambientes, usaremos la siguiente configuración por defecto, ya que solo usaremos la local.
```
development:
  <<: *default
  # database: db/development.sqlite3
test:
  <<: *default
  # database: db/test.sqlite3
production:
  <<: *default
  # database: db/production.sqlite3
```

Luego debes eliminar el fichero Gemfile.lock, para incluir todas las nuevas dependencias en el bundle.

Para instalar dependencias que se hayan configurado de forma manual en el paso anterior (Opcional, pero si lo realizaste debes ejecutarlo de igual forma).
```
docker-compose run --entrypoint='sh /usr/local/bin/bundle-deps' rails_local sh -c
```

Ejecutamos la creación de la base de datos y corremos las migraciones:
```
docker-compose run --entrypoint='rails db:create' rails_local
docker-compose run --entrypoint='rails db:migrate' rails_local
docker-compose run --entrypoint='rails db:seed' rails_local
```

Finalmente levantar la aplicación:
```
docker-compose run --publish 3000:3000 --entrypoint='sh /usr/local/bin/init-app' rails_local sh -c
```