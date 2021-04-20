({
	getTitulosListViewNames : function(component) {
		var getListNames = component.get('c.getTitulosListViewNames');
	    getListNames.setCallback(this,function(response){
	      var state = response.getState();
	      if ( state === 'SUCCESS' ) {
	       var listas = response.getReturnValue();
	       component.set('v.listNames', listas);
	      }
	    });
	    $A.enqueueAction(getListNames);

	},
    getAccountIdFromUser : function(component) {
		var getAccountIdFromUser = component.get('c.getAccountIdFromUser');
	    getAccountIdFromUser.setCallback(this,function(response){
	      	var state = response.getState();
	      	if ( state === 'SUCCESS' ) {
                console.log('hay success : '+response.getReturnValue() );
	       	var objString = response.getReturnValue();
	       		if (objString) {
		       		
			       	component.set('v.accountId', objString);
		      	}
	      	}
	    });
        console.log('pasamos');
	    $A.enqueueAction(getAccountIdFromUser);
        console.log('pasamos2');
	},
	getAccountDetails : function(component) {
        
		var getAccountDetails = component.get('c.getAccountDetail');
	    getAccountDetails.setCallback(this,function(response){
	      	var state = response.getState();
	      	if ( state === 'SUCCESS' ) {
	       	var objString = response.getReturnValue();
	       		if (objString) {
		       		var obj = JSON.parse(objString);
                    console.log('resultado available credit : ' + JSON.stringify(obj));
                    var aux2 = 0.00;
        			aux2 += obj.credDebt;
        			aux2 += obj.credOrderAppr;
		       		this.setPercentage(component, obj); 
			       	component.set('v.account', this.formatAccountFields(obj));
                    console.log('aux2 : ');
                    
                    console.log('aux2 : ' + aux2);
        			component.set('v.usedCredit',this.formatMoney(aux2));
                    
		      	}
	      	}
	    });
	    $A.enqueueAction(getAccountDetails);
	},
	getOpportunity : function(component) {
		var getOpportunity = component.get('c.getLastOpportunity');
	    getOpportunity.setCallback(this,function(response){
	      	var state = response.getState();
	      	if ( state === 'SUCCESS' ) {
	       	var objString = response.getReturnValue();
	       		if (objString) {
		       		var obj = JSON.parse(objString); 
			       	component.set('v.opportunityName', obj.name);
			       	component.set('v.opportunityValue', this.formatMoney(obj.value));
		      	}
	      	}
	    });
	    $A.enqueueAction(getOpportunity);
	},
	setPercentage : function(component, account) {
		var percent = this.getWholePercent(account);
		component.set('v.percent', percent);
	},
	getWholePercent : function(account) {
		if ((account.credLimit && account.credLimit > 1) && account.credDebt) {
            var aux = account.credDebt + account.credOrderAppr;
			return Math.floor(aux / account.credLimit*100);	
		} else {
			return 0;
		}	
	},
	formatAccountFields : function(account){ 
    	var aux = 0.00;
        aux -= account.credDebt;
        aux -= account.credOrderAppr;
        aux += account.credLimit;
		account.credDebt = this.formatMoney(account.credDebt);
       
		account.credLimit = account.credLimit > 1 ? this.formatMoney(account.credLimit) : 0;
        
		account.credOrderAppr = account.credOrderAppr> 1 ? this.formatMoney(account.credOrderAppr) : 0;
        
        account.credOrderPending = account.credOrderPending> 1 ? this.formatMoney(account.credOrderPending) : 0;
		//account.availableCredit =  account.credLimit -account.credDebt-account.credOrderAppr;
		account.availableCredit = this.formatMoney(aux);
        
		return account;
	},
	formatMoney : function (amount, decimalCount, decimal, thousands) {
		decimalCount = decimalCount ? decimalCount : 2;
		decimal = decimal ? decimal : ",";
		thousands = thousands ? thousands : '.';

		try {
		    decimalCount = Math.abs(decimalCount);
		    decimalCount = isNaN(decimalCount) ? 2 : decimalCount;

		    const negativeSign = amount < 0 ? "-" : "";

		    let i = parseInt(amount = Math.abs(Number(amount) || 0).toFixed(decimalCount)).toString();
		    let j = (i.length > 3) ? i.length % 3 : 0;

		    return negativeSign + (j ? i.substr(0, j) + thousands : '') + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousands) + (decimalCount ? decimal + Math.abs(amount - i).toFixed(decimalCount).slice(2) : "");
	 	} catch (e) {
		    console.log(e)
	  	}
	}, 
    getRelatedContacts : function(component) {
        console.log('entramos 1');
		var getRelatedContacts = component.get('c.getRelatedContacts');
         console.log('entramos 2');
	    getRelatedContacts.setCallback(this,function(response){
             console.log('entramos 3');
	      var state = response.getState();
	      if ( state === 'SUCCESS' ) {
              console.log('entramos 4');
              var listas = response.getReturnValue();
              console.log('entramos listas : ' + listas);
              component.set('v.contacts', listas);
	      }
	    });
         console.log('entramos 5');
	    $A.enqueueAction(getRelatedContacts);

	},
    loadSelectedTab: function (component) {
        var url = decodeURIComponent(window.location.search.substring(1));
        var urlParams = url.split('&');
        var reorderParam;
        for (var i = 0; i < urlParams.length; i++) {
            reorderParam = urlParams[i].split('=');
            console.log('urlParams[i]'+urlParams[i]);
            if (reorderParam[0] === 'tab') {
                
                reorderParam[1] === undefined ? 0 : reorderParam[1];
                if (reorderParam[1] != 0) {
                    console.log('setear :'+reorderParam[1]);
                    console.log('tabset encontrado:'+component.find("tabs"));
                    component.find("tabs").set("v.selectedTabId",reorderParam[1]);
                }
            }
        }
    },
})