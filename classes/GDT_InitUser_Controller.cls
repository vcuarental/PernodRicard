/**
 * @name GDT_InitUser_Controller
 * @description
 * 
 * 
 * @author Simon GAZIN
 */
public with sharing class GDT_InitUser_Controller {

    private final sObject mysObject;

    /**
     * The extension constructor initializes the private member
     * variable mysObject by using the getRecord method from the standard
     * controller.
     * @param  stdController [description]
     */
    public GDT_InitUser_Controller(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }


    /** Listing all record (Custom Settings AD Domaine) */
    public List<GDT_CustomSettings_ADDomaine__c> listUpdate_csADDomain = new List<GDT_CustomSettings_ADDomaine__c>();
    public List<GDT_CustomSettings_ADDomaine__c> listAll_csADDomain {
        get {
            try {
                listUpdate_csADDomain = [SELECT Id, ADDomaine__c, AffiliateGroup__c FROM GDT_CustomSettings_ADDomaine__c ORDER BY ADDomaine__c ASC NULLS FIRST];  
                return listUpdate_csADDomain;
            } catch(Exception e) {
                System.debug(e.getMessage());
                return null;
            }
        }
    }

    /** Listing all record (Custom Settings Company Name) */
    public List<GDT_CustomSettings_CompanyName__c> listUpdate_csCompanyName = new List<GDT_CustomSettings_CompanyName__c>();
    public List<GDT_CustomSettings_CompanyName__c> listAll_csCompanyName {
        get {
            try {
                listUpdate_csCompanyName = [SELECT Id, CompanyName__c, CompanyNameUser__c FROM GDT_CustomSettings_CompanyName__c ORDER BY CompanyName__c ASC NULLS FIRST];  
                return listUpdate_csCompanyName;
            } catch(Exception e) {
                System.debug(e.getMessage());
                return null;
            }
        }
    }

    /** If a new domain isn't present in list */
    public void refresh_CustomSettings_ADDomain() {
        GDT_CS_ADDomaine_Batch myBatchObject = new GDT_CS_ADDomaine_Batch();
        ID batchprocessid = Database.executebatch(myBatchObject);
        
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The values are being calculated. Thanks to refresh the page in a few minutes')); 
    }

    /** Update record in custom settings (Inline Edit) */
    public void saveCustomSettings_ADDomain() {
        if(listUpdate_csADDomain != null)
            update listUpdate_csADDomain;
    }

    /** If a new CompanyName isn't present in list */
    public void refresh_CustomSettings_CompanyName() {
        GDT_CS_CompanyName_Batch myBatchObject = new GDT_CS_CompanyName_Batch();
        ID batchprocessid = Database.executebatch(myBatchObject);
        
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The values are being calculated. You can see the records in the Custom Settings (GDT CustomSettings CompanyName)'));
    }

    /** Update record in custom settings (Inline Edit) */
    public void saveCustomSettings_CompanyName() {
        if(listUpdate_csCompanyName != null)
            update listUpdate_csCompanyName;
    }
}