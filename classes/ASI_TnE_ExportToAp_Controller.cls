public without sharing class ASI_TnE_ExportToAp_Controller {
    
    public List<ASI_TnE_ClaimHeader__c> claimHeaderList  {get; set;}
    public ASI_TnE_ClaimHeader__c claimHeaderInstance    {get; set;}
    public Date glDate                                   {get; set;}
    public boolean isFinanceUser {get;set;}
    public boolean isSuccess {get;set;}
    public String country {get;set;}
    
    public ID reportID {get;set;}
    
    //HK Only
    public ID reportHSBCID {get;set;}
    public ID reportAMEXID {get;set;}
    
    public ID afterSyncReportID {get;set;}
    
    //HK Only
    public ID afterSyncReportHSBCID {get;set;}
    public ID afterSyncReportAMEXID {get;set;}
    
    public boolean isHSBCClicked {get;set;}
    public boolean isAMEXClicked {get;set;}
    
    public Set<String> tneTypeFilter {get;set;}
    // DC - 01/28/2016 - Marked as test visible to access in test class.
    @testVisible String developerNameFilter;
    
    public ASI_TnE_ExportToAp_Controller() {
        claimHeaderInstance = new ASI_TnE_ClaimHeader__c();
        isSuccess = false;
        developerNameFilter = '';
        this.isFinanceUser = true;
        String reportDeveloperName = 'ASI_TnE_SG_Corp_Card_for_AP_Sync';
        String afterSyncReportDeveloperName = 'ASI_TnE_SG_Corp_Card_after_AP_Sync';
        
        isHSBCClicked = false;
        isAMEXClicked = false;
        
        //HK Only
        String reportDeveloperHSBCName = 'ASI_TnE_HK_Corp_Card_HSBC_for_AP_Sync';
        String reportDeveloperAMEXName = 'ASI_TnE_HK_Corp_Card_AMEX_for_AP_Sync';
        String afterSyncReportDeveloperHSBCName = 'ASI_TnE_HK_Corp_Card_HSBC_after_AP_Sync';
        String afterSyncReportDeveloperAMEXName = 'ASI_TnE_HK_Corp_Card_AMEX_after_AP_Sync';
        
        country = '';
        tneTypeFilter = new Set<String>();
        if (retrieveFinanceState('ASI_TnE_TW_Finance_Users')) {
            developerNameFilter = 'ASI_TnE_TW%';
            reportDeveloperName = 'ASI_TnE_TW_Corp_Card_for_AP_Sync';
            afterSyncReportDeveloperName = 'ASI_TnE_TW_Corp_Card_after_AP_Sync';
            country = 'TW';
            tneTypeFilter.add('Corp Card');
        } else if(retrieveFinanceState('ASI_TnE_HK_Finance_Users')) {
            developerNameFilter = 'ASI_TnE_HK%';
            reportDeveloperName = 'ASI_TnE_HK_Corp_Card_for_AP_Sync';
            afterSyncReportDeveloperName = 'ASI_TnE_HK_Corp_Card_after_AP_Sync';
            country = 'HK';
            tneTypeFilter.add('Corp Card');
            
            List<Report> reportListHSBC = [Select ID from Report where DeveloperName = : reportDeveloperHSBCName];
            if(reportListHSBC.size() > 0) {
               reportHSBCID = reportListHSBC.get(0).id; 
            }
            
            List<Report> reportListAMEX = [Select ID from Report where DeveloperName = : reportDeveloperAMEXName ];
            if(reportListAMEX.size() > 0) {
               reportAMEXID = reportListAMEX.get(0).id; 
            }
            
            
            List<Report> reportListAfterSyncHSBC = [Select ID from Report where DeveloperName = : afterSyncReportDeveloperHSBCName ];
            if(reportListAfterSyncHSBC.size() > 0) {
                afterSyncReportHSBCID = reportListAfterSyncHSBC.get(0).id;
            }
            
            List<Report> reportListAfterSyncAMEX = [Select ID from Report where DeveloperName = : afterSyncReportDeveloperAMEXName];
            if(reportListAfterSyncAMEX.size() > 0) {
                afterSyncReportAMEXID = reportListAfterSyncAMEX.get(0).id;
            }
            
        } else if (retrieveFinanceState('ASI_TnE_SG_Finance_Users')) {
            developerNameFilter = 'ASI_TnE_SG%';
            reportDeveloperName = 'ASI_TnE_SG_Corp_Card_for_AP_Sync';
            afterSyncReportDeveloperName = 'ASI_TnE_SG_Corp_Card_after_AP_Sync';
            country = 'SG';
            tneTypeFilter.add('Corp Card');
            tneTypeFilter.add('Out of Pocket');
            tneTypeFilter.add('Cash Advance');
        } else if (retrieveFinanceState('ASI_TnE_TH_Finance_Users')) {
            developerNameFilter = 'ASI_TnE_TH%';
            reportDeveloperName = 'ASI_TnE_TH_Corp_Card_for_AP_Sync';
            afterSyncReportDeveloperName = 'ASI_TnE_TH_Corp_Card_after_AP_Sync';
            country = 'TH';
            tneTypeFilter.add('Corp Card');
        } else if (retrieveFinanceState('ASI_TnE_MY_Finance_Users')) {
            developerNameFilter = 'ASI_TnE_MY%';
            reportDeveloperName = 'ASI_TnE_MY_Corp_Card_for_AP_Sync';
            afterSyncReportDeveloperName = 'ASI_TnE_MY_Corp_Card_after_AP_Sync';
            country = 'MY';
            tneTypeFilter.add('Corp Card');
        } else if (retrieveFinanceState('ASI_TnE_ID_Finance_Users')) {
            developerNameFilter = 'ASI_TnE_ID%';
            //TODO
            reportDeveloperName = 'ASI_TnE_ID_Out_of_Pocket_for_AP_Sync';
            //TODO
            afterSyncReportDeveloperName = 'ASI_TnE_ID_Out_of_Pocket_after_AP_Sync';
            country = 'ID';
            tneTypeFilter.add('Out of Pocket');
        } else if (retrieveFinanceState('ASI_TnE_PH_Finance_Users')) {
            developerNameFilter = 'ASI_TnE_PH%';
            //TODO
            reportDeveloperName = 'ASI_TnE_PH_Out_of_Pocket_for_AP_Sync';
            //TODO
            afterSyncReportDeveloperName = 'ASI_TnE_PH_Out_of_Pocket_after_AP_Sync';
            country = 'PH';
            tneTypeFilter.add('Out of Pocket');
        } else {
            isFinanceUser = false;
        }
        
        List<Report> reportList = [Select ID from Report where DeveloperName = : reportDeveloperName ];
        if(reportList.size() > 0) {
           reportID = reportList.get(0).id; 
        }
        
        
        List<Report> reportListAfterSync = [Select ID from Report where DeveloperName = : afterSyncReportDeveloperName ];
        if(reportListAfterSync.size() > 0) {
            afterSyncReportID = reportListAfterSync.get(0).id;
        }
        
        
        if(isFinanceUser) {
			//VKWOK - 8/1/2016 - Added SG case for include APSync = null or 'Y'
			if (country == 'SG') {
				this.claimHeaderList = [SELECT ID, Name, ASI_TnE_Export_to_AP_Voucher_GL__c, ASI_TnE_Payee_Supplier__c, ASI_TnE_Payee_Supplier__r.Name FROM ASI_TnE_ClaimHeader__c
												WHERE ASI_TnE_Type__c IN : tneTypeFilter
												AND ASI_TnE_Status__c != 'Final' AND ASI_TnE_Status__c != 'Complete'
												AND recordtype.developername LIKE : developerNameFilter 
												AND (ASI_TnE_AP_Sync__c = NULL OR ASI_TnE_AP_Sync__c = 'Y')
                                       			AND ASI_TnE_Total_Amount_LCY__c <> 0];
				if(claimHeaderList.size() == 0) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'There are no records to be AP synced.'));
					isFinanceUser = false;
				}
			}else{
				// DC - 01/27/2016 - Added debugs for checking value of tneTypeFilter & developerNameFilter.
				System.debug('------ tneTypeFilter ------ : ' + tneTypeFilter);
				System.debug('------ developerNameFilter ------ : ' + developerNameFilter);
				this.claimHeaderList = [SELECT ID, Name, ASI_TnE_Export_to_AP_Voucher_GL__c, ASI_TnE_Payee_Supplier__c, ASI_TnE_Payee_Supplier__r.Name FROM ASI_TnE_ClaimHeader__c
												WHERE ASI_TnE_Type__c IN : tneTypeFilter
												AND ASI_TnE_Status__c != 'Final' AND ASI_TnE_Status__c != 'Complete'
												AND recordtype.developername LIKE : developerNameFilter 
												AND ASI_TnE_AP_Sync__c = NULL
												AND ASI_TnE_Sync_to_JDE_Date__c = NULL];
				if(claimHeaderList.size() == 0) {
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'There are no records to be AP synced.'));
					isFinanceUser = false;
				}
			}
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,'Current user is a non finance user.'));
        }
        
    }
    
    public pageReference updateVoucher() {
        Pagereference ref = null;
        try {
            List<ASI_TnE_ClaimHeader__c> claimHeadersToUpdateList = new List<ASI_TnE_ClaimHeader__c>(); 
            for(ASI_TnE_ClaimHeader__c claimHeader : this.claimHeaderList) {
                claimHeader.ASI_TnE_AP_Sync__c = 'R';
                // DC - 02/29/2016 - Added condition to limit validation of GL Date to TW only
                // and changed from claimHeaderInstance.ASI_TnE_KR_GL_Date__c to glDate
                // to avoid internal server error issue.
                if(glDate == NULL
                && developerNameFilter.containsIgnoreCase('ASI_TnE_TW')) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,System.Label.ASI_TnE_TW_Export_AP_Require_GL_Date));
                } else if(developerNameFilter.containsIgnoreCase('ASI_TnE_TW')){
                    claimHeader.ASI_TnE_KR_GL_Date__c = glDate;
                }
                claimHeadersToUpdateList.add(claimHeader);
            }
            if(claimHeadersToUpdateList.size() > 0) {
                // DC - 02/29/2016 - Added condition to limit validation of GL Date to TW only
                // and changed from claimHeaderInstance.ASI_TnE_KR_GL_Date__c to glDate
                // to avoid internal server error issue.
                if(glDate == NULL
                && developerNameFilter.containsIgnoreCase('ASI_TnE_TW')) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,System.Label.ASI_TnE_TW_Export_AP_Require_GL_Date));
                } else {
                    update claimHeadersToUpdateList;
                    isSuccess = true;
                }
            }
        } catch (exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,ex.getMessage()));
            isSuccess = false;
            return null;
        }
        return ref;
    
    }
    
    public pageReference updateVoucherHSBC() {
        Pagereference ref = null;
        isHSBCClicked = true;
        try {
            List<ASI_TnE_ClaimHeader__c> claimHeadersToUpdateList = new List<ASI_TnE_ClaimHeader__c>(); 
            for(ASI_TnE_ClaimHeader__c claimHeader : this.claimHeaderList) {
                if(claimHeader.ASI_TnE_Payee_Supplier__c != null) {
                    if(claimHeader.ASI_TnE_Payee_Supplier__r.name.contains('HSBC')) {
                        claimHeader.ASI_TnE_AP_Sync__c = 'R';
                        claimHeadersToUpdateList.add(claimHeader);
                    }
                }
            }
            if(claimHeadersToUpdateList.size() > 0) {
                update claimHeadersToUpdateList;
                isSuccess = true;
            } else {
                isSuccess = false;
            }
        } catch (exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,ex.getMessage()));
            isSuccess = false;
            return null;
        }
        return ref;
    
    }
    
    public pageReference updateVoucherAmex() {
        Pagereference ref = null;
        isAMEXClicked = true;
        try {
            List<ASI_TnE_ClaimHeader__c> claimHeadersToUpdateList = new List<ASI_TnE_ClaimHeader__c>(); 
            for(ASI_TnE_ClaimHeader__c claimHeader : this.claimHeaderList) {
                if(claimHeader.ASI_TnE_Payee_Supplier__c != null) {
                    if(claimHeader.ASI_TnE_Payee_Supplier__r.name.contains('AMERICAN EXPRESS')) {
                        claimHeader.ASI_TnE_AP_Sync__c = 'R';
                        claimHeadersToUpdateList.add(claimHeader);
                    }
                }
            }
            if(claimHeadersToUpdateList.size() > 0) {
                update claimHeadersToUpdateList;
                isSuccess = true;
            } else {
                isSuccess = false;
            }
        } catch (exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal,ex.getMessage()));
            isSuccess = false;
            return null;
        }
        return ref;
    
    }
    
    private Boolean retrieveFinanceState(String pGroupDevName){
        String userId = UserInfo.getUserId();
        Boolean financeView = false;
        List<Group> publicGroup = new List<Group>();
        publicGroup = [Select Id, DeveloperName From Group Where DeveloperName =: pGroupDevName];
        if(publicGroup.size() > 0){
            for(GroupMember grpM :[Select Id, UserOrGroupId From GroupMember Where GroupId =: publicGroup[0].Id]){
                if(grpM.UserOrGroupId == userId){
                    financeView = true;
                }
            }
        }
        return financeView;
    }
    
}