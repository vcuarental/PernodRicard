/*****************************************************************
*	Controller for the Germany Admin Console
*	related to: EUR_CRM_DE_AdminConsole.page
*	Handles Territory and PROS levels updates. As well as accuring visit activities and on trade activities. 
*****************************************************************/

public class EUR_CRM_DE_AdminConsoleController{
    
    public Boolean isEditAll{get;set;}
    public Boolean isTerritory{get;set;}
    public Boolean isOP{get;set;}
    public Boolean isOPOnTrade{get;set;}
    public List<EUR_CRM_Visit_Action__c> pagedVisitActions{get;set;}
    public List<EUR_CRM_Visit_Action__c> allVisitActions{get;set;}
    public Integer visitActionsPageNum {get; set;}
	public Boolean visitActionsPageHasMore {get; set;}
	public Integer visitActionsFirstIndex {get; set;}
	public Integer totalPages;
	
    public static Integer ROWS_PER_PAGE = 50;
    public final Set<String> territoryProfiles = new Set<String>{''};
    public final Set<String> opProfiles = new Set<String>{''};
    public final Set<String> adminProfiles = new Set<String>{'System Administrator','EUR System Admin','EUR DE/AT IT Admin User'};
    public final Set<String> opOnTradeProfiles = new Set<String>{'EUR DE Trade Marketing User'};
    
    public Set<String> validOPAdmins = new Set<String>{'EUR_DE_ON_Trade_O_P_Admin', 'EUR_DE_OFF_Trade_O_P_Admin'};
    public Set<String> validOPOnTradeAdmins = new Set<String>{'EUR_DE_ON_Trade_O_P_Admin'};
    public Set<String> validTerritoryAdmins = new Set<String>{'EUR_DE_Territory_Region_Admin'};
    public Set<String> validAllDE = new Set<String>{'EUR_DE_Territory_Region_Admin', 'EUR_DE_ON_Trade_O_P_Admin'};
    
    
    /*****************************************************************
	*	Constructor
	*
	*	Makes sure the user has the right access permission to edit the data
	*****************************************************************/

    public EUR_CRM_DE_AdminConsoleController(){
        String userProfileName = [select name from Profile where id =: UserInfo.getProfileId()].name;
        
        isEditAll = adminProfiles.contains(userProfileName);
        
        Set<Id> validOPAdminUsers = new Set<Id>();
        Set<Id> validOPOnTradeAdminUsers = new Set<Id>();
        for(PermissionSetAssignment pa : [SELECT Id, Assignee.Name, Assignee.Id, PermissionSet.Name
                    FROM PermissionSetAssignment where  PermissionSet.Name in:validOPAdmins AND Assignee.Id = :UserInfo.getUserId()] ){
            validOPAdminUsers.add(pa.Assignee.Id);
        }
        Set<Id> validTerritoryAdminUsers = new Set<Id>();
        for(PermissionSetAssignment pa : [SELECT Id, Assignee.Name, Assignee.Id, PermissionSet.Name
                    FROM PermissionSetAssignment where  PermissionSet.Name in:validAllDE AND Assignee.Id = :UserInfo.getUserId()] ){
            if('EUR_DE_Territory_Region_Admin' == pa.PermissionSet.Name)
                validTerritoryAdminUsers.add(pa.Assignee.Id);
            if('EUR_DE_ON_Trade_O_P_Admin' == pa.PermissionSet.Name)
                validOPOnTradeAdminUsers.add(pa.Assignee.Id);
        }
        // Checks whether the current use belongs to any of the profiles with the needed permission sets to edit the data
        isTerritory = validTerritoryAdminUsers.contains(UserInfo.getUserId()) || territoryProfiles.contains(userProfileName);
        isOP = validOPAdminUsers.contains(UserInfo.getUserId()) || opProfiles.contains(userProfileName);        
        isOPOnTrade = opOnTradeProfiles.contains(userProfileName) || validOPOnTradeAdminUsers.contains(UserInfo.getUserId()); 
        
        if(isEditAll || isOPOnTrade){ 
            initOnTradeOPActivities();
        }
        // Prepares the visit action data
        prepareVisitActions();
    }
    
