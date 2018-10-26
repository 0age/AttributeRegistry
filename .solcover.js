module.exports = {
  testCommand: 'node --max-old-space-size=4096 ./scripts/testCoverage.js',
  compileCommand: '../node_modules/.bin/truffle compile',
  copyPackages: ['web3']
}