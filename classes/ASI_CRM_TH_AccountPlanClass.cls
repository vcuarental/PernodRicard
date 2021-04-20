/*********************************************************************************
 * Name: ASI_CRM_TH_AccountPlanClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_AccountPlanClass
*********************************************************************************/

public with sharing class ASI_CRM_TH_AccountPlanClass {   
    private ApexPages.StandardController standardController{get;set;}   
    private static Integer PAGE_BREAK = 4;
    public Account acct{get; set;}
    public ASI_CRM_Pros_Segmentation__c prosSeg{get;set;}
    public ASI_CRM_ServicePack__c serPack {get; set;}
    public List <ASI_CRM_ServicePackItem__c> listSerPackitem {get; set;}
    public Map<Integer, List<ASI_CRM_ServicePackItem__c>> serPackItemMap {get;set;}
    public Datetime servicePackLastModifiedDate {get;set;} 
    private static Set<String> printPDFEnbledRecordTypes= new Set<String>{
        'ASI_TH_PROS_Segmentation'
    }; 
    public Map<Id, Attachment> attachmentMap {get;set;}
    
    public ASI_CRM_TH_AccountPlanClass (ApexPages.StandardController standardController){
        //Standard Controller = Pros Segmentation
        this.standardController = standardController;
        
        prosSeg = (ASI_CRM_Pros_Segmentation__c)standardController.getRecord();
        prosSeg = [SELECT id, Name, ASI_CRM_SG_Customer__r.Name, Recordtype.DeveloperName,
                                ASI_CRM_SG_Account__c, ASI_CRM_SG_Account__r.Name,
                                ASI_CRM_SG_Customer__c, 
                                ASI_CRM_SG_Service_Pack__c,                                      
                                ASI_CRM_SG_Group_Outlet_Type__c, ASI_CRM_SG_Outlet_Type__c,
                                ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c,
                                ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c, 
                                ASI_CRM_SG_Outlet_Type__r.ASI_CRM_SG_Name__c,
                                ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c,
                                ASI_CRM_SG_Customer__r.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c,
                                ASI_CRM_SG_DAMD_Threshold__c, ASI_CRM_SG_DAMD_Threshold__r.ASI_CRM_SG_Action__c,
                                LastModifiedDate
                                FROM ASI_CRM_Pros_Segmentation__c
                                WHERE id =: prosSeg.id];
                                
        System.debug('Flag - Service Pack ID:' + prosSeg.ASI_CRM_SG_Service_Pack__c);
        System.debug('Flag - Check Pros:' + prosSeg);
        
        if(prosSeg.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c !=null && prosSeg.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c!=null && prosSeg.ASI_CRM_SG_DAMD_Threshold__r.ASI_CRM_SG_Action__c!=null && prosSeg.ASI_CRM_SG_Outlet_Type__r.ASI_CRM_SG_Name__c!=null){
            getSerPack();
            if(serPack != null)
                servicePackLastModifiedDate = initSerivePackLastmodifiedDate(serPack.id);
        }
    }
    
    public void getSerPack(){
        serPack = null;
        // SERVICE PACK 
        System.debug('Flag - getSerPack - Check Pros:' + prosSeg);
        if (prosSeg != null){
            //Edit 10/15 - Changed source of image level from Image Level Threshold to Account (EU) image level to support Force Iconic.
            //Edit 11/06 - Retained use of Image Level Threshold for PRT
            String imageLevelName = prosSeg.ASI_CRM_SG_Customer__r.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c;
            
            List<ASI_CRM_ServicePack__c> tempSerPack = [SELECT id, Name, ASI_CRM_SG_Segmentation__c, ASI_CRM_SG_Outlet_Type__c 
                                                        FROM ASI_CRM_ServicePack__c
                                                        WHERE ASI_CRM_SG_Outlet_Type__c =: prosSeg.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c
                                                        AND ASI_CRM_SG_Segmentation__c =: imageLevelName
                                                        AND ASI_CRM_SG_DAMD_Action__c =: prosSeg.ASI_CRM_SG_DAMD_Threshold__r.ASI_CRM_SG_Action__c
                                                        AND ASI_CRM_SG_Sub_Outlet_Type__c =: prosSeg.ASI_CRM_SG_Outlet_Type__r.ASI_CRM_SG_Name__c
                                                        ];
            if(tempSerPack.size()>0){
                serPack = tempSerPack[0];
                prosSeg.ASI_CRM_SG_Service_Pack__c = serPack.Id;
                System.debug('FLAG - Service Pack: ' + serPack);
                listSerPackitem  = retrieveServicePackItems();                                                        
                System.debug('FLAG - Service Pack Items: ' + listSerPackitem);
                attachmentMap = fileMap(listSerPackitem);
                System.debug(attachmentMap);
                prepareSerPackItemPerPage();
            }
        }
    }
    
    public void prepareSerPackItemPerPage(){
        serPackItemMap = new Map<Integer, List<ASI_CRM_ServicePackItem__c>>();
        
        List<ASI_CRM_ServicePackItem__c> serPackItemPerPage = new List<ASI_CRM_ServicePackItem__c>();
        Integer ctr = 0;
        Integer ctrMap = 0;        
        Boolean pageBreak = false;
        
        for(ASI_CRM_ServicePackItem__c sp :listSerPackitem){
            ctr++;
            if(ctr <= PAGE_BREAK){
                serPackItemPerPage.add(sp);
                system.debug('***serPackItemPerPage : ' + serPackItemPerPage);
            }
            if(ctr == PAGE_BREAK){
                ctr = 0;
                ctrMap++;
                
                serPackItemMap.put(ctrMap, serPackItemPerPage);
                serPackItemPerPage = new List<ASI_CRM_ServicePackItem__c>();
                system.debug('***serPackItemMap : ' + serPackItemMap);
                system.debug('***serPackItemPerPage2 : ' + serPackItemPerPage);
            }
        }
        
        if(serPackItemPerPage.size() > 0){
            serPackItemMap.put(serPackItemMap.size()+1, serPackItemPerPage);
        }
        
        system.debug('***: ' + serPackItemMap);
    }
    
    public PageReference gotoProsSegmentation(){
        PageReference pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id'));
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    private List <ASI_CRM_ServicePackItem__c> retrieveServicePackItems() {
        Set<String> iFields = new Set<String>();
        system.debug('key key :' + SObjectType.ASI_CRM_ServicePackItem__c.FieldSets.getMap().keySet());
        for(String key: SObjectType.ASI_CRM_ServicePackItem__c.FieldSets.getMap().keySet()){
          Schema.FieldSet f = SObjectType.ASI_CRM_ServicePackItem__c.FieldSets.getMap().get(key); 
            for(Schema.FieldSetMember fm: f.getFields()){
                iFields.add(fm.getFieldPath());
            }
        }
        system.debug('the fields: '+iFields);
        String serPackId = serPack.id;
        String theQuery = '';
        if(!Test.isRunningTest())
            theQuery = 'SELECT ASI_CRM_SG_Sub_family__c, ASI_CRM_SG_Sub_family__r.Name,ASI_CRM_SG_Sub_family__r.ASI_CRM_SG_Brand__c, ASI_CRM_SG_Sub_family__r.ASI_CRM_SG_Brand__r.Name, ASI_CRM_SG_Act_Vis__c, ASI_CRM_SG_No_of_Events__c, ASI_CRM_SG_POSM_Cost__c, ASI_CRM_SG_Signage__c,' + joinList(iFields, ', ') +  
                              ' FROM ASI_CRM_ServicePackItem__c WHERE ASI_CRM_ServicePack__c = :serPackId order by ASI_CRM_SG_Sub_family__r.Name,ASI_CRM_SG_Sub_family__r.ASI_CRM_SG_Brand__r.Name ASC';
        else
            theQuery = 'SELECT ASI_CRM_SG_Sub_family__c, ASI_CRM_SG_Sub_family__r.Name,ASI_CRM_SG_Sub_family__r.ASI_CRM_SG_Brand__c, ASI_CRM_SG_Sub_family__r.ASI_CRM_SG_Brand__r.Name, ASI_CRM_SG_Act_Vis__c, ASI_CRM_SG_No_of_Events__c, ASI_CRM_SG_POSM_Cost__c, ASI_CRM_SG_Signage__c' + 
                              ' FROM ASI_CRM_ServicePackItem__c WHERE ASI_CRM_ServicePack__c = :serPackId order by ASI_CRM_SG_Sub_family__r.Name,ASI_CRM_SG_Sub_family__r.ASI_CRM_SG_Brand__r.Name ASC';
        return(List <ASI_CRM_ServicePackItem__c>)Database.query(theQuery);       
    }
    
    private static String joinList(Set<String> theList, String separator) {
        if (theList == null)   { return null; }
        if (separator == null) { separator = ''; }
    
        String joined = '';
        Boolean firstItem = true;
        for (String item : theList) {
            if(null != item) {
                if(firstItem){ firstItem = false; }
                else { joined += separator; }
                joined += item;
            }
        }
        return joined;
    }
    
    private DateTime initSerivePackLastmodifiedDate(Id servicePackId ){
        List<ASI_CRM_ServicePackItem__c > servicePackItems = [select id, lastmodifieddate, ASI_CRM_ServicePack__r.lastmodifieddate from ASI_CRM_ServicePackItem__c where ASI_CRM_ServicePack__c=: servicePackId order by lastmodifieddate desc];
        if(servicePackItems != null && servicePackItems.size()>0){
            ASI_CRM_ServicePackItem__c servicePackItem= servicePackItems.get(0);
            if(servicePackItem.lastmodifieddate > servicePackItem.ASI_CRM_ServicePack__r.lastmodifieddate)
                return   servicePackItem.lastmodifieddate;
            else
                return   servicePackItem.ASI_CRM_ServicePack__r.lastmodifieddate;
        }
        return null;
    }
    
    private Map<Id, Attachment> fileMap(List<ASI_CRM_ServicePackItem__c> sptList){       
        Set<Id> sptIds = new Set<Id>();
        Map<Id, Attachment> tempMap = new Map<Id, Attachment>();
        
        for(ASI_CRM_ServicePackItem__c spt : sptList){
            sptIds.add(spt.Id);
            tempMap.put(spt.Id, new Attachment(Name = ''));
        }
        
        List<Attachment> attList = [SELECT Name, ParentId, Id FROM Attachment WHERE ParentId in: sptIds];
        
        for(Attachment att : attList){
            tempMap.put(att.ParentId, att);
        }
        
        return tempMap;
    }

}