    /*****************************************************************
	*	Retrieves the unAccured visit actions records. 
	*****************************************************************/
    
    public void prepareVisitActions(){
    	visitActionsPageNum = 0;
    	allVisitActions = new List<EUR_CRM_Visit_Action__c>();
    	allVisitActions = [
            select id,name, 
                EUR_CRM_End_Datetime__c,
                EUR_CRM_Brand_Quality_Size__c,
                EUR_CRM_SKU__c,
                EUR_CRM_Account__c,
                EUR_CRM_Status__c,
                recordtype.developername, 
                EUR_CRM_IS_successful__c, 
                EUR_CRM_Sell_In_Volume_Bottles__c ,
                EUR_CRM_ObjPromo__c,
                recordtypeid,
                EUR_CRM_ObjPromo_Target__c,
                EUR_CRM_Visit_ID__c,
                EUR_CRM_Sell_In_Volume_Total_SKU_Bottles__c,
                EUR_CRM_Sell_In_Volume_Total_Bottles__c
                
            from EUR_CRM_Visit_Action__c 
            where EUR_CRM_Entitle_Achievement__c = true AND
        EUR_CRM_Is_Accrued__c = false
        ORDER BY LASTMODIFIEDDATE DESC
        ]; 
		
		// Sets up the pagination of the result of the SOQL query 
        getPagedVisitActions();
    }
    
    /*****************************************************************
	*	Manages the pagination of the visit actions list 
	*****************************************************************/
    
    public void getPagedVisitActions(){
        pagedVisitActions = new List<EUR_CRM_Visit_Action__c>();
        // The list index of the first record in the currently displayed page 
    	visitActionsFirstIndex = visitActionsPageNum * ROWS_PER_PAGE ;
    	// Whether there are more pages with data to be displayed
   		visitActionsPageHasMore = (1+visitActionsPageNum) < getTotalPages();
		// populates the paged visit actions list to be sent to the VF component, with a maximum of ROWS_PER_PAGE number of records 
    	for(Integer i=visitActionsFirstIndex; i<visitActionsFirstIndex+ROWS_PER_PAGE && allVisitActions.size() > i; i++){
    	   pagedVisitActions.add(allVisitActions.get(i));
		}
    }
    
    /*****************************************************************
	*	Sets the current page in the Accured Achievements to the first one
	*****************************************************************/
    public void firstPage(){
    	visitActionsPageNum = 0;
    	getPagedVisitActions();
	}
	/*****************************************************************
	*	Sets the current page in the Accured Achievements to the last one
	*****************************************************************/
	public void lastPage(){
    	visitActionsPageNum = getTotalPages() - 1;
    	getPagedVisitActions();
	}
	/*****************************************************************
	*	Sets the current page in the Accured Achievements to the next one in order
	*****************************************************************/    
    public void nextPage(){
    	Math.min(visitActionsPageNum++, getTotalPages());
    	getPagedVisitActions();
	}
	/*****************************************************************
	*	Sets the current page in the Accured Achievements to the previous one in order
	*****************************************************************/  
	public void previousPage(){
	    Math.max(visitActionsPageNum--, 0);
	    getPagedVisitActions();
	}
	/*****************************************************************
	*	calculates the total number of pages needed to display the full amount of data in the allVisitActions list
	*   returns: and Integer number of maximum number of pages needed
	*****************************************************************/  
	public Integer getTotalPages(){
	   if(System.Math.mod(allVisitActions.size(), ROWS_PER_PAGE ) == 0)
	      return allVisitActions.size() / ROWS_PER_PAGE ;
	   else
	      return (allVisitActions.size() / ROWS_PER_PAGE ) + 1;
	}
    /*****************************************************************
	*	calls the accure function on all of the visit actions
	*****************************************************************/
    public PageReference accrue(){
        EUR_CRM_DE_AccrueAchievements.accrue(allVisitActions);
        return null;
    }
    /*****************************************************************
	*	Refreshes the full page
	*****************************************************************/
     public PageReference refresh(){ 
        return null;
    }
     
