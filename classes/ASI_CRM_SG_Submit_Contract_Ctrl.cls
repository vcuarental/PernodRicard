public class ASI_CRM_SG_Submit_Contract_Ctrl {
    @AuraEnabled
    public static String preSubmitValidate(string recordId){
        try{
        ASI_TH_CRM_Contract__c contractRec = [Select Id,ASI_CRM_Ad_hoc_Contract__c,Name,ASI_CRM_Converted_From__c,ASI_CRM_Type__c,ASI_CRM_Is_Proposal__c, ASI_CRM_Contract_Exist_Before_RTM__c, RecordType.Name, RecordType.DeveloperName, ASI_TH_CRM_Start_Date__c,ASI_TH_CRM_Contract_Status__c,ASI_CRM_Remarks__c,ASI_TH_CRM_End_Date__c,ASI_CRM_Total_Cash_Sponsorship_Cash__c,ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
            if(!contractRec.ASI_CRM_Contract_Exist_Before_RTM__c && contractRec.ASI_CRM_Type__c=='Partner'){
               List<ASI_CRM_ContractTarget__c> contractTargetsWithPreset = [SELECT Id, ASI_CRM_TargetCase__c,  ASI_CRM_Minimum_Sales_Cases__c FROM ASI_CRM_ContractTarget__c WHERE ASI_CRM_Contract__c = :recordId  AND ASI_CRM_SKU__r.ASI_CRM_Preset__c = TRUE];
               Boolean isatLeast1Ct = false;
                if(contractTargetsWithPreset != null && contractTargetsWithPreset.size()>0){
                    for(ASI_CRM_ContractTarget__c ctt : contractTargetsWithPreset){
                        if(ctt.ASI_CRM_TargetCase__c >= ctt.ASI_CRM_Minimum_Sales_Cases__c){
                            isatLeast1Ct = true;
                            break;
                        }
                    }
                }
                if(! isatLeast1Ct && !contractRec.ASI_CRM_Ad_hoc_Contract__c){
                    return 'For Partner contract type, please select at least one SKU from the preset SKU list with Target case >= Minimum case.';
                }
                List<ASI_CRM_ContractTarget__c> contractTargetsWithKeyBrand = [SELECT Id, ASI_CRM_TargetCase__c,  ASI_CRM_Minimum_Sales_Cases__c FROM ASI_CRM_ContractTarget__c WHERE ASI_CRM_Contract__c = :recordId AND ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_CRM_Key_Account_Brand__c = TRUE AND ASI_CRM_SKU__r.ASI_CRM_Preset__c = TRUE];
                integer count1 = 0;
                if(contractTargetsWithKeyBrand != null && contractTargetsWithKeyBrand.size()>0){
                    for(ASI_CRM_ContractTarget__c ctt : contractTargetsWithKeyBrand){
                        if(ctt.ASI_CRM_TargetCase__c >= ctt.ASI_CRM_Minimum_Sales_Cases__c){
                            count1++;
                        }
                    }
                }
                if(count1 >= 2){
                    return 'Confirm';
                }else{
                    return 'Success';
                }
            }else{
                return 'Success';
            }            
        }catch(Exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static resultWrapper submitValidate(String recordId){
        ResultWrapper wrp = new resultWrapper();
        ASI_TH_CRM_Contract__c contractRec = [Select Id,ASI_CRM_Ad_hoc_Contract__c,Name,ASI_CRM_Converted_From__c,ASI_CRM_Type__c,ASI_CRM_Is_Proposal__c, ASI_CRM_Contract_Exist_Before_RTM__c, RecordType.Name, RecordType.DeveloperName, ASI_TH_CRM_Start_Date__c,ASI_TH_CRM_Contract_Status__c,ASI_CRM_Remarks__c,ASI_TH_CRM_End_Date__c,ASI_CRM_Total_Cash_Sponsorship_Cash__c,ASI_CRM_CN_Outlet_WS__c from ASI_TH_CRM_Contract__c where Id = :recordId limit 1];
        if(!contractRec.ASI_CRM_Contract_Exist_Before_RTM__c && contractRec.ASI_CRM_Type__c=='Key Account'){
            List<ASI_CRM_ContractTarget__c> contractTargetsWithKeyBrand = [SELECT Id, ASI_CRM_TargetCase__c,  ASI_CRM_Minimum_Sales_Cases__c FROM ASI_CRM_ContractTarget__c WHERE ASI_CRM_Contract__c = :recordId AND ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_CRM_Key_Account_Brand__c = TRUE AND ASI_CRM_SKU__r.ASI_CRM_Preset__c = TRUE];
            integer cttLength = 0;
            if(contractTargetsWithKeyBrand != null && contractTargetsWithKeyBrand.size()>0){
                
                for(ASI_CRM_ContractTarget__c ctt : contractTargetsWithKeyBrand){
                    if(ctt.ASI_CRM_TargetCase__c >= ctt.ASI_CRM_Minimum_Sales_Cases__c){
                        cttLength ++;
                    }
                }
            }
            if(cttLength < 2 && !contractRec.ASI_CRM_Ad_hoc_Contract__c){
                wrp.msg = 'For Key Account contract type, please select at least two SKUs of Chivas, Martell or Glenlivet from the preset SKU list with Target case >= Minimum case.';
                return wrp;
            }
        }
        if(contractRec.ASI_CRM_Is_Proposal__c && contractRec.ASI_CRM_Contract_Exist_Before_RTM__c){
            wrp.msg = 'Only RTM Proposal can be submitted, please delete this proposal and create an RTM Proposal for the outlet.';
            return wrp;
        }
        else if (contractRec.ASI_CRM_CN_Outlet_WS__c == null || contractRec.ASI_TH_CRM_Start_Date__c == null ||
            contractRec.ASI_TH_CRM_End_Date__c == null || contractRec.ASI_CRM_Remarks__c== '') {
                wrp.msg = 'Please input all required fields (Outlet, Remarks, Start and End Date) before submit.';
                return wrp;
        } 
        
        List<ASI_CRM_ContractTarget__c> detailRecords= [Select Id from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c = :recordId];
        if (detailRecords == null || detailRecords.size() <= 0){
            wrp.msg = 'No Contract Target lines! You cannot submit for approval.';
            return wrp;
        }
        List<AggregateResult> cashScheduleRecords = [Select sum(ASI_CRM_Sponsorship__c) totalCash from ASI_CRM_Payment_Schedule__c where ASI_CRM_Contract__c = :recordId and ASI_CRM_Type__c = 'Cash Sponsorship' and recordtype.developername = 'ASI_CRM_SG_Payment_Schedule'];
        Decimal totalCashSchedule=0.0;
        if(cashScheduleRecords != null && cashScheduleRecords.size()>0){
 			totalCashSchedule = cashScheduleRecords[0].get('totalCash') == null ? 0.0 : (Decimal)cashScheduleRecords[0].get('totalCash');
        }
       
        Decimal totalCashContracted = contractRec.ASI_CRM_Total_Cash_Sponsorship_Cash__c == null ? 0.0 : contractRec.ASI_CRM_Total_Cash_Sponsorship_Cash__c;
         If (totalCashSchedule != totalCashContracted){
			wrp.msg = 'Total cash payment amount in Payment Schedule should be an exact match with the Total Cash Sponsorship Amount.';
			return wrp;		 
         }
        List<AggregateResult> contractScheduleRecords = [Select sum(ASI_CRM_Sponsorship__c) totalContract from ASI_CRM_Payment_Schedule__c where ASI_CRM_Contract__c = :recordId and ASI_CRM_Type__c = 'Contract Sponsorship' and recordtype.developername = 'ASI_CRM_SG_Payment_Schedule'];
      system.debug('@#debugg'+contractScheduleRecords);
        Decimal totalContractSchedule = 0.0;
        if(contractScheduleRecords != null && contractScheduleRecords.size()>0){
            totalContractSchedule = contractScheduleRecords[0].get('totalContract') == null ? 0.0 : (Decimal)contractScheduleRecords[0].get('totalContract');
        }
        List<AggregateResult>  contractTargetRecords = [Select sum(ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c) totalContract from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c = :recordId and recordtype.developername = 'ASI_CRM_SG_Contract_Target'];
        Decimal totalContractContracted = 0.0;
        if(contractTargetRecords != null && contractTargetRecords.size()>0){
            totalContractContracted = contractTargetRecords[0].get('totalContract') == null ? 0.0 : (Decimal)contractTargetRecords[0].get('totalContract');
        }

        if (totalContractSchedule != totalContractContracted){
            wrp.msg = 'Total contract sponsorship cases in Payment Schedule should be an exact match with the Total Contract Sponsorship / Target Incentive cases.';
        	return wrp;
        }
        else if (contractRec.ASI_TH_CRM_Contract_Status__c == 'Draft' || contractRec.ASI_TH_CRM_Contract_Status__c== 'Contract Rejected' || contractRec.ASI_TH_CRM_Contract_Status__c == 'Proposal Rejected'){
			try {
				String recordtype = contractRec.RecordType.Name == 'ASI CRM SG 1. Proposal' ? 'ASI_CRM_SG_Proposal_Read_Only' : 'ASI_CRM_SG_Contract_Read_Only';
				String originalContractName1 = ContractRec.Name;
				String originalContractName = contractRec.RecordType.Name == 'ASI CRM SG 1. Proposal' ? originalContractName1.substring(0,17) : originalContractName1.substring(0,15);
				String contractStatus = contractRec.RecordType.Name == 'ASI CRM SG 1. Proposal' ? 'Proposal Approved' : 'Contract Approved';
                String revisingContractArrayQuery = 'SELECT Id from ASI_TH_CRM_Contract__c where recordtype.developername = \'' + recordtype + '\' and name like \'' + originalContractName + '%\' and ASI_TH_CRM_Contract_Status__c = \'' + contractStatus + '\' Limit 1';
                List<ASI_TH_CRM_Contract__c> revisingContractArray =Database.query(revisingContractArrayQuery);
				String lastversion = '';
                if (revisingContractArray.size()>0){
                	lastversion = revisingContractArray[0].Id;
                }
                else if (contractRec.ASI_CRM_Converted_From__c != null){
					lastversion = contractRec.ASI_CRM_Converted_From__c;
				}
				ASI_TH_CRM_Contract__c contractToUpdate = new ASI_TH_CRM_Contract__c();
				contractToUpdate.Id = contractRec.Id;
				contractToUpdate.ASI_CRM_Sys_Allow_Submit_Approval__c = true;
                update contractToUpdate;
                wrp.msg = 'Success';
                wrp.lv = lastversion ;
                return wrp;
		}catch(Exception e){
            wrp.msg = e.getMessage();
            return wrp;
        }
        }else{
            wrp.msg = 'Cannot submit at this stage.';
            return wrp;    
        }
    }    
    public class resultWrapper{
        @AuraEnabled public String msg{get;set;}
        @AuraEnabled public String lv{get;set;}
    }
}