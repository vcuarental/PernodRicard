@RestResource(UrlMapping='/ASI_CRM_CN_SalesOrder_Upsert/*')
Global Without Sharing class ASI_CRM_CN_SalesOrder_Upsert {

    global Class salesOrderClass{
        global list <salesOrderStructure> salesOrderlist{set;get;}    
    }
    
    /*
     *{"jsonString":"{\"salesOrderlist\":[{\"recordID\":\"\",\"requestedDate\":\"2016/09/07\",\"orderDate\":\"2016/09/31\",\"RTD\":false,\"contactPerson\":\"Ben\",\"otherRequirement\":\"No!!!\",\"TelMobile\":\"12345678\",\"Address\":\"HK\",\"Outlet\":\"a8bM00000008P59\",\"recordTypeID\":\"012M00000000kAe\"}]}"}
     */
    
    @HttpPost
    Global Static String UpsertSalesOrder(String jsonString){
        
        salesOrderClass salesOrder = (salesOrderClass)JSON.deserialize(jsonString, salesOrderClass.class);
        List<ASI_KOR_Sales_Order_Request__c> insertSOList = new List<ASI_KOR_Sales_Order_Request__c>();
        
        for(salesOrderStructure obj : salesOrder.salesOrderlist){
            
            ASI_KOR_Sales_Order_Request__c tempSO = new ASI_KOR_Sales_Order_Request__c();
            
            if(obj.recordID != '' && obj.recordID != NULL){

                tempSO.Id = obj.recordID;
            }else{
                tempSO.Id = NULL;
                if(obj.recordTypeID != NULL && obj.recordTypeID != '' )
                    tempSO.RecordTypeId = obj.recordTypeID;
            }
            
            if(obj.Outlet != NULL && obj.Outlet != '')
                tempSO.ASI_CRM_CN_Customer__c = obj.Outlet;
            
            if(obj.requestedDate != '' && obj.requestedDate != NULL){
                
                try{
                    tempSO.ASI_KOR_Requested_Date__c = date.newInstance(integer.valueOf(obj.requestedDate.split('/')[0]), integer.valueOf(obj.requestedDate.split('/')[1]), integer.valueOf(obj.requestedDate.split('/')[2]));
                    
                }catch(exception e){Return e.getMessage();}
            }
            
            if(obj.orderDate != '' && obj.orderDate != NULL){
                
                try{
                    tempSO.ASI_CRM_SG_Order_Date__c = date.newInstance(integer.valueOf(obj.orderDate.split('/')[0]), integer.valueOf(obj.orderDate.split('/')[1]), integer.valueOf(obj.orderDate.split('/')[2]));
                    
                }catch(exception e){Return e.getMessage();}
            }
            
            tempSO.ASI_CRM_CN_RTD__c = obj.RTD;
            
            tempSO.ASI_CRM_CN_Premium__c = obj.premium;
            
            tempSO.ASI_CRM_CN_Contact_Person__c = obj.contactPerson;
            
            tempSO.ASI_CRM_CN_Other_Requirement__c = obj.otherRequirement;
            
            tempSO.ASI_CRM_CN_Tel_Mobile__c = obj.TelMobile;
            
            tempSO.ASI_CRM_CN_Address__c = obj.Address;
            
            insertSOList.add(tempSO);
        }
        
        try{
            Upsert insertSOList;
            
        }catch(dmlException dmle){
            
            return dmle.getMessage();
        }
        
        Return 'Success';
    }
    
    global Class salesOrderStructure{
        
        Global String Outlet{Set; Get;}
        Global String recordTypeID{Set; Get;}
        Global String recordID{Set; Get;}
        Global String requestedDate {Set; Get;}
        Global String orderDate {Set; Get;}
        Global Boolean RTD {Set; Get;}
        Global Boolean premium {Set; Get;}
        Global String contactPerson {Set; Get;}
        Global String otherRequirement {Set; Get;}
        Global String TelMobile {Set; Get;}
        Global String Address {Set; Get;}
        
    }
}