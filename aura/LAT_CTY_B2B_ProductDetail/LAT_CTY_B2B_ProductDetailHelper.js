({
	loadProduct : function(component) {
		var productId = component.get("v.productId");
        var action = component.get("c.getProduct");
        action.setParams({ "productId" : productId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ret = response.getReturnValue();
                console.info(ret);
                component.set("v.product", ret);
            }
        });
        $A.enqueueAction(action);
	},
    
    loadProductId: function (component) {
        var url = decodeURIComponent(window.location.search.substring(1));
        var urlParams = url.split('&');
        var reorderParam;
        for (var i = 0; i < urlParams.length; i++) {
            reorderParam = urlParams[i].split('=');
            if (reorderParam[0] === 'pid') {
                reorderParam[1] === undefined ? 0 : reorderParam[1];
                if (reorderParam[1] != 0) {
                    component.set("v.productId", reorderParam[1]);
                }
            }
        }
    },
})