    public List<String> outletTypes {get; set;} 
    public List<String> imageTypes {get; set;} 
    
    public List<SelectOption> outletTypeOptions {get; set;} 
    public List<SelectOption> imageTypeOptions {get; set;} 
    public List<SelectOption> variationTypeOptions {get; set;}
    public String  outletTypeValue {get; set;} 
    public String  imageTypeValue {get; set;} 
    public String  variationTypeValue {get; set;}
    public SelectOption[] selectedVariations { get; set; }
    public SelectOption[] allVariations { get; set; }
    private Map<id,EUR_CRM_ObjPromo_OnTrade_Variation__c>  variationsMap;
    private Map<String,Id> opProsMap;
    private Id opProsSegmentRecordType;
    // Map<String,Map<String,List<String>>>
    
    public void initOnTradeOPActivities(){
        RecordType rt = [select id from RecordType where sobjectType='EUR_CRM_ObjPromo_PROS_Segment__c' and developername ='EUR_DE_ObjPromo_Promo_Activity'];
        opProsSegmentRecordType = rt!=null ? rt.id : null;
        outletTypes = new List<String>();
        imageTypes = new List<String>();
        outletTypeOptions = getOutletTypeOptions();
        imageTypeOptions = getImageTypeOptions(); 
        variationsMap = new Map<Id,EUR_CRM_ObjPromo_OnTrade_Variation__c>([select id, name from EUR_CRM_ObjPromo_OnTrade_Variation__c where EUR_CRM_Is_Active__c = true]);
        opProsMap = new Map<String,Id>();
        for(EUR_CRM_ObjPromo_PROS_Segment__c opPros : [select id,EUR_CRM_Outlet_Image__c,EUR_CRM_Outlet_Type__c  from EUR_CRM_ObjPromo_PROS_Segment__c]){
            opProsMap.put(opPros.EUR_CRM_Outlet_Type__c + opPros.EUR_CRM_Outlet_Image__c, opPros.id);
        }
        retrieveVariationTypeOptions(); 
    }
    
    private List<SelectOption> getOutletTypeOptions(){    
        system.debug('++ getOutletTypeOptions');
        List<SelectOption> typeOptions= new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult =
        EUR_CRM_ObjPromo__c.EUR_CRM_PROS_Group_Outlet__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        outletTypeValue = ple.get(0).getValue();
        for( Schema.PicklistEntry f : ple){
            typeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            outletTypes.add(f.getLabel());
        }     
        return typeOptions;
    }
    private List<SelectOption> getImageTypeOptions (){
        system.debug('++ getImageTypeOptions ');
        
        List<SelectOption> typeOptions= new List<SelectOption>();
         
        Schema.DescribeFieldResult fieldResult =
        EUR_CRM_ObjPromo__c.EUR_CRM_PROS_Image_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        imageTypeValue = ple.get(0).getValue();
        
        for( Schema.PicklistEntry f : ple){
            typeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
            imageTypes.add(f.getLabel());
        }   
              
        return typeOptions ;
    }
    private List<EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c> opProsVarMapList;
    
