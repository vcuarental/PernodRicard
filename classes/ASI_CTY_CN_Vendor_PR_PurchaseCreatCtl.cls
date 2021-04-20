/*****************************************************************************************************************
* Name:        ASI_CTY_CN_Vendor_PR_PurchaseController       
* Test Class:  ASI_CTY_CN_Vendor_PR_PurchaseControllerTest
* Description: 
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    -----------------------------------------------------------------------------
* 2020-12-04       bls                  Create Class
*****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_PR_PurchaseCreatCtl {

	public ASI_MFM_Purchase_Request__c pr{get;set;}
	public List<SelectOption> categorys{get;set;}
	public List<SelectOption> acCodes{get;set;}
	public String planId {get;set;}
    public String errMsg {get;set;}
    public boolean isedit {get;set;}
    public ASI_CTY_CN_Vendor_PR_PurchaseCreatCtl(ApexPages.StandardController con) {
        
        System.debug(LoggingLevel.INFO, '*** con: ' + con);
        isedit = false;
        if(null == con.getId())
        {
            pr = new ASI_MFM_Purchase_Request__c();
            pr.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_CN_Vendor_Purchase_Request');
            pr.OwnerId = System.UserInfo.getUserId();
            pr.CurrencyIsoCode = 'CNY';
           //pr.ASI_CTY_CN_Vendor_Responsible_by__c = System.UserInfo.getUserId();
        }
        else
        {
            pr = (ASI_MFM_Purchase_Request__c)con.getRecord();
        }
       System.debug(LoggingLevel.INFO, '*** pr: ' + pr);
        
    }

    public void changePlan()
    {
    	System.debug(LoggingLevel.INFO, '*** pr: ' + pr);
    	List<ASI_MFM_Plan__c> plans = [SELECT Id,ASI_MFM_Marketing_Category__c FROM ASI_MFM_Plan__c WHERE Id = :pr.ASI_CTY_CN_Vendor_Plan__c];
        if(plans.size()>0)
        {   
            ASI_MFM_Plan__c plan  = plans.get(0);
            List<ASI_MFM_PP_Category__c> cateList = [SELECT Id,Name  FROM ASI_MFM_PP_Category__c WHERE ASI_MFM_Marketing_Category__c =:plan.ASI_MFM_Marketing_Category__c];
            categorys = new List<SelectOption>();
            categorys.add(new SelectOption('', 'Please Select'));
            for(ASI_MFM_PP_Category__c ca:cateList)
            {
              System.debug(LoggingLevel.INFO, '*** ca: ' + ca);
              categorys.add(new SelectOption(ca.Id, ca.Name));
            }
            if(!isedit)
            {
               pr.ASI_CTY_CN_Vendor_AC_Code__c = null;
               pr.ASI_CTY_CN_Vendor_PP_Category__c = null;
            }
        }
    	
    }


    public void changeCategory()
    {
    	
		List<ASI_MFM_PP_Category_A_C__c> caAcList = [SELECT ASI_MFM_A_C_Code__c,ASI_MFM_A_C_Code__r.Name FROM ASI_MFM_PP_Category_A_C__c WHERE ASI_MFM_PP_Category__c =:pr.ASI_CTY_CN_Vendor_PP_Category__c];
    	acCodes = new List<SelectOption>();
    	acCodes.add(new SelectOption('', 'Please Select'));
    	for(ASI_MFM_PP_Category_A_C__c ca:caAcList)
    	{
          acCodes.add(new SelectOption(ca.ASI_MFM_A_C_Code__c, ca.ASI_MFM_A_C_Code__r.Name));
    	}
        if(!isedit)
        {
    	  pr.ASI_CTY_CN_Vendor_AC_Code__c = null;
        }
    	System.debug(LoggingLevel.INFO, '*** acCodes: ' + acCodes);
    	
    }


    public PageReference onSave(){

       errMsg = '';
       if(null == pr.ASI_CTY_CN_Vendor_AC_Code__c)
       {
         errMsg = 'A/C Code Required!';

       }
        if( null == pr.ASI_CTY_CN_Vendor_PP_Category__c)
       {
         errMsg = 'Category Required!';

       }
        if(null == pr.ASI_CTY_CN_Vendor_Responsible_by__c)
       {
         errMsg = 'Budget Owner Required!';

       }
        if('' == pr.ASI_CTY_CN_Vendor_Bu__c || null == pr.ASI_CTY_CN_Vendor_Bu__c)
       {
         errMsg = 'BU Required!';

       }
        if(null == pr.ASI_CTY_CN_Vendor_Plan__c)
       {
         errMsg = 'Plan Required!';

       }
        if('' == pr.ASI_CTY_CN_Vendor_Subchannel__c || null == pr.ASI_CTY_CN_Vendor_Subchannel__c)
       {
         errMsg = 'Po Channel Required!';

       }
        if('' == pr.ASI_CTY_CN_Vendor_Enqulry_Name__c || null == pr.ASI_CTY_CN_Vendor_Enqulry_Name__c)
       {
         errMsg = 'Enquiry Name Required!';

       }
       if(String.isEmpty(errMsg))
       {
         errMsg = checkTeam(pr,errMsg);
       }
       System.debug(LoggingLevel.INFO, '*** errMsg: ' + errMsg);
       if(!String.isEmpty(errMsg))
       {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, errMsg));
            return null;
       }
       upsert pr;
       return new PageReference('/' + pr.Id);
    }

    public static String  checkTeam(ASI_MFM_Purchase_Request__c pur,String errMsg)
    {
        List<ASI_MFM_Team_Member__c> teamMemberList = new List<ASI_MFM_Team_Member__c>([SELECT id, ASI_MFM_Team__c, ASI_MFM_Team_Member__c FROM ASI_MFM_Team_Member__c WHERE ASI_MFM_Team__r.RecordType.DeveloperName = 'ASI_MFM_CN_Project_Team']);
        ASI_MFM_Plan__c plan = [SELECT Id,ASI_MFM_Team__c FROM ASI_MFM_Plan__c WHERE Id =: pur.ASI_CTY_CN_Vendor_Plan__c];
        Map<Id, Set<Id>> mapTeamMember = new Map<Id, Set<Id>>();
        for(ASI_MFM_Team_Member__c obj : teamMemberList){//20170112 Elufa changed to teamMemberList
            
            Set<Id> tmpSet = new Set<Id>();
            
            if(mapTeamMember.containsKey(obj.ASI_MFM_Team__c)){
                tmpSet = mapTeamMember.get(obj.ASI_MFM_Team__c);
            }
            
            tmpSet.add(obj.ASI_MFM_Team_Member__c);
            
            mapTeamMember.put(obj.ASI_MFM_Team__c, tmpSet);
        }
        User prOwner = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(System.UserInfo.getUserId());
        User prBudgetOwner = ASI_CRM_CN_RoleAndSubordinateHelperCLS.getUser(pur.ASI_CTY_CN_Vendor_Responsible_by__c);
        if(prOwner != NULL && prBudgetOwner != NULL && prOwner.ASI_MFM_Team__c != prBudgetOwner.ASI_MFM_Team__c && prOwner.ASI_MFM_Team__c != '' && prBudgetOwner.ASI_MFM_Team__c != ''){
                
                if(mapTeamMember.containsKey(plan.ASI_MFM_Team__c)){
                    if(!mapTeamMember.get(plan.ASI_MFM_Team__c).contains(System.UserInfo.getUserId()) || !mapTeamMember.get(plan.ASI_MFM_Team__c).contains(pur.ASI_CTY_CN_Vendor_Responsible_by__c)){
                      errMsg ='You are NOT allowed to created Purchase Request for budget owner not in your team';
                    }
                }else{
                    errMsg ='You are NOT allowed to created Purchase Request for budget owner not in your team';
                }
      }

      return errMsg;
    }


    public pageReference getEditRecord() {
        
        String url = '';
        isedit = true;
        String recId = apexpages.currentPage().getParameters().get('id');
        System.debug(LoggingLevel.INFO, '*** recId: ' + recId);
        pr = [SELECT Id,ASI_CTY_CN_Vendor_Responsible_by__c,CurrencyIsoCode,ASI_CTY_CN_Vendor_Enqulry_Name__c,ASI_CTY_CN_Vendor_Subchannel__c,ASI_CTY_CN_Vendor_Plan__c,
            ASI_CTY_CN_Vendor_Bu__c,ASI_CTY_CN_Vendor_PP_Category__c,ASI_CTY_CN_Vendor_AC_Code__c,RecordType.Name FROM ASI_MFM_Purchase_Request__c 
            WHERE Id =:pr.Id];
            System.debug(LoggingLevel.INFO, '*** pr.RecordType.Name: ' + pr.RecordType.Name);
        if(pr.RecordType.Name == 'CN Purchase Request')
        {
          changePlan();
          changeCategory();
          return null;
        }
        else
        {
           url = '/'+ recId + '/e?retURL=%2F'+recId + '%2Fo&nooverride=1';
        }
        

        System.debug(LoggingLevel.INFO, '*** url: ' + url);
        return new pageReference(url);
    }

}