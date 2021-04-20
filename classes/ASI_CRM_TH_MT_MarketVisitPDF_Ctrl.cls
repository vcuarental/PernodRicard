/*********************************************************************************
 * Name: ASI_CRM_TH_MT_MarketVisitPDF_Ctrl 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/06/2016       Introv: Twinkle         Created
*********************************************************************************/
global without sharing class ASI_CRM_TH_MT_MarketVisitPDF_Ctrl{
    public Id idMarketVisit {get;set;}
    public List<ASI_CRM_Market_Visit__c> listMV {get;set;}
    public List<ASI_CRM_Sales_Movement__c> listSM {get;set;}
    public List<Attachment> listAttachments {set;get;}
    public Boolean showAttachment1 {set;get;}
    public Boolean showAttachment2 {set;get;}
    public Boolean showAttachment3 {set;get;}
    public Boolean showAttachment4 {set;get;}
    public Boolean showAttachment5 {set;get;}
    
    public ASI_CRM_TH_MT_MarketVisitPDF_Ctrl (ApexPages.StandardController stdController){
        idMarketVisit = ApexPages.currentPage().getParameters().get('id');
        
        //Market Visit
        listMV = [
            SELECT Id, Name, ASI_CRM_Account_Group__c, ASI_CRM_Account_Name__c, ASI_CRM_Branch_Name__c, ASI_CRM_Visit_Date__c,
                   ASI_CRM_Attendee__c, ASI_CRM_Objectives__c, ASI_CRM_Objectives_Others__c, ASI_CRM_Who__c, ASI_CRM_Who_Others__c,
                   ASI_CRM_Insight__c, ASI_CRM_KeyIssuesOpportunities__c, ASI_CRM_Action_Plans__c, ASI_CRM_Report_Summary__c
            FROM ASI_CRM_Market_Visit__c
            WHERE Id =: idMarketVisit
        ];
        
        //Define PDF file name
        String fileName = listMV[0].Name+'.pdf' ;
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName);
        
        //Sales Movements
        List<ASI_CRM_Sales_Movement__c> listQuerySM = [
            SELECT id, ASI_CRM_TH_Category__r.Name, ASI_CRM_Brand__r.Name, ASI_CRM_Sub_brand__r.Name, 
                   ASI_CRM_Promotion_Period_From__c, ASI_CRM_Promotion_Period_To__c, ASI_CRM_Promotion_Type__c, 
                   ASI_CRM_Promotion_Type_Others__c, ASI_CRM_RSP__c, ASI_CRM_Remarks__c
            FROM ASI_CRM_Sales_Movement__c
            WHERE ASI_CRM_Market_Visit__c =: listMV[0].id
        ];
        
        listSM = new List<ASI_CRM_Sales_Movement__c>();
        for(ASI_CRM_Sales_Movement__c mv : listQuerySM){
            if(mv.ASI_CRM_Promotion_Type__c != NULL){
                String[] tmpStringPT = mv.ASI_CRM_Promotion_Type__c.split(';');
                String strPT = '';
                
                For(String s : tmpStringPT){
                    strPT += s+'; ';
                }
                mv.ASI_CRM_Promotion_Type__c = strPT;
                
                listSM.add(mv);
            }
        }
        
        //Attachments
        listAttachments = new List<Attachment>();
        listAttachments = [
            SELECT Id, Name, ContentType 
            FROM Attachment 
            WHERE ParentId =: idMarketVisit 
            ORDER BY CreatedDate DESC
        ];
            
        if(listAttachments.size() >= 1){
            showAttachment1 = TRUE;
        }
        if(listAttachments.size() >= 2){
            showAttachment2 = TRUE;
        }
        if(listAttachments.size() >= 3){
            showAttachment3 = TRUE;
        }
        if(listAttachments.size() >= 4){
            showAttachment4 = TRUE;
        }
        if(listAttachments.size() >= 5){
            showAttachment5 = TRUE;
        }
    }
}