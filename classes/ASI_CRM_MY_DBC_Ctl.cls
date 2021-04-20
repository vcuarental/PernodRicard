/*Filename:    ASI_CRM_MY_DBC_Ctl.cls
* Author:      Daniel WONG (Introv Limited)
* Purpose:     DBC/E
*
*
* History
* -----------------------------------------------------------------------------
* 2015-01-20        daniel.wong@introv.com        Created
*/

public without sharing class ASI_CRM_MY_DBC_Ctl{

    private ApexPages.StandardController standardController {get;set;}
    public Integer NumOfMonth {get; set;}
    public datetime currentTime {get; set;} {currentTime = system.now();}
    public String Type {get; set;}
    private Id ContractId{
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }
    public Map<Integer, String> mapTableId {get; set;} {mapTableId = new Map<Integer, String>();}
    
    // Declaration
    public integer COL_PER_PAGE = 8;
    public Map<integer, Map<integer, Map<integer, String>>> mapStrTblData{get; set;} {mapStrTblData = new Map<integer, Map<integer, Map<integer, String>>>{}; }
    public ASI_CRM_MY_ContractDBC clsContractDBC;
    public string strTitle {get; set;} {strTitle = 'Direct Brand Contribution (DBC) Actual';}
    // Declaration - End
    public static Map<String, Set<id>> mapMYGroup_user = ASI_CRM_MY_Function.getMYGroup();
        
    public ASI_CRM_MY_DBC_Ctl(ApexPages.StandardController standardController){
        this.standardController = standardController;
        boolean isGroupMember = False;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        Type = params.get('Type');
        
        if(ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_DBC_Actual') == FALSE && Type == 'DBCa'){
            if(Test.isRunningTest()){
                if(Type == 'DBCe')
                    strTitle = 'Direct Brand Contribution (DBC) Evaluation';
                    
                List <ASI_TH_CRM_Contract__c> c = [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE id =:contractId];  
                NumOfMonth = c[0].ASI_TH_CRM_Start_Date__c.monthsBetween(c[0].ASI_TH_CRM_End_Date__c) + 1;
        
                if(ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_DBC_IGC'))
                    isGroupMember = TRUE;
                                
                clsContractDBC = new ASI_CRM_MY_ContractDBC();
                if(Type == 'DBCe'){
                    mapStrTblData = clsContractDBC.renderCompareDataTable(ContractId, COL_PER_PAGE, Type, isGroupMember, false);
                }
                else{
                    mapStrTblData = clsContractDBC.renderDataTable(ContractId, COL_PER_PAGE, Type, isGroupMember);    
                }
                
                
                Integer tableSize = mapStrTblData.size() - 1;
                
                for(Integer i = 0; i <= tableSize; i++){
                    mapTableId.put(i, 'TABLE' + string.valueof(i));
                }
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Insufficient Privileges: You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
            }
        }else{
            if(Type == 'DBCe')
                strTitle = 'Direct Brand Contribution (DBC) Evaluation';
                
            List <ASI_TH_CRM_Contract__c> c = [SELECT id, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE id =:contractId];  
            NumOfMonth = c[0].ASI_TH_CRM_Start_Date__c.monthsBetween(c[0].ASI_TH_CRM_End_Date__c) + 1;
    
            if(ASI_CRM_MY_Function.isGroupMember(UserInfo.getUserId(), 'ASI_CRM_MY_DBC_IGC'))
                isGroupMember = TRUE;
                            
            clsContractDBC = new ASI_CRM_MY_ContractDBC();
            if(Type == 'DBCe'){
                mapStrTblData = clsContractDBC.renderCompareDataTable(ContractId, COL_PER_PAGE, Type, isGroupMember, false);
            }
            else{
            	mapStrTblData = clsContractDBC.renderDataTable(ContractId, COL_PER_PAGE, Type, isGroupMember);    
            }
            
            
            Integer tableSize = mapStrTblData.size() - 1;
            
            for(Integer i = 0; i <= tableSize; i++){
                mapTableId.put(i, 'TABLE' + string.valueof(i));
            }
        }
    }
}