module.exports = {
    preset: '@salesforce/sfdx-lwc-jest',
    moduleFileExtensions: ['js', 'html'],
    moduleNameMapper: {
        '^@salesforce/apex$': '@salesforce/sfdx-lwc-jest'
    }
};
