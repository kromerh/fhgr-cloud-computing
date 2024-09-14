from flask import Flask, request, abort
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.queue import QueueServiceClient
import logging
import sys

KET_VAULT_NAME = 'hkr-kv-webshop'
STORAGE_ACCOUNT_NAME = 'staccwebshophkr'
QUEUE_NAME = 'hkrqueue'

logger = logging.getLogger('order_service')
logger.setLevel(logging.DEBUG)

handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

logger.addHandler(handler)

app = Flask(__name__)

key_vault_name = KET_VAULT_NAME
key_vault_uri = f"https://{key_vault_name}.vault.azure.net"
logger.info(f'Accessed Key Vault URI: {key_vault_uri}')

credential = DefaultAzureCredential()
client = SecretClient(vault_url=key_vault_uri, credential=credential)

api_key = client.get_secret('api-key').value
logger.info('Read API Key from key vault.')

storage_account_key = client.get_secret('storage-account-key').value
logger.info('Read storage account key from key vault.')

queue_service_client = QueueServiceClient(account_url=f"https://{STORAGE_ACCOUNT_NAME}.queue.core.windows.net",
                                          credential=storage_account_key)

queue_client = queue_service_client.get_queue_client(QUEUE_NAME)
logger.info('Connected to Azure Queue Service.')

@app.route('/order', methods=['POST'])
def create_order():
    incoming_api_key = request.headers.get('X-API-Key')
    if incoming_api_key != api_key:
        logger.warning('Unauthorized access attempt detected.')
        abort(401, 'Invalid API Key')

    order = request.json
    queue_client.send_message(str(order))
    logger.info('Order processed and sent to the queue.')

    return 'Order processed successfully', 200

if __name__ == '__main__':
    logger.info('Starting the order service.')
    app.run(host='0.0.0.0', port=5000)
    logger.info('Order service stopped.')
