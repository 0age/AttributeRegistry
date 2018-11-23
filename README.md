# Attribute Registry EIP

![GitHub](https://img.shields.io/github/license/0age/AttributeRegistry.svg)
[![Build Status](https://travis-ci.com/0age/AttributeRegistry.svg?branch=master)](https://travis-ci.com/0age/AttributeRegistry)
[![Coverage Status](https://coveralls.io/repos/github/0age/AttributeRegistry/badge.svg?branch=master)](https://coveralls.io/github/0age/AttributeRegistry?branch=master)
[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg)](https://github.com/RichardLitt/standard-readme)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

> An EIP proposing an interface for querying a registry for attribute metadata assigned to Ethereum addresses.

This EIP proposes a light-weight standard for an address metadata registry interface, differentiated from claims by designating metadata as an "attribute" on an address. Attributes are registered as a flat `uint256 -> uint256` key-value pair on each address, with the important property that **each attribute has one canonical value per address**.

This EIP also prescribes a general method for determining the set of attribute keys or IDs made available by the registry, but otherwise does not lay out any requirements or recommendations for how attributes and their values are managed, or what additional metadata may be associated with attributes.

Existing EIPs for assigning metadata to addresses include EIP-735 and EIP-780, which both allow for multiple claims to be issued on the same address for any given claim topic. This forces verifiers of said metadata to assess the veracity of each claim, taking into account the relative reputation of each claim issuer. It also prescribes a methodology for adding and removing claims, which may not be appropriate for all use cases. The Attribute Registry serves as an alternative standard in cases where these limitations are problematic.

For more information, see the [EIP specification](https://github.com/0age/AttributeRegistry/blob/master/EIP-%23%23%23.md). EIP discussion can be found at [EIP issue #1616](https://github.com/ethereum/EIPs/issues/1616).


## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [API](#api)
- [Motivation](#motivation)
- [Maintainers](#maintainers)
- [Contribute](#contribute)
- [License](#license)


## Install
First, ensure that [Node.js](https://nodejs.org/en/download/current/), [Yarn](https://yarnpkg.com/en/docs/install), and [ganache-cli](https://github.com/trufflesuite/ganache-cli#installation) are installed. Next, clone the repository and install dependencies:

```sh
$ git clone https://github.com/0age/AttributeRegistry
$ cd AttributeRegistry
$ yarn install
```

## Usage
To interact with these contracts, start up a testRPC node in a seperate terminal window:
```sh
$ ganache-cli --gasLimit 8000000
```

Then, to run tests:
```sh
$ yarn test
$ yarn run coverage
$ yarn run linter
```

## API

* [hasAttribute](#hasattribute-function)
* [getAttributeValue](#getattributevalue-function)
* [countAttributeTypes](#countattributetypes-function)
* [getAttributeTypeID](#getattributetypeid-function)

#### `hasAttribute` function
```
function hasAttribute(address account, uint256 attributeTypeID) external view returns (bool)
```

Check if an attribute has been assigned to a given account on the registry and is currently valid.


#### `getAttributeValue` function
```
function getAttributeValue(address account, uint256 attributeTypeID) external view returns (uint256)
```

Retrieve the `uint256` value of an attribute on a given account on the registry, assuming the attribute is currently valid.


#### `countAttributeTypes` function
```
function countAttributeTypes() external view returns (uint256)
```

Retrieve the total number of valid attribute types defined on the registry. Used alongside `getAttributeTypeID` to determine all of the attribute types that are available on the registry.


#### `getAttributeTypeID` function
```
function getAttributeTypeID(uint256 index) external view returns (uint256)
```

Retrieve an ID of an attribute type defined on the registry by index. Used alongside `countAttributeTypes` to determine all of the attribute types that are available on the registry.


## Maintainers

[@0age](https://github.com/0age)

## Contribute

PRs accepted. Contribute to the discussion around this EIP [here](https://github.com/ethereum/EIPs/issues/1616).

## License

MIT License

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
