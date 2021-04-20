/*********************************************************************************
 * Name: ASI_CRM_JP_CheckOutletTelephone_Ctrl
 * Description: Controller class for ASI_CRM_JP_CheckOutletTelephone_Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 01/06/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_JP_CheckOutletTelephone_Ctrl {
    //Parameter from VF Page Name
    private final static String TELEPHONE_NUMBER = 'telephoneNumber';
    
    private List<ASI_CRM_AccountsAdditionalField__c> outletList {get; set;}
    
    //JSON String for VF Page
    public String outletListJson {get {return toJsonString(outletList);}}
    
    public Id ontradeRecordTypeId {get {
        return [SELECT Id FROM RecordType WHERE sObjectType = 'ASI_CRM_AccountsAdditionalField__c' AND DeveloperName = 'ASI_CRM_JP_On_Trade_Outlet'].Id;
    }}
    
    public String outletObjectPrefix {get {
        return Schema.getGlobalDescribe().get('ASI_CRM_AccountsAdditionalField__c').getDescribe().getKeyPrefix(); 
    }}
                                   
    public ASI_CRM_JP_CheckOutletTelephone_Ctrl(ApexPages.StandardController standardController) {
    }
    
    /***************
    View Action Handler
    ***************/
    public void searchTelephone() {
    	Map<String, String> params = ApexPages.currentPage().getParameters();
        String telephoneNumber  = params.get(TELEPHONE_NUMBER);
        
       	outletList = retrieveOnTradeOutletList(telephoneNumber);
    }
    
    public PageReference cancel() {
    	PageReference planPage = new PageReference('/' + outletObjectPrefix);
        planPage.setRedirect(true);
        return planPage;
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveOnTradeOutletList(String telephoneNumber) {
        String query = 'SELECT Id, Name, ASI_CRM_Customer_Name_Kanji__c, ASI_CRM_Customer_Name_Katakana__c, ASI_CRM_CN_CRM_Code__c '
                     + ', ASI_CRM_VN_Channel__c, ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletType__r.Name '
                     + ', ASI_CRM_Customer_Headquarter__c, ASI_CRM_Customer_Headquarter__r.Name '
                     + ', ASI_CRM_CN_Phone_Number__c, ASI_CRM_Branch__c, ASI_CRM_Large_Geographical_Area__c, OwnerId, Owner.Name '
                     + ', ASI_CRM_AR_Location__c, ASI_CRM_JP_Prefecture_Japanese__c '
                     + 'FROM ASI_CRM_AccountsAdditionalField__c '
                     + 'WHERE ASI_CRM_CN_Phone_Number__c = :telephoneNumber ';
        
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }    
        
   	/***************
    Tools Function
    ***************/
    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }
}