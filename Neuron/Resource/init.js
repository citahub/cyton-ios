

function executeCallback (id, error, value) {
  Neuron.executeCallback(id, error, value)
}
function onSignSuccessful(id, value) {
  console.log("onSignSuccessful", value)
  Neuron.executeCallback(id, null, value)
}
function onSignError(id, error) {
  Neuron.executeCallback(id, error, null)
}
window.Neuron.init(rpcURL, {
  getAccounts: function (cb) { cb(null, [addressHex]) },
  processTransaction: function (tx, cb){
    console.log('signing a transaction', tx)
    const { id = 8888 } = tx
    Neuron.addCallback(id, cb)

    var data = tx.data || null;
    var nonce = tx.nonce || -1;
    var chainId = tx.chainId || -1;
    var version = tx.version || 0;
    var value = tx.value || null;
    var chainType = tx.chainType || null;

    if (tx.chainType == "ETH") {
        var gasLimit = tx.gasLimit || tx.gas || null;
        var gasPrice = tx.gasPrice || null;
        chainId = -1;
        webkit.messageHandlers.signTransaction.postMessage({"name": "signTransaction", "object": tx, id: id})
    } else {
        var quota = tx.quota || null;
        var validUntilBlock = tx.validUntilBlock || 0;
        webkit.messageHandlers.signTransaction.postMessage({"name": "signTransaction", "object": tx, id: id})
    }
  },
  signMessage: function (msgParams, cb) {
    console.log('signMessage', msgParams)
    const { data, chainType } = msgParams
    const { id = 8888 } = msgParams
    Neuron.addCallback(id, cb)
    webkit.messageHandlers.signMessage.postMessage({"name": "signMessage", "object": { data }, id: id})
  },
  signPersonalMessage: function (msgParams, cb) {
    console.log('signPersonalMessage', msgParams)
    const { data, chainType } = msgParams
    const { id = 8888 } = msgParams
    Neuron.addCallback(id, cb)
    webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object": { data }, id: id})
  },
  signTypedMessage: function (msgParams, cb) {
    console.log('signTypedMessage ', msgParams)
    const { data } = msgParams
    const { id = 8888 } = msgParams
    Neuron.addCallback(id, cb)
    webkit.messageHandlers.signTypedMessage.postMessage({"name": "signTypedMessage", "object": { data }, id: id})
  }
}, {
    address: addressHex,
    networkVersion: chainID
})
window.web3.setProvider = function () {
  console.debug('Neuron Wallet - overrode web3.setProvider')
}

window.web3.version.getNetwork = function(cb) {
    cb(null, chainID)
}
window.web3.eth.getCoinbase = function(cb) {
    return cb(null, addressHex)
}
window.web3.eth.defaultAccount = addressHex

window.isNervosReady = true
window.isMetaMask = true
