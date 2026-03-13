#!/usr/bin/env bash
#
# TrueChain Node Setup Script
#
# Usage:
#   ./setup-node.sh                    # First node (local) or add to local cluster
#   ./setup-node.sh --connect-to URL   # Add node that connects to existing cluster (local or EC2)
#
# Examples:
#   ./setup-node.sh                                    # Create node1 on this machine
#   ./setup-node.sh --connect-to http://10.0.1.50:8545 # Add node, connect to EC2 node1
#   ./setup-node.sh --connect-to http://localhost:8545  # Add node, connect to local node1
#
# See README.md for full documentation.
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GENESIS="genesis.json"
DEFAULT_PASSWORD="truechain"
P2P_BASE_PORT=30310
RPC_BASE_PORT=8545

# Parse arguments
CONNECT_TO=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --connect-to)
      CONNECT_TO="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--connect-to RPC_URL]"
      echo ""
      echo "  --connect-to RPC_URL  Connect new node to existing cluster (e.g. http://ec2-ip:8545)"
      echo "  -h, --help            Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check geth is installed
if ! command -v geth &> /dev/null; then
  echo "Error: geth is not installed. Install with: brew install ethereum"
  exit 1
fi

# Check genesis exists
if [[ ! -f "$GENESIS" ]]; then
  echo "Error: $GENESIS not found in $SCRIPT_DIR"
  exit 1
fi

# Detect existing nodes
EXISTING_NODES=()
for d in node*/; do
  if [[ -d "$d" ]] && [[ "$d" =~ ^node([0-9]+)/$ ]]; then
    EXISTING_NODES+=("${BASH_REMATCH[1]}")
  fi
done

