"""
This module builds shared parts for other modules.
"""

import json
import os

from fastapi.templating import Jinja2Templates

with open('config.json') as config_json:
  config = json.load(config_json)
  users = config['users']
  db_config = config['db_config']

DEPLOY_REF = os.getenv("DEPLOY_REF", "NA")

secret_key = config['secret_key']

templates = Jinja2Templates(directory="templates")