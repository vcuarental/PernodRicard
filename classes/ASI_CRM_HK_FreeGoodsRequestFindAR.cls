public without sharing class ASI_CRM_HK_FreeGoodsRequestFindAR extends ASI_HK_CRM_TriggerAbstract{
    
    private Map<Id, Account> accMap;
    private List<ASI_FOC_Free_Goods_Request__c> soBeforeInsertList;
    private Set<Id> soIdSetInput;
    public static boolean needUpdate;
    
        /*private static Set<String> requiredAccFields() {
            return new Set<String> {
                		'ASI_HK_CRM_Credit_Limit__c'
                    	, 'ASI_HK_CRM_Payment_Term_Code__c'
                    	, 'ASI_HK_CRM_Payment_Term_Description__c'
                        , 'ASI_HK_CRM_Current_Amount__c'
                        , 'ASI_HK_CRM_X1_30__c'
                        , 'ASI_HK_CRM_X31_60__c'
                        , 'ASI_HK_CRM_X61_90__c'
                        , 'ASI_HK_CRM_Over_91__c'
                        , 'ASI_HK_CRM_Total_Exposure__c'
                        , 'ASI_HK_CRM_Overdue_30_days__c'
                        , 'ASI_HK_CRM_AR_Info_Last_Updated_By__c'
                    };
				}*/
    
    /*private static Map<Id, Account> getAccMap(Set<Id> soIdSet){
        Set<String> accQueryFields = requiredAccFields();
        
        List<Account> accList = (List<Account>)database.query(ASI_HK_CRM_CommonUtils.genQueryString(
            accQueryFields
            , 'Account'
            , 'Id IN :soIdSet'
        ));
        
        Map<Id,Account> result = new Map<Id,Account>();
        result.putAll(accList);
        
        return result;
        
    }*/  
    
    
    public ASI_CRM_HK_FreeGoodsRequestFindAR() {
        super('ASI_CRM_HK_FreeGoodsRequestFindAR');
    }   
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) 
    {
        
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE) && !isBypassByCurrentUser() && tAction != TriggerAction.AFTER_UPDATE) 
        {
            List<ASI_FOC_Free_Goods_Request__c> soList = (List<ASI_FOC_Free_Goods_Request__c>)sObjList;
            Map<ID, ASI_FOC_Free_Goods_Request__c> oldSOMap = (Map<ID, ASI_FOC_Free_Goods_Request__c>)oldMap;
            soBeforeInsertList = new List<ASI_FOC_Free_Goods_Request__c>();
            soIdSetInput = new Set<Id>();
            for( ASI_FOC_Free_Goods_Request__c so: soList ){
                
                //Boolean boolValue = so.ASI_HK_CRM_Order_Date__c > so.ASI_HK_CRM_Delivery_Date__c;
                //System.debug('Findcdjp1 operation boolValue ' + boolValue);
                //System.debug('Findcdjp4After Order Date ' + so.ASI_HK_CRM_Order_Date__c);
                //System.debug('Findcdjp5After Delivery Date ' + so.ASI_HK_CRM_Delivery_Date__c);
                
                ASI_FOC_Free_Goods_Request__c oldSO = tAction == TriggerAction.BEFORE_UPDATE ? (ASI_FOC_Free_Goods_Request__c)oldMap.get(so.Id) : null;
                if(oldSO != null){
                    if(oldSO.ASI_FOC_Account_DA__c == so.ASI_FOC_Account_DA__c){
                        continue;
                    }
                }
                
                //System.debug('kdk3'+so.ASI_HK_CRM_Customer_DA__c);
                if ( so.ASI_FOC_Account_DA__c != null ){
                    //System.debug('kdk4'+so.ASI_HK_CRM_Customer_DA__c);
                    Id temp = so.ASI_FOC_Account_DA__c;
                    //System.debug('kdk5'+temp);
                    soIdSetInput.add(temp);
                    soBeforeInsertList.add(so);
                }
            }
            Map<id,ASI_CRM_AccountsAdditionalField__c> CustomerMap = new Map<id,ASI_CRM_AccountsAdditionalField__c>();
            List<ASI_CRM_AccountsAdditionalField__c> aclist = [SELECT id, ASI_CRM_CN_Phone_Number__c, ASI_CRM_CN_Fax_Number__c, ASI_HK_CRM_Delivery_Window_Instruction__c, ASI_HK_CRM_Delivery_Time_1__c, ASI_HK_CRM_Delivery_Time_2__c, ASI_HK_CRM_Payment_Method__c, ASI_HK_CRM_Instruction_txt__c, ASI_HK_CRM_Attention__c, ASI_HK_CRM_Delivery_Remarks__c, ASI_HK_CRM_User_D_O__c, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c IN :soIdSetInput];
            
            for (ASI_CRM_AccountsAdditionalField__c ac : aclist){
            	CustomerMap.put(ac.ASI_CRM_Account__c ,ac);        
            }
            
            //if(soIdSetInput != null) accMap = getAccMap(soIdSetInput);
            if (soBeforeInsertList != null && tAction == TriggerAction.BEFORE_INSERT ){
                for( ASI_FOC_Free_Goods_Request__c so: soBeforeInsertList ){
                    
                    //System.debug('kdk1'+so.ASI_HK_CRM_Customer_DA__c);
                    //so.ASI_HK_CRM_Credit_Limit__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Credit_Limit__c;
                    //System.debug('kdk3'+so.ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_Credit_Limit__c);
                    /*so.ASI_HK_CRM_Payment_Term_Code__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Payment_Term_Code__c;
                    so.ASI_HK_CRM_Payment_Term_Description__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Payment_Term_Description__c;
                    so.ASI_HK_CRM_Current_Amount__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Current_Amount__c;
                    so.ASI_HK_CRM_X1_30__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_X1_30__c;
                    so.ASI_HK_CRM_X31_60__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_X31_60__c;
                    so.ASI_HK_CRM_X61_90__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_X61_90__c;
                    so.ASI_HK_CRM_Over_91__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Over_91__c;
                    so.ASI_HK_CRM_Total_Exposure__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Total_Exposure__c;
                    so.ASI_HK_CRM_Overdue_30_days__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Overdue_30_days__c;    
                    so.ASI_HK_CRM_AR_Info_Last_Updated_By__c = accMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_AR_Info_Last_Updated_By__c;*/
                    if(so.ASI_FOC_Account_DA__c != null && CustomerMap.containsKey(so.ASI_FOC_Account_DA__c)){
                        if(so.ASI_FOC_Phone_Number__c == null) {
                            so.ASI_FOC_Phone_Number__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_CRM_CN_Phone_Number__c;
                        }              
                        if(so.ASI_FOC_Fax__c == null) {
                            so.ASI_FOC_Fax__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_CRM_CN_Fax_Number__c;
                        }            
                        if(so.ASI_FOC_Delivery_Window_Instruction__c == null) {
                            so.ASI_FOC_Delivery_Window_Instruction__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Delivery_Window_Instruction__c;
                        }                
                        if(so.ASI_FOC_Delivery_Time_1__c == null){
                            so.ASI_FOC_Delivery_Time_1__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Delivery_Time_1__c;
                        }             
                        if(so.ASI_FOC_Delivery_Time_2__c == null) {
                            so.ASI_FOC_Delivery_Time_2__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Delivery_Time_2__c;
                        }       
                        //if(so.ASI_HK_CRM_Payment_Method__c == null || so.ASI_HK_CRM_Payment_Method__c == 'N/A') {
                            //so.ASI_HK_CRM_Payment_Method__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Payment_Method__c;
                        //}
                        if(so.ASI_FOC_Instruction__c == null) {
                            so.ASI_FOC_Instruction__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Instruction_txt__c;
                        }             
                        if(so.ASI_FOC_Attention__c == null) {
                            so.ASI_FOC_Attention__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Attention__c;
                        }              
                        /*if(so.ASI_FOC_Delivery_Remarks__c == null) {
                            so.ASI_FOC_Delivery_Remarks__c = CustomerMap.get(so.ASI_FOC_Account_DA__c).ASI_HK_CRM_Delivery_Remarks__c;
                        }*/
                    }
                }
            }
        }   
    }
    
    public static boolean getNeedUpdate(){
        return ASI_HK_CRM_SalesOrderFindARFromDA.needUpdate;
    }
    
    public static void setNeedUpdate(boolean status){
        ASI_HK_CRM_SalesOrderFindARFromDA.needUpdate = status;
    }
    
}