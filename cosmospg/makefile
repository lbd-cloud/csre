.PHONY: build init-network generate-keys start-network stop-network clean

# Network and version settings
CHAIN_ID=csre
IMAGE_NAME=cosmos-sdk-image

# Validator and account settings
VALIDATOR1_NAME=validator1
VALIDATOR2_NAME=validator2
GENESIS_ACCOUNT_AMOUNT=<amount>
DOCKER_VOLUME_PATH=$(PWD)/build

# Build the docker image
build:
	@echo "Building custom Cosmos SDK image..."
	docker build -t $(IMAGE_NAME) .

# Generate keys for validators
generate-keys:
	@echo "Generating keys for validators..."
	# Generate key for validator1 and capture the address
	$(eval VALIDATOR1_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/cosmos $(IMAGE_NAME) simd keys add $(VALIDATOR1_NAME) | grep "address:" | cut -d' ' -f2))
	# Generate key for validator2 and capture the address
	$(eval VALIDATOR2_ADDRESS=$(shell docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/cosmos $(IMAGE_NAME) simd keys add $(VALIDATOR2_NAME) | grep "address:" | cut -d' ' -f2))

# Initialize the network
init-network: generate-keys
	@echo "Initializing network with validators: $(VALIDATOR1_NAME), $(VALIDATOR2_NAME)"
	# Initialize the genesis file for the first validator
	docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/cosmos $(IMAGE_NAME) init $(VALIDATOR1_NAME) --chain-id $(CHAIN_ID)
	# Add genesis accounts
	docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/cosmos $(IMAGE_NAME) add-genesis-account $(VALIDATOR1_ADDRESS) $(GENESIS_ACCOUNT_AMOUNT)
	docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME):/cosmos $(IMAGE_NAME) add-genesis-account $(VALIDATOR2_ADDRESS) $(GENESIS_ACCOUNT_AMOUNT)
	# Create and collect gentx for the first validator
	docker run --rm -v $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME):/cosmos $(IMAGE_NAME) gentx $(VALIDATOR1_NAME) $(GENESIS_ACCOUNT_AMOUNT) --chain-id $(CHAIN_ID)
	# Copy the genesis file to the second validator
	cp -r $(DOCKER_VOLUME_PATH)/$(VALIDATOR1_NAME)/config/genesis.json $(DOCKER_VOLUME_PATH)/$(VALIDATOR2_NAME)/config/genesis.json

# Start the network
start-network:
	@echo "Starting network..."
	docker-compose up -d

# Stop the network
stop-network:
	@echo "Stopping network..."
	docker-compose down

# Clean up the environment
clean:
	@echo "Cleaning up..."
	rm -rf $(DOCKER_VOLUME_PATH)
