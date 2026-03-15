# DariBudget

![status](https://img.shields.io/badge/status-MVP-yellow)
![license](https://img.shields.io/badge/license-MIT-blue)
![stack](https://img.shields.io/badge/stack-React%20%2B%20Node%20%2B%20PostgreSQL-3b82f6)

Smart household budgeting (FR/AR/EN).

## ✨ Features
- Expenses + categories
- Category budgets
- Dashboard
- Shopping list
- i18n FR/AR/EN

## 🎬 Demo
- Screenshots / video: _to add_ (see `docs/`)
- Live URL: _to add_

## 🧱 Stack
- **Web**: React + Vite + Tailwind
- **API**: Node.js + Express
- **DB**: PostgreSQL

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- npm
- PostgreSQL

### Install
```bash
npm install
```

### Environment variables
Copy examples:

```bash
cp backend/.env.example backend/.env
cp web/.env.example web/.env
```

**Backend (.env)**
- `PORT`
- `FRONTEND_URL`
- `DATABASE_URL`

**Web (.env)**
- `VITE_API_URL`

### Run locally
**API**
```bash
cd backend
npm run dev
```

**Web**
```bash
cd web
npm run dev
```

## 📁 Structure
- `backend/` Express API
- `web/` React web app
- `mobile/` Mobile app
- `shared/` Types / utilities
- `docs/` Documentation

## ✅ Scripts
- `npm run lint`
- `npm run format`

## 🤝 Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md)

## 🔐 Security
See [SECURITY.md](SECURITY.md)

## 📜 License
MIT — see [LICENSE](LICENSE)
