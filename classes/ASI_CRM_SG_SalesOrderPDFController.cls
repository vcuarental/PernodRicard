/*********************************************************************************
 * Name:ASI_CRM_SG_SalesOrderPDFController
 * Description: Controller to handle the data of Sales Order Request PDF Attachement.
 * Related Test Class: ASI_CRM_SG_SalesOrder_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 18/11/2014       Laputa: Conrad          Created
 * 29/04/2016       Laputa: Hugo            Add the additional FOC and total sum FOC in PDF, Create Class SalesOrderLineWrapper
 * 21/02/2018       Wilken Lee	            [WL 1.0] Correct PDF to show SKU Name instead of JDE Search Text
*********************************************************************************/
public with sharing class ASI_CRM_SG_SalesOrderPDFController{
        
    public ID currentHeaderId {get;set;}
    public string init;
    public ASI_KOR_Sales_Order_Request__c Header;
    public List<SalesOrderLineWrapper> details;
    public decimal totalCarton {get;set;}
    public decimal totalBottle {get;set;}
    public decimal totalFOC {get;set;}
    public decimal totalAdditionalFOC {get;set;}
    public decimal totalSumFOC {get;set;}

    public Boolean isWholeSaler {get;set;} {isWholeSaler = true;}
    
    public String approverName {get;set;}
    
    public ASI_CRM_SG_SalesOrderPDFController(){
        totalCarton = 0;
        totalBottle = 0;
        totalFOC = 0;
        totalAdditionalFOC = 0;
        totalSumFOC = 0;
    }  
    
    public ASI_KOR_Sales_Order_Request__c getHeader(){
        ASI_KOR_Sales_Order_Request__c Headertemp = (ASI_KOR_Sales_Order_Request__c)(queryAll(currentHeaderId, 'ASI_KOR_Sales_Order_Request__c', 'ID', ' , owner.name ', '').get(0));
        if(Headertemp != null) {
            List<ProcessInstance> approvalProcessList = [SELECT ID, TargetObjectId, Status, LastActorId, LastActor.name
                                                            FROM ProcessInstance
                                                            WHERE TargetObjectId = : Headertemp.id
                                                            AND Status = : 'Approved'];
            if(approvalProcessList.size() > 0) {
                this.approverName = approvalProcessList.get(0).LastActor.name;
            }
            System.debug('approvalProcessList ' + approvalProcessList);
        }
        
        if(Headertemp.Recordtype.DeveloperName == 'ASI_CRM_SG_Wholesaler' || 
           Headertemp.Recordtype.DeveloperName == 'ASI_CRM_SG_Wholesaler_Lock') {
            isWholeSaler = true;
        } else {
            isWholeSaler = false;
        }

        return Headertemp;
    }    
    
    public List<SalesOrderLineWrapper> getDetails(){
        List<SalesOrderLineWrapper> salesOrderLineWrapperList = new List<SalesOrderLineWrapper>();

		/*[WL 1.0] BEGIN*/
        //List<ASI_KOR_Sales_Order_Transaction__c> detailsTemp = (List<ASI_KOR_Sales_Order_Transaction__c>)queryAll(currentHeaderId, 'ASI_KOR_Sales_Order_Transaction__c', 'ASI_KOR_Sales_Order_Request__c', '', '');
		List<ASI_KOR_Sales_Order_Transaction__c> detailsTemp = (List<ASI_KOR_Sales_Order_Transaction__c>)queryAll(currentHeaderId, 'ASI_KOR_Sales_Order_Transaction__c', 'ASI_KOR_Sales_Order_Request__c', ',ASI_CRM_SG_SKU__r.Name', '');
		/*[WL 1.0] END*/
		
        totalCarton = 0;
        totalBottle = 0;
        totalFOC = 0;
        totalAdditionalFOC = 0;
        totalSumFOC = 0;

        for(ASI_KOR_Sales_Order_Transaction__c detail : detailsTemp) {
            totalCarton += detail.ASI_CRM_SG_Request_Quantity_Carton__c != null ? detail.ASI_CRM_SG_Request_Quantity_Carton__c : 0;
            totalBottle += detail.ASI_CRM_SG_Request_Quantity_Bottle__c != null ? detail.ASI_CRM_SG_Request_Quantity_Bottle__c : 0;
            totalFOC += detail.ASI_CRM_SG_FOC__c != null ? detail.ASI_CRM_SG_FOC__c : 0;
            if(isWholeSaler) {
                totalAdditionalFOC += detail.ASI_CRM_FOC_Additional__c != null ? detail.ASI_CRM_FOC_Additional__c : 0;
            }

            SalesOrderLineWrapper salesOrderLineWrapper = new SalesOrderLineWrapper(detail);
            salesOrderLineWrapperList.add(salesOrderLineWrapper);
        }
		
        totalSumFOC = totalFOC + totalAdditionalFOC;
        
        return salesOrderLineWrapperList;
    }
    
    private List<sObject> queryAll(ID filterID, String sObjectName, String filteringField, String extraFields, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery += extraFields + ' , recordtype.developername From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
        
		system.debug('thequery: ' + thequery);
		
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }

    public class SalesOrderLineWrapper {

            public ASI_KOR_Sales_Order_Transaction__c salesOrderLineItem {get; set;}
            public decimal totalFOC {get; set;}

            public SalesOrderLineWrapper(ASI_KOR_Sales_Order_Transaction__c salesOrderLineItem) {
                if(salesOrderLineItem.ASI_CRM_SG_FOC__c == null) {
                    salesOrderLineItem.ASI_CRM_SG_FOC__c = 0;
                }
                
                if(salesOrderLineItem.ASI_CRM_FOC_Additional__c == null) {
                    salesOrderLineItem.ASI_CRM_FOC_Additional__c = 0;
                }
     			
                totalFOC = 0;
                totalFOC += salesOrderLineItem.ASI_CRM_SG_FOC__c;
                totalFOC += salesOrderLineItem.ASI_CRM_FOC_Additional__c;
                
                this.salesOrderLineItem = salesOrderLineItem;
            }

    }
    
}