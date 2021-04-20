/********************************************************************************
* Controller for LAT_MX_VFP11_ExternalSys , 
*
* NAME: LAT_MX_VFP11_ExternalSys_Controller .cls
* AUTHOR: Mariano Boezio                           DATE: 28/07/2015
********************************************************************************/
public with sharing class LAT_MX_VFP11_ExternalSys_Controller {

    public List<LAT_MX_External_Links__c> lista;

    public LAT_MX_VFP11_ExternalSys_Controller() {}
    
    // Get List of Custom Settings to display in VF page
    public  List<LAT_MX_External_Links__c> getLista() {
        List<LAT_MX_External_Links__c> links = [SELECT Id, LAT_MX_Label__c, LAT_MX_Link__c, LAT_MX_Display_Order__c, 
        											   LAT_DisplayInCurrentPage__c
                                                    FROM LAT_MX_External_Links__c 
                                                    ORDER BY LAT_MX_Display_Order__c];
        if (links != null && !links.isEmpty()) {
            return links;
        } else {
            return new List<LAT_MX_External_Links__c>();
        }
        
    }

}