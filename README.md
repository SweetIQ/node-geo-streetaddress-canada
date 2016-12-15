# geo-streetaddress-canada

[![npm](https://img.shields.io/npm/v/geo-streetaddress-canada.svg)](https://www.npmjs.com/package/geo-streetaddress-canada)
[![GitHub tag](https://img.shields.io/github/tag/SweetIQ/node-geo-streetaddress-canada.svg)](https://github.com/SweetIQ/node-geo-streetaddress-canada)
[![CircleCI branch](https://img.shields.io/circleci/project/github/SweetIQ/node-geo-streetaddress-canada/master.svg)](https://circleci.com/gh/SweetIQ/node-geo-streetaddress-canada)

This is a NodeJS wrapper for Perl extension [Geo::StreetAddress::Canada].

> Geo::StreetAddress::Canada is a regex-based street address and street intersection parser for Canada. Its basic goal is to be as forgiving as possible when parsing user-provided address strings. Geo::StreetAddress::Canada knows about directional prefixes and suffixes, fractional building numbers, building units, grid-based addresses, postal codes, and all of the official Canada Post abbreviations for street types, province names and secondary unit designators. Please note that this extension will only return data in English.

## Dependencies

- Node.js v6
- Perl 5

## Usage

Install GeoStreetAddressCanada from npm

```bash
npm install --save geo-streetaddress-canada
```

Use in NodeJS:

```javascript

var geoStreetAddressCanada = require('geo-streetaddress-Canada')

geoStreetAddressCanada.parseLocation('1005 Gravenstein Hwy N, Sebastopol CA 95272')

/*
{
    suffix: 'N',
    number: '1005',
    city: 'Sebastopol',
    street: 'Gravenstein',
    state: 'CA',
    zip: '95272',
    type: 'Hwy'
}
*/

geoStreetAddressCanada.parseAddress('1005 Gravenstein Hwy N, Sebastopol CA 95272')

/*
{
    suffix: 'N',
    number: '1005',
    city: 'Sebastopol',
    street: 'Gravenstein',
    state: 'CA',
    zip: '95272',
    type: 'Hwy'
}
*/

geoStreetAddressCanada.parseInformalAddress('1025 Gravenstein hwy north Sebastopol CA 95272-3092')

/*
{
    suffix: 'N',
    number: '1025',
    city: 'Sebastopol',
    street: 'Gravenstein',
    state: 'CA',
    zip: '95272',
    type: 'Hwy'
}
*/

```


[Geo::StreetAddress::Canada]: https://metacpan.org/pod/release/TEEDOT/Geo-StreetAddress-Canada-1.04/Canada.pm
