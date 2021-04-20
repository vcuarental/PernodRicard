global without sharing class ASI_CRM_CN_ContractFinanceLandingBatch implements Database.Batchable<sObject> ,Database.Stateful{

    Private Date cutOffDate;
    
    global ASI_CRM_CN_ContractFinanceLandingBatch(Date cutOffDate){
        
        this.cutOffDate = cutOffDate;
        
        if(this.cutOffDate == Null)
            this.cutOffDate = date.today();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Date d = date.newInstance(cutOffDate.addYears(-1).Year(), 7, 1);//cutOffDate.year() > date.today().year() && cutOffDate.month() < 7 ? date.newInstance(cutOffDate.addYears(-2).Year(), 7, 1) : date.newInstance(cutOffDate.addYears(-1).Year(), 7, 1);
        Date d2 = d.addYears(1);
        
        String whereClausePO = 'ASI_CRM_CN_Last_Submitted_Date__c <= : cutOffDate AND ASI_CRM_CN_Status__c = \'Submitted\' AND ASI_CRM_CN_Effective_Date__c >= : d AND RecordType.DeveloperName Like \'ASI_CRM_CN_%\'';
        
        String soqlQuery = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_TH_CRM_Contract__c', whereClausePO, '');
        
        return Database.getQueryLocator(soqlQuery);
    }

    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        CloneContract((List<ASI_TH_CRM_Contract__c>) scope);
    }
    
    global void finish(Database.BatchableContext BC){}
    
    
    public void CloneContract(List<ASI_TH_CRM_Contract__c> LContract){

        //---- List for mapping 'original contract id' and 'cloned contract pbject position' ----
        Map<id, integer> MapContract = new Map<id, integer>();
        
        //---- original child objects ----
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_Contract_Cost__c> LContractCost = new List<ASI_CRM_Contract_Cost__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet = new List<ASI_CRM_CN_Covered_Outlet__c>();
        List<Attachment> LAtth = new List<Attachment>();
        List<ASI_TH_CRM_Contract__Feed> LFeed = new List<ASI_TH_CRM_Contract__Feed>();
        List<ASI_CRM_Approval_Comment__c> approvalContractComment = new List<ASI_CRM_Approval_Comment__c>();
        
        //----- Check Duplication PO
        Set<String> landingPOSet = new Set<String>();
        
        string strListOfOriginalId = '';
        
        for(ASI_TH_CRM_Contract__c originalContract :LContract) {
            if(strListOfOriginalId == '')
                strListOfOriginalId = '\'' + originalContract.Id + '\'';
            else
                strListOfOriginalId += ', \'' + originalContract.Id + '\'';
            
            String n = originalContract.Name + '.F';
            
            landingPOSet.add(n);
        }        
        
        string whereClause = 'ASI_CRM_CN_Contract__c IN (' + strListOfOriginalId + ')';
        string whereClause2 = 'ASI_CRM_Contract__c IN (' + strListOfOriginalId + ')';
        string whereClauseAtth = 'Parentid IN (' + strListOfOriginalId + ')';
        string whereClauseFeed = 'Type = \'ContentPost\' AND ParentId IN (' + strListOfOriginalId + ') AND Id != null ORDER BY ContentFileName';
        
        //--- get original Approval Comment
        String soqlApprovalComment = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_Approval_Comment__c', whereClause2, '');
        approvalContractComment = DATABASE.Query(soqlApprovalComment);
        
        //---- get original BRSF line items ----
        string soqlBRSF = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_CN_Contract_BRSF_Line_Item__c', whereClause, '');
        LBRSF = DATABASE.Query(soqlBRSF);
        
        //---- get original Contract Cost items ----
        string soqlContractCost = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_Contract_Cost__c', whereClause, '');
        LContractCost = DATABASE.Query(soqlContractCost);
        
        //---- get original Covered Outlet items ----
        string soqlCoveredOutlet = ASI_CRM_Function.getCreatableFieldsSOQL('ASI_CRM_CN_Covered_Outlet__c', whereClause, '');
        LCoveredOutlet = DATABASE.Query(soqlCoveredOutlet);
        
        //---- cloned objects ----
        List<ASI_TH_CRM_Contract__c> LContract_Clone = new List<ASI_TH_CRM_Contract__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> LBRSF_Clone = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_Contract_Cost__c> LContractCost_Clone = new List<ASI_CRM_Contract_Cost__c>();
        List<ASI_CRM_CN_Covered_Outlet__c> LCoveredOutlet_Clone = new List<ASI_CRM_CN_Covered_Outlet__c>();
        List<Attachment> LAtth_Clone = new List<Attachment>();
        List<FeedItem> LFeed_Clone = new List<FeedItem>();
        
       
        integer contractListPos = 0;
        
        Set<String> existingPO = new Set<String>();
        if(LContract != null && LContract.size() > 0)
        {
            
            if(landingPOSet.size() > 0){
                for(ASI_TH_CRM_Contract__c obj : [SELECT id, Name FROM ASI_TH_CRM_Contract__c WHERE Name IN : landingPOSet]){
                    
                    existingPO.add(obj.Name);
                }
            }
            
            for(ASI_TH_CRM_Contract__c originalContract :LContract) {
                
                if(!existingPO.contains(originalContract.Name + '.F')){
                    ASI_TH_CRM_Contract__c cloneContract =originalContract.clone(false, true);
                    cloneContract.ASI_CRM_Contract_Original_Owner__c = originalContract.OwnerId;
                    cloneContract.ASI_CRM_CN_IsClone__c = true;         // set IsClone flag
                    cloneContract.ASI_TH_CRM_Contract_External_ID__c=null;//lokman 4/7/2014 external id remove for clone record
                    cloneContract.ASI_CRM_CN_PO_Modification__c = false;
                    cloneContract.ASI_CRM_CN_Status__c = 'FY Landing Archive';//20170126 Elufa
                    cloneContract.OwnerId = userInfo.getUserId();
                    //cloneContract.ASI_CRM_CN_PO_Version__c =originalContract.ASI_CRM_CN_PO_Version__c;
                    cloneContract.Name = originalContract.Name + '.F';
                    cloneContract.ASI_CRM_Landing_Cutoff_Date__c = cutOffDate;
                    cloneContract.id=null;
                    LContract_Clone.add(cloneContract);
                    
                    MapContract.put(originalContract.Id, contractListPos);
                    contractListPos++;
                }
            }
        }
        System.debug('Cloning LContract_Clone:'+LContract_Clone);
        if(LContract_Clone != null && LContract_Clone.size() > 0) {
            Insert LContract_Clone;
        }
        
        //Clone Sharing Rules
        
        /*List<ASI_TH_CRM_Contract__Share> cloneSharingList = new List<ASI_TH_CRM_Contract__Share>();
        
        for(ASI_TH_CRM_Contract__Share sr : [SELECT Id, AccessLevel, RowCause, UserOrGroupId, ParentID FROM ASI_TH_CRM_Contract__Share WHERE RowCause = : Schema.ASI_TH_CRM_Contract__Share.RowCause.ASI_CRM_CN_Share_To_BA__c AND ParentID IN : LContract]){
            
            if(MapContract.containsKey(sr.ParentID)){
                ASI_TH_CRM_Contract__Share tmp = new ASI_TH_CRM_Contract__Share(ParentID = LContract_Clone[MapContract.get(sr.ParentID)].id, RowCause = sr.RowCause, AccessLevel = sr.AccessLevel, UserOrGroupId = sr.UserOrGroupId);
                cloneSharingList.add(tmp);
            }
            
        }
        
        Insert cloneSharingList;*/
        
        List<ASI_CRM_Approval_Comment__c> LTransferContractComment_Insert = new List<ASI_CRM_Approval_Comment__c>();
        for(ASI_CRM_Approval_Comment__c a : approvalContractComment){
            
            if(MapContract.containsKey(a.ASI_CRM_Contract__c)){
                ASI_CRM_Approval_Comment__c tmp = a.clone(false, true);
                tmp.ASI_CRM_Contract__c = LContract_Clone[MapContract.get(a.ASI_CRM_Contract__c)].id;
                LTransferContractComment_Insert.add(tmp);
            }
        }
        
        insert LTransferContractComment_Insert;
        if(LBRSF != null && LBRSF.size()>0)
        {
            for(ASI_CRM_CN_Contract_BRSF_Line_Item__c originalBRSF :LBRSF) {
                
                if(MapContract.containsKey(originalBRSF.ASI_CRM_CN_Contract__c)){
                    ASI_CRM_CN_Contract_BRSF_Line_Item__c cloneBRSF = originalBRSF.clone(false, true);
                    cloneBRSF.ASI_CRM_CN_Contract__c = LContract_Clone[MapContract.get(originalBRSF.ASI_CRM_CN_Contract__c)].Id;
                    cloneBRSF.ASI_CRM_CN_External_ID__c=null;//lokman 4/7/2014
                    LBRSF_Clone.add(cloneBRSF);
                }
            }
        }
        
        if(LBRSF_Clone != null && LBRSF_Clone.size() > 0) {
            insert LBRSF_Clone;
        }
        if(LContractCost != null && LContractCost.size()>0)
        {
            for(ASI_CRM_Contract_Cost__c originalCost :LContractCost) {
                
                if(MapContract.containsKey(originalCost.ASI_CRM_CN_Contract__c)){
                    ASI_CRM_Contract_Cost__c cloneCost = originalCost.clone(false, true);
                    cloneCost.ASI_CRM_CN_Contract__c = LContract_Clone[MapContract.get(originalCost.ASI_CRM_CN_Contract__c)].Id;
                    cloneCost.ASI_CRM_CN_External_ID__c=null;//lokman 4/7/2014
                    LContractCost_Clone.add(cloneCost);
                }
            }
        }
        
        if(LContractCost_Clone != null && LContractCost_Clone.size() > 0) {
            insert LContractCost_Clone;
        }
        if(LCoveredOutlet != null && LCoveredOutlet.size()>0)
        {
            for(ASI_CRM_CN_Covered_Outlet__c originalCoveredOutlet :LCoveredOutlet) {
                
                if(MapContract.containsKey(originalCoveredOutlet.ASI_CRM_CN_Contract__c)){
                    ASI_CRM_CN_Covered_Outlet__c cloneCoveredOutlet = originalCoveredOutlet.clone(false, true);
                    cloneCoveredOutlet.ASI_CRM_CN_Contract__c = LContract_Clone[MapContract.get(originalCoveredOutlet.ASI_CRM_CN_Contract__c)].Id;
                    cloneCoveredOutlet.ASI_CRM_CN_External_ID__c=null;//lokman 4/7/2014
                    LCoveredOutlet_Clone.add(cloneCoveredOutlet);
                }
            }
        }
        
        if(LCoveredOutlet_Clone != null && LCoveredOutlet_Clone.size() > 0) {
            insert LCoveredOutlet_Clone;
        }
      
        /*if(LAtth != null && LAtth.size()>0)
        {
            for(Attachment originalAtth :LAtth) {
                
                if(MapContract.containsKey(originalAtth.ParentId)){
                    Attachment cloneAtth = originalAtth.clone(false, true);
                    cloneAtth.ParentId = LContract_Clone[MapContract.get(originalAtth.ParentId)].Id;
                    System.debug(cloneAtth.ParentID);
                    cloneAtth.ownerid = UserInfo.getUserID();
                }

            }
        }*/
        
        /*if(LAtth_Clone != null && LAtth_Clone.size() > 0) {
            System.debug(LAtth_Clone);
            insert LAtth_Clone;
        }*/
      
        /*if(LFeed_Clone != null && LFeed_Clone.size() > 0) {
            insert LFeed_Clone;
        }*/
       
    }
}