The contract in this repo is a simple registry where ERC721 owner can register a user for their token.
This allow the onwer to continue trading its token, while users are able to use their token in every place that support such registry.
The obvious use case is off-chain reasing for nft display, etc...
But this could be potentially used on-chain too for various use cases.

The onwer can also sent its token as collateral but unless the collateral contract support such registry, the owner can only choose one user and not change later

## requirements :

### node

This project requires [node.js](https://nodejs.org/) (tested on v12+)

## intall dependencies :

```bash
yarn install
```

# Development

The following command will test your contracts

```bash
yarn test
```
