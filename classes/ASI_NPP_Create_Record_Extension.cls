public class ASI_NPP_Create_Record_Extension {
    Boolean show = false;
    Boolean CanEdit = true;
    List<String> args = new String[]{'0','number','###,###,##0.00'};
    private final ASI_NPP_New_Product_Promotion__c npp;
	public Boolean canViewCM{
		get{
			Boolean flag = false;
			
			List<GroupMember> viewCMGroupList = [SELECT groupID, userOrGroupID FROM groupMember 
				WHERE GroupID in (SELECT ID FROM Group WHERE DeveloperName = 'ASI_NPP_SG_View_CM')];
				
			for (GroupMember viewCMGroup:viewCMGroupList){
				if (UserInfo.getUserId() == viewCMGroup.userOrGroupID)
					flag = true;
			}
			
			return flag;
		}
		set;
	}
	
    public ASI_NPP_Create_Record_Extension(ApexPages.StandardController stdController) {
        // get method variables  
        if(!test.isRunningTest()) { 
    	stdController.addFields( new list<string>{'ownerId','ASI_NPP_Start_Launch_Date__c','ASI_NPP_Sub_brand__c','ASI_NPP_Total_A_P_Expenses__c','ASI_NPP_Forecast_AND_Target__c','ASI_NPP_9LC_conversion__c','ASI_NPP_Volume_Sub_Brands_Per_Annum__c','ASI_NPP_FOB_Cost_w_o_Duties__c','ASI_APP_FOB_Cost_conversion_to_SGD__c','ASI_NPP_Percent_of_CAAP__c','ASI_NPP_Benchmark_CAAP__c','ASI_NPP_Percent_Contribution_Margin__c','ASI_NPP_Benchmark_CM__c','ASI_NPP_New_Product_Assessment_Form__c'});
        
        // create standard controller
        }
     	npp = (ASI_NPP_New_Product_Promotion__c)stdController.getRecord();
		
        npp.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_NPP_New_Product_Promotion__cASI_NPP_SG_New_Product_or_Promotion');
        // check to see if assessment needed
        this.show = this.npp.ASI_NPP_New_Product_Assessment_Form__c;
        // check if user allowed to edit
        system.debug(this.npp.ownerId);
    	if (this.npp.ownerId!=null)
        {
            if (this.npp.ownerId == UserInfo.getUserId())
            	this.CanEdit = true;
            else 
                this.CanEdit = false;
        }        
    }
    
     
    public pagereference showSection1() {
        setHideshow(true);
    return null; }

    public Boolean getCanEdit()
    {
        return this.CanEdit;
    }

    public Boolean getHideshow()
    {
        return this.show;
    }
    public void setHideshow(boolean s)
    {
        this.show = s;
    }
   
    public string getdate()
    {
        if(npp.ASI_NPP_Launch_Date__c!=null)
        {
            return string.valueof(npp.ASI_NPP_Launch_Date__c.month()) + '/' +string.valueof(npp.ASI_NPP_Launch_Date__c.day())+ '/' +string.valueof(npp.ASI_NPP_Launch_Date__c.year());
        }
        else
        {
            return '';
        }
    }
    
    public string getsubBrand()
    {
        if (npp.ASI_NPP_Sub_brand__c != null){
            ASI_MFM_Sub_brand__c sub = [SELECT Name FROM ASI_MFM_Sub_brand__c WHERE id = :npp.ASI_NPP_Sub_brand__c];
        	return sub.Name;
        }
        else
        {
            return '';
        }
    }
/*    
    public string getTotalAnPExpense()
    {
        if (npp.ASI_NPP_Total_A_P_Expenses__c != null){
            String anpExpensenpp = String.format(npp.ASI_NPP_Total_A_P_Expenses__c.format(), args);
        	return anpExpensenpp;
        }
        else
        {
            return '';
        }
        
    }
    
    public string getAnnualTargetForecastPromotionalTarget()
    {
        if (npp.ASI_NPP_Forecast_AND_Target__c != null){
            String AnnualTargetForecastPromotionalTarget = String.format(npp.ASI_NPP_Forecast_AND_Target__c.format(), args);
        	return AnnualTargetForecastPromotionalTarget;
        }
        else
        {
            return '';
        }
        
    }
    
    public string getLCconversion()
    {
        if (npp.ASI_NPP_9LC_conversion__c != null){
            String LCconversion = String.format(npp.ASI_NPP_9LC_conversion__c.format(), args);
        return LCconversion;
        }
        else
        {
            return '';
        }
        
    }
    
    public string getVolumeSubBrandsPerAnnum()
    {
        if (npp.ASI_NPP_Volume_Sub_Brands_Per_Annum__c != null){
            String VolumeSubBrandsPerAnnum = String.format(npp.ASI_NPP_Volume_Sub_Brands_Per_Annum__c.format(), args);
        	return VolumeSubBrandsPerAnnum;
        }
        else
        {
            return '';
        }
        
    }
    
    public string getFOBCostwoDuties()
    {
        if (npp.ASI_NPP_FOB_Cost_w_o_Duties__c != null){
            String FOBCostwoDuties = String.format(npp.ASI_NPP_FOB_Cost_w_o_Duties__c.format(), args);
        	return FOBCostwoDuties;
        }
        else
        {
            return '';
        }
        
    }
    */
    public string getCAAPcolor()
    {
        String CAAPcolor = 'red';
        if (npp.ASI_NPP_Percent_of_CAAP__c != null && npp.ASI_NPP_Benchmark_CAAP__c !=null){
           	if (npp.ASI_NPP_Percent_of_CAAP__c > npp.ASI_NPP_Benchmark_CAAP__c)
           	{
            	CAAPcolor = '#82FA58';
        	}
        }
        
        return CAAPcolor;
    }
    
    public string getCMcolor()
    {
        String CMcolor = 'red';
        if (npp.ASI_NPP_Percent_Contribution_Margin__c != null && npp.ASI_NPP_Benchmark_CM__c !=null){
           	if (npp.ASI_NPP_Percent_Contribution_Margin__c > npp.ASI_NPP_Benchmark_CM__c){
            	CMcolor = '#82FA58';
        	}
        }     
        return CMcolor;
    }   
}