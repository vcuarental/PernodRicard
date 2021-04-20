public class ASI_CRM_CN_EditHeavyPaymentHeaderCtrl {
    
    
    public ASI_TH_CRM_PaymentRequest__c PH {set;get;} {PH= new ASI_TH_CRM_PaymentRequest__c();} 
    public string PageId {set;get;}
    
    public boolean UpsertPermission {get;set;}{UpsertPermission=true;}
    public boolean ContractDateKey {get;set;}{ContractDateKey=true;}
    public String Msg {get;set;} {Msg='';}
    public String paymentViewPageName {get;set;} {paymentViewPageName='';}

    public ASI_CRM_CN_EditHeavyPaymentHeaderCtrl(ApexPages.StandardController controller) {
        String promotionType = '';
        Boolean twondKey=false;
        if(ApexPages.currentPage().getParameters().get('id') != null ){ 
            //edit 
            this.PH = (ASI_TH_CRM_PaymentRequest__c)controller.getRecord();     
            PageId = PH.id;
            
            if (PageId != null){
                list <ASI_TH_CRM_PaymentRequest__c> HeaderList  = new list <ASI_TH_CRM_PaymentRequest__c>();
                
                //Get Header information
                if (PageId != null){
                    HeaderList = [SELECT id, name,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c, ASI_CRM_CN_Payable_Amount__c, ASI_CRM_CN_Other_Reason__c, ASI_TH_CRM_Status__c, ASI_CRM_CN_Bottle_Collection_Rate__c,  ASI_CRM_CN_BRSF_End_Date__c, ASI_CRM_CN_BRSF_Start_Date__c,ASI_CRM_CN_Channel__c, ASI_CRM_CN_Currency__c, ASI_CRM_CN_Last_Payment__c, ASI_CRM_CN_Last_Year_Payment__c,ASI_CRM_CN_Division__c,ASI_CRM_CN_OutletWS__c, ASI_CRM_CN_Payment_Raised_Date__c, ASI_CRM_CN_Payment_Type__c, ASI_CRM_CN_PO_End_Date__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_Volume_Option__c,ASI_CRM_CN_Promotion_Type__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.ASI_CRM_Region_Code__c, ASI_CRM_CN_Reference_Code__c,ASI_TH_CRM_Total_Amount__c, ASI_CRM_CN_Total_Other_Amount__c, ASI_CRM_CN_PO_Version_Latest__c, ASI_CRM_CN_Overpayment_Reason__c,ASI_CRM_CN_Total_BRSF_Amount__c,ASI_CRM_CN_Reason_For_Business_License__c, ASI_CRM_CN_Business_License_Qualify__c ,ASI_CRM_CN_Total_PSF_Amount__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.RecordType.DeveloperName,ASI_CRM_CN_Adjustment__c, ASI_CRM_CN_No_of_Month__c   , ASI_CRM_CN_Total_Payment__c , ASI_CRM_CN_Overpayment_Comment__c,ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Total_Contract_Amount__c, ASI_CRM_CN_Total_BRSF_Actual_Amount__c,ASI_TH_CRM_Contract__r.ASI_TH_CRM_Contract_Status__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_TH_CRM_Contract_Status__c  ,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Last_PO_version__r.ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Description__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Modification__c,ASI_TH_CRM_Contract__r.ASI_CRM_CN_Status__c, ASI_CRM_New_FY_Payment__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Greater_Region_Code__c, ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c
                                  FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :PageId];
                    
                }
                if (HeaderList.size()> 0){
                    this.PH = HeaderList[0];
                    promotionType = HeaderList[0].ASI_TH_CRM_Contract__r.ASI_TH_CRM_Promotion_Type__c;
                    twondKey=HeaderList[0].ASI_TH_CRM_Contract__r.ASI_CRM_CN_Is_2nd_KPI_PO__c;
                }
                init();
            }
            
        }else{
            //create payment 
            String contractId = ApexPages.currentPage().getParameters().get('contractid');            
            if (String.isNotEmpty(contractId)) {
                
                ASI_TH_CRM_Contract__c contract = [
                    Select ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_PaymentRequestNumber__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_Version__c, ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_TH_CRM_Promotion_Type__c
                                                   from ASI_TH_CRM_Contract__c where id =:contractId limit 1];
                Decimal nextNumber = contract.ASI_CRM_CN_PaymentRequestNumber__c == null?1:contract.ASI_CRM_CN_PaymentRequestNumber__c+1;
                PH = new ASI_TH_CRM_PaymentRequest__c (ASI_CRM_CN_OutletWS__c = contract.ASI_CRM_CN_Outlet_WS__c,
                                                       name=contract.ASI_CRM_CN_PO_No__c + '-'+digit_formatting(3,nextNumber ),
                                                       recordtypeid=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'),
                                                       ASI_CRM_CN_PO_Version__c = contract.ASI_CRM_CN_PO_Version__c,
                                                       ASI_CRM_CN_Bottle_Collection_Rate__c = contract.ASI_CRM_CN_Bottle_Collection_Rate__c,
                                                       ASI_CRM_CN_Adjustment__c = 100);
                PH.ASI_TH_CRM_Contract__c = (id)contractId;

                // Set paymentViewPageName by contract's promotion type
                promotionType = contract.ASI_TH_CRM_Promotion_Type__c;
                twondKey=contract.ASI_CRM_CN_Is_2nd_KPI_PO__c;
            }
            
        }
        if (promotionType == 'Heavy Contract On') {
            paymentViewPageName = 'ASI_CRM_CN_HeavyPaymentHeader_Page';
            if(twondKey){
                paymentViewPageName = 'ASI_CRM_CN_HeavyPaymentHeader2nd_Page';
            }
        }
        if (promotionType == 'TOT/MOT Contract') {
            paymentViewPageName = 'ASI_CRM_CN_Edit_OffPR_DetailsPage';
        }

    }
    
    
    
    public void init(){
        
    }
    
    
    
    public boolean ValdationChecking(){
        Boolean isProcess = true;
        
        if(PH.ASI_TH_CRM_Contract__c == Null){
            msg += ' Please input Contract.' + '</br>';
            isProcess=false;
        }
        
        
        if(PH.ASI_CRM_CN_OutletWS__c == null){
            msg += ' Please input Outlet/WS.' + '</br>';
            isProcess=false;
        }
        
        if(PH.ASI_CRM_CN_Payment_Type__c == Null ){
            msg += ' Please select Payment Type.' + '</br>';
            isProcess=false;
        }
        
        if(PH.ASI_CRM_CN_Description__c == Null || PH.ASI_CRM_CN_Description__c == ''){
            msg += ' Please input Description.' + '</br>';
            isProcess=false;
        }
        
        
        
        return isProcess;
    }
    
    
    
    
    public PageReference UpdateRecord(){
        
        if (PageId != null){
            update PH;
        }else{
            if(!ValdationChecking()){
                UpsertPermission=false;
                return null;
            }
            
            ASI_TH_CRM_Contract__c contract = [SELECT ASI_CRM_CN_Is_2nd_KPI_PO__c,ASI_CRM_CN_Last_PO_version__r.CreatedDate,CreatedDate,
                                                    ASI_CRM_CN_PO_No__c,ASI_CRM_New_FY_PO__c , ASI_TH_CRM_Promotion_Type__c, ASI_CRM_CN_Is_Aggregation_Batch_Run__c
                                               FROM ASI_TH_CRM_Contract__c 
                                               WHERE id =:PH.ASI_TH_CRM_Contract__c limit 1];
            if(contract.ASI_CRM_CN_Is_2nd_KPI_PO__c && ContractDateKey&&contract.ASI_CRM_CN_Last_PO_version__r.CreatedDate!=null){
                if(Date.valueOf(contract.ASI_CRM_CN_Last_PO_version__r.CreatedDate).daysBetween(Date.today())>=90){
                    
                    ContractDateKey=false;
                    return null;
                }
            }else if(contract.ASI_CRM_CN_Is_2nd_KPI_PO__c && ContractDateKey&&Date.valueOf(contract.CreatedDate).daysBetween(Date.today())>=90){
                
                ContractDateKey=false;
                return null;
            }

            string tempPHName_seq = '';
            Integer tmpPHSeq = 0;
            Integer countPH = 0;
            List<ASI_TH_CRM_PaymentRequest__c> listOtherPH = [SELECT id, Name FROM ASI_TH_CRM_PaymentRequest__c 
            WHERE ASI_TH_CRM_Contract__c =:PH.ASI_TH_CRM_Contract__c AND ASI_CRM_CN_Is_Dolphin_Auto_Payment__c = false ORDER BY Name Desc];
            if(listOtherPH != null && listOtherPH.size() > 0){
                for(ASI_TH_CRM_PaymentRequest__c tmpPH : listOtherPH){
                    string[] strName = tmpPH.Name.split('-');
                    if(strName.size() > 1){
                        if(strName[1].isNumeric()){
                            if(Integer.valueOf(strName[1]) > tmpPHSeq)
                                tmpPHSeq = Integer.valueOf(strName[1]);
                        }
                    }
                    countPH += 1;
                } 
            }
            
            if(tmpPHSeq == 0 && countPH == 0){
                tempPHName_seq = '001';
            }else{
                if(tmpPHSeq > countPH){
                    tempPHName_seq = digit_formatting(3, tmpPHSeq + 1);
                }else{
                    tempPHName_seq = digit_formatting(3, countPH + 1);
                }
            }
            
            PH.Name = contract.ASI_CRM_CN_PO_No__c + '-' + tempPHName_seq; 
            PH.ASI_CRM_New_FY_Payment__c = contract.ASI_CRM_New_FY_PO__c;
            
            try{
                upsert PH;
                PageId = PH.id;

                if (contract.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract' 
                    && !contract.ASI_CRM_CN_Is_Aggregation_Batch_Run__c
                    && getOutletIds(contract.Id).size() > ASI_CRM_CN_OffContractUtilitiesClass.outletThreshold()) { 

                    Database.executeBatch(new ASI_CRM_CN_OffVolumeDeleteJob(new Set<Id> {contract.Id}), 2000);
                }

            }catch(Exception exp){
                msg += exp.getMessage() + '</br>';
                UpsertPermission=false;
                return null;
            }
        }
        if (String.isNotEmpty(paymentViewPageName)) {
            PageReference ab = new PageReference('/apex/' + paymentViewPageName);
            ab.getParameters().put('id',PageId);
            ab.setRedirect(true);
            return ab;
        } else {
            // Rely on Payment Redirect Page to redirect to customer payment page
            PageReference ab = new PageReference('/' + PageId);
            ab.setRedirect(true);
            return ab;
        }
    }

    /**
     * Get all outletIds, including contract's outlet and its covered outlets
     *
     * @param contractId
     *
     * @return Set of outlet Ids
     */
    public Set<Id> getOutletIds(Id contractId) {
        Set<Id> outletIds = new Set<Id>();
        //Getting Outlet Id including 'Covered Outlet'
        for (ASI_CRM_CN_Covered_Outlet__c o : [SELECT Id, ASI_CRM_CN_Outlet__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :contractId]) {
            outletIds.add(o.ASI_CRM_CN_Outlet__c);
        }
        outletIds.add(PH.ASI_CRM_CN_OutletWS__c);
        return outletIds;
    }
    
    public PageReference doCancel(){
        String retURL = '';
        retURL = ApexPages.currentPage().getParameters().get('retURL'); 
        
        String contractid = '';
        contractid = ApexPages.currentPage().getParameters().get('contractid');
        
        String pid = '';
        pid = ApexPages.currentPage().getParameters().get('id');   
        
        PageReference redirect;
        
        if(retURL != null && retURL != ''){
            redirect = new PageReference(retURL); 
        }        
        else
        {
            if(contractid != null && contractid != ''){
                
                redirect = new PageReference('/' + contractid); 
            }else{    
                if(pid != null && pid != ''){
                    
                    redirect = new PageReference('/apex/' + paymentViewPageName + '?id=' + pid);
                }
                else{    
                    redirect = new PageReference('/apex/' + paymentViewPageName);
                }                
            }
        }
        
        redirect.setRedirect(true); 
        return redirect;
    }
    
    
    
    
    //****************************************************************************************
    public String digit_formatting(Integer digit,Decimal numbers){
        Decimal base=Math.pow(10,(digit-1));
        String formate='';
        Decimal counter = numbers/base;
        if(counter>1)formate= String.valueOf(numbers);
        else{ 
            counter=0;
            for(Integer dec=Integer.valueOf(numbers);dec>0;dec=dec/10){
                counter++;
            }
            for(Integer a=0;a<digit-counter;a++){
                formate+='0';
            }
            
            formate +=numbers;
        }
        return formate;
    }
    
    
}