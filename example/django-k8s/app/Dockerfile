# Dockerfile para aplicação Django com Gunicorn e UV
FROM python:3.13-slim

# Definir diretório de trabalho
WORKDIR /app

# Instalar dependências do sistema + UV
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements primeiro (para cache do Docker)
COPY ./requirements.txt .

# Instalar dependências Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código da aplicação
COPY ./django_k8s/ /app

# Coletar arquivos estáticos
RUN python manage.py collectstatic --noinput

# Criar usuário não-root
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# Expor porta
EXPOSE 8000

# Comando padrão
CMD ["gunicorn", "django_k8s.wsgi:application", "--bind", "0.0.0.0:8000"]
