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

The contract is deployed on Base Sepolia testnet:

- Contract Address: `0x7Cd309B089F7C276365337e140Dd4a8d01ebB5D6`
- Network: Base Sepolia (Chain ID: 84532)
- Explorer: [Base Sepolia Explorer](https://sepolia.basescan.org/address/0x7Cd309B089F7C276365337e140Dd4a8d01ebB5D6)

To deploy the contract locally:

1. Configure your environment variables in `.env`:
```
PRIVATE_KEY=your_private_key
RPC_URL=your_base_sepolia_rpc_url
```

2. Deploy using Forge:
```bash
forge script script/Leaderboard.s.sol:LeaderboardScript --rpc-url $RPC_URL --broadcast --verify -vvvv
```

## Contract Usage

### Interacting with the Contract

You can interact with the deployed contract using any Ethereum wallet or development environment that supports Base Sepolia. Here are some example interactions:

1. Submit a score:
```solidity
function submitScore(string memory gameId, uint256 score)
```

2. Get top scores for a game:
```solidity
function getTopScores(string memory gameId) returns (Score[] memory)
```

3. Get a player's score:
```solidity
function getPlayerScore(string memory gameId, address player) returns (Score memory)
```

### Integration Example

To integrate with your game:

1. Connect to the contract using the deployed address
2. Call `submitScore` whenever a player completes a game
3. Use `getTopScores` to display the leaderboard
4. Use `getPlayerScore` to show individual player rankings

## Gas Optimization

The contract is optimized for Base network's low gas fees:
- Average deployment cost: ~0.00000000085 ETH
- Score submission cost: ~0.0000000001 ETH
- Read operations are free (view functions)

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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

The MIT License is a permissive license that is short and to the point. It lets people do anything they want with your code as long as they provide attribution back to you and don't hold you liable.

Key features of the MIT License:
- Commercial use
- Modification
- Distribution
- Private use

For more information about the MIT License, visit [choosealicense.com/licenses/mit/](https://choosealicense.com/licenses/mit/).

## Contract Functions

### Write Functions

1. `submitScore(uint256 score)`
   - Submits a new score for the caller
   - Only updates if new score is higher than current score
   - Automatically sorts and maintains top 100 scores
   - Emits `ScoreSubmitted` event
   - Requirements:
     - Score must be greater than 0

2. `setPlayerName(string memory playerName)`
   - Sets or updates a player's display name
   - Updates both player-to-name and name-to-player mappings
   - Emits `PlayerNameSet` event
   - Requirements:
     - Player name cannot be empty
     - Player name must be 32 characters or less

### Read Functions

1. `getTopScores() returns (Score[] memory)`
   - Returns all scores in descending order
   - Each score includes player address, score value, and timestamp

2. `getPlayerScore(address player) returns (uint256)`
   - Returns a specific player's current score
   - Returns 0 if player has no score

3. `getScores() returns (uint256[] memory)`
   - Gas-efficient version of getTopScores
   - Returns only the score values in descending order

4. `getScoreByPosition(uint256 position) returns (uint256)`
   - Returns score at a specific position in the leaderboard
   - Returns 0 if position is invalid

5. `getPlayerByPosition(uint256 position) returns (address)`
   - Returns player address at a specific position
   - Returns address(0) if position is invalid

6. `getTimestampByPosition(uint256 position) returns (uint256)`
   - Returns timestamp of score at a specific position
   - Returns 0 if position is invalid

7. `getPlayerNameByPosition(uint256 position) returns (string memory)`
   - Returns player name at a specific position
   - Returns empty string if position is invalid or player has no name

8. `getPlayerNames() returns (string[] memory)`
   - Returns all player names in descending order of scores

9. `getPlayerNamesInRange(uint256 start, uint256 end) returns (string[] memory)`
   - Returns player names for a specific range of positions
   - Requirements:
     - Start position must be less than end position
     - End position must not exceed leaderboard length

### Public Variables

1. `scores` (Score[])
   - Array of all scores in the leaderboard
   - Each score contains:
     - `player`: address of the player
     - `score`: player's score value
     - `timestamp`: when the score was submitted

2. `playerScores` (mapping(address => uint256))
   - Maps player addresses to their current scores

3. `playerNames` (mapping(address => string))
   - Maps player addresses to their display names

4. `playerNameToAddress` (mapping(string => address))
   - Maps player names to their addresses

5. `MAX_SCORES` (uint256 constant)
   - Maximum number of scores kept in the leaderboard (100)

### Events

1. `ScoreSubmitted(address player, uint256 score)`
   - Emitted when a new score is submitted

2. `PlayerNameSet(address player, string playerName)`
   - Emitted when a player sets or updates their name

3. `ScoreRemoved(address player)`
   - Emitted when a player's score is removed

## Repository Usage

### Getting Started

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Rasta669/UnityGameLeaderboard.git
   cd UnityGameLeaderboard
   ```

2. **Install Dependencies**
   ```bash
   forge install
   ```

3. **Environment Setup**
   - Copy `.env.example` to `.env` (if not exists)
   - Add your private key and RPC URL to `.env`
   - Never commit your `.env` file

4. **Build and Test**
   ```bash
   # Build the project
   forge build
   
   # Run tests
   forge test
   
   # Run tests with gas reporting
   forge test --gas-report
   ```

### Development Workflow

1. **Create a New Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Follow Solidity style guide
   - Add tests for new features
   - Update documentation

3. **Test Your Changes**
   ```bash
   # Run all tests
   forge test
   
   # Run specific test
   forge test --match-test testName
   ```

4. **Deploy (if needed)**
   ```bash
   forge script script/Leaderboard.s.sol:LeaderboardScript --rpc-url $RPC_URL --broadcast --verify
   ```

## Contributing

We welcome contributions from the community! Here's how you can help:

### Pull Requests

1. **Before Submitting**
   - Fork the repository
   - Create a feature branch
   - Ensure all tests pass
   - Update documentation
   - Follow the commit message format:
     ```
     type(scope): description
     
     [optional body]
     [optional footer]
     ```
     Types: feat, fix, docs, style, refactor, test, chore

2. **PR Process**
   - Submit PR against `main` branch
   - Include clear description of changes
   - Reference any related issues
   - Ensure CI checks pass
   - Request review from maintainers

3. **Code Review**
   - Address review comments
   - Keep PR focused and small
   - Update PR as needed
   - Squash commits if requested

### Community Guidelines

1. **Communication**
   - Use GitHub Issues for bug reports
   - Use Discussions for feature requests
   - Be respectful and constructive
   - Follow the Code of Conduct

2. **Getting Help**
   - Check existing issues and discussions
   - Search documentation
   - Join our community chat (if available)
   - Create a new issue if needed

3. **Feature Requests**
   - Use the issue template
   - Describe the use case
   - Explain the benefit
   - Consider implementation complexity

4. **Bug Reports**
   - Use the bug report template
   - Include steps to reproduce
   - Add error messages/logs
   - Describe expected behavior

### Code of Conduct

- Be respectful and inclusive
- Give and accept constructive feedback
- Focus on the best for the community
- Show empathy towards others

### Recognition

Contributors will be:
- Listed in the README
- Mentioned in release notes
- Given credit in commit history
- Invited to join the maintainer team (for significant contributions)