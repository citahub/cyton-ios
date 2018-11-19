function clickMyCollection(){
    window.webkit.messageHandlers.pushCollectionView.postMessage({body: ''})
}

function clickMyDApp(){
    window.webkit.messageHandlers.pushMyDAppView.postMessage({body: ''})
}

function touchSearchbar(){
    window.webkit.messageHandlers.pushSearchView.postMessage({body: ''})
}
