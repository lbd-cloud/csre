FROM golang:alpine as builder

# Set the working directory in the container
WORKDIR /cosmos

# Install minimum necessary dependencies
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev
RUN apk add --no-cache $PACKAGES

# Clone the Cosmos SDK repository
RUN git clone https://github.com/cosmos/cosmos-sdk.git .

# Check out a specific version if needed
# RUN git checkout <version_tag>

# Build cosmosd and simapp
RUN  make build

# Start a new stage from scratch for a smaller, final image
FROM alpine:latest

WORKDIR /root/

# Copy the cosmosd and simapp binaries from the builder stage
COPY --from=builder /cosmos/build/simd /usr/bin/simd

# Expose necessary ports (adjust these if different ports are needed)
EXPOSE 26656 26657 1317 9090

# Run cosmosd by default
CMD ["simd"]
