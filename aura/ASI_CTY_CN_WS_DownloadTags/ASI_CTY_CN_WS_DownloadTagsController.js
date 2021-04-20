({
    doInit: function(component, event, helper) {
        
        console.log('load start');
        component.set('v.showSpinner', true);
        helper.loadProducts(component);
        console.log('load end');

	},
	downloadCSV : function(component,event,helper){
        
        // get the Records [product] list from 'products' attribute 
        var stockData = component.get("v.products");
        
        let currentDate = new Date();
        console.log('currentDate'+currentDate);

        let csvContent = stockData.map(e => e.join(",")).join("\n");
        var encodedUri = encodeURI(csvContent);
        var universalBOM = "\uFEFF";
        var link = document.createElement("a");
        link.setAttribute('href', 'data:text/csv; charset=utf-8,' + encodeURIComponent(universalBOM+csvContent));
        link.setAttribute("download", $A.get('$Label.c.ASI_CTY_CN_WS_Products_Info') + ".csv");
        document.body.appendChild(link); // Required for FF

        link.click();
    }, 
})