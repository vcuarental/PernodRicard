/*****************************************************************************************************************
 * Name:        ASI_MFM_CAP_PlanSummaryByAPCodeCtrl
 * Test Class:  ASI_MFM_CAP_Plan_Test
 * Description: Controller for PO Summary PDF on CAPEX Plan
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-10-21       Wilken Lee              [WL 1.0] Add PO Balance calculation
 * 2019-10-28       Wilken Lee              [WL 2.0] Change PDF item to show Paid Amount by Account Code
 *****************************************************************************************************************/
public with sharing class ASI_MFM_CAP_PlanSummaryByAPCodeCtrl{
    public ASI_MFM_Plan__c plan {get; set;}
    public Map<String,Double> acAmountMap {get; set;}
    public Double poBalance {get; set;} //WL 1.0
    public Double actualAmount {get; set;} //WL 1.0
    public string currentHeaderId;
    
    public void setcurrentHeaderId (String s) {
            currentHeaderId = s;
            init();
        }

    public String getcurrentHeaderId() {
        return currentHeaderId;
    }
        
  public ASI_MFM_CAP_PlanSummaryByAPCodeCtrl(ApexPages.StandardController stdController){  
    this.plan = (ASI_MFM_Plan__c)stdController.getRecord();  
  }
  
  public ASI_MFM_CAP_PlanSummaryByAPCodeCtrl(){  
  }
  
    public void init(){
        acAmountMap = new Map<String,Double>();
        
        if (currentHeaderId != null){
             Map<String, Schema.SObjectField> planFieldMap = Schema.SObjectType.ASI_MFM_Plan__c.fields.getMap();
             String theQuery = 'Select ';
        
             for(String fields  : planFieldMap.keySet()){
                theQuery += fields + ' ,';
             }
         
             thequery = theQuery.subString(0,theQuery.length()-1);
             thequery += ', owner.name, createdby.name From ASI_MFM_Plan__c where  ID = ' + '\'' + currentHeaderId + '\' ';
             
             List<ASI_MFM_Plan__c> planList = (List<ASI_MFM_Plan__c>)Database.query(theQuery); 
             if (planList.size() > 0) {
                 plan = planList.get(0);
            }
        
            List<ASI_MFM_PO_Line_Item__c> polineList = [select id, ASI_MFM_A_C_Code__r.Name, ASI_MFM_Amount__c, ASI_MFM_Paid_Amount_in_Base_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__r.ASI_MFM_Plan__c = :plan.id];
            Double totalAmount = 0;
            
            for (ASI_MFM_PO_Line_Item__c poline:polineList){
                Double amt = 0;
                if (poline.ASI_MFM_Paid_Amount_in_Base_Currency__c != null)  //WL 2.0
                    amt = poline.ASI_MFM_Paid_Amount_in_Base_Currency__c ; //WL 2.0
                    
                    
                if (acAmountMap.containsKey(poline.ASI_MFM_A_C_Code__r.Name)){
                    totalAmount = acAmountMap.get(poline.ASI_MFM_A_C_Code__r.Name) + amt;
                    acAmountMap.put(poline.ASI_MFM_A_C_Code__r.Name,totalAmount);                    
                }
                else {
                    acAmountMap.put(poline.ASI_MFM_A_C_Code__r.Name, amt);
                }
            }

            system.debug('AC Description and PO Amount Map: ' + acAmountMap);
            
            /*[WL 1.0] BEGIN*/
            poBalance = 0;
            
            List<ASI_MFM_PO__c> poList = [SELECT ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Balance__c FROM ASI_MFM_PO__c where ASI_MFM_Plan__c = :currentHeaderId];
            
            for (ASI_MFM_PO__c po:poList){
                poBalance+= po.ASI_MFM_Exchange_Rate__c * po.ASI_MFM_PO_Balance__c;
            }
            
            actualAmount = plan.ASI_MFM_Plan_Amount__c - poBalance;
            
            system.debug('PO Balance: ' + poBalance + ' Actual Amount: ' + actualAmount);
            /*[WL 1.0] END*/
        }       
    }
}