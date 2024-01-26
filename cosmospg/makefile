.PHONY: build init-network generate-keys start-network stop-network clean full-test

# Network and version settings
CHAIN_ID=csre-1

IMAGE_NAME=simd:latest

# Validator and account settings
VALIDATOR1_NAME=validator1
VALIDATOR2_NAME=validator2
GENESIS_ACCOUNT_AMOUNT=10000000000stake
DOCKER_VOLUME_PATH=$(PWD)/validators

# Build the docker image
build:
	@echo "Building custom Cosmos SDK image..."
	@docker build -t $(IMAGE_NAME) .

# Full test: Generate keys, initialize network, start network, wait, and then test the network
full-test: generate-all-keys init-network start-network wait-for-network test-network

wait-for-network:
	@echo "Waiting for network to be ready..."
	@sleep 30 # Waits for 30 seconds


# Generate keys for a validator
generate-keys:
	@if [ -z "$(VALIDATOR_NAME)" ]; then \
		echo "No VALIDATOR_NAME provided. Exiting..."; \
		exit 1; \
	fi
	@echo "Listing Current Keys for $(VALIDATOR_NAME)... "
	@docker run --rm -it -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR_NAME):/root/.simapp $(IMAGE_NAME) simd keys list --keyring-backend test

	@echo "Generating keys for $(VALIDATOR_NAME)..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR_NAME):/root/.simapp $(IMAGE_NAME) simd keys add $(VALIDATOR_NAME) --keyring-backend test

	@echo "Retrieving address for $(VALIDATOR_NAME)..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR_NAME):/root/.simapp $(IMAGE_NAME) simd keys show $(VALIDATOR_NAME) -a --keyring-backend test


# Generate keys for validator1 and validator2
generate-all-keys:
	$(MAKE) generate-keys VALIDATOR_NAME=validator1
	$(MAKE) generate-keys VALIDATOR_NAME=validator2


# Initialize the network
init-network: clean generate-all-keys
	@echo "Initializing network with 2 validators"

	# Retrieve validator addresses directly from the keyring
	$(eval VALIDATOR1_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd keys show $(VALIDATOR1_NAME) -a --keyring-backend test))
	$(eval VALIDATOR2_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/root/.simapp $(IMAGE_NAME) simd keys show $(VALIDATOR2_NAME) -a --keyring-backend test))

	# Initialize the genesis file and add genesis account for Validator 1
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd init $(VALIDATOR1_NAME) --home /root/.simapp --chain-id $(CHAIN_ID)
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd genesis add-genesis-account $(VALIDATOR1_ADDRESS) $(GENESIS_ACCOUNT_AMOUNT) --home /root/.simapp --keyring-backend test

	# Create gentx for Validator 1
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd genesis gentx $(VALIDATOR1_NAME) $(GENESIS_ACCOUNT_AMOUNT) --home /root/.simapp --chain-id $(CHAIN_ID) --keyring-backend test

	# Initialize the genesis file and add genesis account for Validator 2
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/root/.simapp $(IMAGE_NAME) simd init $(VALIDATOR2_NAME) --home /root/.simapp --chain-id $(CHAIN_ID)
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/root/.simapp $(IMAGE_NAME) simd genesis add-genesis-account $(VALIDATOR2_ADDRESS) $(GENESIS_ACCOUNT_AMOUNT) --home /root/.simapp --keyring-backend test

	# Create gentx for Validator 2
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/root/.simapp $(IMAGE_NAME) simd genesis gentx $(VALIDATOR2_NAME) $(GENESIS_ACCOUNT_AMOUNT) --home /root/.simapp --chain-id $(CHAIN_ID) --keyring-backend test

	# Collect gentxs and finalize the genesis file
	@echo "Collecting gentxs..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd genesis collect-gentxs --home /root/.simapp

	# Copy the final genesis file to both validators using Docker to avoid permission issues
	@echo "Copying the final genesis file to $(VALIDATOR2_NAME)"
	@docker run --rm -v $(DOCKER_VOLUME_PATH):/data $(IMAGE_NAME) cp /data/$(VALIDATOR1_NAME)/config/genesis.json /data/$(VALIDATOR2_NAME)/config/genesis.json
	@echo "Genesis file copied to $(VALIDATOR2_NAME)"

	@echo "Copying the final genesis file back to $(VALIDATOR1_NAME)"
	@docker run --rm -v $(DOCKER_VOLUME_PATH):/data $(IMAGE_NAME) cp /data/$(VALIDATOR2_NAME)/config/genesis.json /data/$(VALIDATOR1_NAME)/config/genesis.json
	@echo "Genesis file copied back to $(VALIDATOR1_NAME)"

# Test the network by creating an account, checking balances, performing a transaction, and checking balances again
test-network:
	# Create accounta and get its address
	@echo "Creating accounta..."
	$(eval ACCOUNT_A_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/accounta:/root/.simapp $(IMAGE_NAME) simd keys add csreaccount --home /root/.simapp --keyring-backend test | grep -o 'cosmos[[:alnum:]]*' | head -n 1))
	@echo "accounta address: $(ACCOUNT_A_ADDRESS)"

	@if [ -z "$(ACCOUNT_A_ADDRESS)" ]; then \
		echo "Error: Failed to retrieve accounta address"; \
		exit 1; \
	fi

	# Check balance of the Genesis account
	@echo "Checking balance of the Genesis account..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd query bank balances $(VALIDATOR1_ADDRESS) --home /root/.simapp

	# Check balance of accounta
	@echo "Checking balance of accounta..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/accounta:/root/.simapp $(IMAGE_NAME) simd query bank balances $(ACCOUNT_A_ADDRESS) --home /root/.simapp

	# Execute transaction from Genesis account to accounta
	@echo "Executing transaction from Genesis account to accounta..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd tx bank send $(VALIDATOR1_ADDRESS) $(ACCOUNT_A_ADDRESS) 100000stake --from $(VALIDATOR1_NAME) --keyring-backend test --home /root/.simapp -y

	# Check balance of the Genesis account again
	@echo "Checking balance of the Genesis account again..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd query bank balances $(VALIDATOR1_ADDRESS) --home /root/.simapp

	# Check balance of accounta again
	@echo "Checking balance of accounta again..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/accounta:/root/.simapp $(IMAGE_NAME) simd query bank balances $(ACCOUNT_A_ADDRESS) --home /root/.simapp


# Start the network
start-network:
	@echo "Starting network with 2 validatos ..."
	@docker-compose up -d validator1 validator2

# Stop the network
stop-network:
	@echo "Stopping network..."
	@docker-compose down

# Clean up the environment
clean:
	@echo "Cleaning up..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH):/data --user root $(IMAGE_NAME) rm -rf /data/* /data/*/* /data/*/*/*
