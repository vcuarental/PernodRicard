/*Filename:    ASI_CRM_TW_PromotionSetup_Ctrl.cls
* Author:      Twinkle LI (Introv Limited)
* Purpose:     Controller Class for promotion setup (add/edit/delete Promotion Unit,Promotion POSM,Promotion Target) for TW CRM
*
* History
* -----------------------------------------------------------------------------
*/
public without sharing class ASI_CRM_TW_PromotionSetup_Ctrl{
    public id promoId {set;get;}
    public ASI_HK_CRM_Promotion__c promo {set;get;}
    
    public List<ASI_CRM_Promotion_Unit__c> listPromoUnit {set;get;}
    public List<ASI_CRM_Promotion_Unit__c> listDeletedPromoUnit {set;get;}
    public integer PUselectindex {get; set;}
    public Map<integer, promoUnitobj> mapPromoUnit {set;get;}
    
    public List<ASI_CRM_Promotion_POSM__c> listPromoPOSM {set;get;}
    public List<ASI_CRM_Promotion_POSM__c> listDeletedPromoPOSM {set;get;}
    public Map<integer, promoPOSM> mapPromoPOSM {set;get;}
    
    public List<ASI_CRM_Promotion_POSM__c> listNewPromoPOSM {set;get;}
    public Map<integer, promoPOSM> mapNewPromoPOSM {set;get;}
    
    public List<ASI_CRM_Promotion_Target__c> listPromoTarget {set;get;}
    public List<ASI_CRM_Promotion_Target__c> listDeletedPromoTarget {set;get;}
    public Map<integer, ASI_CRM_Promotion_Target__c> mapPromoTarget {set;get;}
    
    public Integer intRowid {set;get;}
    public Integer intIndexPromoUnit {set;get;}
    public Integer intIndexPromoPOSM {set;get;}
    public Integer intIndexNewPromoPOSM {set;get;}
    public Integer intIndexPromoTarget {set;get;}    
    
    public String searchSKU {set;get;}
    public Set<Id> setSKUId {set;get;}
    public List<ASI_MFM_SKU_Code__c> listSKU {set;get;}
    public Map<String, ASI_MFM_SKU_Code__c> mapSKU {set;get;}
    public List<ContentDocumentLink> listSKUImage {set;get;}
    public Map<String, ContentDocumentLink> mapSKUImage {set;get;}    
    public List<SelectOption> listSuBbrandsPicklist {set; get;}
    public String userLanguage {set; get;}
    public ASI_CRM_TW_Settings__c customSettingAccId {set; get;}
    public Set<String> setStrRegion {set; get;}
    
    //Renderring based on Permission Sets
    public Boolean readOnly {set; get;}

    public Class promoUnitobj{
        public ASI_CRM_Promotion_Unit__c PU {set; get;}
        public list<SelectOption> Itemgroups {set; get;}
    }
    
    public Class promoPOSM{
        public ASI_CRM_Promotion_POSM__c posm {set; get;}
        public String skuName {set; get;}
        public String skuImageURL {set; get;}
        public String skuCode {set; get;}
        public String packing {set; get;}
        public String subbrand {set; get;}
        public String region {set; get;}
        public String category {set; get;}
        public String stock {set; get;}
        public String department {set; get;}
    }
    
    public ASI_CRM_TW_PromotionSetup_Ctrl(ApexPages.StandardController controller) {
        promoId = ApexPages.currentPage().getParameters().get('id');
        init();     
    }
    
    public void init(){

        userLanguage = UserInfo.getLanguage();
        
        intIndexPromoUnit = 0;
        intIndexPromoPOSM = 0;
        intIndexPromoTarget = 0;
        
        this.promo = new ASI_HK_CRM_Promotion__c();
        
        listDeletedPromoUnit = new List<ASI_CRM_Promotion_Unit__c>();
        listDeletedPromoPOSM = new List<ASI_CRM_Promotion_POSM__c>();
        listDeletedPromoTarget = new List<ASI_CRM_Promotion_Target__c>();
        Map<string, list<ASI_MFM_Item_Group__c>> Subbrand_ItemGroup_map = new Map<string, list<ASI_MFM_Item_Group__c>>();
        set<string> SubbrandId_set = new set<string>();
        mapPromoUnit = new Map<integer, promoUnitobj>();

        mapPromoPOSM = new Map<integer, promoPOSM>();
        mapPromoTarget = new Map<integer, ASI_CRM_Promotion_Target__c>();
        
        setSKUId = new Set<Id>();
        listSKUImage = new List<ContentDocumentLink>();
        mapSKUImage = new Map<String, ContentDocumentLink>();  
        Set<String> setExistSkuCode = new Set<String>();
        
        //Check Current User Permission Sets
        List<PermissionSetAssignment> lstcurrentUserPerSet = new List<PermissionSetAssignment>();
        if(Userinfo.getUserId() != NULL)
            lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];
        
        for (PermissionSetAssignment psa: lstcurrentUserPerSet){
            system.debug('##lstcurrentUserPerSet' + psa.PermissionSet.Name);
            if(psa.PermissionSet.Name.equals('ASI_CRM_TW_TMKT_Users') || 
               psa.PermissionSet.Name.equals('ASI_CRM_TW_TMKT_Sales_Assist') ||
               psa.PermissionSet.Name.equals('ASI_CRM_TW_System_Admin') ||
               psa.PermissionSet.Name.equals('ASI_CRM_TW_Power_User')){
                readOnly = false;
                break;
            }
            else
                readOnly = true;
        }
        
        //Get Sub-Brand picklist values
        listSuBbrandsPicklist = new List<SelectOption>();      
        List<ASI_MFM_Sub_brand__c> listSubBrands = [SELECT Id, Name FROM ASI_MFM_Sub_brand__c WHERE RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand') AND ASI_CRM_TW_Company__c = 'PRT' ORDER BY Name]; //AND ASI_MFM_Active_for_MFM__c = TRUE 
        for(ASI_MFM_Sub_brand__c subBrand: listSubBrands){
           listSuBbrandsPicklist.add(new SelectOption(subBrand.Id, subBrand.Name));
        }
        
        if(promoId != NULL){
            this.promo = [SELECT id, Name, ASI_HK_CRM_Promotion_Name__c, ASI_CRM_Region__c FROM ASI_HK_CRM_Promotion__c WHERE id =: promoId];        
            if(this.promo != NULL){
                listPromoUnit = [SELECT id, ASI_CRM_Promotion__c, ASI_CRM_Sub_brand__c, ASI_CRM_Qty__c, ASI_CRM_Item_Group__c FROM ASI_CRM_Promotion_Unit__c
                                 WHERE ASI_CRM_Promotion__c =: promoId AND RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Unit__cASI_CRM_TW_PromotionUnit')];
                listPromoPOSM = [SELECT id, ASI_CRM_Promotion__c, ASI_CRM_SKU__c, ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c, ASI_CRM_Qty__c FROM ASI_CRM_Promotion_POSM__c
                                 WHERE ASI_CRM_Promotion__c =: promoId AND RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_POSM__cASI_CRM_TW_PromotionPOSM')];
                listPromoTarget = [SELECT id, ASI_CRM_Promotion__c, ASI_CRM_Target_Unit__c, ASI_CRM_Region__c, ASI_CRM_Confirmed__c FROM ASI_CRM_Promotion_Target__c
                                   WHERE ASI_CRM_Promotion__c =: promoId AND RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Target__cASI_CRM_TW_PromotionTarget')];
            }
        }
        //Added by Introv - Twinkle LI @20161012, get Promotion region
        if(this.promo.ASI_CRM_Region__c != NULL){
            String[] tmpStrRegion = this.promo.ASI_CRM_Region__c.split(';');
            setStrRegion = new Set<String>();
            integer index = 0;
            for(String s : tmpStrRegion){
                s = s.replace('[', '').replace(']', '');
                setStrRegion.add(s);
                index++;
            }
        }
            
        for(ASI_CRM_Promotion_Unit__c unit : listPromoUnit){
            promoUnitobj PUobj = new promoUnitobj();
            PUobj.PU = unit;
            mapPromoUnit.put(intIndexPromoUnit++, PUobj);

            SubbrandId_set.add(unit.ASI_CRM_Sub_brand__c);
        }

        for(ASI_MFM_Sub_brand__c SB : [select id, (select id, name, ASI_MFM_Item_Group_Code__c from Item_Groups__r) from ASI_MFM_Sub_brand__c where id in: SubbrandId_set])
        {
            Subbrand_ItemGroup_map.put(SB.id, SB.Item_Groups__r);
        }

        for(integer i : mapPromoUnit.keySet())
        {
            string SBid = mapPromoUnit.get(i).PU.ASI_CRM_Sub_brand__c;
            list<SelectOption> SO = new list<SelectOption>();
            SO.add(new SelectOption('', '-- Blank ---'));
            if(Subbrand_ItemGroup_map.containskey(SBid))
            {
                for(ASI_MFM_Item_Group__c IG : Subbrand_ItemGroup_map.get(SBid))
                {
                    SO.add(new SelectOption(IG.id, Ig.Name));
                }
            }
            mapPromoUnit.get(i).Itemgroups = SO;
        }
        
        for(ASI_CRM_Promotion_POSM__c posm : listPromoPOSM){
            if(posm.ASI_CRM_SKU__c != NULL)
                setExistSkuCode.add(posm.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c);
        }
        
        //Get Dummy account contains SKU Image
        //ASI_MFM_SKU_Code__c sku = [SELECT Id FROM ASI_MFM_SKU_Code__c WHERE Name = 'SKU Images' AND RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code')];
        customSettingAccId = [SELECT ASI_CRM_TW_POSM_Image_Account_Id__c FROM ASI_CRM_TW_Settings__c];  
        if(!Test.isRunningTest() && customSettingAccId != NULL && setExistSkuCode.size() > 0)
            listSKUImage = [SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: customSettingAccId.ASI_CRM_TW_POSM_Image_Account_Id__c AND ContentDocument.Title IN:setExistSkuCode];
        for(ContentDocumentLink image : listSKUImage){
            //String[] strArray = image.Name.split('\\.');
            mapSKUImage.put(image.ContentDocument.Title, image);
        }
            
        for(ASI_CRM_Promotion_POSM__c posm : listPromoPOSM){
            promoPOSM classPOSM = new promoPOSM();
            classPOSM.posm = posm;
            if(posm.ASI_CRM_SKU__c != NULL){
                classPOSM.skuCode = posm.ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c;
                classPOSM.skuName = posm.ASI_CRM_SKU__r.Name;
            }
            //set image url for each sku
            String imageURL;
            if(classPOSM.skuCode != NULL && mapSKUImage.get(classPOSM.skuCode) != NULL){
                //imageURL = '/servlet/servlet.FileDownload?file='+mapSKUImage.get(classPOSM.skuCode+'.jpg').id;
                imageURL = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+mapSKUImage.get(classPOSM.skuCode).ContentDocument.LatestPublishedVersionId;
            }else{
                imageURL = NULL;
            }
            classPOSM.skuImageURL = imageURL;
            
            mapPromoPOSM.put(intIndexPromoPOSM++, classPOSM);
            setSKUId.add(posm.ASI_CRM_SKU__c);
        } 
        
        for(ASI_CRM_Promotion_Target__c target : listPromoTarget){
            mapPromoTarget.put(intIndexPromoTarget++, target);
        }
    }

    public void queryItemGroup()
    {
        promoUnitobj PUobj = mapPromoUnit.get(PUselectindex);
        list<SelectOption> SO = new list<SelectOption>();
        for(ASI_MFM_Item_Group__c IG : [select id, name, ASI_MFM_Item_Group_Code__c from ASI_MFM_Item_Group__c where ASI_MFM_Sub_brand__c =: PUobj.PU.ASI_CRM_Sub_brand__c])
        {
            SO.add(new SelectOption(IG.id, IG.name));
        }
        mapPromoUnit.get(PUselectindex).Itemgroups = SO;
    }
    
    public void addPromoUnit(){
        ASI_CRM_Promotion_Unit__c objPromoUnit = new ASI_CRM_Promotion_Unit__c(ASI_CRM_Promotion__c=promoId, ASI_CRM_Qty__c=0, RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Unit__cASI_CRM_TW_PromotionUnit'));
        promoUnitobj PUobj = new promoUnitobj();
        PUobj.PU = objPromoUnit;
        mapPromoUnit.put(intIndexPromoUnit++, PUobj);
    }
    public void deletePromoUnit(){
        if(intRowid != NULL && mapPromoUnit.get(intRowid) != NULL){
            if(mapPromoUnit.get(intRowid).PU.id != NULL)
                listDeletedPromoUnit.add(mapPromoUnit.get(intRowid).PU);
            mapPromoUnit.remove(intRowid);
        }
    }
    
    public void deletePromoTarget(){
        if(intRowid != NULL && mapPromoTarget.get(intRowid) != NULL){
            if(mapPromoTarget.get(intRowid).id != NULL)
                listDeletedPromoTarget.add(mapPromoTarget.get(intRowid));
            mapPromoTarget.remove(intRowid);
        }
    }
    public void addPromoTarget(){
        ASI_CRM_Promotion_Target__c objPromoTarget = new ASI_CRM_Promotion_Target__c(ASI_CRM_Promotion__c=promoId, RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Target__cASI_CRM_TW_PromotionTarget'));
        mapPromoTarget.put(intIndexPromoTarget++, objPromoTarget);
    }
        
    public void addPromoPOSM(){
        if(intRowid != NULL && mapNewPromoPOSM.get(intRowid) != NULL){
            ASI_CRM_Promotion_POSM__c objPromoPOSM = mapNewPromoPOSM.get(intRowid).posm;
            if(objPromoPOSM != NULL)
                setSKUId.add(objPromoPOSM.ASI_CRM_SKU__c);
            
            promoPOSM classPOSM = new promoPOSM();
            classPOSM.posm = new ASI_CRM_Promotion_POSM__c();
            classPOSM.posm.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_POSM__cASI_CRM_TW_PromotionPOSM');
            classPOSM.posm.ASI_CRM_Promotion__c = promoId;
            classPOSM.posm.ASI_CRM_SKU__c = objPromoPOSM.ASI_CRM_SKU__c;
            classPOSM.skuName = mapNewPromoPOSM.get(intRowid).skuName;
            classPOSM.skuImageURL = mapNewPromoPOSM.get(intRowid).skuImageURL;

            mapPromoPOSM.put(intIndexPromoPOSM++, classPOSM);
            mapNewPromoPOSM.remove(intRowid);
        }
    }
    public void deletePromoPOSM(){
        if(intRowid != NULL && mapPromoPOSM.get(intRowid) != NULL){
            if(mapPromoPOSM.get(intRowid).posm != NULL && mapPromoPOSM.get(intRowid).posm.id != NULL)
                listDeletedPromoPOSM.add(mapPromoPOSM.get(intRowid).posm);
            setSKUId.remove(mapPromoPOSM.get(intRowid).posm.ASI_CRM_SKU__c);
            mapPromoPOSM.remove(intRowid);
        }
    }
    
    public void clonePromoUnit(){
        if(intRowid != NULL && mapPromoUnit.get(intRowid).PU != NULL){
            ASI_CRM_Promotion_Unit__c objPromoUnit = mapPromoUnit.get(intRowid).PU;
            ASI_CRM_Promotion_Unit__c objPromoUnit_Clone = objPromoUnit.clone(false, true);
            promoUnitobj PUobj = new promoUnitobj();
            PUobj.PU = objPromoUnit_Clone;
            mapPromoUnit.put(intIndexPromoUnit++, PUobj);
        }
    }
    
    public void clonePromoTarget(){
        if(intRowid != NULL && mapPromoTarget.get(intRowid) != NULL){
            ASI_CRM_Promotion_Target__c objPromoTarget = mapPromoTarget.get(intRowid);
            ASI_CRM_Promotion_Target__c objPromoTarget_Clone = objPromoTarget.clone(false, true);
            mapPromoTarget.put(intIndexPromoTarget++, objPromoTarget_Clone);
        }
    }
    
    public void searchSKU(){
        listSKU = new List<ASI_MFM_SKU_Code__c>();
        mapSKU = new Map<String, ASI_MFM_SKU_Code__c>();
        mapNewPromoPOSM = new Map<integer, promoPOSM>();
        listNewPromoPOSM = new List<ASI_CRM_Promotion_POSM__c>();
        intIndexNewPromoPOSM = 0;        
        mapSKUImage = new Map<String, ContentDocumentLink>(); 
         
        if(!String.isBlank(searchSKU)){
            Set<String> setSearchSkuCode = new Set<String>();
            Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_MFM_TW_SKU_Code');
            listSKU = Database.query('SELECT id, Name, ASI_CRM_Department__c, ASI_CRM_Category__c, ASI_FOC_Packing_Description__c, ASI_MFM_Sub_brand__r.Name, ASI_CRM_Region__c, ASI_CRM_TW_Current_Stock__c, ASI_MFM_SKU_Code__c  FROM ASI_MFM_SKU_Code__c WHERE Name like \'%' +searchSKU+ '%\'' + 'AND RecordTypeId = \'' +RecordTypeId+ '\'' + 'AND id NOT IN:setSKUId AND ASI_HK_CRM_IsPOSProduct__c = true AND ASI_CRM_TW_Current_Stock__c != null AND ASI_CRM_TW_Current_Stock__c != 0 ORDER BY Name LIMIT 200');          
            for(ASI_MFM_SKU_Code__c sku : listSKU){
                mapSKU.put(sku.id, sku);
                setSearchSkuCode.add(sku.ASI_MFM_SKU_Code__c);
            } 
            
            if(!Test.isRunningTest() && customSettingAccId != NULL && setSearchSkuCode.size() > 0)
                listSKUImage = [SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: customSettingAccId.ASI_CRM_TW_POSM_Image_Account_Id__c AND ContentDocument.Title IN:setSearchSkuCode];
            for(ContentDocumentLink image : listSKUImage){
                //String[] strArray = image.Name.split('\\.');
                mapSKUImage.put(image.ContentDocument.Title, image);
            }
            
            for(ASI_MFM_SKU_Code__c sku : listSKU){
                String imageURL;
                if(sku.ASI_MFM_SKU_Code__c != NULL && mapSKUImage.get(sku.ASI_MFM_SKU_Code__c) != NULL){
                    //imageURL = '/servlet/servlet.FileDownload?file='+mapSKUImage.get(sku.ASI_MFM_SKU_Code__c+'.jpg').id;
                    imageURL = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+mapSKUImage.get(sku.ASI_MFM_SKU_Code__c).ContentDocument.LatestPublishedVersionId;
                }else{
                    imageURL = NULL;
                } 
                system.debug(imageURL);              
                
                ASI_CRM_Promotion_POSM__c objPOSM = new ASI_CRM_Promotion_POSM__c(RecordTypeId=Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_POSM__cASI_CRM_TW_PromotionPOSM'), ASI_CRM_Promotion__c=this.promo.id, ASI_CRM_SKU__c=sku.id);                
                promoPOSM classPOSM = new promoPOSM();
                classPOSM.posm = objPOSM;
                classPOSM.skuName = sku.Name;
                classPOSM.skuImageURL = imageURL;
                classPOSM.skuCode = sku.ASI_MFM_SKU_Code__c;
                classPOSM.category = sku.ASI_CRM_Category__c;
                classPOSM.department = sku.ASI_CRM_Department__c;
                classPOSM.region = sku.ASI_CRM_Region__c;
                classPOSM.subbrand = sku.ASI_MFM_Sub_brand__r.Name;
                classPOSM.stock = String.valueof(sku.ASI_CRM_TW_Current_Stock__c);
                classPOSM.packing = sku.ASI_FOC_Packing_Description__c;
                
                system.debug(classPOSM);
                
                listNewPromoPOSM.add(objPOSM);
                mapNewPromoPOSM.put(intIndexNewPromoPOSM++, classPOSM);
                mapSKU.put(sku.Name, sku);
            }
        }  
    }
    
    public void reset(){
        searchSKU = '';
        searchSKU(); 
    }
    
    public PageReference quickSave(){
       Boolean saveSuccess = implSaveChanges();
       PageReference redirectPage = NULL;
        if (saveSuccess) {
            redirectPage = Page.ASI_CRM_TW_PromotionSetup_Page;
            redirectPage.setRedirect(true);
            redirectPage.getParameters().put('id', promoId);
        }
        return redirectPage;
    }
    
    public PageReference saveAction(){
       Boolean saveSuccess = implSaveChanges();
       PageReference redirectPage = NULL;
       if (saveSuccess) {
           redirectPage = new PageReference('/' + promoId);
           redirectPage.setRedirect(true);
       }
       return redirectPage;
    }    
    
    
    public Boolean implSaveChanges(){
        Boolean allSuccess = true;
        System.Savepoint sp = database.setSavepoint();
        
        List<ASI_CRM_Promotion_Unit__c> listPromoUnit = new List<ASI_CRM_Promotion_Unit__c>();
        List<ASI_CRM_Promotion_POSM__c> listPromoPOSM = new List<ASI_CRM_Promotion_POSM__c>();
        List<ASI_CRM_Promotion_Target__c> listPromoTarget = new List<ASI_CRM_Promotion_Target__c>();

        for(Integer promoUnitKey : mapPromoUnit.keySet()){
            ASI_CRM_Promotion_Unit__c promoUnit = mapPromoUnit.get(promoUnitKey).PU;
            listPromoUnit.add(promoUnit);
        }
        
        for(Integer promoPOSMKey : mapPromoPOSM.keySet()){
            if(mapPromoPOSM.get(promoPOSMKey) != NULL){
                ASI_CRM_Promotion_POSM__c promoPOSM = mapPromoPOSM.get(promoPOSMKey).posm;
                listPromoPOSM.add(promoPOSM);
            }
        }
        
        for(Integer promoTargetKey : mapPromoTarget.keySet()){
            ASI_CRM_Promotion_Target__c promoTarget = mapPromoTarget.get(promoTargetKey);
            if(setStrRegion == NULL || !setStrRegion.contains(promoTarget.ASI_CRM_Region__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Promotion Target: Region '+'\''+promoTarget.ASI_CRM_Region__c+'\''+' is invalid.'));
                allSuccess = false;
            }
            listPromoTarget.add(promoTarget);
        }
        
        if (allSuccess) {
            try {
                if(listDeletedPromoUnit.size() > 0)
                    delete listDeletedPromoUnit;
                if(listDeletedPromoPOSM.size() > 0)
                    delete listDeletedPromoPOSM;
                if(listDeletedPromoTarget.size() > 0)
                    delete listDeletedPromoTarget;
                if(listPromoUnit.size() > 0)
                    upsert listPromoUnit;
                if(listPromoPOSM.size() > 0)
                    upsert listPromoPOSM;
                if(listPromoTarget.size() > 0)
                    upsert listPromoTarget;                    
            } 
            catch (DmlException dmle) {
                allSuccess = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '-'+dmle));
                database.rollback(sp);
            }
        }        
        return allSuccess;    
    }
}