# Attribute Registry EIP

![GitHub](https://img.shields.io/github/license/0age/AttributeRegistry.svg)
[![Build Status](https://travis-ci.com/0age/AttributeRegistry.svg?branch=master)](https://travis-ci.com/0age/AttributeRegistry)
[![Coverage Status](https://coveralls.io/repos/github/0age/AttributeRegistry/badge.svg?branch=master)](https://coveralls.io/github/0age/AttributeRegistry?branch=master)
[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg)](https://github.com/RichardLitt/standard-readme)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

> An EIP proposing an interface for querying a registry for attribute metadata assigned to Ethereum addresses.

Existing EIPs for assigning metadata to addresses include EIP-735 and EIP-780, which both allow for multiple claims to be issued on the same address for any given claim topic. This forces verifiers of said metadata to assess the veracity of each claim, taking into account the relative reputation of each claim issuer. It also prescribes a methodology for adding and removing claims, which may not be appropriate for all use cases.

This EIP proposes an alternative light-weight standard for an address metadata registry interface, differentiated from claims by designating metadata as an "attribute" on an address. Attributes are registered as a flat `uint256 -> uint256` key-value pair on each address, with the important property that **each attribute has one canonical value per address**.

This EIP also prescribes a general method for determining the set of attribute keys or IDs made available by the registry, but otherwise does not lay out any requirements or recommendations for how attributes and their values are managed, or what additional metadata may be associated with attributes.

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

_**NOTE**_: This function MUST return either true or false - i.e. calling this function MUST NOT cause the caller to revert. Implementations that wish to call into another contract during execution of this function MUST catch any `revert` and instead return `false`.

_**NOTE**_: This function MUST return two equal values when performing two consecutive function calls with identical `account` and `attributeTypeID` parameters, regardless of either caller's address or any other factors. In other words, variability of the function output is derived entirely from the storage state and the two designated parameters.

#### `getAttributeValue` function
```
function getAttributeValue(address account, uint256 attributeTypeID) external view returns (uint256)
```

Retrieve the `uint256` value of an attribute on a given account on the registry, assuming the attribute is currently valid.

_**NOTE**_: This function MUST revert if a directly preceding or subsequent function call to `hasAttribute` with identical `account` and `attributeTypeID` parameters would return false.

_**NOTE**_: This function MUST return two equal values when performing two consecutive function calls with identical `account` and `attributeTypeID` parameters, regardless of either caller's address or any other factors. In other words, variability of the function output is derived entirely from the storage state and the two designated parameters.

#### `countAttributeTypes` function
```
function countAttributeTypes() external view returns (uint256)
```

Retrieve the total number of valid attribute types defined on the registry.

_**NOTE**_: This function MUST return a positive integer value  - i.e. calling this function MUST NOT cause the caller to revert.

_**NOTE**_: This function MUST return a value that encompasses all indexes of attribute type IDs whereby a call to `hasAttribute` on some address with an attribute type ID at the given index would return `true`.

#### `getAttributeTypeID` function
```
function getAttributeTypeID(uint256 index) external view returns (uint256)
```

Retrieve an ID of an attribute type defined on the registry by index.

_**NOTE**_: This function MUST revert if the provided `index` value falls outside of the range of the value returned from a directly preceding or subsequent function call to `countAttributeTypes`. It MUST NOT revert if the provided `index` value falls inside said range.

_**NOTE**_: This function MUST return an `attributeTypeID` value on *some* index if the same `attributeTypeID` value would cause a given call to `hasAttribute` to return `true` when passed as a parameter.

## Motivation
This EIP is motivated by the need for contracts and external accounts to be able to verify information about a given address from a single trusted source **without concerning themselves with the particular details of how the information was set or by whom**, and to do so in as straightforward and efficient a manner as possible. It is also motivated by the desire to promote broad **cross-compatibility and composability** between other attribute registries, a property which is amplified by both the simplicity of the interface as well as by the guarantees on uniqueness provided by the proposed standard.

## Maintainers

[@0age](https://github.com/0age)

## Contribute

PRs accepted.

## License

MIT License

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
