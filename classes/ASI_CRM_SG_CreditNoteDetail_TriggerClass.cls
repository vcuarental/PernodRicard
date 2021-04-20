/*********************************************************************************
* Name:ASI_CRM_SG_CreditNoteDetail_TriggerClass 
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2020-04-14       Ceterna                 Created
* 2020-10-22       Wilken Lee              [WL 1.0] Assign calculated amount to "Actual Amount" field for user to adjust down if skipping rebate to WS
*********************************************************************************/
public class ASI_CRM_SG_CreditNoteDetail_TriggerClass {
    public static void CreateCreditNoteItem (Map<Id,ASI_CRM_SG_Credit_Note_Item_Detail__c> trigger_new) {        

        List<ASI_CRM_SG_Credit_Note_Item_Detail__c> fullItems = new List<ASI_CRM_SG_Credit_Note_Item_Detail__c>();
       
        fullItems = [Select Id, ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c,ASI_CRM_SG_Credit_Debit_Note_Line_Item__c,ASI_CRM_SG_Credit_Debit_Note__c,ASI_CRM_SG_Rebate_Type__c,ASI_CRM_SG_Amount__c from ASI_CRM_SG_Credit_Note_Item_Detail__c where Id IN :trigger_new.keySet()];

        List <ASI_CRM_SG_Credit_Note_Item_Detail__c> full_CreditNoteItemDetail_List = new List <ASI_CRM_SG_Credit_Note_Item_Detail__c>();        
        Map<String, ASI_CRM_SG_Credit_Note_Item_Detail__c> valid_CreditNoteItemDetail_Map = new Map<String, ASI_CRM_SG_Credit_Note_Item_Detail__c>();
        Map<String, Decimal> total_Amount_Map = new Map<String, Decimal>();
      //  Map<String, ASI_CRM_Credit_Debit_Note_Line_Item__c> creditNoteItem_Map = new Map<String, ASI_CRM_Credit_Debit_Note_Line_Item__c>();
            
        for(ASI_CRM_SG_Credit_Note_Item_Detail__c creditNoteItemDetail :fullItems){
            Decimal Amount = 0;
            System.debug('ccc each record id ' + creditNoteItemDetail.id);
            full_CreditNoteItemDetail_List.add(creditNoteItemDetail);
            for (integer i=0; i<fullItems.size(); i++){
                If (creditNoteItemDetail.ASI_CRM_SG_Rebate_Type__c == fullItems.get(i).ASI_CRM_SG_Rebate_Type__c && 
                    creditNoteItemDetail.ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c == fullItems.get(i).ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c){
                        Amount = Amount + ( fullItems.get(i).ASI_CRM_SG_Amount__c != null ? fullItems.get(i).ASI_CRM_SG_Amount__c : 0 );
                    }
                String key = creditNoteItemDetail.ASI_CRM_SG_Rebate_Type__c +'_' +creditNoteItemDetail.ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c;
                valid_CreditNoteItemDetail_Map.put(key,creditNoteItemDetail);
                total_Amount_Map.put(key,Amount);
            }
            System.debug('ccc map amount ' + total_Amount_Map);
            System.debug('ccc validitemlist  ' + valid_CreditNoteItemDetail_Map);

        }
        
        try{
            List<ASI_CRM_Credit_Debit_Note_Line_Item__c> itemList = new List<ASI_CRM_Credit_Debit_Note_Line_Item__c>();
            for (ASI_CRM_SG_Credit_Note_Item_Detail__c eachValid_CreditNoteItemDetail : valid_CreditNoteItemDetail_Map.values() ){
                String key = eachValid_CreditNoteItemDetail.ASI_CRM_SG_Rebate_Type__c + '_' + eachValid_CreditNoteItemDetail.ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c;
                System.debug('ccc key  ' +key);
             
                ASI_CRM_Credit_Debit_Note_Line_Item__c newItem = new ASI_CRM_Credit_Debit_Note_Line_Item__c();
                newItem.ASI_CRM_Sub_brand__c = eachValid_CreditNoteItemDetail.ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c;
                newItem.ASI_CRM_Amount__c = total_Amount_Map.get(key);
                newItem.ASI_CRM_Actual_Amount__c = total_Amount_Map.get(key);   //[WL 1.0]
                newItem.RecordTypeId = Schema.SObjectType.ASI_CRM_Credit_Debit_Note_Line_Item__c.getRecordTypeInfosByName().get('SG Wholesaler Credit Debit Note').getRecordTypeId();
                newItem.ASI_CRM_Credit_Debit_Note__c = eachValid_CreditNoteItemDetail.ASI_CRM_SG_Credit_Debit_Note__c;
                System.debug('ccc amount  ' +newItem.ASI_CRM_Amount__c);
                newItem.ASI_CRM_SG_Rebate_Type__c = eachValid_CreditNoteItemDetail.ASI_CRM_SG_Rebate_Type__c;
                insert newitem;
                System.debug('ccc newitem id  ' +newItem.id);
               itemList.add(newitem);
               // creditNoteItem_Map.put(key,newitem);
            }
            insert itemList;
          /*  List<ASI_CRM_SG_Credit_Note_Item_Detail__c> updateItemDetail = new List<ASI_CRM_SG_Credit_Note_Item_Detail__c>();
            for (ASI_CRM_SG_Credit_Note_Item_Detail__c creditNoteItemDetail :full_CreditNoteItemDetail_List){
                System.debug('ccc before id ' + creditNoteItemDetail.ASI_CRM_SG_Credit_Debit_Note_Line_Item__c);
                String key = creditNoteItemDetail.ASI_CRM_SG_Rebate_Type__c +'_' +creditNoteItemDetail.ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c;
                updateItemDetail.add(new ASI_CRM_SG_Credit_Note_Item_Detail__c( Id = creditNoteItemDetail.Id,  ASI_CRM_SG_Credit_Debit_Note_Line_Item__c = creditNoteItem_Map.get(key).id));
              //  creditNoteItemDetail.ASI_CRM_SG_Credit_Debit_Note_Line_Item__c = creditNoteItem_Map.get(key).id;
              //  Update creditNoteItemDetail;
                System.debug('ccc after id ' + creditNoteItemDetail.ASI_CRM_SG_Credit_Debit_Note_Line_Item__c);
            }
            
            if(updateItemDetail.size()>0){
                //updateItemDetails(JSON.serialize(updateItemDetail));  
              //  system.enqueueJob(new ASI_CRM_SG_updateItemDetailsQueueable(updateItemDetail)) ;
            }  */          
            
        }catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
      
       
    }
    
      
}