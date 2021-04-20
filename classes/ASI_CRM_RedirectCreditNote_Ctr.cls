/*********************************************************************************
 * Name: ASI_CRM_RedirectCreditNote_Ctr
 * Description: Assign default value for Credit Note when click [New] button
 * Test Class: ASI_CRM_SG_TestClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 07/08/2015         Wilken Lee            Created
*********************************************************************************/
public class ASI_CRM_RedirectCreditNote_Ctr {
    private Id rtId{get;set;}
	private String recordTypeId{get;set;}
    private RecordType rt{get;set;}
    public PageReference redirectPage {get;set;}
    
    public ASI_CRM_RedirectCreditNote_Ctr (ApexPages.StandardController controller) {
        rtId = ((ASI_CRM_Credit_Debit_Note__c)controller.getRecord()).RecordTypeId;
        
          // handle user with only one record type
        if(rtId  == null){
            Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.ASI_CRM_Credit_Debit_Note__c;    
            List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
            system.debug(rtInfos);
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                // For only one record type available user
                if(rtInfo.isAvailable() && rtInfo.getName() != 'Master') {               
                    //ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
                    rtId  = rtInfo.getRecordTypeId();
                    break;
                }
            }
        }
        system.debug('Record Type ID: ' + rtId);
        rt = Global_RecordTypeCache.getRt(rtId);
    }
    
    public PageReference redirect(){
        system.debug('rt DeveloperName: ' + rt.DeveloperName);
        if(rt.DeveloperName.contains('ASI_CRM_SG_Manual')){
            Schema.DescribeSObjectResult cNoteObj = ASI_CRM_Credit_Debit_Note__c.sObjectType.getDescribe();
            redirectPage = new PageReference('/'+ cNoteObj.getKeyPrefix() +'/e?RecordType=' + rtId + '&nooverride=1&Name=Auto-generated Number');
            return redirectPage;
        }
        else 
            return null;
    }
}