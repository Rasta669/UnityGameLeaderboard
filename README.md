# Game Leaderboard Smart Contract

A decentralized leaderboard system built with Foundry for managing game scores and rankings on the EVM blockchain.

## Features

- Submit and track scores for multiple games
- Maintain top 100 scores per game
- Automatic score sorting and ranking
- Player score history tracking
- Gas-efficient score management

## Contract Overview

The `Leaderboard` contract provides the following main functionalities:

- `submitScore`: Submit a new score for a game
- `getTopScores`: Retrieve the top scores for a specific game
- `getPlayerScore`: Get a specific player's score for a game

## Development

This project uses [Foundry](https://getfoundry.sh/) for development, testing, and deployment.

### Prerequisites

- [Foundry](https://getfoundry.sh/)
- [Git](https://git-scm.com/)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd game-leaderboard
```

2. Install dependencies:
```bash
forge install
```

### Testing

Run the test suite:
```bash
forge test
```

### Deployment

To deploy the contract:

1. Configure your environment variables in `.env`:
```
PRIVATE_KEY=your_private_key
RPC_URL=https://sepolia.base.org
```

2. Deploy using Forge:
```bash
forge script script/Leaderboard.s.sol:LeaderboardScript --rpc-url $RPC_URL --broadcast --verify -vvvv
```

## Contract Architecture

The contract uses the following data structures:
- `Score`: Struct containing player address, score value, and timestamp
- `gameScores`: Mapping from game ID to array of scores
- `hasSubmittedScore`: Mapping to track player submissions per game

## Security Considerations

- Scores are stored on-chain and are immutable
- Each player can only have one active score per game
- Scores are automatically sorted and trimmed to maintain efficiency
- All operations are permissionless but require a valid Ethereum address

## License

MIT
