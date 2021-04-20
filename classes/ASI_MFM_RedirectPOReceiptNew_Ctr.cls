/*
    - This Controller controls the Page Traffic of the PO Receipt Standard New Action.
*/

public class ASI_MFM_RedirectPOReceiptNew_Ctr {
    private ASI_MFM_PO_Receipt__c receipt{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    
  
    
    public ASI_MFM_RedirectPOReceiptNew_Ctr (ApexPages.StandardController controller) {

        recordTypeId = ((ASI_MFM_PO_Receipt__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_MFM_PO_Receipt__c)controller.getRecord()).Id;
        // handle user with only one record type
        if(recordTypeId  == null){
            Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.ASI_MFM_PO_Receipt__c;    
            List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
            system.debug(rtInfos);
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                System.debug(rtInfo);
                System.debug(rtInfo.isDefaultRecordTypeMapping());
                // For only one record type available user
                if(rtInfo.isAvailable() && rtInfo.getName() != 'Master') {               
                    //ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
                    recordTypeId  = rtInfo.getRecordTypeId();
                    break;
                }
            }
            
        }
        
        recordTypeName = 'null';
        System.debug(recordTypeId);
        if(recordTypeId != '' && recordTypeId != null){
            Recordtype rt = Global_RecordTypeCache.getRt(recordTypeId);
            recordTypeName = rt.DeveloperName;
        }
        /*for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1]){
            recordTypeName = rt.DeveloperName;
            system.debug(recordtypeName);     
        }*/
    }
    public PageReference redirect(){
        //if RecordTypeName = 'ASI_MFM_CN_PO_Receipt', redirect to page 'ASI_MFM_CN_InputPOReceiptItemsPage', else redirect to default create page
        
        System.debug('recordtypeNameTest'+recordtypeName);
        if(recordTypeName == 'ASI_MFM_CN_PO_Receipt') 
        {
            redirectPage =  new PageReference('/apex/ASI_MFM_CN_InputPOReceiptItemsPage?RecordType='+recordTypeId);
        }
        else if(recordTypeName == 'ASI_MFM_JP_PO_Receipt' || recordTypeName == 'ASI_MFM_KR_PO_Receipt' ) 
        {
            apexpages.message err = new apexpages.message(apexpages.severity.error, 'Please click PO Tab to create PO Receipt.');
             apexpages.addmessage(err); 
        }
        else {
            Schema.DescribeSObjectResult receiptObj = ASI_MFM_PO_Receipt__c.sObjectType.getDescribe();
            if(recordTypeId != null)
                redirectPage =  new PageReference('/'+ receiptObj.getKeyPrefix() +'/e?RecordType='+recordTypeId+'&nooverride=1');
            else{
                redirectPage =  new PageReference('/'+ receiptObj.getKeyPrefix() +'/e?nooverride=1');
            }
        }
        
        return redirectPage;
    }

}