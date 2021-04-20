global class ASI_CRM_JP_ItemPriceUpdate_Webservice {

    global ASI_CRM_JP_ItemPriceUpdate_Webservice(){
        
    }
    global class InputResult{
        webservice String SKUCode {get;set;}
        webservice String ItemGroupPrice {get;set;}
    }
    
    global class OutputResult{
        webservice String result {get;set;}
        webservice List<id> failureList {get;set;} 
    } 
    
    webservice static OutputResult updateItemPrice(List<InputResult> input_result){
        OutputResult output = new OutputResult();
		Set<Id> Idset = new Set<id>();
        List<Id> failureList = new List<Id>();
        List<ASI_CRM_JP_Customer_Product_Price__c> updateList = new List<ASI_CRM_JP_Customer_Product_Price__c>();
        
        for(InputResult input: input_result){
            system.debug('SKU Code: ' + input.SKUCode);
            system.debug('Item Price Id: ' + input.ItemGroupPrice);
        	
            List<String> set_Priceid = input.ItemGroupPrice.split(';');
            for(String priceId: set_Priceid){
                IdSet.add(priceId);
            }
            system.debug('IdSet: ' + IdSet);
            //Idset.add(input.ItemGroupPrice);
        }
        
        for(ASI_CRM_JP_Customer_Product_Price__c temp: [Select id, ASI_CRM_Octopus_Synced__c,ASI_CRM_Octopus_Synced_Date__c from ASI_CRM_JP_Customer_Product_Price__c where id in:IdSet ]){
        	temp.ASI_CRM_Octopus_Synced__c = true;
            temp.ASI_CRM_Octopus_Synced_Date__c = Datetime.now();
            
            updateList.add(temp);    
        }
        system.debug('updateList size: ' + updateList.size());    
        Database.SaveResult[] srList = Database.update(updateList, false);
        
        for(Database.SaveResult sr: srList){
            if(sr.isSuccess()){
                system.debug('Success: ' + sr.getId());
            }else{
                for(Database.Error err : sr.getErrors()){
                    System.debug('The following error has occurred.');                   
                    System.debug('Id: ' + sr.getId() + ' Status Code: ' + err.getStatusCode() + ': ' + err.getMessage());
					failureList.add(sr.getId());	
                }
            }
        }
        
        output.result = failureList.size() == 0? 'Success!': 'Please find the below list of failure Id';
        output.failureList = failureList;
        return output;
    }
}