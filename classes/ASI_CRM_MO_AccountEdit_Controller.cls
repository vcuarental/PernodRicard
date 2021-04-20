/*********************************************************************************
 * Name: ASI_CRM_MO_AccountEdit_Controller
 * Description: Controller class for MO Account Create/ Edit (ASI_HK_CRM_Outlet)
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-03-20       Daniel WONG             Created 
 */

public class ASI_CRM_MO_AccountEdit_Controller {
    public ApexPages.StandardController standardController;
    
    public ID MOAccountRT = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet');
    public ID MOCustomerRT = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_HK_Outlet');
    public String selectedOutletTypeId {set;get;}
    public String selectedOutletImageId {set;get;}
    public ASI_CRM_AccountsAdditionalField__c accountAdditionalField {set;get;}
    public Account objAcc;
    
    public list<ASI_CRM_Audit_Trail__c> getAccountAT(){
        list<ASI_CRM_Audit_Trail__c> lstAT = new list<ASI_CRM_Audit_Trail__c>();
        
        for(ASI_CRM_Audit_Trail__c at : [SELECT id, createdDate, owner.name, ASI_CRM_Field_Name__c, ASI_CRM_Original__c, ASI_CRM_New__c FROM ASI_CRM_Audit_Trail__c WHERE ASI_CRM_Account__c = :objAcc.id ORDER BY createdDate DESC LIMIT 15]){
            lstAT.add(at);
        }
        
        return lstAT;
    }
    
    public list<ASI_TH_CRM_Contract__c> getAccountContract(){
        list<ASI_TH_CRM_Contract__c> lstContract = new list<ASI_TH_CRM_Contract__c>();
        
        for(ASI_TH_CRM_Contract__c c : [SELECT id, name, ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Outlet__c = :objAcc.id ORDER BY CreatedDate DESC LIMIT 5]){
            lstContract.add(c);
        }
        
        return lstContract;
    }
    
    public list<ASI_TH_CRM_Contract__c> getAccountContractALL(){
        list<ASI_TH_CRM_Contract__c> lstContract = new list<ASI_TH_CRM_Contract__c>();
        
        for(ASI_TH_CRM_Contract__c c : [SELECT id, name, ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE ASI_TH_CRM_Outlet__c = :objAcc.id ORDER BY CreatedDate DESC]){
            lstContract.add(c);
        }
        
        return lstContract;
    }
    
    public list<ASI_HK_CRM_Visitation_Plan_Detail__c> getAccountVPD(){
        list<ASI_HK_CRM_Visitation_Plan_Detail__c> lstVPD = new list<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : [SELECT id, name, ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Visit_Objective__c, ASI_HK_CRM_Subject__c FROM ASI_HK_CRM_Visitation_Plan_Detail__c WHERE ASI_HK_CRM_Account__c = :objAcc.id ORDER BY ASI_HK_CRM_Visit_Date__c DESC LIMIT 5]){
            lstVPD.add(vpd);
        }
        
