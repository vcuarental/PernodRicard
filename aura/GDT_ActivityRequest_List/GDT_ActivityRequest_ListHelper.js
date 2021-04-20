({
	
	sortData: function (cmp, fieldName, sortDirection) {
        var pageNumber = cmp.get("v.currentPageNumber");
        var itemsPerPage = cmp.get('v.itemsPerPage');
        var data = cmp.get("v.allRows");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.allRows", data);
        console.log(data);
        var pageRecords = data.slice((pageNumber-1)*itemsPerPage, pageNumber*itemsPerPage);
    	cmp.set("v.rows", pageRecords);
    },

    sortBy: function (field, reverse, primer) {
    	var thisC = this;
        var key = primer ?
            function(x) {return primer(thisC.getFieldValue(x,field))} :
            function(x) {return thisC.getFieldValue(x,field)};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    getFieldValue: function(obj, fieldName){
    	if (fieldName.indexOf(".") >= 0) {
            var ParentSobject = obj[fieldName.split(".")[0]];
            if(ParentSobject != undefined){
                return ParentSobject[fieldName.split(".")[1]];
            }
        }
        console.log(obj[fieldName]);
        return obj[fieldName] != null ? obj[fieldName] : '';
    },

   	showGivenAmount: function(component, helper){
        var itemsPerPage = component.get("v.itemsPerPage");
        var totalRecords = component.get("v.allRows").length;

        var toDisplay = itemsPerPage < totalRecords ? itemsPerPage : totalRecords;
        component.set("v.showing", toDisplay);
    },

    renderPage: function(component) {
		var records = component.get("v.allRows");
        var pageNumber = component.get("v.currentPageNumber");
        var itemsPerPage = component.get('v.itemsPerPage');

        var pageRecords = records.slice((pageNumber-1)*itemsPerPage, pageNumber*itemsPerPage);
    	component.set("v.rows", pageRecords);
    	component.find("loadingTable").hide();
	}


})