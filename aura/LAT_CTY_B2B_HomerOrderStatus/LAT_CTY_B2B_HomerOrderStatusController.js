({
	getOrderInfo : function(component, event, helper) {
        //var aux = $(".profile-menuList--nameOnly").html();
        //console.log('la aux es así:'+aux);
        //document.getElementsByClassName("profile-name slds-truncate profile-menuList--nameOnly")[0].innerHTML=document.getElementsByClassName("profile-name slds-truncate profile-menuList--nameOnly")[0].innerHTML.split(" ")[0];
		//console.log($("div.profile-menuList--nameOnly").innerHTML);
        helper.getOrderInfo(component);
        
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        
        helper.getAccountIdFromUser(component);
		component.set('v.userId', userId);        
        
        helper.getAccountDetails(component);
        console.log('en init 1 : '+component.get('v.mostrarCuadroPago'));
       	component.set('v.mostrarCuadroPago',false);
        console.log('en init 2 : '+component.get('v.mostrarCuadroPago'));
        // Set the columns of the Table 
        component.set('v.columns', [
            {label: 'Nro Pedido', fieldName: 'oppName', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'linkLabelOpp' }
                  }
            },
            {label: 'Fecha Creación', fieldName: 'oppCloseDate', type: 'text'},
            {label: 'Importe', fieldName: 'oppAmmount', type: 'currency', 
             	typeAttributes: { currencyCode: 'ARS', maximumSignificantDigits: 2}
            },
            {label: 'Estado Logística', fieldName: 'logiticStatus', type: 'text'},
            {label: 'Tracking', fieldName: 'linkCalyco', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'linkLabel' }
                  }
            },
            
        ]);
       
        console.log('en init 2 :'+ JSON.stringify(component.get('v.fiscalNotes')));
        helper.getSemaforoStatus(component); 
        helper.doFetchFacturas(component);
        
        console.log('en init 3');
		
	},
    hide : function(component,event,helper){
        component.set('v.mostrarCuadroPago',false);
    },
    show : function(component,event,helper){
        component.set('v.mostrarCuadroPago',true);
    }
})