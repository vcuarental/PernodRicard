/*Filename:    ASI_CRM_MY_DBCComparison_Ctl.cls
* Author:      Introv Limited
* Purpose:     DBCA & DBCE COmparision Report
*
*
* History
* -----------------------------------------------------------------------------
* 2018-01               Introv Limited              Created
*/


public with sharing class ASI_CRM_MY_DBCComparison_Ctl {

	private final ASI_TH_CRM_Contract__c MYContract;
    public Integer NumOfMonth {get; set;}
    public datetime currentTime {get; set;} {currentTime = datetime.now();}
    private Id ContractId;
    public Map<Integer, String> mapTableId {get; set;} {mapTableId = new Map<Integer, String>();}
    public List<Integer> tableOutputControl {get;private set;} {tableOutputControl=new List<Integer>{1};}
    
    // Declaration
    public integer COL_PER_PAGE = 5;
    //public List<Integer> TABLE_COL_REPEAT_CONTROL {get; private set;}{TABLE_COL_REPEAT_CONTROL = new List<Integer>(); for(Integer i=1;i<=COL_PER_PAGE;i++){TABLE_COL_REPEAT_CONTROL.add(i);} }
    public Map<integer, Map<integer, Map<integer, String>>> mapStrTblDBCAData{get; set;} {mapStrTblDBCAData = new Map<integer, Map<integer, Map<integer, String>>>{}; }
    public Map<integer, Map<integer, Map<integer, String>>> mapStrTblDBCEData{get; set;} {mapStrTblDBCEData = new Map<integer, Map<integer, Map<integer, String>>>{}; }
    public ASI_CRM_MY_ContractDBCComparison clsContractDBC;
    public string strTitle {get; set;} {strTitle = 'Direct Brand Contribution (DBC) Actual VS Target';}
    public Map<Integer, String> mapIndexCrossSKUTitle {get;private set;} {mapIndexCrossSKUTitle= new Map<Integer, String>();}

    // Declaration - End
    public static Map<String, Set<id>> mapMYGroup_user = ASI_CRM_MY_Function.getMYGroup();

    
    public ASI_CRM_MY_DBCComparison_Ctl(ApexPages.StandardController stdController) {
        this.MYContract = (ASI_TH_CRM_Contract__c)stdController.getRecord();
        if (MYContract !=null){
            ContractId =MYContract.Id;
        }


        boolean isGroupMember = False;
        
        
        //if(ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_DBC_Actual') == FALSE ){
        //    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
        //}else{
              
            List <ASI_TH_CRM_Contract__c> c = [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE id =:ContractId];  
            NumOfMonth = c[0].ASI_TH_CRM_Start_Date__c.monthsBetween(c[0].ASI_TH_CRM_End_Date__c) + 1;
    
            if(ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_DBC_IGC'))
                isGroupMember = TRUE;
                            
            clsContractDBC = new ASI_CRM_MY_ContractDBCComparison();
            mapStrTblDBCAData = clsContractDBC.renderCompareDataTable(ContractId, COL_PER_PAGE, 'DBCa', isGroupMember, FALSE);
            mapIndexCrossSKUTitle = clsContractDBC.mapIndexCrossSKUTitle;
            mapStrTblDBCEData = clsContractDBC.renderCompareDataTable(ContractId, COL_PER_PAGE, 'DBCe', isGroupMember, FALSE);

            system.debug('mapIndexCrossSKUTitle='+mapIndexCrossSKUTitle);
            
            Integer tableSize = mapStrTblDBCAData.size() - 1;
            
            for(Integer i = 0; i <= tableSize; i++){
                mapTableId.put(i, 'TABLE' + string.valueof(i));
            }
        
        //}
        
    }

    
}