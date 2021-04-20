/*********************************************************************************
 * Name: ASI_HK_CRM_SalesOrderItemETLUpdate
 * Description: 
 * Test Class: ASI_HK_CRM_SalesOrderTriggerTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-11-14       Wilken Lee             [WL 1.0] Add advance pricing for SKU bottle price
 */
public without sharing class ASI_HK_CRM_SalesOrderItemETLUpdate extends ASI_HK_CRM_TriggerAbstract {

    //private ASI_HK_CRM_SalesOrderManager.SalesOrderManagerHttpPort soPort;
    /*
    *   This Trigger class is used to update the Has Cancelled Item checkbox in the related Sales Order record 
    *   When the related sales order items are manually updated through ETL
    */
    
    public ASI_HK_CRM_SalesOrderItemETLUpdate() {
        super('ASI_HK_CRM_SalesOrderItemETLUpdate');
    }

    public Map<ID, ASI_HK_CRM_Customer_Product_Price__c> productMap = new Map<ID, ASI_HK_CRM_Customer_Product_Price__c>();

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) 
    {
        // added before trigger Introv Alvin 2018-07-06  
        if (tAction == TriggerAction.BEFORE_INSERT)
        {
            List<ASI_HK_CRM_Sales_Order_Item__c> soDetails = (List<ASI_HK_CRM_Sales_Order_Item__c>)sObjList;
            Set<ID> soIds = new Set<ID>();
            for (ASI_HK_CRM_Sales_Order_Item__c soDetail : soDetails)
            {
                soIds.add(soDetail.ASI_HK_CRM_Sales_Order__c);
            }

            List<ASI_HK_CRM_Sales_Order__c> soList = [SELECT Id,ASI_HK_CRM_Order_Status_Name__c, ASI_HK_CRM_Account_PA__c, ASI_HK_CRM_Account_PA__r.RecordType.DeveloperName,ASI_HK_CRM_Customer_DA__c, ASI_HK_CRM_Customer_DA__r.RecordType.DeveloperName,
				ASI_HK_CRM_Customer_DA__r.ASI_HK_CRM_Customer_Type__c //[WL 1.0]
				FROM ASI_HK_CRM_Sales_Order__c WHERE ID IN: soIds];

            for (ASI_HK_CRM_Sales_Order__c so : soList)
            {
                if(so.ASI_HK_CRM_Order_Status_Name__c!='Draft')// add by mark  ssc 2018-08-02
                    return;
                else if ((so.ASI_HK_CRM_Account_PA__c!=null && so.ASI_HK_CRM_Account_PA__r.RecordType.DeveloperName == 'ASI_HK_CRM_JDE_Salesman_Cash_Account')||so.ASI_HK_CRM_Customer_DA__r.RecordType.DeveloperName == 'ASI_HK_CRM_JDE_Salesman_Cash_Account')
                {
                    for (ASI_HK_CRM_Sales_Order_Item__c soDetail : soDetails)
                    {
                        if (soDetail.ASI_HK_CRM_Sales_Order__c == so.Id && soDetail.ASI_HK_CRM_Price__c == null)
                        {
                            soDetail.addError('Please enter price for Cash Account');
                            return;
                        }
                        else if (soDetail.ASI_HK_CRM_Sales_Order__c == so.Id)
                        {
                            soDetail.CurrencyIsoCode = 'HKD';
                        }
                    }
                }
                else
                {              
                    Date todayDate = Date.today();
                    List<ASI_HK_CRM_Customer_Product_Price__c> productList = [
                        SELECT Id, Name, ASI_HK_CRM_SKU_Lookup__r.Name, ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_SKU_Lookup__r.ASI_MFM_Item_Group__c, 
                        ASI_HK_CRM_Bottle_Price__c, ASI_HK_CRM_Case_Price__c, ASI_CRM_Percentage_Discount__c, ASI_CRM_Fix_Discount__c 
                        FROM ASI_HK_CRM_Customer_Product_Price__c
                        WHERE RecordType.DeveloperName = 'ASI_HK_CRM_Customer_Product_Price' AND ASI_HK_CRM_Customer_Name__c = :so.ASI_HK_CRM_Customer_DA__c
                            AND (ASI_HK_CRM_Effective_Date__c = NULL OR ASI_HK_CRM_Expiry_Date__c = NULL
                                OR (ASI_HK_CRM_Effective_Date__c <= :todayDate AND ASI_HK_CRM_Expiry_Date__c >= :todayDate))
                    ];
					
					/*[WL 1.0] BEGIN*/
                    for (ASI_HK_CRM_Customer_Product_Price__c product : productList) {
                        if (product.ASI_HK_CRM_Bottle_Price__c != null){
                            if (product.ASI_CRM_Fix_Discount__c!= null){    //Fix $ Dis
                                product.ASI_HK_CRM_Bottle_Price__c = product.ASI_HK_CRM_Bottle_Price__c + product.ASI_CRM_Fix_Discount__c;
                                //system.debug('SKU: ' + product.ASI_HK_CRM_SKU_Lookup__r.Name + ' Discounted Bt Price: ' + product.ASI_HK_CRM_Bottle_Price__c);
                            }
                            
                            if (product.ASI_CRM_Percentage_Discount__c != null){    //% of GS discount
                                product.ASI_HK_CRM_Bottle_Price__c = product.ASI_HK_CRM_Bottle_Price__c * (100 - product.ASI_CRM_Percentage_Discount__c) / 100;
                                //system.debug('SKU: ' + product.ASI_HK_CRM_SKU_Lookup__r.Name + ' Discounted % Price: ' + product.ASI_HK_CRM_Bottle_Price__c);
                            }
                                
                            productMap.put(product.ASI_HK_CRM_SKU_Lookup__c, product);
                        }
                    }
                    /*[WL 1.0] END*/

                    // List<ASI_MFM_SKU_Code__c> skuList = [
                    //     SELECT Id, Name, ASI_MFM_SKU_Code__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                    //         , ASI_HK_CRM_Base_Price__c, ASI_HK_CRM_Available_Quantity__c, ASI_HK_CRM_Std_Bottle_Size__c
                    //         , ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c
                    //         , ASI_MFM_Item_Group__c,ASI_MFM_Item_Group__r.Name
                    //     FROM ASI_MFM_SKU_Code__c
                    //     WHERE RecordType.DeveloperName = 'ASI_HK_CRM_SKU' AND ASI_HK_CRM_Active__c = TRUE
                    //         AND ASI_HK_CRM_IsPOSProduct__c != TRUE
                    // ];
                    // Map<ID, ASI_MFM_SKU_Code__c> skuMap = new Map<ID, ASI_MFM_SKU_Code__c>();
                    // for (ASI_MFM_SKU_Code__c sku : skuList) {
                    //     skuMap.put(sku.ID, sku);
                    // }

                    for (ASI_HK_CRM_Sales_Order_Item__c soDetail : soDetails)
                    {
                        if (soDetail.ASI_HK_CRM_Sales_Order__c == so.Id)
                        {
                            soDetail.CurrencyIsoCode = 'HKD';
                            ASI_HK_CRM_Customer_Product_Price__c productPrice = productMap.get(soDetail.ASI_HK_CRM_SKU__c);
                            // ASI_MFM_SKU_Code__c sku = skuMap.get(soDetail.ASI_HK_CRM_SKU__c);
                            soDetail.ASI_HK_CRM_Price__c = productPrice != null ? productPrice.ASI_HK_CRM_Bottle_Price__c : 0;
                        }
                    }
                }
            }
        }
        
        if ((tAction == TriggerAction.AFTER_INSERT || tAction == TriggerAction.AFTER_UPDATE || tAction == TriggerAction.AFTER_DELETE) && !isBypassByCurrentUser()) 
        { 
            //initSalesOrderPortIfNeeded();
            
            List<ASI_HK_CRM_Sales_Order_Item__c> soDetails = (List<ASI_HK_CRM_Sales_Order_Item__c>)sObjList;
            
            Set<ID> soIds = new Set<ID>();
            for (ASI_HK_CRM_Sales_Order_Item__c soDetail : soDetails)
                soIds.add(soDetail.ASI_HK_CRM_Sales_Order__c);
                
            List<ASI_HK_CRM_Sales_Order__c> soList = [SELECT ID, ASI_HK_CRM_Has_Cancelled_Line_Item__c, name, owner.Name, owner.email, ASI_HK_CRM_Customer_DA__r.Name FROM ASI_HK_CRM_Sales_Order__c WHERE ID IN: soIds];
            List<ASI_HK_CRM_Sales_Order_Item__c> relatedsoDetails = [SELECT ID, ASI_HK_CRM_Quantity__c, ASI_HK_CRM_Cancel_Qty__c, ASI_HK_CRM_Sales_Order__c FROM ASI_HK_CRM_Sales_Order_Item__c WHERE ASI_HK_CRM_Sales_Order__c IN: soIds];
            Map<ID, List<ASI_HK_CRM_Sales_Order_Item__c>> soDetailsMap = new Map<ID, List<ASI_HK_CRM_Sales_Order_Item__c>>();
            
            //Map the sales order item list according to their master relationship: Sales Order
            for (ASI_HK_CRM_Sales_Order_Item__c soDetail : soDetails)
            {
                List<ASI_HK_CRM_Sales_Order_Item__c> tempsoDetail = new List<ASI_HK_CRM_Sales_Order_Item__c>();
                for (ASI_HK_CRM_Sales_Order_Item__c relatedsoDetail : relatedsoDetails)
                {
                    if (soDetail.ASI_HK_CRM_Sales_Order__c == relatedsoDetail.ASI_HK_CRM_Sales_Order__c)
                        tempsoDetail.add(relatedsoDetail);
                }
                if (tempsoDetail.size() > 0)
                    soDetailsMap.put(soDetail.ASI_HK_CRM_Sales_Order__c, tempsoDetail);
            }
            
            Set<ASI_HK_CRM_Sales_Order__c> soToUpdateSet = new Set<ASI_HK_CRM_Sales_Order__c>();
            for (ASI_HK_CRM_Sales_Order__c so : soList) 
            {
                List<ASI_HK_CRM_Sales_Order_Item__c> tempSoDetail = soDetailsMap.get(so.id) == null ? new List<ASI_HK_CRM_Sales_Order_Item__c>() :  soDetailsMap.get(so.id);
                boolean isCancel = true;
                for (ASI_HK_CRM_Sales_Order_Item__c soDetail : tempSoDetail)
                {
                    if (soDetail.ASI_HK_CRM_Cancel_Qty__c == null && so.ASI_HK_CRM_Has_Cancelled_Line_Item__c == true)
                    {
                        so.ASI_HK_CRM_Has_Cancelled_Line_Item__c = false;
                        isCancel = false;
                    }
                    
                    if (soDetail.ASI_HK_CRM_Cancel_Qty__c != null && so.ASI_HK_CRM_Has_Cancelled_Line_Item__c == false)
                    {
                        so.ASI_HK_CRM_Has_Cancelled_Line_Item__c = true;
                        soToUpdateSet.add(so);
                        isCancel = true;
                        break;
                    }
                }
                if (!isCancel)
                    soToUpdateSet.add(so);
            }
            if (soToUpdateSet.size() > 0)
            {
                List<ASI_HK_CRM_Sales_Order__c> soToUpdateList = new List<ASI_HK_CRM_Sales_Order__c>();
                soToUpdateList.addAll(soToUpdateSet);
                for(ASI_HK_CRM_Sales_Order__c updateSO : soToUpdateList){
                System.debug('updclk1 ' + updateSo.name);
                    if(updateSO.ASI_HK_CRM_Has_Cancelled_Line_Item__c){
                        System.debug('updclk2 ' + updateSo.name);
                        if (updateSO.name != null)
                        {
                            sendHasUnavailableEmail(updateSO);
                        }
                    }
                }
                update soToUpdateList;
            }
        }
    }
    
    public void sendHasUnavailableEmail(ASI_HK_CRM_Sales_Order__c so){
        System.debug('aku1'+so.Name); 
        System.debug('aku2'+so.owner.Name);
        System.debug('aku3'+so.Id);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        EmailTemplate et = [select id, subject, Body, developerName from EmailTemplate where developerName = 'ASI_HK_CRM_SO_Has_Unavailable_Item'];
        //String[] toAddresses = new String[]{'cpantua@laputatech.com'};
        //String[] toAddresses = new String[]{'aku@laputatech.com','vkoh@laputatech.com','kxie@laputatech.com'};
        //String[] toAddresses = getRecipientFromCustomSet();
        //String[] toAddresses = new String[]{'vkoh@laputatech.com'};       
        //String[] toAddresses = new String[]{'aku@laputatech.com','vkoh@laputatech.com'};  
        String[] toAddresses = new String[]{};
        if (so.ownerId != null) {
            if(so.owner.email != null){ 
                System.debug('aku4'+so.owner.email);
                toAddresses.add(so.owner.email);
            }
        }   
        System.debug('address mailing3:'+toAddresses);
        System.debug('aku1:'+so.ASI_HK_CRM_Customer_DA__r.Name);
        mail.setToAddresses(toAddresses);
        //Mailing Subject
        String mailingSubject = et.subject;
        mailingSubject = mailingSubject.replace('soNumber', so.Name);
        mailingSubject = mailingSubject.replace('customerDA', so.ASI_HK_CRM_Customer_DA__r.Name);
        mailingSubject = mailingSubject.replace('salesmanName', so.owner.Name);
        
        //Mailing Message
        String mailingBody = et.body;
        mailingBody = mailingBody.replace('{soOwner}', so.owner.Name);
        mailingBody = mailingBody.replace('{soURL}', URL.getSalesforceBaseUrl().toExternalForm() + '/' + so.Id);
        
        
        mail.setSubject(mailingSubject);              
        mail.setPlainTextBody(mailingBody);
        mail.setEmailPriority('High');
        if(!Test.isRunningTest())
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});        
    }
}