public without sharing class ASI_CRM_CN_SalesOrderNewRequestCRTLLER {
    
    String headerId;
    ASI_CRM_AccountsAdditionalField__c customer;
    String salesOrderRecordTypeID;
	public ASI_CRM_CN_SalesOrderNewRequestCRTLLER(ApexPages.StandardController stdCON) {
    	headerId = ApexPages.currentPage().getParameters().get('id');
        customer = [SELECT id
                    , Name
                    , ASI_CRM_CN_Address__c
                    , ASI_CRM_CN_Contact_Person__c
                    , ASI_CRM_CN_Tel__c
                    , ASI_CRM_CN_Warehouse_Contact_person__c
                    , ASI_CRM_CN_Warehouse_Address1__c 
                    , ASI_CRM_CN_Warehouse_Address2__c
                    , ASI_CRM_CN_Warehouse_Tel__c
                    , ASI_CRM_CN_Contact_Person_CAP__c
                    , ASI_CRM_CN_Address_CAP__c
                    , ASI_CRM_CN_Tel_CAP__c
                    , recordType.DeveloperName
                    FROM ASI_CRM_AccountsAdditionalField__c WHERE ID = : headerId];
        salesOrderRecordTypeID = [SELECT id FROM recordType WHERE developerName = 'ASI_CRM_CN_SalesOrder'].id;
    }
    
    public pageReference newSalesOrder(){
        
        /*if(customer.recordType.DeveloperName == 'ASI_CRM_CN_WS'){
            String url = '/' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SalesOrder_Object_ID__c + '/e?';
            url += ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Customer__c + '=' + customer.Name;
            url += '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Customer__c + '_lkid=' + customer.id + '&retURL=%2F' + customer.id;
            url += '&RecordType=' + salesOrderRecordTypeID;
            url += customer.ASI_CRM_CN_Warehouse_Contact_person__c != NULL ? ( '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Contact_Person__c + '=' + customer.ASI_CRM_CN_Warehouse_Contact_person__c ) : '';
            url += customer.ASI_CRM_CN_Warehouse_Address1__c != NULL ? '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Address__c + '=' + customer.ASI_CRM_CN_Warehouse_Address1__c : '';
            url += customer.ASI_CRM_CN_Warehouse_Address2__c != NULL ? ' ' + customer.ASI_CRM_CN_Warehouse_Address2__c : '';
            url += customer.ASI_CRM_CN_Warehouse_Tel__c != NULL ? '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Tel_Mobile__c + '=' + customer.ASI_CRM_CN_Warehouse_Tel__c : '';
           
            PageReference redirect = new PageReference(url);
            redirect.setRedirect(true);
            return redirect;
        }else if(customer.recordType.DeveloperName == 'ASI_CRM_Outlet_CN'){
            
            String url = '/' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SalesOrder_Object_ID__c + '/e?';
            url += ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Customer__c + '=' + customer.Name;
            url += '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Customer__c + '_lkid=' + customer.id + '&retURL=%2F' + customer.id;
            url += '&RecordType=' + salesOrderRecordTypeID;
            url += customer.ASI_CRM_CN_Contact_Person_CAP__c != NULL ? '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Contact_Person__c + '=' + customer.ASI_CRM_CN_Contact_Person_CAP__c : '';
            url += customer.ASI_CRM_CN_Address_CAP__c != NULL ? '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Address__c + '=' + customer.ASI_CRM_CN_Address_CAP__c : '';
            url += customer.ASI_CRM_CN_Tel_CAP__c != NULL ? '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Tel_Mobile__c + '=' + customer.ASI_CRM_CN_Tel_CAP__c : '';
           
            PageReference redirect = new PageReference(url);
            redirect.setRedirect(true);
            return redirect;*/
        if(customer.recordType.DeveloperName.contains('CN')){
            String url = '/' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SalesOrder_Object_ID__c + '/e?';
            url += ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Customer__c + '=' + customer.Name;
            url += '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Customer__c + '_lkid=' + customer.id + '&retURL=%2F' + customer.id;
            url += '&RecordType=' + salesOrderRecordTypeID;
            url += customer.ASI_CRM_CN_Contact_Person__c != NULL ? ( '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Contact_Person__c + '=' + customer.ASI_CRM_CN_Contact_Person__c ) : '';
            url += customer.ASI_CRM_CN_Address__c != NULL ? '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Address__c + '=' + customer.ASI_CRM_CN_Address__c : '';
            url += customer.ASI_CRM_CN_Tel__c != NULL ? '&' + ASI_CRM_CN_Field_ID_Mapping__c.getValues('SalesOrder Field Id').ASI_CRM_CN_SO_Tel_Mobile__c + '=' + customer.ASI_CRM_CN_Tel__c : '';
           
            PageReference redirect = new PageReference(url);
            redirect.setRedirect(true);
            return redirect;
        }else{
            return NULL;
        }
    }
}