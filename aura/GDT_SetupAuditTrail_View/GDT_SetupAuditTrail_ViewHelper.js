({
	toastIt: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    getFromDate: function(){
    	var today = new Date();
		var from = new Date(today);
		from.setDate(from.getDate() - 7);
        var fromDate = from.getFullYear() + '-' + (from.getMonth() + 1) + '-' + from.getDate();
        return fromDate;
    },

    getToDate: function(){
    	var today = new Date();
        var todayDate = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        return todayDate;
    },
})