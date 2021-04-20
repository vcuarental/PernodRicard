({
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
        
    }
})