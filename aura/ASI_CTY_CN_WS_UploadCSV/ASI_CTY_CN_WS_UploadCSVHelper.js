({
    doInitHelper : function(component, event) {
    	let orderId = this.getJsonFromUrl().orderId;
    	let customerId = this.getJsonFromUrl().customerId;
    	component.set('v.uploadUrl', '/ASICTYWholesalerCN/apex/ASI_CTY_CN_WS_UploadCSV?orderId=' + orderId + '&customerId=' + customerId);
    },
    
    getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    }
})