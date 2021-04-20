/* Filename:    ASI_CRM_CN_PreContractEvalMain_Ctrl.cls
* Author:      Michael Yip (Introv Limited)
* Purpose: 
*
*
* History
* -----------------------------------------------------------------------------
* 2014-02-14   michael.yip@introv.com      Created
* 2014-04-27   stella.sing@introv.com      Modified
* 2014-05-02   stella.sing@introv.com      Modified (Add Paging and Team's Pre-Contract View)
*/

public with sharing class ASI_CRM_CN_PreContractEvalMain_Ctrl {
    
    public ASI_CRM_PreContractEval__c PC {get; set;}
    public List<ASI_CRM_PreContractEval__c> LPreContract {get; set;}
    public List<ASI_CRM_PreContractEval__c> LPreContract_Others {get; set;}
    public List<ASI_CRM_PreContractEval__c> ShowPreContracts {get; set;}
    public string OutletId {set;get;}
    
    public string statusSelected {set;get;}
    public integer counter=0;  //keeps track of the offset
    public integer list_size=10; //sets the page size or number of rows
    public integer total_size{set;get;} //used to show user the total size of the list
    public integer start_index{set;get;}
    public integer end_index{set;get;}
    public integer pageNumber=1;
    public integer totalrecords{set;get;}
    public integer totalpage{set;get;}
    
    //Identify User locale
    public string UserId {set;get;}
    public boolean showCN {set;get;}
    
    public Id precontractId_del {get;set;}
    
    public ASI_CRM_CN_PreContractEvalMain_Ctrl(apexpages.standardController sc){
        ShowPreContracts = new List <ASI_CRM_PreContractEval__c>();
        UserId = UserInfo.getUserId();
        showCN = false;
        statusSelected = 'LPreContract';
        //statusSelected = 'LPreContract_Others';
        //changeStatus();
        init1();
        counter=0;
        //end_index = list_size;
        //start_index=1;
        PC = new ASI_CRM_PreContractEval__c();
        chooseLocale();
    }
    //Choose the right locale for User
    public void chooseLocale(){
        /*User thisUser = [SELECT LanguageLocaleKey FROM User WHERE id = :UserId];
        if (thisUser.LanguageLocaleKey == 'zh_CN'){
            showCN = true;
        }*/
        showCN = UserInfo.getLanguage()=='zh_CN';
    }
    public void init1(){
        system.debug('init1()');
        ShowPreContracts.clear();
        
        total_size = [Select count() from ASI_CRM_PreContractEval__c WHERE CreatedById = :UserInfo.getUserId() ];
        
        LPreContract = [Select name, id, ASI_CRM_CN_Outlet_Chi_Name__c, ASI_CRM_OutletChannel__c, ASI_CRM_CN_Outlet__r.name, ASI_CRM_Status__c, ASI_CRM_Monthly_Contract_Total_Vol_9LC__c, 
                        ASI_CRM_Investment_per_Equiv_Chivas_12Y__c, CreatedDate, Owner.Name, ASI_CRM_Contract_Total__c, 
                        ASI_CRM_CN_New_Contract_Index__c,ASI_CRM_CN_New_Regional_Index__c,ASI_CRM_CN_Last_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,
                        ASI_CRM_CN_Sub_Channel_Chi_Name__c, ASI_CRM_City__c
                        from ASI_CRM_PreContractEval__c WHERE CreatedById = :UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT :list_size OFFSET :counter];
        
        ShowPreContracts = LPreContract;
    }
    public void init2(){
        system.debug('init2()');
        ShowPreContracts.clear();
        string strStatus = 'Shared';
        total_size = [Select count() from ASI_CRM_PreContractEval__c WHERE CreatedById != :UserInfo.getUserId() 
                      AND ASI_CRM_Status__c = :strStatus];
        
        LPreContract_Others = [Select name, id, ASI_CRM_CN_Outlet_Chi_Name__c, ASI_CRM_OutletChannel__c, ASI_CRM_CN_Outlet__r.name, ASI_CRM_Status__c, ASI_CRM_Monthly_Contract_Total_Vol_9LC__c, 
                               ASI_CRM_Investment_per_Equiv_Chivas_12Y__c, CreatedDate, Owner.Name, ASI_CRM_Contract_Total__c,
                               ASI_CRM_CN_New_Contract_Index__c,ASI_CRM_CN_New_Regional_Index__c,ASI_CRM_CN_Last_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c,
                               ASI_CRM_CN_Sub_Channel_Chi_Name__c, ASI_CRM_City__c
                               from ASI_CRM_PreContractEval__c WHERE CreatedById != :UserInfo.getUserId() 
                               AND ASI_CRM_Status__c = :strStatus AND ASI_CRM_Status__c ='Shared'
                               ORDER BY CreatedDate DESC LIMIT :list_size OFFSET :counter];
        
        ShowPreContracts = LPreContract_Others;
    }
    public List<SelectOption> getStatusItems(){
        List<SelectOption> options = new List<SelectOption>();
        if (showCN == true){
            options.add(new SelectOption('1','我的合同试算'));
            options.add(new SelectOption('2','团队的合同试算'));
        }else{
            options.add(new SelectOption('1','My Pre-Contract'));
            options.add(new SelectOption('2','My Team\'s Pre-Contract'));
        }
        return options;
    }
    
    public List<SelectOption> SupplierList {
        get{
            List<ASI_CRM_AccountsAdditionalField__c> listSupplier = [SELECT id, ASI_CRM_Account__c, Name FROM ASI_CRM_AccountsAdditionalField__c 
                                                                     WHERE RecordType.DeveloperName In ('ASI_CRM_Outlet_CN', 'ASI_CRM_TW_KeyAccount', 'ASI_CRM_TW_Wholesaler')
                                                                     AND OwnerId= :UserInfo.getUserID()];
            
            List<SelectOption> supplierList = new List<SelectOption>();
            
            for(ASI_CRM_AccountsAdditionalField__c supplier : listSupplier ){
                supplierList.add(new SelectOption(supplier.id, supplier.Name));
            }
            return supplierList;
        }
    } 
    
    
    
    public void changeStatus(){
        system.debug('changeStatus()');
        counter = 0;
        pageNumber=1;
        if (StatusSelected == '1')
            init1();
        if (StatusSelected == '2')
            init2();
    }
    public PageReference Beginning() { //user clicked beginning
        system.debug('Beginning()');
        counter = 0;
        start_index = 1;
        //end_index = list_size;
        if (StatusSelected == '1')
            init1();
        if (StatusSelected == '2')
            init2();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        system.debug('Previous()');
        //start_index -= list_size;
        //end_index -= list_size;
        counter -= list_size;
        if(counter<0) counter = 0;
        if (StatusSelected == '1')
            init1();
        if (StatusSelected == '2')
            init2();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        system.debug('Next()');
        //start_index += list_size;
        //end_index += list_size;
        counter += list_size;
        if (StatusSelected == '1')
            init1();
        if (StatusSelected == '2')
            init2();
        return null;
    }
    
    public PageReference End() { //user clicked end
        system.debug('End()');
        if (math.mod(total_size, list_size) == 0)
            counter = total_size - list_size + 1;
        else
            counter = total_size - math.mod(total_size, list_size) ;
        if(counter<0) counter = 0;
        //end_index = total_size;
        //start_index = counter + 1;
        if (StatusSelected == '1')
            init1();
        if (StatusSelected == '2')
            init2();
        return null;
    }
    
    public Boolean getDisablePrevious() { 
        //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    public Integer getStartIndex(){
        start_index = counter + 1;
        return start_index;
    }
    public Integer getEndIndex(){
        if (counter + list_size > total_size)
            end_index = total_size;
        else
            end_index = counter + list_size;
        return end_index;
    }
    
    public pageReference Create(){
        if (PC.ASI_CRM_CN_Outlet__c != null){
            pageReference newPage = new pageReference('/apex/ASI_CRM_CN_PreContractEval_Page');
            newPage.setRedirect(true);
            Map<String, String> p = newPage.getParameters();
            p.put('OutletId', PC.ASI_CRM_CN_Outlet__c); 
            return newPage;
        }else{
            PC.addError('Invalid Value: \'Outlet\'');
            //ApexPages.addMessages('Required Field: \'Outlet\'');
            return null;
        }
    }
    
    public void deletePreContract() {
        if(precontractId_del==null) return;
        ASI_CRM_PreContractEval__c record = new ASI_CRM_PreContractEval__c(Id=precontractId_del);
        delete record;
        if (StatusSelected == '1')
            init1();
        if (StatusSelected == '2')
            init2();
    }
        
}