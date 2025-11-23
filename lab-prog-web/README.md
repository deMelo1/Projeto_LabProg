# Central de Controle do Grifo

Sistema de gestão de estoque e cautelas para atlética.

## Tecnologias

- **Backend:** Java 21, Spring Boot 3.5, PostgreSQL
- **Frontend:** HTML5, CSS3, JavaScript
- **Mobile:** Flutter/Dart

## Configuração

### Backend

```bash
./gradlew bootRun
```

### Acesso

- Web: `http://localhost:8081/login.html`
- Usuário padrão: `grifo` / `grifo1792`

## Estrutura

```
src/
├── main/
│   ├── java/          # Controllers, Services, Entities
│   └── resources/
│       ├── static/    # Frontend web
│       └── application.properties
```

## Deploy

Railway: `https://teste-lab-prog-production.up.railway.app`