        return lstVPD;
    }
    
    public list<ASI_HK_CRM_Visitation_Plan_Detail__c> getAccountVPDALL(){
        list<ASI_HK_CRM_Visitation_Plan_Detail__c> lstVPD = new list<ASI_HK_CRM_Visitation_Plan_Detail__c>();
        
        for(ASI_HK_CRM_Visitation_Plan_Detail__c vpd : [SELECT id, name, ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Visit_Objective__c, ASI_HK_CRM_Subject__c FROM ASI_HK_CRM_Visitation_Plan_Detail__c WHERE ASI_HK_CRM_Account__c = :objAcc.id ORDER BY ASI_HK_CRM_Visit_Date__c DESC]){
            lstVPD.add(vpd);
        }
        
        return lstVPD;
    }
    
    public List<SelectOption> OutletTypeList{
        get{
            List<ASI_TH_CRM_OutletType__c> outletTypes = [
                SELECT id, Name 
                FROM ASI_TH_CRM_OutletType__c 
                WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletType__cASI_CRM_MO_Outlet_Type') //.DeveloperName = 'ASI_CRM_MO_Outlet_Type'
                ORDER BY ASI_CRM_Channel__c, ASI_CRM_Sub_Channel__c
            ];
            
            List<SelectOption> outletTypeList = new List<SelectOption>();
            
            for(ASI_TH_CRM_OutletType__c outletType : outletTypes){
                outletTypeList.add(new SelectOption(outletType.id, outletType.Name));
            }
            return outletTypeList;
        }
    }
    
    public List<SelectOption> OutletImageList{
        get{
            List<ASI_TH_CRM_OutletImage__c> outletImages = [
                SELECT id, Name 
                FROM ASI_TH_CRM_OutletImage__c
                WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_TH_CRM_OutletImage__cASI_CRM_MO_Outlet_Image')
                ORDER BY ASI_CRM_Sequence__c
            ];
            
            List<SelectOption> outletImageList = new List<SelectOption>();
            
            for(ASI_TH_CRM_OutletImage__c outletImage : outletImages){
                outletImageList.add(new SelectOption(outletImage.id, outletImage.Name));
            }
            return outletImageList;
        }
    }
    
    public ASI_CRM_MO_AccountEdit_Controller(ApexPages.StandardController controller){
        standardController = controller;        
        objAcc = (Account)controller.getRecord();
        objAcc.ASI_HK_CRM_Location__c = '#_MACDPLOC';
        objAcc.RecordTypeID = MOAccountRT;
        if (objAcc.OwnerId == null) {
            objAcc.OwnerId = UserInfo.getUserId();
        }
        
        if(objAcc.id != null)
            accountAdditionalField = getAccountsAdditionalField_DynamicSOQL(objAcc.id);         
        
        if (accountAdditionalField == null){
            accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c();
            accountAdditionalField.RecordTypeId = MOCustomerRT;
        }else{
            selectedOutletTypeId = accountAdditionalField.ASI_TH_CRM_OutletType__c;
        }                               
    }
    
    private ASI_CRM_AccountsAdditionalField__c getAccountsAdditionalField_DynamicSOQL(String accountId) {  
        System.Debug(accountId);
        String query = 'SELECT ';    
        /*for(Schema.FieldSetMember f : SObjectType.ASI_CRM_AccountsAdditionalField__c.FieldSets.ASI_CRM_MO_AdditionalField.getFields()) {    
            query += f.getFieldPath() + ', ';    
        }*/                  
        query += 'Id, Name, ASI_CRM_Account__c, ASI_CRM_VN_Channel__c, ASI_CRM_MO_Local_Channel__c,  ASI_TH_CRM_OutletType__c, ASI_TH_CRM_OutletImage__c, ASI_CRM_Branch__c, ';
        query += 'ASI_CRM_CN_No_of_Tables__c, ASI_CRM_Sales_Potential__c, ASI_CRM_District__c ';
        query += 'FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c = \''+accountId+'\' LIMIT 1';  
        
        System.Debug('------DEBUG ASI_CRM_MO_AccountEdit_Controller------ Query: ' + query);
        if(Database.query(query) != null && Database.query(query).size() > 0)
            return Database.query(query);    
        
        return null;
    }        
    
    public PageReference save(){
        //Replicate the AccountAdditional values to Account
        objAcc.ASI_HK_CRM_Channel__c = accountAdditionalField.ASI_CRM_VN_Channel__c;
        objAcc.ASI_HK_CRM_Local_Channel__c = accountAdditionalField.ASI_CRM_MO_Local_Channel__c;
        objAcc.ASI_HK_CRM_District__c = accountAdditionalField.ASI_CRM_District__c;
        upsert(standardController.getRecord());
        
        accountAdditionalField.Name = objAcc.Name;
        if(accountAdditionalField.ASI_CRM_Account__c == null){
            accountAdditionalField.ASI_CRM_Account__c = standardController.getRecord().id;
            accountAdditionalField.RecordTypeId = MOCustomerRT;                                                 
        }
        accountAdditionalField.ASI_TH_CRM_OutletType__c = selectedOutletTypeId;
        accountAdditionalField.ASI_TH_CRM_OutletImage__c = selectedOutletImageId;
        upsert(accountAdditionalField);
        
        PageReference ReturnPage = new PageReference('/' + standardController.getRecord().id);
        ReturnPage.setRedirect(true); 
        return ReturnPage;
    }
}