# Sort and get next node number
if [[ ${#EXISTING_NODES[@]} -eq 0 ]]; then
  NODE_NUM=1
  IS_FIRST=true
else
  NODE_NUM=$(printf '%s\n' "${EXISTING_NODES[@]}" | sort -n | tail -1)
  NODE_NUM=$((NODE_NUM + 1))
  IS_FIRST=false
fi

NODE_DIR="node${NODE_NUM}"
P2P_PORT=$((P2P_BASE_PORT + NODE_NUM - 1))
RPC_PORT=$((RPC_BASE_PORT + NODE_NUM - 1))

echo "=========================================="
echo "TrueChain Node Setup"
echo "=========================================="
echo "Node number: $NODE_NUM"
echo "Node directory: $NODE_DIR"
echo "P2P port: $P2P_PORT"
echo "RPC port: $RPC_PORT"
echo "Mode: $([ "$IS_FIRST" = true ] && echo "First node" || echo "Adding to existing cluster")"
[[ -n "$CONNECT_TO" ]] && echo "Connect to: $CONNECT_TO"
echo "=========================================="

# Create node directory
mkdir -p "$NODE_DIR"
cd "$NODE_DIR"

# Create account if keystore is empty
if [[ ! -d keystore ]] || [[ -z "$(ls -A keystore 2>/dev/null)" ]]; then
  echo ""
  echo "Creating new account for $NODE_DIR..."
  PASSWORD="${TRUECHAIN_PASSWORD:-$DEFAULT_PASSWORD}"
  echo "$PASSWORD" > password.txt
  geth --datadir . account new --password password.txt
  echo "Account created. Password saved to $NODE_DIR/password.txt"
else
  echo "Account already exists in $NODE_DIR/keystore"
fi

# Init with genesis (idempotent - safe to run again)
echo ""
echo "Initializing with genesis..."
geth --datadir . init "$SCRIPT_DIR/$GENESIS"

# Build static-nodes.json
if [[ -n "$CONNECT_TO" ]]; then
  echo ""
  echo "Fetching enodes from $CONNECT_TO..."
  
  # Get enode of the node we're connecting to
  NODE_INFO=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' "$CONNECT_TO" 2>/dev/null || true)
  
  if [[ -z "$NODE_INFO" ]] || [[ "$NODE_INFO" == *"error"* ]]; then
    echo "Error: Could not fetch node info from $CONNECT_TO"
    echo "Ensure the node is running and RPC is accessible."
    exit 1
  fi
  
  ENODE=$(echo "$NODE_INFO" | grep -o '"enode":"[^"]*"' | cut -d'"' -f4)
  
  if [[ -z "$ENODE" ]]; then
    echo "Error: Could not parse enode from response"
    exit 1
  fi
  
  # Get peers' enodes too
  PEERS=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"admin_peers","params":[],"id":1}' "$CONNECT_TO" 2>/dev/null || true)
  ENODES=("$ENODE")
  
  if [[ -n "$PEERS" ]] && [[ "$PEERS" != *"error"* ]]; then
    while IFS= read -r line; do
      [[ -n "$line" ]] && ENODES+=("$line")
    done < <(echo "$PEERS" | grep -o '"enode":"[^"]*"' | cut -d'"' -f4)
  fi
  
  # Remove duplicates
  ENODES=($(printf '%s\n' "${ENODES[@]}" | sort -u))
  
  # Build JSON array
  STATIC_NODES="["
  for i in "${!ENODES[@]}"; do
    [[ $i -gt 0 ]] && STATIC_NODES+=","
    STATIC_NODES+="\"${ENODES[$i]}\""
  done
  STATIC_NODES+="]"
  
  echo "$STATIC_NODES" > static-nodes.json
  echo "static-nodes.json created with ${#ENODES[@]} peer(s)"
  
elif [[ "$IS_FIRST" = false ]]; then
  # Local cluster - use localhost enodes from repo's static-nodes.json
  echo ""
  echo "Building static-nodes.json for local cluster..."
  
  ENODES=()
  if [[ -f "$SCRIPT_DIR/static-nodes.json" ]]; then
    # Take first (NODE_NUM-1) enodes - these are node1, node2, ... node(N-1)
    count=0
    while IFS= read -r line && [[ $count -lt $((NODE_NUM - 1)) ]]; do
      line=$(echo "$line" | tr -d '"' | tr -d ',' | tr -d ' ')
      [[ -n "$line" ]] && [[ "$line" == enode://* ]] && ENODES+=("$line") && ((count++)) || true
    done < <(grep -oE 'enode://[^"]+' "$SCRIPT_DIR/static-nodes.json")
  fi
  
  if [[ ${#ENODES[@]} -gt 0 ]]; then
    STATIC_NODES="["
    for i in "${!ENODES[@]}"; do
      [[ $i -gt 0 ]] && STATIC_NODES+=","
      STATIC_NODES+="\"${ENODES[$i]}\""
    done
    STATIC_NODES+="]"
    echo "$STATIC_NODES" > static-nodes.json
    echo "static-nodes.json created with ${#ENODES[@]} peer(s) from existing config"
  else
    echo "[]" > static-nodes.json
    echo "static-nodes.json created (empty - copy enodes from running nodes if needed)"
  fi
else
  # First node - empty static nodes
  echo "[]" > static-nodes.json
  echo "static-nodes.json created (empty - first node)"
fi

cd "$SCRIPT_DIR"

# Get account address for signer (node1 only - if it's a signer per genesis)
ACCOUNT_ADDRESS=""
if [[ -d "$NODE_DIR/keystore" ]] && [[ -n "$(ls -A $NODE_DIR/keystore 2>/dev/null)" ]]; then
  KEYFILE=$(ls "$NODE_DIR/keystore" | head -1)
  ACCOUNT_ADDRESS="0x${KEYFILE##*--}"
fi

# Output start command
echo ""
echo "=========================================="
echo "Setup complete. Start the node with:"
echo "=========================================="
echo ""
echo "  cd $NODE_DIR"
echo "  geth --nodiscover --nousb --datadir . --syncmode full \\"
echo "    --port $P2P_PORT \\"
echo "    --http --http.addr localhost --http.port $RPC_PORT \\"
echo "    --http.api admin,eth,miner,net,txpool,personal,web3 \\"
echo "    --miner.gasprice 0 --miner.gastarget 470000000000 \\"
echo "    --allow-insecure-unlock \\"
if [[ $NODE_NUM -le 3 ]] && [[ -n "$ACCOUNT_ADDRESS" ]]; then
  echo "    --mine --unlock $ACCOUNT_ADDRESS --password password.txt"
else
  echo "    --mine"
fi
echo ""
echo "RPC will be available at: http://localhost:$RPC_PORT"
echo ""
echo "To get this node's enode (for other nodes to connect):"
echo "  geth attach http://localhost:$RPC_PORT"
echo "  admin.nodeInfo"
echo ""