    public PageReference retrieveVariationTypeOptions(){
        system.debug('retrieve Variation Type Options');
        selectedVariations = new List<SelectOption>();
        allVariations = new List<SelectOption>(); 
        List<SelectOption> typeOptions = new List<SelectOption>(); 
        
        Id opProsSegmentId = retrieveOPProsSegmentId(outletTypeValue,imageTypeValue);
        
        opProsVarMapList =[select EUR_CRM_ObjPromo_OnTrade_Variation__c from EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c where EUR_CRM_ObjPromo_PROS_Segment__c =: opProsSegmentId];
        
        Set<id> varIds = new Set<Id>();
        
        for(EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c vm : opProsVarMapList){
            varIds.add(vm.EUR_CRM_ObjPromo_OnTrade_Variation__c);
        }
        for(EUR_CRM_ObjPromo_OnTrade_Variation__c v : [select name, id from EUR_CRM_ObjPromo_OnTrade_Variation__c where id in:VarIds]){ 
            selectedVariations.add(new SelectOption((String) v.id, v.name));
            system.debug(' ++ ' + v.name + ' ' + v.id);
        } 
        for(Id key : variationsMap.keySet()){
            EUR_CRM_ObjPromo_OnTrade_Variation__c variation = variationsMap.get(key);
            if(!varIds.contains(key))
                allVariations.add(new SelectOption(key, variation.Name));            
        }
        
        return null;
    }
    public void quickSaveParticipants(){
        List<EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c> opPRosVarMapListDelete = new List<EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c>();
        List<EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c> opPRosVarMapListInsert = new List<EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c>();
        Id opProsSegmentId = retrieveOPProsSegmentId(outletTypeValue,imageTypeValue);
        
        Set<Id> existingVarMapIds = new Set<Id>();
        Set<Id> toSaveIds = new Set<Id>();
        Map<Id,Id> vMap = new Map<Id,Id>();
        for(EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c vm : opProsVarMapList){
            existingVarMapIds.add(vm.EUR_CRM_ObjPromo_OnTrade_Variation__c);
            vMap.put(vm.EUR_CRM_ObjPromo_OnTrade_Variation__c, vm.id);
        }
        for ( SelectOption so : selectedVariations){
            if(!existingVarMapIds.contains((ID)so.getValue())){
                opPRosVarMapListInsert.add(new EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c(
                    EUR_CRM_ObjPromo_OnTrade_Variation__c = (ID)so.getValue(),
                    EUR_CRM_ObjPromo_PROS_Segment__c = opProsSegmentId));                
            }
            toSaveIds.add((ID)so.getValue());
        }
        for(Id key :vMap.keySet()){
            if(!toSaveIds.contains(key))
                opPRosVarMapListDelete.add(new EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c(id=vMap.get(key)));
        }
        insert opPRosVarMapListInsert;
        delete opPRosVarMapListDelete;
        retrieveVariationTypeOptions();
    }
    
    private Id retrieveOPProsSegmentId(String outletType, String imageType){
        Id opProsSegmentId = opProsMap.get(outletType + imageType);
        if(opProsSegmentId == null){
            EUR_CRM_ObjPromo_PROS_Segment__c newOPProsSegment = new EUR_CRM_ObjPromo_PROS_Segment__c(
            EUR_CRM_Outlet_Type__c = outletType, EUR_CRM_Outlet_Image__c = imageType, recordtypeid = opProsSegmentRecordType);
            insert newOPProsSegment;
            opProsMap.put(outletType+imageType,newOPProsSegment.id);
            opProsSegmentId = newOPProsSegment.id;
        }
        return opProsSegmentId;
    }
    
    public Map<String,List<List<String>>> getProsTable(){
        Map<String, List<String>> mVariations = new Map<String, List<String>>();
        
        for(EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c vm : [select id,EUR_CRM_ObjPromo_OnTrade_Variation__r.name,EUR_CRM_ObjPromo_PROS_Segment__r.EUR_CRM_Outlet_Image__c, EUR_CRM_ObjPromo_PROS_Segment__r.EUR_CRM_Outlet_Type__c from EUR_CRM_ObjPromo_PROS_To_Var_Mapping__c]){
            String key = vm.EUR_CRM_ObjPromo_PROS_Segment__r.EUR_CRM_Outlet_Type__c + vm.EUR_CRM_ObjPromo_PROS_Segment__r.EUR_CRM_Outlet_Image__c;
            if(mVariations.get(key) == null)
                mVariations.put(key,new List<String>());
            mVariations.get(key).add(vm.EUR_CRM_ObjPromo_OnTrade_Variation__r.name);
        }
        Map<String,List<List<String>>> prosTable = new Map<String,List<List<String>>>();
        for(String image:  imageTypes){
            if(prosTable.get(image) == null)
                prosTable.put(image,new List<List<String>>());
            List<List<String>> prosRow = prosTable.get(image);
            for(String outlet: outletTypes ){
                if(mVariations.get(outlet+image) == null)
                    prosRow.add(new List<String>());
                else
                    prosRow.add(mVariations.get(outlet+image));
            }
        }
        return prosTable;
    } 
}