/*********************************************************************************
* Name:ASI_CRM_SG_CreditNote_ButtonController 
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2020-04-15       Ceterna 	               Created
*********************************************************************************/
public with sharing class ASI_CRM_SG_CreditNote_ButtonController {
	
    @AuraEnabled
    public static String deleteFWO(String recordId){
        try {
			ASI_CRM_Credit_Debit_Note__c fwo = [Select Id, ASI_CRM_SG_FWO_End_Date__c,ASI_CRM_SG_FWO_Start_Date__c ,ASI_CRM_SG_Rebate_Type__c
                                                from ASI_CRM_Credit_Debit_Note__c where Id = :recordId];
        	Map<Id, ASI_CRM_Credit_Debit_Note__c> creditNotes = new Map<Id,ASI_CRM_Credit_Debit_Note__c>([Select Id 
                                                                                                          from ASI_CRM_Credit_Debit_Note__c 
                                                                                                          where ASI_CRM_SG_FWO_Period__c = :recordId]);
      
            if (creditNotes != null && creditNotes.keySet().size()>0){
                Map<Id,ASI_CRM_AccountsAdditionalField__c> wholesalerList = new Map<Id,ASI_CRM_AccountsAdditionalField__c>([Select Id 
                                                                                                                            from ASI_CRM_AccountsAdditionalField__c 
                                                                                                                            where ASI_CRM_Active__c = true 
                                                                                                                            and ASI_CRM_Record_Type_Name__c = 'ASI_CRM_SG_Wholesaler']);
                
                deleteItems(creditNotes, wholesalerList.keySet(), fwo.ASI_CRM_SG_FWO_Start_Date__c, fwo.ASI_CRM_SG_FWO_End_Date__c, fwo.ASI_CRM_SG_Rebate_Type__c);
            }
            delete new ASI_CRM_Credit_Debit_Note__c(Id = recordId);
            return 'Success';
        } catch (Exception e){
            return e.getMessage();
        }
    }
	
    public Static void deleteItems(Map<Id, ASI_CRM_Credit_Debit_Note__c> creditNotes, Set<Id> wholesalers, Date startDate, Date endDate, String rebateType){
    	if(creditNotes != null &&  creditNotes.keySet().size()>0){
        	Map<Id,ASI_HK_CRM_Sales_Order_History_Detail__c> sohDetails = new Map<Id,ASI_HK_CRM_Sales_Order_History_Detail__c>();
        	Map<Id,ASI_TH_CRM_Actual_Offtake__c> offtakes = new Map<Id,ASI_TH_CRM_Actual_Offtake__c>();
            for(ASI_CRM_SG_Credit_Note_Item_Detail__c itemDetail : [SELECT Id, ASI_CRM_SG_Sales_Order_History_Detail__c, 
                                                                    ASI_CRM_SG_Actual_Offtake__c 
                                                                    FROM ASI_CRM_SG_Credit_Note_Item_Detail__c 
                                                                    WHERE ASI_CRM_SG_Credit_Debit_Note__c IN :creditNotes.keySet()])
            {
                
                if(itemDetail.ASI_CRM_SG_Sales_Order_History_Detail__c != null && ! sohDetails.containsKey(itemDetail.ASI_CRM_SG_Sales_Order_History_Detail__c )){
                    ASI_HK_CRM_Sales_Order_History_Detail__c tempsohDetail = new ASI_HK_CRM_Sales_Order_History_Detail__c(id=itemDetail.ASI_CRM_SG_Sales_Order_History_Detail__c,
                                                                                                                         ASI_CRM_SG_Credit_Note_Status__c = 'Required');
                    if(rebateType=='FWO'){
                        tempsohDetail.ASI_CRM_SG_Credit_Note_FWO_Created__c = false;
                    }
                    else if(rebateType=='Portfolio'){
                        tempsohDetail.ASI_CRM_SG_Credit_Note_Portfolio_Created__c = false;
                    }else if(rebateType=='Bottle'){
                        tempsohDetail.ASI_CRM_SG_Credit_Note_Bottle_Created__c = false;
                    }
                    sohDetails.put(itemDetail.ASI_CRM_SG_Sales_Order_History_Detail__c, tempsohDetail);
                }
               /* if(itemDetail.ASI_CRM_SG_Actual_Offtake__c != null && !offtakes.containskey(itemDetail.ASI_CRM_SG_Actual_Offtake__c)){
                    offtakes.put(itemDetail.ASI_CRM_SG_Actual_Offtake__c, new ASI_TH_CRM_Actual_Offtake__c (
                    				Id = itemDetail.ASI_CRM_SG_Actual_Offtake__c, 
                        			ASI_CRM_SG_Credit_Note_Status__c = 'Required',
                    				ASI_CRM_SG_Credit_Note_OOM_Created__c = false));
                }*/
            }
			
			Map<Id,ASI_HK_CRM_Sales_Order_History__c> sohList = new Map<Id,ASI_HK_CRM_Sales_Order_History__c>([Select Id from ASI_HK_CRM_Sales_Order_History__c where ASI_HK_CRM_Order_Date__c >= :startDate and ASI_HK_CRM_Order_Date__c <= :endDate  and ASI_CRM_AccountAdditionalField__r.ASI_CRM_CN_Parent_Outlet__c IN :wholesalers]);
			
			List<ASI_HK_CRM_Sales_Order_History_Detail__c> sohDetailList = [Select Id from ASI_HK_CRM_Sales_Order_History_Detail__c where ASI_HK_CRM_Sales_Order_History__c IN :sohList.keySet() and Id Not IN :sohDetails.keySet() for update];
			if(rebateType != 'OOM' && sohDetailList != null && sohDetailList.size()>0){
				for (ASI_HK_CRM_Sales_Order_History_Detail__c detail : sohDetailList) {
					ASI_HK_CRM_Sales_Order_History_Detail__c tempsohDetail2 = new ASI_HK_CRM_Sales_Order_History_Detail__c(Id = detail.Id,ASI_CRM_SG_Credit_Note_Status__c = 'Required');
					if(rebateType=='FWO'){
                        tempsohDetail2.ASI_CRM_SG_Credit_Note_FWO_Created__c = false;
                    }
                    else if(rebateType=='Portfolio'){
                        tempsohDetail2.ASI_CRM_SG_Credit_Note_Portfolio_Created__c = false;
                    }else if(rebateType=='Bottle'){
                        tempsohDetail2.ASI_CRM_SG_Credit_Note_Bottle_Created__c = false;
                    }                   
					 sohDetails.put(detail.Id, tempsohDetail2);
				}
			}
            if(rebateType == 'OOM'){
               
			List<ASI_TH_CRM_Actual_Offtake__c> offtakes2 = [Select Id from ASI_TH_CRM_Actual_Offtake__c where ASI_CRM_SG_Credit_Note_Status__c = 'Issued' and 
			ASI_CRM_FromWS__c IN :wholesalers and ASI_TH_CRM_Month__c = : String.valueOf(startDate.month())
                                                                 AND ASI_TH_CRM_Year__c =:String.valueOf(startDate.Year())];
			
			if(offtakes2 != null && offtakes2.size()>0){
				for(ASI_TH_CRM_Actual_Offtake__c offtake : offtakes2){
					offtakes.put(offtake.Id, new ASI_TH_CRM_Actual_Offtake__c(
                    				Id = offtake.Id,
                        			ASI_CRM_SG_Credit_Note_Status__c = 'Required',
                    				ASI_CRM_SG_Credit_Note_OOM_Created__c = false));
				}
			}
            }
            
            If(offtakes.keySet().size()>0){
                database.update(offtakes.values(),true);
            }
            if(rebateType != 'OOM' && sohDetails.keySet().size()>0){
                database.update( sohDetails.values(),true);
            }
            delete creditNotes.values();
           
        }
    }
    
    @AuraEnabled 
    public static responseWrap reCalculate(String recordId){
        try {
            List<String> fields = new List<String>();
            fields.addAll(ASI_CRM_Credit_Debit_Note__c.getsObjectType().getDescribe().fields.getMap().keySet());
            String soql = 'SELECT ' 
                			+ String.join(fields, ',') 
                			+ ' FROM ASI_CRM_Credit_Debit_Note__c WHERE Id =: recordId ';
            ASI_CRM_Credit_Debit_Note__c creditNote = Database.query(soql);
            ASI_CRM_Credit_Debit_Note__c newCreditNote = creditNote.clone(false,false,false,false);
			Set<Id> wholesalers = new Set<Id>();
			wholesalers.add(creditNote.ASI_CRM_Wholesaler__c);
            deleteItems(new Map<Id,ASI_CRM_Credit_Debit_Note__c>{creditNote.Id => creditNote},wholesalers,creditNote.ASI_CRM_SG_FWO_Start_Date__c,creditNote.ASI_CRM_SG_FWO_End_Date__c, creditNote.ASI_CRM_SG_Rebate_Type__c); 
        	
            insert newCreditNote;
            responseWrap wrp = new responseWrap();
            wrp.msg = 'Success';
            wrp.newId= newCreditNote.Id;
            return wrp;
            
        } catch (Exception e) {
            responseWrap wrp = new responseWrap();
            wrp.msg = e.getMessage();
            wrp.newId= null;
            return wrp;
        }
    }
    
    public class responseWrap{
        @AuraEnabled public String msg {get;set;}
        @AuraEnabled public String newId {get;set;}
    }
}