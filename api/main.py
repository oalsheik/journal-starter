from dotenv import load_dotenv
from fastapi import FastAPI
import logging

from api.routers.journal_router import router as journal_router

load_dotenv(override=True)

# Setup basic console logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI(title="Journal API",
              description="A simple journal API for tracking daily work, struggles, and intentions")
app.include_router(journal_router)

logger.info("Journal API application started")
