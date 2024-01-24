.PHONY: build init-network generate-keys start-network stop-network clean

# Network and version settings
CHAIN_ID=csre
IMAGE_NAME=cosmos-sdk-image

# Validator and account settings
VALIDATOR1_NAME=validator1
VALIDATOR2_NAME=validator2
GENESIS_ACCOUNT_AMOUNT=10000000000stake
DOCKER_VOLUME_PATH=$(PWD)/build

# Build the docker image
build:
	@echo "Building custom Cosmos SDK image..."
	@echo "docker build -t $(IMAGE_NAME) ."
	@docker build -t $(IMAGE_NAME) .

# Generate keys for validators
generate-keys:
	@echo "Generating keys for validator1..."
	@echo "docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd keys add $(VALIDATOR1_NAME) --keyring-backend file"
	$(eval VALIDATOR1_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd keys add $(VALIDATOR1_NAME) --keyring-backend file | grep -o 'cosmos[[:alnum:]]*' | head -n 1))
	@echo "Validator1 address: $(VALIDATOR1_ADDRESS)"

	@echo "Generating keys for validator2..."
	@echo "docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/root/.simapp $(IMAGE_NAME) simd keys add $(VALIDATOR2_NAME) --keyring-backend file"
	$(eval VALIDATOR2_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/root/.simapp $(IMAGE_NAME) simd keys add $(VALIDATOR2_NAME) --keyring-backend file | grep -o 'cosmos[[:alnum:]]*' | head -n 1))
	@echo "Validator2 address: $(VALIDATOR2_ADDRESS)"

# Initialize the network
init-network: generate-keys
	@echo "Initializing network with validators: $(VALIDATOR1_NAME), $(VALIDATOR2_NAME)"
	@echo "Creating directories for validator nodes..."
	@mkdir -p $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME)
	@mkdir -p $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME)

	@echo "Initializing the genesis file for $(VALIDATOR1_NAME)"
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd init $(VALIDATOR1_NAME) --home /root/.simapp --chain-id $(CHAIN_ID)
	@echo "Adding genesis account for $(VALIDATOR1_NAME)"
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd genesis add-genesis-account $(VALIDATOR1_ADDRESS) $(GENESIS_ACCOUNT_AMOUNT) --home /root/.simapp --keyring-backend file

	@echo "Creating and collecting gentx for $(VALIDATOR1_NAME)"
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd genesis gentx $(VALIDATOR1_NAME) $(GENESIS_ACCOUNT_AMOUNT) --home /root/.simapp --chain-id $(CHAIN_ID) --keyring-backend file

	@echo "Copying the genesis file to $(VALIDATOR2_NAME)"
	@cp $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME)/config/genesis.json $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME)/config/

	@echo "Collecting gentxs..."
	@docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/root/.simapp $(IMAGE_NAME) simd genesis collect-gentxs --home /root/.simapp
	@echo "Copying the final genesis file to $(VALIDATOR2_NAME)"
	@cp $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME)/config/genesis.json $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME)/config/


# Start the network
start-network:
	@echo "Starting network..."
	@echo "docker-compose up -d"
	@docker-compose up -d

# Stop the network
stop-network:
	@echo "Stopping network..."
	@echo "docker-compose down"
	@docker-compose down

# Clean up the environment
clean:
	@echo "Cleaning up..."
	@echo "rm -rf $(DOCKER_VOLUME_PATH)"
	@rm -rf $(DOCKER_VOLUME_PATH)
