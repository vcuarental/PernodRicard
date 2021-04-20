/* Filename:    ASI_CRM_CN_ChannelStratgy_Controller.cls
 * Author:      Stella Sing (Introv Limited)
 * Purpose:     View and edit page controller for channel Strategy
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2014-03-18   stella.sing@introv.com      Created
 * 2014-04-22   stella.sing@introv.com      Updated with copy to area function
 * 2014-06-21   michael.yip@introv.com      Copy to area by image/segment, fiscal year, national strategy
 * 2014-06-22   michael.yip@introv.com      Only user with permission set "ASI CRM CN HQ TMKT User" can create national strategy
 *
 */


public with sharing class ASI_CRM_CN_ChannelStratgy_Controller {
    public string PageId {get;set;}
    public boolean Show {get;set;}
    public boolean showNational {get;set;}
    public List<ASI_CRM_CN_Channel_Strategy__c> objCS1 {get; set;}
    public List<ASI_CRM_CN_Channel_Strategy__c> objCSArea {get; set;}
    public ASI_CRM_CN_Channel_Strategy__c objCS {get; set;}
    public List <ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSAreaItem {get; set;}
    public List <ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem {get; set;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem1 {get; set;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem2 {get; set;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem3 {get; set;}
    public List <ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem0 {get; set;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem1a {get; set;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem2b {get; set;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem3c {get; set;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objCSItem_Del {get; set;}
    public List<ASI_CRM_CN_Area__c> objAllArea {set;get;}
    public Map <string, string> AreaMap {set;get;}
    public set <id> AreaStrategyId {set;get;}
    public id RTName {set;get;}
    public string rowid {set;get;}
    public string rowindex {set;get;}
    public integer removepos{get;set;}
    public decimal index = 0;
     //Identify User locale
    public string UserId {set;get;}
    public boolean showCN {set;get;}
    
    public boolean allowEdit {set;get;}

    //----- edited by leo @20140714 (start) ------
    public boolean showEditBtn {set;get;}
    public boolean isAreaStrategy {set;get;}
    public boolean isHQUser {set;get;}
    public boolean isExistingRecord {set;get;}
    //----- edited by leo @20140714 (end) ------
     
    public ASI_CRM_CN_ChannelStratgy_Controller(ApexPages.StandardController controller) {

        //----- edited by leo @20140714 (start) ------
        showEditBtn = false;
        isAreaStrategy = false;
        isHQUser = false;
        isExistingRecord = false;

            // check is HQ User
        if([SELECT Assignee.Name, PermissionSet.name
            FROM PermissionSetAssignment where (permissionSet.name ='ASI_CRM_CN_HQ_TMKT_User' OR permissionSet.name ='ASI_CRM_CN_Master_Data_Admin' )and Assigneeid = :Userinfo.getUserid()].size()==0){
            
            isHQUser = false;
        }
        else
        {
            isHQUser = true;
            showEditBtn = true;
        }
        //----- edited by leo @20140714 (end) ------
        
        allowEdit = true;
        PageId = ApexPages.currentPage().getParameters().get('id');
        //choose User locale
        UserId = UserInfo.getUserId();
        chooseLocale();
        this.objCS = (ASI_CRM_CN_Channel_Strategy__c)controller.getRecord();
        system.debug('PageId: ' + PageId);
        ShowNational = false;
        objCSItem_Del = new List <ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        if (PageId != null)
        objCS1 = [SELECT OwnerId, RecordTypeId, RecordType.DeveloperName, ASI_CRM_CN_National__c, Name, ASI_CRM_CN_Area__c, ASI_CRM_CN_Sub_Channel__c, 
                  ASI_CRM_CN_Description__c, ASI_CRM_CN_Fiscal_Year__c, 
                  ASI_CRM_CN_Image__c, ASI_CRM_CN_Status__c, ASI_CRM_CN_CS_Strategy_1__c,
                  ASI_CRM_CN_MS_Strategy_1__c, ASI_CRM_CN_CS_Strategy_2__c, ASI_CRM_CN_MS_Strategy_2__c, ASI_CRM_CN_CS_Strategy_3__c,
                  ASI_CRM_CN_MS_Strategy_3__c, ASI_CRM_CN_CS_Strategy_4__c, ASI_CRM_CN_MS_Strategy_4__c, ASI_CRM_CN_CS_Strategy_5__c, 
                  ASI_CRM_CN_MS_Strategy_5__c, ASI_CRM_CN_Strategy_Type__c, ASI_CRM_CN_CS_National_Strategy_1__c, ASI_CRM_CN_CS_National_Strategy_2__c, 
                  ASI_CRM_CN_CS_National_Strategy_3__c, ASI_CRM_CN_CS_National_Strategy_4__c, ASI_CRM_CN_CS_National_Strategy_5__c, 
                  ASI_CRM_CN_MS_National_Strategy_1__c, ASI_CRM_CN_MS_National_Strategy_2__c, ASI_CRM_CN_MS_National_Strategy_3__c, 
                  ASI_CRM_CN_MS_National_Strategy_4__c, ASI_CRM_CN_MS_National_Strategy_5__c
                 FROM ASI_CRM_CN_Channel_Strategy__c
                 WHERE id = :PageId];
        if (PageId != null && objCS1.size()>0){
            this.objCS = objCS1[0];

            //----- edited by leo @20140714 (start) ------
            isExistingRecord = true;

            if(objCS1[0].RecordType.DeveloperName == 'ASI_CRM_CN_Area')
            {
                isAreaStrategy = true;
            }
            //----- edited by leo @20140714 (end) ------
        }else{
            // Added by Michael Yip (Introv) 22Jun2014 for limit creation of national strategy
            if(!isHQUser){
                allowEdit = false;
            }
            else{
                ASI_CRM_CN_Channel_Strategy__c a = new ASI_CRM_CN_Channel_Strategy__c();
                this.objCS = a;
            }
        }
        objCSItem = [SELECT id, Name, ASI_CRM_CN_National_Strategy_Sub_Brand__c, ASI_CRM_CN_National_Strategy__c, 
                    ASI_CRM_CN_Channel_Strategy__r.ASI_CRM_CN_Fiscal_Year__c, ASI_CRM_CN_Sub_brand__c, ASI_CRM_CN_Channel_Strategy__c, 
                    ASI_CRM_CN_Sub_brand__r.Name, ASI_CRM_CN_Brand__c 
                    FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c 
                    WHERE ASI_CRM_CN_Channel_Strategy__c = :Pageid
                    order by ASI_CRM_CN_Sub_brand__r.name];

        objCSItem0 = [SELECT id,Name, ASI_CRM_CN_National_Strategy_Sub_Brand__c, ASI_CRM_CN_National_Strategy__c, 
                    ASI_CRM_CN_Channel_Strategy__r.ASI_CRM_CN_Fiscal_Year__c ,ASI_CRM_CN_Sub_brand__r.Name, ASI_CRM_CN_Brand__c 
                    FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c 
                    WHERE ASI_CRM_CN_Channel_Strategy__c = :objCS.ASI_CRM_CN_National__c
                    order by ASI_CRM_CN_Sub_brand__r.name];
        /*
        objCSItem2 = [SELECT ASI_CRM_CN_Sub_brand__r.Name, ASI_CRM_CN_Brand__c FROM
                    ASI_CRM_CN_Channel_Strategy_Line_Item__c WHERE ASI_CRM_CN_Channel_Strategy__c = :Pageid AND
                    ASI_CRM_CN_Brand__c = 'Priority 2'];
        objCSItem3 = [SELECT ASI_CRM_CN_Sub_brand__r.Name, ASI_CRM_CN_Brand__c FROM
                    ASI_CRM_CN_Channel_Strategy_Line_Item__c WHERE ASI_CRM_CN_Channel_Strategy__c = :Pageid AND
                    ASI_CRM_CN_Brand__c = 'Priority 3' ];
        */
        //Global_RecordTypeCache grt = new Global_RecordTypeCache();
        //RTName = [SELECT id FROM RecordType WHERE SObjectType = 'ASI_CRM_CN_Channel_Strategy__c' AND DeveloperName = 'ASI_CRM_CN_Area'].id;
        RTName = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel_Strategy__cASI_CRM_CN_Area');
        system.debug('RecordType: ' + RTName );
        if (objCS.RecordTypeId == RTName)
            showNational = true;
  
        
        system.debug('Line Items: ' + objCSItem.size());  
        objCSItem1 = new List <ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        objCSItem2 = new List <ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        objCSItem3 = new List <ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        //i = 0;
        for (ASI_CRM_CN_Channel_Strategy_Line_Item__c a : objCSItem){
            ASI_CRM_CN_Channel_Strategy_Line_Item__c b = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
            system.debug('for loop');
            b = a;
            if (a.ASI_CRM_CN_Brand__c == 'Priority 1')
                objCSItem1.add(b);    
            if (a.ASI_CRM_CN_Brand__c == 'Priority 2')
                objCSItem2.add(b); 
            if (a.ASI_CRM_CN_Brand__c == 'Priority 3')
                objCSItem3.add(b);  
        }
        
        if (objCSItem0.size() > 0){
            system.debug('Line Items: ' + objCSItem0.size());     
            objCSItem1a = new List <ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            objCSItem2b = new List <ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            objCSItem3c = new List <ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c c : objCSItem0){
                ASI_CRM_CN_Channel_Strategy_Line_Item__c d = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                d = c;
                if (c.ASI_CRM_CN_Brand__c == 'Priority 1')
                    objCSItem1a.add(d);    
                if (c.ASI_CRM_CN_Brand__c == 'Priority 2')
                    objCSItem2b.add(d); 
                if (c.ASI_CRM_CN_Brand__c == 'Priority 3')
                    objCSItem3c.add(d);   
            }
        }  
        objAllArea = [SELECT Id FROM ASI_CRM_CN_Area__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Area'];

        //----- edited by leo @20140714 (start) ------
            //---- set 'showEditBtn' flag ----
        if(isExistingRecord)
        {
            if(isAreaStrategy)
            {
                showEditBtn = true;
            }
            else
            {
                if(isHQUser)
                {
                    showEditBtn = true;
                }
            }
        }
        //----- edited by leo @20140714 (end) ------
           
    }
    //Choose the right locale for User
    public void chooseLocale(){
        User thisUser = [SELECT Profile.Name, LanguageLocaleKey FROM User WHERE id = :UserId];
        if (thisUser.LanguageLocaleKey == 'zh_CN'){
            showCN = true;
        }
        if (thisUser.Profile.Name.contains('System Administrator')){
            isHQUser = true;
            showEditBtn = true;
        }
    }

    public void AddNew1(){
        AddNew(objCSItem1, 'Priority 1');        
    }
    public void AddNew2(){
        AddNew(objCSItem2, 'Priority 2');
    }
    public void AddNew3(){
        AddNew(objCSItem3, 'Priority 3');
    }
    public void Remove1(){
        removeRow(objCSItem1);
    }
    public void Remove2(){
        removeRow(objCSItem2);
    }
    public void Remove3(){
        removeRow(objCSItem3);
    }
    
    public void AddNew(List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> strList, string strBand){
        ASI_CRM_CN_Channel_Strategy_Line_Item__c b = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
        b.ASI_CRM_CN_Brand__c = strBand;
        b.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy');
        b.Name = 'a' + (index + 1);
        index = (index + 1);
        strList.add(b);
    }
    
    
     public void removeRow(List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> strList){
        if(strList.size()>0 ){    
            for(Integer i=0;i<strList.size();i++){
                if(strList[i].Name == rowid){
                    objCSItem_Del.add(strList[i]);
                    removepos=i;
                }
            }
            strList.remove(removepos);
        }
    }
    
    public PageReference Save(){//action="/apex/ASI_CRM_CN_ChannelStratgy_EditPage?id={!objCS.id}"
        boolean errormsg = false;
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> UpdateChild = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        list<ASI_CRM_CN_Channel_Strategy_Line_Item__c> InsertChild = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        set<string> subbrandset = new set<string>();
            if (PageId != null){
                system.debug('User: '+ objCS.OwnerId + ' Owner: ' + objCS.OwnerId);
                if (objCS.RecordType.DeveloperName == 'ASI_CRM_CN_Area' && UserInfo.getUserId() != objCS.OwnerId){
                    objCS.ASI_CRM_CN_Status__c = 'Draft';
                }
                update objCS;
            }else if(objCS.id == null){  
                objCS.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy__cASI_CRM_CN_National');           
                insert objCS;
            }
            if (objCSItem1.size() > 0)    
            for ( ASI_CRM_CN_Channel_Strategy_Line_Item__c a : objCSItem1){
                if (a.id != null){
                    //update a;
                    if (subbrandset.contains(a.ASI_CRM_CN_Sub_brand__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicated Sub-brand!'));
                        errormsg = true;
                    }else{
                        subbrandset.add(a.ASI_CRM_CN_Sub_brand__c);
                        UpdateChild.add(a);
                    }
                }else{
                    a.ASI_CRM_CN_Channel_Strategy__c = objCS.id;
                    a.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy');
                    a.Name = '';
                    //insert a;
                    if (subbrandset.contains(a.ASI_CRM_CN_Sub_brand__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicated Sub-brand!'));
                        errormsg = true;
                    }else{
                        subbrandset.add(a.ASI_CRM_CN_Sub_brand__c);
                        InsertChild.add(a);
                    }
                }
            } 
            if (objCSItem2.size() > 0)    
            for ( ASI_CRM_CN_Channel_Strategy_Line_Item__c a : objCSItem2){
                if (a.id != null){
                    if (subbrandset.contains(a.ASI_CRM_CN_Sub_brand__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicated Sub-brand!'));
                        errormsg = true;
                    }else{
                        subbrandset.add(a.ASI_CRM_CN_Sub_brand__c);
                        UpdateChild.add(a);
                    }
                    //update a;
                }else{
                    a.ASI_CRM_CN_Channel_Strategy__c = objCS.id;
                    a.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy');
                    a.Name = '';
                    if (subbrandset.contains(a.ASI_CRM_CN_Sub_brand__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicated Sub-brand!'));
                        errormsg = true;
                    }else{
                        subbrandset.add(a.ASI_CRM_CN_Sub_brand__c);
                        InsertChild.add(a);
                    }
                    //insert a;
                }
            }
            if (objCSItem3.size() > 0)    
            for ( ASI_CRM_CN_Channel_Strategy_Line_Item__c a : objCSItem3){
                if (a.id != null){
                    if (subbrandset.contains(a.ASI_CRM_CN_Sub_brand__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicated Sub-brand!'));
                        errormsg = true;
                    }else{
                        subbrandset.add(a.ASI_CRM_CN_Sub_brand__c);
                        UpdateChild.add(a);
                    }
                    //update a;
                }else{
                    a.ASI_CRM_CN_Channel_Strategy__c = objCS.id;
                    a.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy');
                    a.Name = '';
                    if (subbrandset.contains(a.ASI_CRM_CN_Sub_brand__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicated Sub-brand!'));
                        errormsg = true;
                    }else{
                        subbrandset.add(a.ASI_CRM_CN_Sub_brand__c);
                        InsertChild.add(a);
                    }
                    //insert a;
                }
            }  
            
            if (objCSItem_Del.size() > 0){
                for (ASI_CRM_CN_Channel_Strategy_Line_Item__c  a : objCSItem_Del){
                   if (a.id != null){
                    delete a; 
                    }
                }
                objCSItem_Del.clear();
            }
            
            if (errormsg == true){
                return null;
            }else{
                insert InsertChild;
                update UpdateChild;
            
                string url = '/apex/ASI_CRM_CN_ChannelStratgy_Page?id=' + objCS.id;
                PageReference returnPage = new PageReference(url);
                returnPage.setRedirect(true);
                return returnPage;
        
            }
    }
    
    /*lokman 30/6/2014 editpage start*/
    public PageReference Editpage(){
        
                string url = '/apex/ASI_CRM_CN_ChannelStratgy_EditPage?id=' + objCS.id;
                PageReference returnPage = new PageReference(url);
                returnPage.setRedirect(true);
                return returnPage;
        
            
    }
    /*lokman 30/6/2014 editpage end*/
    public void getAreaStrategy(){
        objCSArea = [SELECT id, ASI_CRM_CN_Area__c FROM ASI_CRM_CN_Channel_Strategy__c 
            WHERE RecordType.DeveloperName = 'ASI_CRM_CN_Area' AND ASI_CRM_CN_Fiscal_Year__c = :objCS.ASI_CRM_CN_Fiscal_Year__c
            AND ASI_CRM_CN_Image__c = :objCS.ASI_CRM_CN_Image__c
            AND ASI_CRM_CN_Sub_Channel__c = :objCS.ASI_CRM_CN_Sub_Channel__c];
        AreaMap = new Map <string, string>();
        AreaStrategyId = new set<id>();
        for (ASI_CRM_CN_Channel_Strategy__c c : objCSArea ){
               AreaMap.put(c.ASI_CRM_CN_Area__c , c.id); 
               AreaStrategyId.add(c.id);    
        }
        system.debug('AreaMap: ' + AreaMap);
        system.debug('AreaStrategyId: ' + AreaStrategyId);
    }
    public PageReference Copy(){
        getAreaStrategy();
        
        List<ASI_CRM_CN_Channel_Strategy__c> MasterList = new List <ASI_CRM_CN_Channel_Strategy__c>();
        List<ASI_CRM_CN_Channel_Strategy__c> MasterUpdate = new List <ASI_CRM_CN_Channel_Strategy__c>();
        set<id> masterId = new set <id>();
        set<id> masterupdateId = new set <id>();
        List <ASI_CRM_CN_Channel_Strategy_Line_Item__c> ChildList = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        List <ASI_CRM_CN_Channel_Strategy_Line_Item__c> ChildListUpdate = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        List <ASI_CRM_CN_Channel_Strategy_Line_Item__c> ChildList_del = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> objLiItemsAll = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        System.debug('pageId'+pageId);
        for (ASI_CRM_CN_Area__c a : objAllArea){
            ASI_CRM_CN_Channel_Strategy__c master = new ASI_CRM_CN_Channel_Strategy__c(); 
                       
            if (PageId != null){
                master = objCS.clone();
                master.ASI_CRM_CN_National__c = objCS.id;
                master.RecordTypeId = RTName;
                master.ASI_CRM_CN_Status__c = 'Final';
                master.ASI_CRM_CN_Strategy_Type__c = 'Area Strategy';
                master.ASI_CRM_CN_Area__c = a.id;
                
                system.debug('master'+master);
                if (AreaMap.containskey(a.id)){
                        system.debug('Channel Strategy Area record exist!');
                        master.id = AreaMap.get(a.id);
                        MasterUpdate.add(master);
                        masterId.add(master.id);
                        masterupdateId.add(master.id);
                        //update master;
                }else{
                    system.debug('Channel Strategy Area record NOT exist!');
                    MasterList.add(master);
                    //masterId.add(master.id);
                    //insert master;
                }
                //MasterList.add(master);
            }
        }
        system.debug('MasterUpdate'+MasterUpdate);
        system.debug('MasterList'+MasterList);
        
        //insert MasterList;
        //update MasterUpdate;
        if(MasterUpdate.size()>0){
        clearupUpdateListMaster(MasterUpdate, 'Update');
        }
        if(MasterList.size()>0){
        clearupUpdateListMaster(MasterList, 'Insert');
        }
        objCSAreaItem = [SELECT id, ASI_CRM_CN_Channel_Strategy__r.ASI_CRM_CN_Fiscal_Year__c, ASI_CRM_CN_Channel_Strategy__c 
        FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c
        where ASI_CRM_CN_Channel_Strategy__c IN :masterupdateId];
        
        for (id mdel : masterupdateId){
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c delc : objCSAreaItem){
                if (delc.ASI_CRM_CN_Channel_Strategy__c == mdel){
                    //ASI_CRM_CN_Channel_Strategy_Line_Item__c delchild = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                    //delchild.id = delc.id;
                    //system.debug('delchild.id: ' + delchild.id);
                    ChildList_del.add(delc);
                    //delete delchild;
                }
            }
        }
        //objLiItemsAll.add(objCSItem1);
        //objLiItemsAll.add(objCSItem2);
        //objLiItemsAll.add(objCSItem3);
        getAreaStrategy();
        for (id a : AreaStrategyId){
            /*
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c b : objLiItemsAll){
                ASI_CRM_CN_Channel_Strategy_Line_Item__c child = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                //if (b.id != null){
                    //child = b;
                    //ChildListUpdate.add(b);
                    //insert child;
                //}else{
                    child.ASI_CRM_CN_Channel_Strategy__c = a;
                    child.ASI_CRM_CN_Brand__c = b.ASI_CRM_CN_Brand__c;
                    child.ASI_CRM_CN_Sub_brand__c = b.ASI_CRM_CN_Sub_brand__c;
                    ChildList.add(child);
                //}
            }
            */
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c b : objCSItem1){
                ASI_CRM_CN_Channel_Strategy_Line_Item__c child = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                //if (b.id != null){
                    //child = b;
                    //ChildListUpdate.add(b);
                    //insert child;
                //}else{
                    child.ASI_CRM_CN_Channel_Strategy__c = a;
                    child.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy');
                    child.ASI_CRM_CN_Brand__c = b.ASI_CRM_CN_Brand__c;
                    child.ASI_CRM_CN_Sub_brand__c = b.ASI_CRM_CN_Sub_brand__c;
                    ChildList.add(child);
                //}
            }
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c b : objCSItem2){
                ASI_CRM_CN_Channel_Strategy_Line_Item__c child = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                //if (b.id != null){
                    //child.id = b.id;
                    //update child;
                    //ChildListUpdate.add(b);
                    
                    //insert child;
                //}else{
                    child.ASI_CRM_CN_Channel_Strategy__c = a;
                    child.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy');
                    child.ASI_CRM_CN_Brand__c = b.ASI_CRM_CN_Brand__c;
                    child.ASI_CRM_CN_Sub_brand__c = b.ASI_CRM_CN_Sub_brand__c;
                    ChildList.add(child);
                //}
            }
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c b : objCSItem3){
                ASI_CRM_CN_Channel_Strategy_Line_Item__c child = new ASI_CRM_CN_Channel_Strategy_Line_Item__c();
                //if (b.id != null){
                    
                    //insert child;
                    //ChildListUpdate.add(b);
                //}else{
                    child.ASI_CRM_CN_Channel_Strategy__c = a;
                    child.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_CN_Channel_Strategy_Line_Item__cASI_CRM_CN_Channel_Strategy');
                    child.ASI_CRM_CN_Brand__c = b.ASI_CRM_CN_Brand__c;
                    child.ASI_CRM_CN_Sub_brand__c = b.ASI_CRM_CN_Sub_brand__c;
                    ChildList.add(child);
               // }
            }
        }
        
        if (objCSItem_Del.size() > 0){
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c  de : objCSItem_Del){
               if (de.id != null){
                //delete de; 
                ChildList_del.add(de);
                }
            }
            objCSItem_Del.clear();
        }
        clearupUpdateList(ChildListUpdate, 'Update');
        clearupUpdateList(childList, 'Insert');
        clearupUpdateList(ChildList_del, 'Delete');
        
        string url = '/apex/ASI_CRM_CN_ChannelStratgy_Page?id=' + PageId;
        PageReference returnPage = new PageReference(url);
        returnPage.setRedirect(true);
        return returnPage;
    }
    public void clearupUpdateListMaster(List<ASI_CRM_CN_Channel_Strategy__c> strList, string strAction){
        
        Set<ASI_CRM_CN_Channel_Strategy__c> myset = new Set<ASI_CRM_CN_Channel_Strategy__c>();
        List<ASI_CRM_CN_Channel_Strategy__c> result = new List<ASI_CRM_CN_Channel_Strategy__c>();
        myset.addAll(strList);
        result.addAll(myset);
        system.debug('result'+result);
        if (strAction == 'Update'){
            update result;
        }else if (strAction == 'Insert'){
            insert result;
        }else if (strAction =='Delete'){
            delete result;
        }
    }
    public void clearupUpdateList(List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> strList, string strAction){
        
        Set<ASI_CRM_CN_Channel_Strategy_Line_Item__c> myset = new Set<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> result = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        myset.addAll(strList);
        result.addAll(myset);
        system.debug('result: ' + result);
        if (strAction == 'Update'){
            update result;
        }else if (strAction == 'Insert'){
            insert result;
        }else if (strAction =='Delete'){
            delete result;
        }
    }
    public PageReference Submit() {
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req1.setObjectId(PageId);
 
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
 
        // Verify the result
        System.assert(result.isSuccess());
 
        System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
        return null;
    }
    
    @RemoteAction
    /*lokman 30/6/2014 SIT issue start*/
        public static String[] findSObjects(string obj, string qry, string rec) {
       
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        
        List<String> results = new List<String>();
        String key='%'+String.escapeSingleQuotes(qry)+'%';

        List <ASI_MFM_Sub_brand__c> sub_brand = new List<ASI_MFM_Sub_brand__c>();
        map<string, id> map_recordtype =ASI_MFM_Function.getRecordTypeId('ASI_MFM_Sub_brand__c');


        try {
        sub_brand=[SELECT Name,ASI_MFM_Active_for_CRM__c,RecordTypeid FROM ASI_MFM_Sub_brand__c 
        WHERE ASI_MFM_Active_for_CRM__c=TRUE 
        AND RecordTypeid=:map_recordtype.get('ASI_FOC_CN_Sub_brand') 
        AND Name like :key 
        AND ASI_MFM_Brand__r.ASI_CRM_CN_Competitor__c = FALSE
        ORDER BY NAME];

            for(ASI_MFM_Sub_brand__c sb:sub_brand){
           results.add(sb.Name);  }
        }
        catch (QueryException e) {
            return null;
        }
        return results;
   }
   /*lokman 30/6/2014 SIT issue end*/
}