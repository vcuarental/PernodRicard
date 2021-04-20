public without sharing class ASI_MFM_CN_POSMCatalogSecCtrl_EditCON extends ASI_FOC_AbstractPageController implements ASI_MFM_POSM_SFObjSelectTableAbstract, ASI_MFM_CN_POSM_Security_MACUAbstract {
    
    public String baseWhereStatm { get; private set; }
    public String UserbaseWhereStatm { get; private set; }
    public String filterUserName { get; set; }
    public Id ItemGroupId { get; set; }
    public ASI_MFM_POSMCatalogSecCtrl__c POSMCatalog {get; set;}
	public ASI_MFM_Item_Group__c ItemGroup {get; set;}
    public ASI_MFM_Item_Group__c filterReqItemInput { get; set; }
    public String filterName { get; set; }
    private String defReqItemRTDevName;
    private List<ASI_MFM_Item_Group__c> origReqItemList;
    private ASI_MFM_POSM_Return_Request__c req;
    public String requestNumber {get;set;}
    
    Public List<User> SelectedUserList{get;set;}
    Public List<ASI_MFM_POSMCatalogSecCtrl__c> POSMCatalogList{get;set;}
    public boolean OpenInCatalog {get; set;}
    public boolean CanOrder {get; set;}
    
    public boolean AllOpenInCatalog {get; set;}
    public boolean AllCanOrder {get; set;}
    
    Public Integer size{get;set;}
    Public Integer noOfRecords{get; set;}
    public List<SelectOption> paginationSizeOptions{get;set;}
    public static final Integer QUERY_LIMIT = 10000;
    public static final Integer PAGE_SIZE = 5;
    
    public List <ASI_MFM_Item_Group__c> wrapperRecordList{get;set;}
    Map<Id, ASI_MFM_Item_Group__c> mapHoldingSelectedRecords{get;set;}
    
    public List<ASI_MFM_Item_Group__c> objList{get;set;}
    public List<ASI_MFM_Item_Group__c> selectedList{get;set;}

    public String objId {get;set;}
    public ASI_MFM_Item_Group__c ItemG{get;set;}
    
    Set<String> Level_1Set = new Set<String>();    
    Map<String, String> Lv1_picklist = new Map<String, String>();
    Public List<string> Lv1_leftselected{get;set;}
    Public List<string> Lv1_rightselected{get;set;}
    Set<string> Lv1_leftvalues = new Set<string>();
    Set<string> Lv1_rightvalues = new Set<string>();
    
    Set<String> Level_2Set = new Set<String>();    
    Map<String, String> Lv2_picklist = new Map<String, String>();
    Public List<string> Lv2_leftselected{get;set;}
    Public List<string> Lv2_rightselected{get;set;}
    Set<string> Lv2_leftvalues = new Set<string>();
    Set<string> Lv2_rightvalues = new Set<string>();
    
    Set<String> Level_3Set = new Set<String>();    
    Map<String, String> Lv3_picklist = new Map<String, String>();
    Public List<string> Lv3_leftselected{get;set;}
    Public List<string> Lv3_rightselected{get;set;}
    Set<string> Lv3_leftvalues = new Set<string>();
    Set<string> Lv3_rightvalues = new Set<string>();
        
    public Map<String, List<String>> Lv1ToLv2CategoryMap {get;set;}
    public Map<String, List<String>> Lv1ToLv3CategoryMap {get;set;}
    
	public Map<String, ASI_HK_CRM_Product_Category__c> CategoryMap {get;set;}
    public Map<String, List<ASI_TH_CRM_Sub_category__c>> Lv1ToSubCatMap {get;set;}
    public Id ASI_MFM_CN_Category_MasterId {get;set;}
    
    public boolean G_IsAdmin {get;set;}

    public ApexPages.StandardSetController stdSetCON {
        get {
            if(stdSetCON == null) {
                stdSetCON = new ApexPages.StandardSetController(Database.getQueryLocator([Select Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Main_Channel__c, ASI_MFM_CloneSecurityFrom__c from ASI_MFM_Item_Group__c]));
            }
            return stdSetCON;
        }
        set;
    }
            
    public ASI_MFM_CN_POSMCatalogSecCtrl_EditCON(){
/*
        this.baseWhereStatm = ' RecordType.DeveloperName IN (\'ASI_MFM_CN_New_POSM_Item_Group\',\'ASI_MFM_CN_New_POSM_Item_Group_Region\',\'ASI_MFM_CN_New_POSM_Item_Group_RO\',\'ASI_MFM_CN_New_POSM_Item_Group_RO_Region\',\'ASI_MFM_CN_POSM_Item_Group\') ';
        this.filterReqItemInput = new ASI_MFM_Item_Group__c();
        
        this.ASI_MFM_CN_Category_MasterId = Schema.SObjectType.ASI_HK_CRM_Product_Category__c.getRecordTypeInfosByName().get('CN Cetagory Master').getRecordTypeId();
        Lv1ToSubCatMap = new Map<String, List<ASI_TH_CRM_Sub_category__c>>();
        Lv1_leftselected = new List<String>();
        Lv1_rightselected = new List<String>();
        objList = new List<ASI_MFM_Item_Group__c>();
        selectedList = new List<ASI_MFM_Item_Group__c>();
        ItemGroup = new ASI_MFM_Item_Group__c();
        POSMCatalog = new ASI_MFM_POSMCatalogSecCtrl__c();
        SelectedUserList = new List<User>();
        POSMCatalogList = new List<ASI_MFM_POSMCatalogSecCtrl__c>();
        this.defReqItemRTDevName = ASI_MFM_CN_CatalogSecGenerator.RT_Default;
		CategoryMap = new Map<String, ASI_HK_CRM_Product_Category__c>();
        CategoryMap = this.retrieveAllCategories();
        for(String Lv1: CategoryMap.keySet())
        {
            system.Debug('lv1'+Lv1);
            system.Debug('ASI_HK_CRM_Product_Category__c'+CategoryMap.get(lv1));
        }
        for(String Lv1: Level_1Set)
        {
            Lv1_picklist.put(Lv1, Lv1);
        }       
        Lv1_leftvalues.addAll(Level_1Set);
        for(String Lv2: Level_2Set)
        {
            Lv2_picklist.put(Lv2, Lv2);
        }       
        Lv2_leftvalues.addAll(Level_2Set);
        for(String Lv3: Level_3Set)
        {
            Lv3_picklist.put(Lv3, Lv3);
        }       
        Lv3_leftvalues.addAll(Level_3Set);
*/
        initSysParam();
        G_IsAdmin = checkAdminSecurity();
    }
     
    public ASI_MFM_CN_POSMCatalogSecCtrl_EditCON(ApexPages.StandardSetController stdSetCON) {
        /*
        String reqId = ApexPages.currentPage().getParameters().get('id');
        ItemG = [Select Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Main_Channel__c, ASI_MFM_CloneSecurityFrom__c,
                          OwnerId, ASI_MFM_Utilization_Status__c, ASI_MFM_Status__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Sub_brand__c, 
                         ASI_MFM_Item_Group_Remark__c, ASI_MFM_Importation__c, ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Period_of_Validity__c,
                         ASI_MFM_Safety_Instruction__c, ASI_MFM_Usage__c, ASI_MFM_CN_FlowItem__c, ASI_MFM_CN_OneTimeItem__c, ASI_CRM_Group_RSP__c, ASI_MFM_Is_Return__c
                         From ASI_MFM_Item_Group__c
                         Where Id =: reqId
                         ];
        ItemGroup = ItemG;
        G_IsAdmin = checkAdminSecurity();
		*/
        initSysParam();
        
        String sReqId = ApexPages.currentPage().getParameters().get('id');
        initGlobalParam(sReqId);
        //ItemGroup = ItemG;
    }
    
    Public Map<String, ASI_HK_CRM_Product_Category__c> retrieveAllCategories(){
        Map<String, ASI_HK_CRM_Product_Category__c> tmpMap = new Map<String, ASI_HK_CRM_Product_Category__c>();

        for(ASI_HK_CRM_Product_Category__c category : [SELECT Id, Name, ASI_HK_CRM_English_Name__c
                                                       , ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Level__c
                                                       , (SELECT Id, ASI_CRM_CN_Product_Category__r.ASI_HK_CRM_English_Name__c, ASI_MFM_Category_Level_2_3__c, ASI_MFM_Category_Level__c 
                                                          , ASI_CRM_CN_Product_Category__r.ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Category_Level_2_3__r.Name FROM Sub_categories__r )
                                                       FROM ASI_HK_CRM_Product_Category__c 
                                                       WHERE recordTypeId =: ASI_MFM_CN_Category_MasterId
                                                       ORDER By ASI_MFM_Level__c])
        {
            If(category.ASI_MFM_Level__c == 'Level 1'){
                Level_1Set.add(category.Name);  
                Lv1ToSubCatMap.put(category.Name, category.Sub_categories__r);
            }
            If(category.ASI_MFM_Level__c == 'Level 2')
                Level_2Set.add(category.Name);  
            If(category.ASI_MFM_Level__c == 'Level 3')
                Level_3Set.add(category.Name);  
            tmpMap.put(category.Name, category);
        }
        
        Return tmpMap;
    }
    
/*
    public PageReference Lv1_selectclick(){
        Lv1_rightselected.clear();
        
        Lv2_leftvalues.clear();
        Lv3_leftvalues.clear();
        
        for(String s : Lv1_leftselected){
            Lv1_leftvalues.remove(s);
            Lv1_rightvalues.add(s);
        }
        
        Set<String> Lv2Tempvalues = new Set<String>();
        Set<String> Lv3Tempvalues = new Set<String>();
		Set<ASI_TH_CRM_Sub_category__c> TempSubCat = new Set<ASI_TH_CRM_Sub_category__c>();
            
        if(Lv1_rightvalues.size()>0)
        {
            for(String Lv1_selected : Lv1_rightvalues)
            {
                TempSubCat.addAll(Lv1ToSubCatMap.get(Lv1_selected));
            }

            for(ASI_TH_CRM_Sub_category__c SubCat : TempSubCat)
            {
                system.debug('SubCat : '+SubCat);
                if(SubCat.ASI_MFM_Category_Level__c == 'Level 2')
                {
                    Lv2Tempvalues.add(SubCat.ASI_MFM_Category_Level_2_3__r.Name);
                }
                else if(SubCat.ASI_MFM_Category_Level__c == 'Level 3')
                    Lv3Tempvalues.add(SubCat.ASI_MFM_Category_Level_2_3__r.Name);
                for(string s : Lv2Tempvalues)
                {
                    if(!Lv2_rightvalues.contains(s))
                        Lv2_leftvalues.add(s);
                }
                for(string s : Lv3Tempvalues)
                {
                    if(!Lv3_rightvalues.contains(s))
                        Lv3_leftvalues.add(s);
                }
                for(string s : Lv2_rightvalues)
                {
                    if(!Lv2Tempvalues.contains(s))
                        Lv2_rightvalues.remove(s);
                }
                
                for(string s : Lv3_rightvalues)
                {
                    if(!Lv3Tempvalues.contains(s))
                        Lv3_rightvalues.remove(s);
                }
            }
        }   
        else
        {
            for(String Lv2: Level_2Set)
            {
                Lv2_picklist.put(Lv2, Lv2);
            }       
            Lv2_leftvalues.addAll(Level_2Set);
            for(String Lv3: Level_3Set)
            {
                Lv3_picklist.put(Lv3, Lv3);
            }       
            Lv3_leftvalues.addAll(Level_3Set);
        }
                
        return null;
    }
     
    public PageReference Lv1_unselectclick(){
        Lv1_leftselected.clear();
        
        Lv2_leftvalues.clear();
        Lv3_leftvalues.clear();
        
        for(String s : Lv1_rightselected){
            Lv1_rightvalues.remove(s);
            Lv1_leftvalues.add(s);
        }
        
        Set<String> Lv2Tempvalues = new Set<String>();
        Set<String> Lv3Tempvalues = new Set<String>();
        Set<ASI_TH_CRM_Sub_category__c> TempSubCat = new Set<ASI_TH_CRM_Sub_category__c>();
        
        if(Lv1_rightvalues.size()>0)
        {
            for(String Lv1_selected : Lv1_rightvalues)
            {
                TempSubCat.addAll(Lv1ToSubCatMap.get(Lv1_selected));
            }

            for(ASI_TH_CRM_Sub_category__c SubCat : TempSubCat)
            {
                if(SubCat.ASI_MFM_Category_Level__c == 'Level 2')
                {
                    Lv2Tempvalues.add(SubCat.ASI_MFM_Category_Level_2_3__r.Name);
                }
                else if(SubCat.ASI_MFM_Category_Level__c == 'Level 3')
                    Lv3Tempvalues.add(SubCat.ASI_MFM_Category_Level_2_3__r.Name);
                for(string s : Lv2Tempvalues)
                {
                    if(!Lv2_rightvalues.contains(s))
                        Lv2_leftvalues.add(s);
                }
                for(string s : Lv3Tempvalues)
                {
                    if(!Lv3_rightvalues.contains(s))
                        Lv3_leftvalues.add(s);
                }
                
            }
            for(string s : Lv2_rightvalues)
            {
                if(!Lv2Tempvalues.contains(s))
                    Lv2_rightvalues.remove(s);
            }
            
            for(string s : Lv3_rightvalues)
            {
                if(!Lv3Tempvalues.contains(s))
                    Lv3_rightvalues.remove(s);
            }
        }   
        else
        {
            for(String Lv2: Level_2Set)
            {
                Lv2_picklist.put(Lv2, Lv2);
            }       
            Lv2_leftvalues.addAll(Level_2Set);
            for(String Lv3: Level_3Set)
            {
                Lv3_picklist.put(Lv3, Lv3);
            }       
            Lv3_leftvalues.addAll(Level_3Set);
        }
        
        return null;
    }
    
    public PageReference Lv2_selectclick(){
        Lv2_rightselected.clear();
        for(String s : Lv2_leftselected){
            Lv2_leftvalues.remove(s);
            Lv2_rightvalues.add(s);
        }
        return null;
    }
     
    public PageReference Lv2_unselectclick(){
        Lv2_leftselected.clear();
        for(String s : Lv2_rightselected){
            Lv2_rightvalues.remove(s);
            Lv2_leftvalues.add(s);
        }
        return null;
    }
 
    public PageReference Lv3_selectclick(){
        Lv3_rightselected.clear();
        for(String s : Lv3_leftselected){
            Lv3_leftvalues.remove(s);
            Lv3_rightvalues.add(s);
        }
        return null;
    }
     
    public PageReference Lv3_unselectclick(){
        Lv3_leftselected.clear();
        for(String s : Lv3_rightselected){
            Lv3_rightvalues.remove(s);
            Lv3_leftvalues.add(s);
        }
        return null;
    }
    
    public List<SelectOption> getLv1_unSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(Lv1_leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getLv1_SelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(Lv1_rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    public List<SelectOption> getLv2_unSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(Lv2_leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getLv2_SelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(Lv2_rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
    
    public List<SelectOption> getLv3_unSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(Lv3_leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getLv3_SelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(Lv3_rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
*/
    
    public void filterItemGroup() {
        String whereStatm = baseWhereStatm;
        
        string sFilterCat1 = this.filterReqItemInput.ASI_MFM_Category_Level_1_Piclklist__c;
        string sFilterCat2 = this.filterReqItemInput.ASI_MFM_Category_Level_2_Piclklist__c;
        string sFilterCat3 = this.filterReqItemInput.ASI_MFM_Category_Level_3_Piclklist__c;
        string sFilterBU = this.filterReqItemInput.ASI_MFM_Usage__c;
		ID idFilterSubBrand = this.filterReqItemInput.ASI_MFM_Sub_brand__c;
        string sFilterChannel = this.filterReqItemInput.ASI_MFM_Main_Channel__c;
        
        if (filterName != NULL && filterName.trim() != '') {
            whereStatm += ' AND Name LIKE \'%' + String.escapeSingleQuotes(filterName.trim()) + '%\'';
        }
        if (sFilterCat1 != NULL && sFilterCat1.trim() != '') {
            whereStatm += ' AND ASI_MFM_Category_Level_1_Piclklist__c = \'' + String.escapeSingleQuotes(sFilterCat1.trim()) + '\'';
        }
        if (sFilterCat2 != NULL && sFilterCat2.trim() != '') {
            whereStatm += ' AND ASI_MFM_Category_Level_2_Piclklist__c = \'' + String.escapeSingleQuotes(sFilterCat2.trim()) + '\'';
        }
        if (sFilterCat3 != NULL && sFilterCat3.trim() != '') {
            whereStatm += ' AND ASI_MFM_Category_Level_3_Piclklist__c = \'' + String.escapeSingleQuotes(sFilterCat3.trim()) + '\'';
        }
        if (sFilterBU != NULL && sFilterBU.trim() != '') {
            whereStatm += ' AND ASI_MFM_Usage__c = \'' + String.escapeSingleQuotes(sFilterBU.trim()) + '\'';
        }
        if (idFilterSubBrand != NULL) {
            whereStatm += ' AND ASI_MFM_Sub_brand__c = \'' + String.escapeSingleQuotes((String)idFilterSubBrand) + '\'';
        }
        if (sFilterChannel != NULL && sFilterChannel.trim() != '') {
            List<string> ltChannel = sFilterChannel.split(',');
            
            List<string> ltFilterChannel = new List<string>();
            if (ltChannel.size()>0) {
                for(string sTmpChannel : ltChannel) {
                	ltFilterChannel.add(String.escapeSingleQuotes(sTmpChannel.trim()));
                }
                string sTmpFilterChannel = string.join(ltFilterChannel, ';');
                sTmpFilterChannel = sTmpFilterChannel.replace(';', '\',\'');
                sTmpFilterChannel = ' AND ASI_MFM_Main_Channel__c INCLUDES (\'' + sTmpFilterChannel + '\')';
                whereStatm += sTmpFilterChannel;
                //whereStatm += (' AND ASI_MFM_Main_Channel__c INCLUDES (\'' + string.join(ltFilterChannel, '\',\'') +'\')');
            }
            //whereStatm += ' AND ASI_MFM_Main_Channel__c INCLUDES (\'传统通路 TOT(bulk purchase/VIP included)\',\'夜店 Night Club\')';
        }
/*
        if(Lv1_rightvalues.size()>0||Lv2_rightvalues.size()>0||Lv3_rightvalues.size()>0)
        {
        	if(Lv1_rightvalues.size()>0) 
            {
                if(whereStatm != '')
                    whereStatm = whereStatm + ' And';
                whereStatm = whereStatm + ' ASI_MFM_Category_Level_1_Piclklist__c =: Lv1_rightvalues';
                    //: Lv1_rightvalues';
            	if(Lv2_rightvalues.size()>0 || Lv3_rightvalues.size()>0)
                    whereStatm = whereStatm + ' And';
			}
            if(Lv2_rightvalues.size()>0) 
            {
                whereStatm = whereStatm + ' ASI_MFM_Category_Level_2_Piclklist__c =: Lv2_rightvalues';
            	if(Lv3_rightvalues.size()>0)
                    whereStatm = whereStatm + ' And';
			}
            if(Lv3_rightvalues.size()>0) 
            {
                whereStatm = whereStatm + ' ASI_MFM_Category_Level_3_Piclklist__c =: Lv3_rightvalues';
			}
        }
*/

        ASI_MFM_POSM_SFObjSelectTableController sobjstController = (ASI_MFM_POSM_SFObjSelectTableController)this.getComponentController('selectTable');
        if (sobjstController != null) {
            //sobjstController.setDataFilter(whereStatm, Lv1_rightvalues, Lv2_rightvalues, Lv3_rightvalues);
            sobjstController.setDataFilter(whereStatm);
            sobjstController.reloadData();
        }   
    }
    
    public PageReference Back() {
        PageReference newpage = new PageReference(System.currentPageReference().getURL());
        newpage.setRedirect(true);
        return newpage;
    }
    
    public List<ASI_MFM_CN_POSM_Security_MACUController.PageBlockActionBtn> mcau_initPageBlockActionButtonList() {
/*
        List<ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn> ltBtn = new List<ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn>();
        ltBtn.add(new ASI_FOC_MassCreateAndUpdateController.PageBlockActionBtn('btnBack','Back'));
        return ltBtn;
*/
        return null;
    }
    
    public PageReference mcau_triggerPageBlockAction(ASI_MFM_CN_POSM_Security_MACUController controller, String actionKey) {
/*
        if (actionKey == 'btnBack')
            return Back();
*/
        return null;
    }
    
    public List<ASI_MFM_POSM_SFObjSelectTableController.SFObjSelectTableActionBtn> sobjst_initActionButtonList() {
        return null;
    }
    
    public void mcau_triggerActionForSObject(ASI_MFM_CN_POSM_Security_MACUController controller, String actionKey, sObject sObj) {
        string sObjTypeName = sObj.getSObjectType().getDescribe().getName();
        system.debug('sObjTypeName:'+sObjTypeName);
        
        if (sObjTypeName == Schema.SObjectType.ASI_MFM_POSMCatalogSecCtrl__c.getName()) {
            ASI_MFM_POSMCatalogSecCtrl__c reqItem = (ASI_MFM_POSMCatalogSecCtrl__c)sObj;
            if (actionKey == ASI_MFM_CN_POSM_Security_MACUController.ACTION_ADD_NEW)
            {
                reqItem.ASI_MFM_ItemGroup__c = ItemGroup.Id;
                reqItem.ASI_MFM_MappingType__c = 'Item Group - User';
                reqItem.ASI_MFM_Open_to_all_user__c = false;
                reqItem.ASI_MFM_CanOrderinCatalog__c = 'No';
                    //mcauC.addNewRowByInfo('ASI_MFM_CN_POSM', newPOSMCatalog);
            }
        }
    }
    
    public Map<ID, Map<String, Integer>> sobjst_initActionButtonStageMap() {
        return null;
    }
    
    public void sobjst_triggerActionForSObject(ASI_MFM_POSM_SFObjSelectTableController controller, String actionKey, sObject sObj) {
        if (actionKey == ASI_MFM_POSM_SFObjSelectTableController.DEF_BTN_KEY_ADD) {
            String sobjtype = sObj.getSObjectType().getDescribe().getName();
			
            system.debug('clicked ADD button of ' + sobjtype);
            if(sobjtype == 'ASI_MFM_Item_Group__c')
            {
                ASI_MFM_Item_Group__c oTmpItemGroup = (ASI_MFM_Item_Group__c)sObj;
                
                ASI_MFM_Item_Group__c oTmpAssignItem = 
                    [SELECT Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Main_Channel__c, ASI_MFM_CloneSecurityFrom__c,
                                OwnerId, ASI_MFM_Utilization_Status__c, ASI_MFM_Status__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Sub_brand__c, 
                                ASI_MFM_Item_Group_Remark__c, ASI_MFM_Importation__c, ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Period_of_Validity__c,
                                ASI_MFM_Safety_Instruction__c, ASI_MFM_Usage__c, ASI_MFM_CN_FlowItem__c, ASI_MFM_CN_OneTimeItem__c, ASI_CRM_Group_RSP__c, ASI_MFM_Is_Return__c
                     FROM ASI_MFM_Item_Group__c
                     WHERE Id = :oTmpItemGroup.Id
            	];
            
                //ItemGroup = (ASI_MFM_Item_Group__c)sObj;
                /*
                system.debug('ItemGroup :' + ItemGroup);
                ItemG = [Select Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Main_Channel__c, ASI_MFM_CloneSecurityFrom__c,
                          OwnerId, ASI_MFM_Utilization_Status__c, ASI_MFM_Status__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Sub_brand__c, 
                         ASI_MFM_Item_Group_Remark__c, ASI_MFM_Importation__c, ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Period_of_Validity__c,
                         ASI_MFM_Safety_Instruction__c, ASI_MFM_Usage__c, ASI_MFM_CN_FlowItem__c, ASI_MFM_CN_OneTimeItem__c, ASI_CRM_Group_RSP__c, ASI_MFM_Is_Return__c
                         From ASI_MFM_Item_Group__c
                         Where Id =: ItemGroup.Id
                         ];
                G_IsAdmin = checkAdminSecurity();
				*/
                string sTmpItemGroupId = ''+oTmpItemGroup.Id;
                initGlobalParam(sTmpItemGroupId);
                
                /*
                ASI_MFM_POSM_SFObjSelectTableController selectTableC = (ASI_MFM_POSM_SFObjSelectTableController)this.getComponentController('selectTable');
                system.debug('selectedList :' + selectedList);

                for(ASI_MFM_Item_Group__c Item : selectedList)
                {
                    selectTableC.setBtnStageBySObjId(
                        Item.Id
                        , ASI_MFM_POSM_SFObjSelectTableController.DEF_BTN_KEY_ADD
                        , ASI_MFM_POSM_SFObjSelectTableController.DEF_BTN_ADD_STAGE_NOT_ADD
                    );
                }
                selectedList.clear();
                selectedList.add(ItemG);
                system.debug('selectedList : '+selectedList);
                */
                
                ASI_MFM_CN_POSM_Security_MACUController mcauC = (ASI_MFM_CN_POSM_Security_MACUController)this.getComponentController('massCreateAndUpdate');
                boolean bInit = mcauC.init(oTmpAssignItem.Id);
                
                ASI_MFM_CN_POSM_Security_MACUController mcauI = (ASI_MFM_CN_POSM_Security_MACUController)this.getComponentController('massCreateMultiItem');
                mcauI.addNewRowByInfo(mcauI.includeRecordTypesStr, oTmpAssignItem);

                /*
                List<ASI_MFM_POSM_SFObjSelectTableController.SFObjSelectTableElement> ltSearchItem = controller.tableEleList;
                for (ASI_MFM_POSM_SFObjSelectTableController.SFObjSelectTableElement oSearchItem : ltSearchItem) {
                    if (oSearchItem.sObj.id != ItemGroup.Id) {
                        controller.changeBtnStage(oSearchItem.sObj.id, ASI_MFM_POSM_SFObjSelectTableController.DEF_BTN_KEY_ADD, ASI_MFM_POSM_SFObjSelectTableController.DEF_BTN_ADD_STAGE_NOT_ADD);
                    }
                }
                */
                //ApexPages.currentPage().getParameters().put('id', ItemGroup.Id);
                //ASI_FOC_MassCreateAndUpdateController mcauC = (ASI_FOC_MassCreateAndUpdateController)this.getComponentController('massCreateAndUpdate');
                //boolean bInit = mcauC.init();
                //mcauC.clearAll();
                /*
                ASI_MFM_POSMCatalogSecCtrl__c reqItem = new ASI_MFM_POSMCatalogSecCtrl__c(
                    ASI_MFM_ItemGroup__c = ItemGroup.Id
                    , ASI_MFM_MappingType__c = 'Item Group - User'
                );
                mcauC.addNewRowByInfo('ASI_MFM_CN_POSM', reqItem);
				*/
                /*
                List<ASI_MFM_POSMCatalogSecCtrl__c> ltSec = [
                    SELECT Id, ASI_MFM_User__c, ASI_MFM_CanOrderinCatalog__c, ASI_MFM_Open_to_all_user__c
                    FROM ASI_MFM_POSMCatalogSecCtrl__c
                    WHERE ASI_MFM_ItemGroup__c = :ItemGroup.Id and ASI_MFM_MappingType__c = 'Item Group - User'
                    	AND RecordType.DeveloperName = :mcauC.includeRecordTypesStr
                ];
                
                if (ltSec.size() > 0) {
                    for (ASI_MFM_POSMCatalogSecCtrl__c oItem : ltSec) {
                    	mcauC.addNewRowByInfo(mcauC.includeRecordTypesStr, oItem);
                    }
                }
				*/
            }            
        }
    }
    
    public void selectAllMC() {
        ASI_MFM_POSM_SFObjSelectTableController selectTableC = (ASI_MFM_POSM_SFObjSelectTableController)this.getComponentController('selectTable');
        ASI_MFM_CN_POSM_Security_MACUController mcauMultiItem = (ASI_MFM_CN_POSM_Security_MACUController)this.getComponentController('massCreateMultiItem');
        
        List<ASI_MFM_POSM_SFObjSelectTableController.SFObjSelectTableElement> ltSearchItem = selectTableC.tableEleList;
        Set<Id> ltIdSelectItemGroup = new Set<Id>();
        for (ASI_MFM_POSM_SFObjSelectTableController.SFObjSelectTableElement oSearchItem : ltSearchItem) {
            ltIdSelectItemGroup.add(oSearchItem.sObj.id);
        }
        
        if (ltIdSelectItemGroup.size()>0) {
            List<ASI_MFM_Item_Group__c> ltTmpSelectItemGroup = 
                [SELECT Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Main_Channel__c, ASI_MFM_CloneSecurityFrom__c,
                     OwnerId, ASI_MFM_Utilization_Status__c, ASI_MFM_Status__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Sub_brand__c, 
                     ASI_MFM_Item_Group_Remark__c, ASI_MFM_Importation__c, ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Period_of_Validity__c,
                     ASI_MFM_Safety_Instruction__c, ASI_MFM_Usage__c, ASI_MFM_CN_FlowItem__c, ASI_MFM_CN_OneTimeItem__c, ASI_CRM_Group_RSP__c, ASI_MFM_Is_Return__c
                 FROM ASI_MFM_Item_Group__c
                 WHERE Id IN :ltIdSelectItemGroup
                 ORDER BY Name
                ];
            
            if (ltTmpSelectItemGroup.size()>0) {
                for(ASI_MFM_Item_Group__c oTmpAssignItem : ltTmpSelectItemGroup) {
                    mcauMultiItem.addNewRowByInfo(mcauMultiItem.includeRecordTypesStr, oTmpAssignItem);
                }
            }
        }
    }
    
    public void refreshPageMC() {
        ASI_MFM_CN_POSM_Security_MACUController mcauMultiItem = (ASI_MFM_CN_POSM_Security_MACUController)this.getComponentController('massCreateMultiItem');
        ASI_MFM_CN_POSM_Security_MACUController mcauMultiSec = (ASI_MFM_CN_POSM_Security_MACUController)this.getComponentController('massCreateMultiSec');

        system.debug('mcauMultiSec-before:' + mcauMultiSec.PARAM_OPEN_TO_ALL);
        List<ASI_MFM_CN_POSM_Security_MACUController.TableRow> ltItemRecord = mcauMultiItem.theRecordTypeElementList[0].myDisplayRecordList;
        List<ASI_MFM_CN_POSM_Security_MACUController.TableRow> ltSecRecord = mcauMultiSec.theRecordTypeElementList[0].myDisplayRecordList;

        system.debug('mcauMultiSec-ltItemRecord:' + ltItemRecord.size());
        system.debug('mcauMultiSec-ltSecRecord:' + ltSecRecord.size());

        boolean bInitItem = mcauMultiItem.init();
        boolean bInitSec = mcauMultiSec.init();

        system.debug('mcauMultiSec-after:' + mcauMultiSec.PARAM_OPEN_TO_ALL);
    }
    
    public PageReference commitAllMC() {
        ASI_MFM_CN_POSM_Security_MACUController mcauMultiItem = (ASI_MFM_CN_POSM_Security_MACUController)this.getComponentController('massCreateMultiItem');
        ASI_MFM_CN_POSM_Security_MACUController mcauMultiSec = (ASI_MFM_CN_POSM_Security_MACUController)this.getComponentController('massCreateMultiSec');
        
        List<ASI_MFM_CN_POSM_Security_MACUController.TableRow> ltItemRecord = mcauMultiItem.theRecordTypeElementList[0].myDisplayRecordList;
        List<ASI_MFM_CN_POSM_Security_MACUController.TableRow> ltSecRecord = mcauMultiSec.theRecordTypeElementList[0].myDisplayRecordList;
        
        boolean bOpenToAll = mcauMultiSec.PARAM_OPEN_TO_ALL;
        string sRTID = Global_RecordTypeCache.getRtId('ASI_MFM_POSMCatalogSecCtrl__cASI_MFM_CN_POSM');
        
        List<ASI_MFM_POSMCatalogSecCtrl__c> ltInsertSec = new List<ASI_MFM_POSMCatalogSecCtrl__c>();
        for(ASI_MFM_CN_POSM_Security_MACUController.TableRow oItemRow : ltItemRecord) {
            ASI_MFM_Item_Group__c oTmpItemRecord = (ASI_MFM_Item_Group__c)oItemRow.mySObj;

            for(ASI_MFM_CN_POSM_Security_MACUController.TableRow oSecRow : ltSecRecord) {
                ASI_MFM_POSMCatalogSecCtrl__c oTmpSecRecord = (ASI_MFM_POSMCatalogSecCtrl__c)oSecRow.mySObj;

                ltInsertSec.add(new ASI_MFM_POSMCatalogSecCtrl__c(
                    RecordTypeId = sRTID
                    , ASI_MFM_ItemGroup__c = oTmpItemRecord.Id
                    , ASI_MFM_MappingType__c = 'Item Group - User'
                    , ASI_MFM_Open_to_all_user__c = FALSE
                    , ASI_MFM_User__c = oTmpSecRecord.ASI_MFM_User__c
                    , ASI_MFM_CanOrderinCatalog__c = oTmpSecRecord.ASI_MFM_CanOrderinCatalog__c
                ));
            }
            
            if (bOpenToAll) {
                ltInsertSec.add(new ASI_MFM_POSMCatalogSecCtrl__c(
                    RecordTypeId = sRTID
                    , ASI_MFM_ItemGroup__c = oTmpItemRecord.Id
                    , ASI_MFM_MappingType__c = 'Item Group - User'
                    , ASI_MFM_Open_to_all_user__c = TRUE
                    , ASI_MFM_CanOrderinCatalog__c = 'Yes'
                ));
            }
        }
        
        if (ltInsertSec.size()>0) {
            insert ltInsertSec;
        }        
        
        refreshPageMC();
        return null;
    }
    
    private void initSysParam() {
        this.baseWhereStatm = ' RecordType.DeveloperName IN (\'ASI_MFM_CN_New_POSM_Item_Group\',\'ASI_MFM_CN_New_POSM_Item_Group_Region\',\'ASI_MFM_CN_New_POSM_Item_Group_RO\',\'ASI_MFM_CN_New_POSM_Item_Group_RO_Region\',\'ASI_MFM_CN_POSM_Item_Group\') ';
        
        string strRTId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        this.filterReqItemInput = new ASI_MFM_Item_Group__c(RecordTypeId=strRTId);
        
        this.ASI_MFM_CN_Category_MasterId = Schema.SObjectType.ASI_HK_CRM_Product_Category__c.getRecordTypeInfosByName().get('CN Cetagory Master').getRecordTypeId();
        Lv1ToSubCatMap = new Map<String, List<ASI_TH_CRM_Sub_category__c>>();
        Lv1_leftselected = new List<String>();
        Lv1_rightselected = new List<String>();
        objList = new List<ASI_MFM_Item_Group__c>();
        selectedList = new List<ASI_MFM_Item_Group__c>();
        ItemGroup = new ASI_MFM_Item_Group__c();
        POSMCatalog = new ASI_MFM_POSMCatalogSecCtrl__c();
        SelectedUserList = new List<User>();
        POSMCatalogList = new List<ASI_MFM_POSMCatalogSecCtrl__c>();
        this.defReqItemRTDevName = ASI_MFM_CN_CatalogSecGenerator.RT_Default;
		CategoryMap = new Map<String, ASI_HK_CRM_Product_Category__c>();
        CategoryMap = this.retrieveAllCategories();
        for(String Lv1: CategoryMap.keySet())
        {
            system.Debug('lv1'+Lv1);
            system.Debug('ASI_HK_CRM_Product_Category__c'+CategoryMap.get(lv1));
        }
        for(String Lv1: Level_1Set)
        {
            Lv1_picklist.put(Lv1, Lv1);
        }       
        Lv1_leftvalues.addAll(Level_1Set);
        for(String Lv2: Level_2Set)
        {
            Lv2_picklist.put(Lv2, Lv2);
        }       
        Lv2_leftvalues.addAll(Level_2Set);
        for(String Lv3: Level_3Set)
        {
            Lv3_picklist.put(Lv3, Lv3);
        }       
        Lv3_leftvalues.addAll(Level_3Set);
    }
    
    private void initGlobalParam(string sId) {
        ItemG = [SELECT Id, Name, ASI_CRM_CN_Eng_Name__c, ASI_CRM_CN_Chinese_Name__c, ASI_MFM_Main_Channel__c, ASI_MFM_CloneSecurityFrom__c,
                          	OwnerId, ASI_MFM_Utilization_Status__c, ASI_MFM_Status__c, ASI_MFM_Item_Group_Code__c, ASI_MFM_Sub_brand__c, 
                         	ASI_MFM_Item_Group_Remark__c, ASI_MFM_Importation__c, ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Period_of_Validity__c,
                         	ASI_MFM_Safety_Instruction__c, ASI_MFM_Usage__c, ASI_MFM_CN_FlowItem__c, ASI_MFM_CN_OneTimeItem__c, ASI_CRM_Group_RSP__c, ASI_MFM_Is_Return__c
                 FROM ASI_MFM_Item_Group__c
                 WHERE Id = :sId
        ];
        ItemGroup = ItemG;
        G_IsAdmin = checkAdminSecurity();
    }
    
    private boolean checkAdminSecurity() {
        boolean bIsAdmin = false;
        
        List<GroupMember> ltMember = [SELECT Group.Name, GroupId, UserorGroupId 
                                      FROM GroupMember 
                                      WHERE Group.name = 'ASI MFM CN POSM ItemGroup Security Admin'
                                      	AND UserorGroupId = :UserInfo.getUserId()
                                      LIMIT 1];
        if (ltMember.size() > 0)
            bIsAdmin = true;
        
        return bIsAdmin;
    }
    
}