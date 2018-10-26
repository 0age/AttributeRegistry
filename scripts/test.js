var assert = require('assert');
const AttributeRegistryContractData = require('../build/contracts/AttributeRegistry.json')

async function send(
  title,
  instance,
  method,
  args,
  from,
  value,
  gas,
  gasPrice,
  shouldSucceed,
  assertionCallback
) {
  let succeeded = true
  receipt = await instance.methods[method](...args).send({
    from: from,
    value: value,
    gas: gas,
    gasPrice:gasPrice
  }).catch(error => {
    succeeded = false
  })

  if (succeeded !== shouldSucceed) {
    return false
  } else if (!shouldSucceed) {
    return true
  }

  let assertionsPassed
  try {
    assertionCallback(receipt)
    assertionsPassed = true
  } catch(error) {
    assertionsPassed = false
  }
  
  return assertionsPassed
}

async function call(
  title,
  instance,
  method,
  args,
  from,
  value,
  gas,
  gasPrice,
  shouldSucceed,
  assertionCallback
) {
  let succeeded = true
  returnValues = await instance.methods[method](...args).call({
    from: from,
    value: value,
    gas: gas,
    gasPrice:gasPrice
  }).catch(error => {
    succeeded = false
  })

  if (succeeded !== shouldSucceed) {
    return false
  } else if (!shouldSucceed) {
    return true
  }

  let assertionsPassed
  try {
    assertionCallback(returnValues)
    assertionsPassed = true
  } catch(error) {
    assertionsPassed = false
  }

  return assertionsPassed
} 

module.exports = {test: async function (provider, testingContext) {
  var web3 = provider

  let passed = 0
  let failed = 0
  console.log('running tests...')
  // get available addresses and assign them to various roles
  const addresses = await Promise.resolve(web3.eth.getAccounts())
  if (addresses.length < 2) {
    console.log('cannot find enough addresses to run tests...')
    process.exit(1)
  }

  const attributeTypeID = {
    'whitehat': '8008',
    'blackhat': '1337'
  }

  const latestBlock = await web3.eth.getBlock('latest')
  const gasLimit = latestBlock.gasLimit

  const addressOne = addresses[0]
  const addressTwo = addresses[1]
  const nullAddress = '0x0000000000000000000000000000000000000000'
  const unownedAddress = '0x1010101010101010101010101010101010101010'

  // create contract objects that will deploy the contracts for testing
  const AttributeRegistryDeployer = new web3.eth.Contract(
    AttributeRegistryContractData.abi
  )

  // *************************** deploy contract **************************** //
  const AttributeRegistry = await AttributeRegistryDeployer.deploy(
    {
      data: AttributeRegistryContractData.bytecode
    }
  ).send({
    from: addressOne,
    gas: gasLimit - 1,
    gasPrice: 10 ** 1
  }).catch(error => {
    console.error(error)
    process.exit(1)
  })

  async function runTest(
    title,
    method,
    callOrSend,
    args,
    shouldSucceed,
    assertionCallback,
    from,
    value
  ) {
    if (typeof(callOrSend) === 'undefined') {
      callOrSend = 'send'
    }
    if (typeof(args) === 'undefined') {
      args = []
    }
    if (typeof(shouldSucceed) === 'undefined') {
      shouldSucceed = true
    }
    if (typeof(assertionCallback) === 'undefined') {
      assertionCallback = (value) => {}
    }
    if (typeof(from) === 'undefined') {
      from = addressOne
    }
    if (typeof(value) === 'undefined') {
      value = 0
    }
    let ok = false
    if (callOrSend === 'send') {
      ok = await send(
        title,
        AttributeRegistry,
        method,
        args,
        from,
        value,
        gasLimit - 1,
        10 ** 1,
        shouldSucceed,
        assertionCallback
      )
    } else if (callOrSend === 'call') {
      ok = await call(
        title,
        AttributeRegistry,
        method,
        args,
        from,
        value,
        gasLimit - 1,
        10 ** 1,
        shouldSucceed,
        assertionCallback
      )      
    } else {
      console.error('must use call or send!')
      process.exit(1)
    }

    if (ok) {
      console.log(` ✓ ${title}`)
      passed++
    } else {
      console.log(` ✘ ${title}`)
      failed++
    }
  }

  // **************************** begin testing ***************************** //
  console.log(' ✓ Attribute Registry contract deploys successfully')
  passed++

  await runTest(
    'correct number of attribute types are set',
    'countAttributeTypes',
    'call',
    [],
    true,
    value => {
      assert.strictEqual(value, '2')
    }
  )

  await runTest(
    'attribute types can be accessed by index',
    'getAttributeTypeID',
    'call',
    [0],
    true,
    value => {
      assert.strictEqual(value, attributeTypeID['whitehat'])
    }
  )

  await runTest(
    'attribute types indexes outside of the available range will revert',
    'getAttributeTypeID',
    'call',
    [2],
    false
  )

  await runTest(
    "attribute can be checked for if it doesn't yet exist",
    'hasAttribute',
    'call',
    [addressOne, attributeTypeID['whitehat']],
    true,
    value => {
      assert.strictEqual(value, false)
    }
  ) 

  await runTest(
    "attribute value check will throw if it doesn't yet exist",
    'getAttributeValue',
    'call',
    [addressOne, attributeTypeID['whitehat']],
    false
  ) 

  await runTest(
    'attributes can be issued',
    'joinWhitehats'
  )

  await runTest(
    'issued attribute counter is correctly incremented',
    'totalHats',
    'call',
    [],
    true,
    value => {
      assert.strictEqual(value[0], '1')
      assert.strictEqual(value[1], '0')
    }
  ) 

  await runTest(
    'attribute can be checked for',
    'hasAttribute',
    'call',
    [addressOne, attributeTypeID['whitehat']],
    true,
    value => {
      assert.ok(value)
    }
  ) 

  await runTest(
    'attribute value can be checked for',
    'getAttributeValue',
    'call',
    [addressOne, attributeTypeID['whitehat']],
    true,
    value => {
      assert.strictEqual(value, '1')
    }
  )

  await runTest(
    'additional attributes can be issued and revoked',
    'joinBlackhats'
  )

  await runTest(
    'issued attribute counter is correctly incremented and decremented',
    'totalHats',
    'call',
    [],
    true,
    value => {
      assert.strictEqual(value[0], '0')
      assert.strictEqual(value[1], '1')
    }
  )

  await runTest(
    'issue additional attributes',
    'joinBlackhats',
    'send',
    [],
    true,
    value => {},
    addressTwo
  )

  await runTest(
    'attempts to add attributes when conditions are not met will revert',
    'joinWhitehats',
    'send',
    [],
    false,
    value => {},
    addressTwo
  )

  await runTest(
    'issued attribute counter finishes in expected state',
    'totalHats',
    'call',
    [],
    true,
    value => {
      assert.strictEqual(value[0], '0')
      assert.strictEqual(value[1], '2')
    }
  )

  console.log(
    `completed ${passed + failed} test${passed + failed === 1 ? '' : 's'} ` + 
    `with ${failed} failure${failed === 1 ? '' : 's'}.`
  )

  if (failed > 0) {
    process.exit(1)
  }

  process.exit(0)

}}
