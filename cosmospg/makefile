.PHONY: build init-network generate-keys start-network stop-network clean full-test

# Network and version settings
CHAIN_ID=csre-1
DENOM=csre

IMAGE_NAME=simd:latest

# Validator and account settings
VALIDATOR1_NAME=validator1
VALIDATOR2_NAME=validator2
GENESIS_ACCOUNT_AMOUNT=10000000000000csre
DOCKER_VOLUME_PATH=$(PWD)/validators

# Build the docker image
build:
	@echo "Building custom Cosmos SDK image..."
	@docker build -t $(IMAGE_NAME) .

# Full test: Generate keys, initialize network, start network, wait, and then test the network
full-test: clean generate-all-keys init-network start-network wait-for-network test-network

wait-for-network:
	@echo "Waiting for network to be ready..."
	@sleep 30 # Waits for 30 seconds

# Generate keys for a validator
generate-keys:
	@if [ -z "$(VALIDATOR_NAME)" ]; then \
		echo "No VALIDATOR_NAME provided. Exiting..."; \
		exit 1; \
	fi
	@echo "Generating keys for $(VALIDATOR_NAME)..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR_NAME):/root/.simapp $(IMAGE_NAME) sh -c \
	"simd keys add $(VALIDATOR_NAME) --keyring-backend test > /root/.simapp/$(VALIDATOR_NAME)_output.txt && \
	cat /root/.simapp/$(VALIDATOR_NAME)_output.txt | grep 'address:' | awk '{print \$$3}' > /root/.simapp/$(VALIDATOR_NAME)_address.txt"

	@echo "Address for $(VALIDATOR_NAME):"
	@cat $(DOCKER_VOLUME_PATH)/$(VALIDATOR_NAME)/$(VALIDATOR_NAME)_address.txt || echo "Address file not found on host."

# Generate keys for validator1 and validator2
generate-all-keys:
	$(MAKE) generate-keys VALIDATOR_NAME=validator1
	$(MAKE) generate-keys VALIDATOR_NAME=validator2
        # Create accounta and get its address
	@echo "Creating account A ..."
	$(MAKE) generate-keys VALIDATOR_NAME=accounta


# Initialize the network
init-network: clean generate-all-keys
	@echo "Initializing network with 2 validators"
	$(eval VALIDATOR1_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp --entrypoint cat $(IMAGE_NAME) /root/.simapp/$(VALIDATOR1_NAME)_address.txt | tr -d '\n'))
	$(eval VALIDATOR2_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/root/.simapp --entrypoint cat $(IMAGE_NAME) /root/.simapp/$(VALIDATOR2_NAME)_address.txt | tr -d '\n'))

        # Initialize the genesis file and add genesis account for Validator 1
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd init --default-denom $(DENOM) $(VALIDATOR1_NAME) --home /root/.simapp --chain-id $(CHAIN_ID)
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd genesis add-genesis-account $(VALIDATOR1_ADDRESS) $(GENESIS_ACCOUNT_AMOUNT) 

        # Create gentx for Validator 1
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd genesis gentx $(VALIDATOR1_NAME) $(GENESIS_ACCOUNT_AMOUNT) --home /root/.simapp --chain-id $(CHAIN_ID) --keyring-backend test

        # Initialize the genesis file and add genesis account for Validator 2
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/root/.simapp $(IMAGE_NAME) simd init --default-denom $(DENOM) $(VALIDATOR2_NAME) --home /root/.simapp --chain-id $(CHAIN_ID)
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

        # Load addresses from files
	@echo "Loading Validator 1 address..."
	$(eval VALIDATOR1_ADDRESS=$(shell cat $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME)/$(VALIDATOR1_NAME)_address.txt))
	@echo "Validator 1 address: $(VALIDATOR1_ADDRESS)"

	@echo "Loading Validator 2 address..."
	$(eval VALIDATOR2_ADDRESS=$(shell cat $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME)/$(VALIDATOR2_NAME)_address.txt))
	@echo "Validator 2 address: $(VALIDATOR2_ADDRESS)"
	@echo "Loading Account A address..."
	$(eval ACCOUNT_A_ADDRESS=$(shell cat $(DOCKER_VOLUME_PATH)/accounta/accounta_address.txt))
	@echo "Account A address: $(ACCOUNT_A_ADDRESS)"

	@if [ -z "$(ACCOUNT_A_ADDRESS)" ]; then \
		echo "Error: Failed to retrieve accounta address"; \
		exit 1; \
	fi
	# Check balance of the Genesis account
	@docker exec -it --privileged validator1 simd query bank balances $(VALIDATOR1_ADDRESS) --home /root/client

	# Check balance of accounta
	@echo "Checking balance of accounta..."
	@docker exec -it --privileged validator1 simd query bank balances $(ACCOUNT_A_ADDRESS) --keyring-backend test

	# Execute transaction from Genesis account to accounta
	@echo "Executing transaction from Genesis account to accounta..."
	@docker exec -it validator1 simd  tx bank send $(VALIDATOR1_ADDRESS) $(ACCOUNT_A_ADDRESS) 1000000csre --from $(VALIDATOR1_NAME) --keyring-backend test --home /root/.simapp --chain-id $(CHAIN_ID) --yes 

	# Check balance of the Genesis account again
	@echo "Checking balance of the Genesis account again..."
	@docker exec validator1 simd query bank balances $(VALIDATOR1_ADDRESS) 

	# Check balance of accounta again
	@echo "Checking balance of accounta again..."
	@docker exec validator1 simd query bank balances $(ACCOUNT_A_ADDRESS)

# Add a new validator (validator3)
add-validator3:
	@if [ -z "$(VALIDATOR3_NAME)" ]; then \
		echo "No VALIDATOR3_NAME provided. Exiting..."; \
		exit 1; \
	fi
	@echo "Adding validator3..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR3_NAME):/root/.simapp $(IMAGE_NAME) sh -c \
	"simd keys add $(VALIDATOR3_NAME) --keyring-backend test > /root/.simapp/$(VALIDATOR3_NAME)_output.txt && \
	cat /root/.simapp/$(VALIDATOR3_NAME)_output.txt | grep 'address:' | awk '{print \$$3}' > /root/.simapp/$(VALIDATOR3_NAME)_address.txt"

	@echo "Address for $(VALIDATOR3_NAME):"
	@cat $(DOCKER_VOLUME_PATH)/$(VALIDATOR3_NAME)/$(VALIDATOR3_NAME)_address.txt || echo "Address file not found on host."

# Start the network
start-network:
	@echo "Starting network with 2 validatos ..."
	@docker compose up -d validator1 validator2

# Stop the network
stop-network:
	@echo "Stopping network..."
	@docker-compose down

# Clean up the environment
clean:
	@echo "Cleaning up..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH):/data --entrypoint /bin/sh $(IMAGE_NAME) -c 'rm -rf /data/* /data/validator1/* /data/validator2/* /data/validator3/*'
	@echo "Environment cleaned up."
