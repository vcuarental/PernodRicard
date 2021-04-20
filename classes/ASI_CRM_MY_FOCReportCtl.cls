public with sharing class ASI_CRM_MY_FOCReportCtl{
        
    private ApexPages.StandardController standardController {get;set;}
    private Id CustomerId{
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }

    public Map<String, Map<String, List<ASI_CRM_MY_CalculatedFOC.FOCdata>>> allMapPaging{get;set;} {allMapPaging = new Map<String, Map<String, List<ASI_CRM_MY_CalculatedFOC.FOCdata>>>();}
    
    public Map<String, Map<String, List<ASI_CRM_MY_CalculatedFOC.FOCdata>>> mapOfData(List<ASI_CRM_MY_CalculatedFOC.FOCdata> focData){
        Map<String, Map<String, List<ASI_CRM_MY_CalculatedFOC.FOCdata>>> mapPaging = new Map<String, Map<String, List<ASI_CRM_MY_CalculatedFOC.FOCdata>>>();
        Map<String, List<ASI_CRM_MY_CalculatedFOC.FOCdata>> mapTemp = new Map<String, List<ASI_CRM_MY_CalculatedFOC.FOCdata>>();
        List<ASI_CRM_MY_CalculatedFOC.FOCdata> listTemp = new List<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        
        for(ASI_CRM_MY_CalculatedFOC.FOCdata i : focData){
            listTemp = new List<ASI_CRM_MY_CalculatedFOC.FOCdata>();
            if(mapPaging.get(i.PeriodKey) != NULL){
                mapTemp = mapPaging.get(i.PeriodKey);
                if(mapTemp.get(i.CustomerNo) != NULL){
                    listTemp = mapTemp.get(i.CustomerNo);
                }
                listTemp.add(i);
                mapTemp.put(i.CustomerNo, listTemp);
                mapPaging.put(i.PeriodKey, mapTemp);
            }else{
                listTemp.add(i);
                mapTemp.put(i.CustomerNo, listTemp);
                mapPaging.put(i.PeriodKey, mapTemp);
            }
        }
        
        system.debug('-----------------------------------------------mapPaging : ' + mapPaging);
        return mapPaging;
    }
    
    public ASI_CRM_MY_FOCReportCtl(ApexPages.StandardController standardController){
        this.standardController = standardController; //Customer ID
        goGenFOCRpt(CustomerId);
        
        system.debug('----CustomerId----' + CustomerId);
    }
    
    public void goGenFOCRpt(id idOutlet) {
        list<ASI_CRM_MY_CalculatedFOC.FOCdata> lstFOC = new list<ASI_CRM_MY_CalculatedFOC.FOCdata>();
        ASI_CRM_MY_CalculatedFOC clsFOC = new ASI_CRM_MY_CalculatedFOC();
        set<id> setCustomer = new set<id>();
        
        setCustomer.add(idOutlet);
        /*for(ASI_CRM_AccountsAdditionalField__c i : [
            SELECT Id 
            FROM ASI_CRM_AccountsAdditionalField__c 
            WHERE ASI_CRM_CN_Parent_Outlet__c = :idOutlet
            AND ASI_CRM_CN_Inactive_Flag__c = FALSE
        ]){
            //setCustomer.add(i.id);
        }*/
        
        date genDate = system.today();
        //date genDate = date.newinstance(2014, 07, 25); // Daniel : it is set for Testing
        
        lstFOC = clsFOC.genFOC_List(setCustomer, genDate);
        
        system.debug('---------------------------------------------------lstFOC: ' + lstFOC);
        allMapPaging = mapOfData(lstFOC);
    }
    

}