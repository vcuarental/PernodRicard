/*********************************************************************************
 * Name: ASI_HK_CRM_SalesOrderAutoFillPA
 * Description: 
 * Test Class: ASI_HK_CRM_SalesOrderRequestSubmitTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-11-16       Wilken Lee             [WL 1.0] Deploy the changes made by Mark on 2018-07-23 to fix empty Account PA problem on SO Header
 */
public without sharing class ASI_HK_CRM_SalesOrderAutoFillPA extends ASI_HK_CRM_TriggerAbstract 
{   
  public ASI_HK_CRM_Sales_Order__c soAllDataList;
  public Set<Id> soIdSetInput;

    public ASI_HK_CRM_SalesOrderAutoFillPA() {
        super('ASI_HK_CRM_SalesOrderAutoFillPA');
    }

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) 
    {                
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE) && !isBypassByCurrentUser()) 
        {   
                                       
            List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
      
            soIdSetInput = new Set<Id>();
            for( ASI_HK_CRM_Sales_Order__c so: soList ){
                if ( so.ASI_HK_CRM_Customer_DA__c != null ){
                  System.debug('via1.2'+so.ASI_HK_CRM_Customer_DA__c);
                     soIdSetInput.add(so.ASI_HK_CRM_Customer_DA__c);
                }
            }
            
            Map<Id,Account> accMap = new Map<Id,Account>(); 
            if (soIdSetInput != null){
              List<Account> accList = [select 
              id
              , Name
              , parentId
              , ownerId 
              , recordType.developerName
              , ASI_HK_CRM_Inactive__c
              , ASI_HK_CRM_JDE_Account_Number__c
              , ASI_LUX_JDE_Parent_Account_Number__c
              from Account where id in: soIdSetInput];
              
              for (Account acc: accList){
                System.debug('via1.1'+acc.id);
                System.debug('via1.2'+acc.Name);
                System.debug('via1.3'+acc.recordType.developerName);
                accMap.put(acc.id,acc);
              }
            }
            
                                          
            for (ASI_HK_CRM_Sales_Order__c so : soList) 
            {               
                
                if ( so.ASI_HK_CRM_Customer_DA__c != null) {
                    // auto fill for Credit Acct
                    if (accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.developerName.equalsIgnoreCase('ASI_HK_CRM_Outlet') || accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.developerName.equalsIgnoreCase('ASI_HK_CRM_JDE_Salesman_Cash_Account')){    
                        System.debug('Customer DA Record Type Name:' + accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.Developername); 
                        if(accMap.get(so.ASI_HK_CRM_Customer_DA__c).Parentid == null){   
                            System.debug('via2.1'+so.ASI_HK_CRM_Customer_DA__c);
                            so.ASI_HK_CRM_Account_PA__c=so.ASI_HK_CRM_Customer_DA__c;
                        }
                        else {   
                            System.debug('via2.2'+so.ASI_HK_CRM_Customer_DA__c);
                            so.ASI_HK_CRM_Account_PA__c = accMap.get(so.ASI_HK_CRM_Customer_DA__c).Parentid;
                        }
                    }
                    else if(accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.developerName.contains('ASI_Luxury_Account_HK') && accMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_HK_CRM_JDE_Account_Number__c != null 
                        && accMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_LUX_JDE_Parent_Account_Number__c != null){
                        
                        Account New_PA_acc =[select id from Account where accountnumber=: accMap.get(so.ASI_HK_CRM_Customer_DA__c).ASI_LUX_JDE_Parent_Account_Number__c and ASI_KOR_Customer_Code__c like 'HK_%' ];
                        so.ASI_HK_CRM_Account_PA__c=New_PA_acc.id;
                    }                   
                    else if(accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.developerName == 'ASI_HK_CRM_Potential_Account' 
                        || accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.developerName == 'ASI_HK_CRM_Potential_Account_Prestige'
                            || accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.developerName == 'PersonAccount'
                                || accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.developerName.contains('ASI_Luxury_Account_HK') ){
                    
                        System.debug('who='+so.ASI_HK_CRM_Customer_DA__c+ ','+accMap.get(so.ASI_HK_CRM_Customer_DA__c).recordType.developerName);
                        if(accMap.get(so.ASI_HK_CRM_Customer_DA__c).Parentid == null){
                            List<Account> New_PA_accList = [select id from Account where ASI_HK_CRM_Inactive__c=false and ownerid =: accMap.get(so.ASI_HK_CRM_Customer_DA__c).ownerid and recordType.name='JDE Salesman Cash Account (HK)' and ASI_KOR_Customer_Code__c like 'HK_%'];                   

                            if (New_PA_accList.size() > 0)
                                so.ASI_HK_CRM_Account_PA__c = New_PA_accList.get(0).id;
                        }
                        else{   
                            so.ASI_HK_CRM_Account_PA__c = accMap.get(so.ASI_HK_CRM_Customer_DA__c).Parentid;
                        }
                    }
                }
            } 
        } 
    }
}