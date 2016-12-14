import { parseLocation, parseAddress, parseInformalAddress } from '../index'

describe('parseLocation', () => {
    it('should parse a correct location', () => {
        const actual = parseLocation('845 Rue Sherbrooke O, Montréal, QC H3A 0G4')
        const expected = { postalcode: 'H3A 0G4', street: 'Rue Sherbrooke O', city: 'Montral', number: '845', type: '', province: 'QC' }
        expect(actual).toEqual(expected)
    })
})

describe('parseAddress', () => {
    it('should parse a correct address', () => {
        const actual = parseAddress('7141 Rue Sherbrooke O, Montréal, QC H4B 1R6')
        const expected = { city: 'Montral', type: '', province: 'QC', street: 'Rue Sherbrooke O', number: '7141', postalcode: 'H4B 1R6' }
        expect(actual).toEqual(expected)
    })
})

describe('parseInformalAddress', () => {
    it('should parse a correct informal address', () => {
        const actual = parseInformalAddress('2900 Boulevard Edouard-Montpetit, Montréal, QC H3T 1J4')
        const expected = { number: '2900', postalcode: 'H3T 1J4', province: 'QC', type: '', street: 'Boulevard Edouard-Montpetit', city: 'Montral' }
        expect(actual).toEqual(expected)
    })
})