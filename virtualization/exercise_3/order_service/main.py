from flask import Flask, request, abort
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.storage.queue import QueueServiceClient

app = Flask(__name__)

key_vault_name = 'hkr-kv-gtc'
key_vault_uri = f"https://{key_vault_name}.vault.azure.net"

credential = DefaultAzureCredential()
client = SecretClient(vault_url=key_vault_uri, credential=credential)
api_key = client.get_secret('api-key').value

# Get the storage account key from Azure Key Vault
storage_account_key = client.get_secret('storage-account-key').value

queue_service_client = QueueServiceClient(account_url="https://stacchkrgtc.queue.core.windows.net",
                                          credential=storage_account_key)
queue_client = queue_service_client.get_queue_client("stqhkr")

@app.route('/order', methods=['POST'])
def create_order():
    # Check for API key in request header
    incoming_api_key = request.headers.get('X-API-Key')
    if incoming_api_key != api_key:
        abort(401, 'Invalid API Key')

    # Process the order
    order = request.json
    queue_client.send_message(str(order))

    return 'Order processed successfully', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
