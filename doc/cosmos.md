# `Makefile` Explanation

The [Makefile](../cosmospg/makefile)  is used to automate various tasks related to managing a Cosmos testnet SDK-based blockchain network.

## Targets

### `build`
- Description: Builds a custom Cosmos SDK Docker image.
- Usage: `make build`

### `full-test`
- Description: Executes a series of actions to fully test the blockchain network, including generating keys, initializing the network, starting the network, waiting for it to be ready, and testing the network.
- Usage: `make full-test`

### `wait-for-network`
- Description: Pauses the execution for 30 seconds to wait for the blockchain network to become ready.
- Usage: This target is automatically called as part of the `full-test` target.

### `generate-keys`
- Description: Generates cryptographic keys for a given validator or account.
- Usage: `make generate-keys VALIDATOR_NAME=<validator_name>`

### `generate-all-keys`
- Description: Generates cryptographic keys for `validator1`, `validator2`, and `accounta`. It is used as part of the network initialization.
- Usage: This target is automatically called as part of the `full-test` target.

### `init-network`
- Description: Initializes the blockchain network with 2 validators (`validator1` and `validator2`), creates genesis accounts, generates and collects genesis transactions (gentxs), and copies the genesis file.
- Usage: `make init-network`

### `test-network`
- Description: Tests the blockchain network by checking balances, performing a transaction from the Genesis account to `accounta`, and checking balances again.
- Usage: This target is automatically called as part of the `full-test` target.

### `add-validator3`
- Description: Adds a new validator (`validator3`) to the network by generating keys for it.
- Usage: `make add-validator3 VALIDATOR3_NAME=<validator_name>`

### `start-network`
- Description: Starts the blockchain network with 2 validators (`validator1` and `validator2`) in detached mode using Docker Compose.
- Usage: `make start-network`

### `stop-network`
- Description: Stops the running blockchain network.
- Usage: `make stop-network`

### `clean`
- Description: Cleans up the environment by removing files and directories related to the blockchain network.
- Usage: `make clean`

## Network and Version Settings

- `CHAIN_ID`: The chain ID for the blockchain network.
- `DENOM`: The default denomination for the cryptocurrency used in the network.
- `IMAGE_NAME`: The name of the custom Docker image for the Cosmos SDK.
- `GENESIS_ACCOUNT_AMOUNT`: The initial amount of cryptocurrency for the genesis accounts.
- `DOCKER_VOLUME_PATH`: The path to the directory where Docker volumes for validator nodes are stored.

## Usage

To use this Makefile, navigate to the directory containing the Makefile and execute the desired target using the `make` command. For example, to build the custom Docker image, run `make build`. Ensure that you have Docker installed and properly configured on your system.
