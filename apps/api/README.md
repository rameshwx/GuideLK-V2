# GuideLK API

FastAPI application backed by MySQL 8 with SRID 4326 spatial columns and Firebase authentication.

## Local development

1. Create a Python 3.11 virtual environment.
2. Install dependencies: `pip install -r requirements-dev.txt`.
3. Export environment variables or create a `.env` file based on `.env.example`.
4. Run migrations (see `infra/sql`).
5. Start the server:
   ```bash
   uvicorn app.main:app --reload --port 8000
   ```

The application expects to run behind `/guidelkv2/api/` in production. Adjust `API_ROOT_PATH`
if deploying elsewhere.
