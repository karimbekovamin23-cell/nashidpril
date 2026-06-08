# NashidPril — Исламская аудиоплатформа

Приложение для Android и iOS: нашиды + Коран. Аналог Spotify для исламского контента.

## Структура проекта

```
Nashidpril/
├── backend/          — Node.js + Express + Prisma + PostgreSQL + AWS S3
└── mobile/           — Flutter (Android + iOS)
```

---

## Backend

### Установка

```bash
cd backend
cp .env.example .env    # заполните переменные
npm install
npx prisma migrate dev  # создание таблиц в PostgreSQL
npm run dev             # запуск на порту 3000
```

### Переменные окружения (.env)

| Переменная | Описание |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `JWT_SECRET` | Секрет для JWT токенов |
| `GOOGLE_CLIENT_ID` | Google OAuth Client ID |
| `AWS_ACCESS_KEY_ID` | AWS ключ доступа |
| `AWS_SECRET_ACCESS_KEY` | AWS секретный ключ |
| `AWS_REGION` | Регион S3 (например `eu-central-1`) |
| `AWS_S3_BUCKET` | Название S3 bucket |

### API endpoints

| Метод | Путь | Описание |
|---|---|---|
| POST | `/api/auth/google` | Вход через Google (idToken) |
| POST | `/api/auth/role` | Выбор роли (LISTENER/ARTIST) |
| GET | `/api/auth/me` | Текущий пользователь |
| GET | `/api/nasheeds` | Список нашидов (page, sort) |
| GET | `/api/nasheeds/search?q=` | Поиск |
| POST | `/api/nasheeds` | Загрузить нашид (только верифицированные артисты) |
| DELETE | `/api/nasheeds/:id` | Удалить нашид |
| POST | `/api/nasheeds/:id/like` | Лайк |
| DELETE | `/api/nasheeds/:id/like` | Убрать лайк |
| POST | `/api/nasheeds/:id/play` | Записать прослушивание |
| GET | `/api/artists/:id` | Профиль артиста |
| GET | `/api/artists/:id/nasheeds` | Нашиды артиста |
| POST | `/api/artists/verification` | Подать заявку на верификацию |
| PATCH | `/api/artists/:id/verification` | Одобрить/отклонить (Admin) |
| GET | `/api/quran` | Список сур Корана |
| GET | `/api/quran/:id` | Одна сура |
| GET | `/api/stats/artist` | Статистика артиста |
| GET | `/api/users/me/liked` | Понравившиеся нашиды |
| GET | `/api/users/me/history` | История прослушиваний |

---

## Mobile (Flutter)

### Установка

```bash
cd mobile
flutter pub get
flutter run
```

### Настройка Google Sign-In

**Android** — добавьте `google-services.json` в `android/app/` и в `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

**iOS** — добавьте `GoogleService-Info.plist` в `ios/Runner/`

### Изменить URL бэкенда

Файл: `lib/services/api_service.dart`
- Android эмулятор: `http://10.0.2.2:3000/api`
- iOS симулятор: `http://localhost:3000/api`
- Продакшен: ваш домен

---

## Флоу приложения

```
Запуск → Проверка JWT
  ├── Нет токена → Экран входа (Google)
  │     └── Новый пользователь → Выбор роли
  │           ├── Слушатель → Главная
  │           └── Исполнитель → Верификация → Ожидание → Главная
  └── Есть токен → Главная

Главная → Список нашидов → Плеер
       → Поиск
       → Коран (114 сур)
       → Библиотека (лайки)
       → Профиль
             └── Исполнитель: Загрузить нашид / Статистика
```

---

## Технологии

**Backend:** Node.js, Express, Prisma, PostgreSQL, AWS S3, JWT, Google OAuth

**Mobile:** Flutter, Riverpod (state management), go_router, just_audio, dio, Google Sign-In
