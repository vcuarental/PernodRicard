({
	getOrderInfo : function(component) {
        component.set('v.showLoading', true);
        var action = component.get("c.getlastOrder");
		console.log('getOrderInfo:');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var order = response.getReturnValue();
                console.log('order:'+ JSON.stringify(order));
                // Set Order Values 
                if(order.LAT_Fiscal_Notes__r){
                    let aux = order.LAT_Fiscal_Notes__r[0].LAT_AR_B2B_Status__c;
                    console.log('aux : ' + aux);
                    if(aux == 'Pago informado'){
                        let today = new Date().toISOString().slice(0, 10);
                        console.log('order.LAT_Fiscal_Notes__r[0].LAT_DueDate__c : ' + order.LAT_Fiscal_Notes__r[0].LAT_DueDate__c);
                        console.log('today : ' + today);
                        if(order.LAT_Fiscal_Notes__r[0].LAT_DueDate__c < today){
                            order.LAT_Fiscal_Notes__r[0].LAT_AR_B2B_Status__c = 'Saldo en FA Pendiente';
                        }
                        
                    }
                }
                component.set("v.order", order);
                
                component.set('v.showLoading', false);
                
            } else {
                console.log('error');
                console.log(response.getError());
                component.set('v.showLoading', false);
                
            }
        });
        $A.enqueueAction(action);
		
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
		       		this.setPercentage(component, obj); 
			       	component.set('v.account', this.formatAccountFields(obj));
		      	}
	      	}
	    });
	    $A.enqueueAction(getAccountDetails);
	},
	setPercentage : function(component, account) {
		var percent = this.getWholePercent(account);
		component.set('v.percent', percent);
	},
	getWholePercent : function(account) {
		if ((account.credLimit && account.credLimit > 1) && account.credDebt) {
			return Math.floor(account.credDebt / account.credLimit*100);	
		} else {
			return 0;
		}	
	},
	formatAccountFields : function(account){ 
    	var aux = 0.00;
        aux -= account.credDebt > 1 ? account.credDebt : 0;
        aux -= account.credOrderAppr > 1 ? account.credOrderAppr : 0;
        aux += account.credLimit > 1 ? account.credLimit : 0;
		account.credDebt = account.credDebt > 1 ? this.formatMoney(account.credDebt) : 0;
       
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
	doFetchFacturas : function(component) {
        console.log('en doFetchFacturas 1 ');
        
        var action = component.get('c.getTrackingFiscalNotes');
        console.log('en doFetchFacturas 2');
        action.setCallback(this, function(response){
            
        	console.log('en doFetchFacturas 3 ');
            var state = response.getState();
            if(state === 'SUCCESS' && component.isValid()){
                
                console.log('en doFetchFacturas 4:'+JSON.stringify(response.getReturnValue()));
          		var rows = response.getReturnValue();
                var data = component.get("v.fiscalNotes");
                console.log('data antes:' + JSON.stringify(data));
                for (var i = 0; i < rows.length; i++) {
                    component.set('v.mostrarTabla', true);
                    var row = rows[i];
                    // Process related field manually
                    row.fiscalNoteNumber = row.LAT_LegalInvoice__c;
                    row.fiscalNoteStatus = row.LAT_AR_B2B_Status__c;
                    row.linkCalyco = row.LAT_B2B_URL_Calico__c;
                    row.trackingUrl = row.LAT_B2B_URL_Calico__c;
                    row.linkLabel = 'Tracking Entrega';
                    row.logiticStatus = row.LAT_B2B_Estado_Calico__c ;
                    row.sfdcId = row.Id;
                    if (row.LAT_Opportunity__r)  {
                        row.linkLabelOpp = row.LAT_Opportunity__r.LAT_NROrderJDE__c;
                        row.oppName = '/s/detalle-pedido?order='+row.LAT_Opportunity__c;
                        row.oppCloseDate = row.LAT_Opportunity__r.LAT_CloseDate__c;
                        row.oppAmmount = row.LAT_Opportunity__r.LAT_TotalValue__c;
                    }
                    console.log('en doFetchFacturas 2 row:' + JSON.stringify(row));
                    
                    data.push(row);
                 }
                console.log('data despues:' + JSON.stringify(data));
                component.set('v.fiscalNotes', data);
            }else{
                alert('ERROR');
        		console.log('en doFetchFacturas 5');
            }
        });
        
        console.log('en doFetchFacturas 6');
        $A.enqueueAction(action);
        
    },
    getSemaforoStatus : function(component) {
		var getAccountIdFromUser = component.get('c.getSemaforoStatus');
	    getAccountIdFromUser.setCallback(this,function(response){
	      	var state = response.getState();
	      	if ( state === 'SUCCESS' ) {
                console.log('hay success semaforo : '+response.getReturnValue() );
	       		var objString = response.getReturnValue();
	       		if (objString=='Rojo') {
                    console.log('hay  semaforo rojo: ');
                   	var cmpTarget = component.find('iconoRojo');
                    $A.util.removeClass(cmpTarget, 'slds-hide');

		      	} else if (objString=='Amarillo') {
                	var cmpTarget = component.find('iconoAmarillo');
			        $A.util.removeClass(cmpTarget, 'slds-hide');
                } else {
                	var cmpTarget = component.find('iconoVerde');
			        $A.util.removeClass(cmpTarget, 'slds-hide');
                } 
	      	}
	    });
        console.log('pasamos');
	    $A.enqueueAction(getAccountIdFromUser);
        console.log('pasamos2');
	}
})