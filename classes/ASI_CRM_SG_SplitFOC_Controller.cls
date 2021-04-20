public without sharing class ASI_CRM_SG_SplitFOC_Controller {
    
    public ASI_FOC_Free_Goods_Request__c header {get;set;}
    public List<ASI_FOC_Request_Item__c> headerLines {get;set;}

    public String wholeSalerSelected {get;set;}{wholeSalerSelected = '';}
    public List<SelectOption> wholeSalerSelectOptions {get;set;}
    
    public ASI_CRM_SG_SplitFOC_Controller(ApexPages.StandardController stdController) {
        
        List<ASI_FOC_Free_Goods_Request__c> headerList = (List<ASI_FOC_Free_Goods_Request__c>)queryAll(((ASI_FOC_Free_Goods_Request__c)stdController.getRecord()).id, 'ASI_FOC_Free_Goods_Request__c', '', 'ID', '');
        
        if(headerList.size() > 0) {   
            Header = headerList.get(0);
            headerLines = (List<ASI_FOC_Request_Item__c>)queryAll(Header.id, 'ASI_FOC_Request_Item__c', 'ASI_CRM_Wholesaler__r.name,', 'ASI_FOC_Request_Order__c', 'AND ASI_CRM_Wholesaler__c <> NULL');
            wholeSalerSelectOptions = setwholeSalerSelectOptions();
        }
    }
    
    public List<SelectOption> setwholeSalerSelectOptions() {
        List<SelectOption> result = new List<SelectOption>();
        Set<ID> wholeSalerIds = new Set<ID>();
        for(ASI_FOC_Request_Item__c headerLine : headerLines) {
            if(!wholeSalerIds.contains(headerLine.ASI_CRM_Wholesaler__c)) {
                result.add(new SelectOption(headerLine.ASI_CRM_Wholesaler__c, headerLine.ASI_CRM_Wholesaler__r.name));
                wholeSalerIds.add(headerLine.ASI_CRM_Wholesaler__c);
            }
        }
        return result;
    }

    public PageReference split() {
        System.Savepoint pSavepoint = Database.setSavepoint();
        Pagereference ref;
        try{
            if(wholeSalerSelected != null && wholeSalerSelected != '' ) {
                List<ASI_FOC_Request_Item__c> cloneHeaderLines = new List<ASI_FOC_Request_Item__c>();
                List<ASI_FOC_Request_Item__c> deleteHeaderLines = new List<ASI_FOC_Request_Item__c>();
                ASI_FOC_Free_Goods_Request__c newHeader = header.clone(false, true, false, false);
                newHeader.ASI_CRM_SG_External_Id__c = null;
                newHeader.ASI_CRM_External_ID__c = null;
                newHeader.ASI_FOC_Request_Status__c = 'Draft';
                insert newHeader;
                for(ASI_FOC_Request_Item__c headerLine : headerLines) {
                    if(headerLine.ASI_CRM_Wholesaler__c == ((id)wholeSalerSelected)) {
                        ASI_FOC_Request_Item__c cloneHeaderLine = headerLine.clone(false, true, false, false);
                        cloneHeaderLine.ASI_FOC_Request_Order__c = newHeader.id;
						cloneHeaderLine.ASI_FOC_Sys_Unique_Key__c = ''; //Wilken 20160906, clear unique external ID field when clone
                        cloneHeaderLines.add(cloneHeaderLine);
                        deleteHeaderLines.add(headerLine);
                    }
                }

                if(cloneHeaderLines.size() > 0) {
                    insert cloneHeaderLines;
                }
                if(deleteHeaderLines.size() > 0) {
                    delete deleteHeaderLines;
                }
                ref = new PageReference('/'+newHeader.Id);

            } else {
                ref = null;   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Wholesaler selected.'));
            }
        } catch (exception e) {
            ref = null;
            Database.rollback(pSavepoint);      
            String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
        }
        return ref;
    }
    
    private List<sObject> queryAll(ID filterID, String sObjectName, String extraField, String filteringField, String extraQuery) {
    
        List<sObject> sObjectList = new List<sObject>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();  
        Schema.sObjectType sObjType = globalDescription.get(sObjectName);  
        Schema.DescribeSObjectResult r1 = sObjType.getDescribe();  
        
        Map<String, Schema.SObjectField> sObjectFieldMap = r1.fields.getMap();
        String theQuery = 'Select ' + extraField + ' ';
        
        for(String fields  : sObjectFieldMap.keySet()){
            theQuery += fields + ' ,';
        }
        thequery = theQuery.subString(0,theQuery.length()-1);
        thequery +=' From '+sObjectName+' where '+filteringField+' = \''+ filterID + '\' ' + extraQuery;
                
        sObjectList = Database.query(theQuery);
        
        return sObjectList;
    }

}