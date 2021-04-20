({
	getFromDate: function(){
    	var today = new Date();
		var from = new Date(today);
		from.setDate(from.getDate() - 200);
        var fromDate = from.getFullYear() + '-' + (from.getMonth() + 1) + '-' + from.getDate();
        return fromDate;
    },

    getToDate: function(){
    	var today = new Date();
        var todayDate = today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
        return todayDate;
    },

    setActionValues : function (component) {
    	var rows = component.get("v.allRows");
    	var actionOptions = [];
    	var act = {};
    	act.value = 'ALL';
    	act.label = 'ALL';
    	actionOptions.push(act);
    	rows.forEach(function(row){
            if (actionOptions.filter(function(e) { return e.value === row.Action__c && row.Action__c != undefined; }).length == 0) {
            	var act = {};
            	act.value = row.Action__c;
            	act.label = row.Action__c;
            	actionOptions.push(act);
            }
        });
    	actionOptions = actionOptions.sort(function (a, b) {
    		if (a.value.toLowerCase() > b.value.toLowerCase())return 1;
		  	if (a.value.toLowerCase() < b.value.toLowerCase())return -1;
		  	return 0;
    	});

	    component.set("v.actionList" , actionOptions);
    },

    setSectionValues : function (component) {
    	var rows = component.get("v.allRows");
    	var sectionOptions = [];
    	var act = {};
    	act.value = 'ALL';
    	act.label = 'ALL';
    	sectionOptions.push(act);
    	rows.forEach(function(row){
    		if(row.Section__c != undefined && row.Section__c != ''){
	            if (sectionOptions.filter(function(e) { return e.value === row.Section__c ; }).length == 0) {
	            	var act = {};
	            	act.value = row.Section__c;
	            	act.label = row.Section__c;
	            	sectionOptions.push(act);
	            }
        	}
        });
    	sectionOptions = sectionOptions.sort(function (a, b) {
    		if (a.value.toLowerCase() > b.value.toLowerCase())return 1;
		  	if (a.value.toLowerCase() < b.value.toLowerCase())return -1;
		  	return 0;
    	});

	    component.set("v.sectionList" , sectionOptions);
    },

    setUserValues : function (component) {
    	var rows = component.get("v.allRows");
    	var userOptions = [];
    	var act = {};
    	act.value = 'ALL';
    	act.label = 'ALL';
    	userOptions.push(act);
    	rows.forEach(function(row){
    		if(row.CreatedById__r != undefined && row.CreatedById__r != ''){
	            if (userOptions.filter(function(e) { return e.value === row.CreatedById__r.Username ; }).length == 0) {
	            	var act = {};
	            	act.value = row.CreatedById__r.Username;
	            	act.label = row.CreatedById__r.Username;
	            	userOptions.push(act);
	            }
        	}
        });
    	userOptions = userOptions.sort(function (a, b) {
    		if (a.value.toLowerCase() > b.value.toLowerCase())return 1;
		  	if (a.value.toLowerCase() < b.value.toLowerCase())return -1;
		  	return 0;
    	});

	    component.set("v.userList" , userOptions);
    },

    searchRows : function(component) {
    	var actionSelected = component.get('v.actionSelected');
    	var sectionSelected = component.get('v.sectionSelected');
    	var userSelected = component.get('v.userSelected');
    	var displaySelected = component.get('v.displaySelected');
    	var controlSelected = component.get('v.toControlSelected');
    	var delegatedSelected = component.get('v.delegatedSelected');


    	var allrows = component.get('v.backupRows');
        var result = allrows.filter(function(item){
        	var isAct = actionSelected == 'ALL' || item['Action__c'].search(new RegExp(actionSelected, "i")) > -1;
        	var isSec = sectionSelected == 'ALL' || item['Section__c'] != undefined && item['Section__c'].search(new RegExp(sectionSelected, "i")) > -1;
        	var isUsr = userSelected == 'ALL' || item['CreatedById__r'] != undefined && item['CreatedById__r']['Username'].search(new RegExp(userSelected, "i")) > -1;
	    	var isDis = displaySelected == '' || item.Display__c.search(new RegExp(displaySelected, "i")) > -1;
	    	var isDel = delegatedSelected == '' || (item.DelegateUser__c != undefined  && (item.DelegateUser__c.search(new RegExp(delegatedSelected, "i")) > -1 && item.DelegateUser__c != ''));
	    	var isCon = item.toControl__c == controlSelected;
	    	return isAct && isSec && isUsr && isDis && isCon && isDel;
	    });

		component.set('v.rows', result.slice(0,100));
        component.set('v.allRows', result);
    }
})