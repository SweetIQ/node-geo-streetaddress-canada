import { spawn, spawnSync } from 'child_process';
import * as path from 'path'

/**
 * Object representing an address
 * 
 * Mirror of http://search.cpan.org/~timb/Geo-StreetAddress-US-1.04/US.pm#ADDRESS_SPECIFIER
 */
export interface AddressSpecifier {
    number: string;
    prefix: string;
    street: string;
    type: string;
    suffix: string;
    city: string;
    state: string;
    zip: string;
    sec_unit_type: string;
    sec_unit_num: string;
}

/**
 * Object representing an intersection
 * 
 * Mirror of http://search.cpan.org/~timb/Geo-StreetAddress-US-1.04/US.pm#INTERSECTION_SPECIFIER
 */
export interface IntersectionSpecifier {
    prefix1: string;
    prefix2: string;
    street1: string;
    street2: string;
    type1: string;
    type2: string;
    suffix1: string;
    suffix2: string;
    city: string;
    state: string;
    zip: string;
}

export type Specifier = AddressSpecifier | IntersectionSpecifier;

export type Command = 'parseLocation' | 'parseAddress' | 'parseInformalAddress';

/**
 * Spawn foreign perl code to parse address.
 */
function foreignSpawn(command: Command, address: string) {
    let foreign =  spawnSync('perl', [
        path.join(__dirname, 'foreign/GeoStreetAddressRPC.pl'),
        command,
        address,
        ], {
        encoding: 'buffer'
    })

    if (foreign.stderr.toString('utf8')) {
        foreign.error = new Error('Non-empty stderr')
    }

    return foreign
    
}

/**
 * Parses any address or intersection string and returns the appropriate specifier. 
 * 
 * Mirror of http://search.cpan.org/~timb/Geo-StreetAddress-US-1.04/US.pm#parse_location
 */
export function parseLocation(address: string): Partial<Specifier> {
    let ret = foreignSpawn('parseLocation', address);
    if (ret.error) {
        throw new Error(`Failed to parse location\n${ret.stdout}\n${ret.stderr}]`);
    } else {
        return JSON.parse((ret.stdout.toString('utf8')));
    }
}

/**
 * Parses formal address string and returns the appropriate specifier. 
 * 
 * Mirror of http://search.cpan.org/~timb/Geo-StreetAddress-US-1.04/US.pm#parse_address
 */
export function parseAddress(address: string): Partial<AddressSpecifier> {
    let ret = foreignSpawn('parseAddress', address);
    if (ret.error) {
        throw new Error(`Failed to parse address \n${ret.stdout}\n${ret.stderr}]`);
    } else {
        return JSON.parse((ret.stdout.toString('utf8')));
    }
}

/**
 * Parses informal address string and returns the appropriate specifier. 
 * 
 * Mirror of http://search.cpan.org/~timb/Geo-StreetAddress-US-1.04/US.pm#parse_informal_address
 */
export function parseInformalAddress(address: string): Partial<AddressSpecifier> {
    let ret = foreignSpawn('parseInformalAddress', address);
    if (ret.error) {
        throw new Error(`Failed to parse informal address\n${ret.stdout}\n${ret.stderr}]`);
    } else {
        return JSON.parse((ret.stdout.toString('utf8')));
    }
}