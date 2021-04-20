Global with sharing class ASI_MFM_CN_RentalRequestCtrl{
    //https://pernod-ricard--asisb5conf--c.cs7.visual.force.com/apex/ASI_MFM_CN_RentalLineManageAll?scontrolCaching=1&id=aGWM000000000B2 
    //https://pernod-ricard--asisb5conf.cs7.my.salesforce.com/01IM00000001jKI?setupid=CustomObjects
    //

    Public String pageId {Get; Set;}
    Public String selectedDepartment {Get; Set;}
    Public ASI_MFM_Rental_Request__c rentalRequest {Get; Set;}
    Public Boolean editMode {Get; Set;} {editMode = False;}
    Public transient Double totalAmountSum {Get; Set;}{totalAmountSum = 0;}
    Public transient Double totalCAPEXSum {Get; Set;}{totalCAPEXSum = 0;}
    Public transient Double totalOPEXSum {Get; Set;}{totalOPEXSum = 0;}
    Public List<ASI_MFM_Rental_Request_Line__c> rentalLine { Get; Set;}{rentalLine = new List<ASI_MFM_Rental_Request_Line__c>();}
    
    Public Boolean edit{Get; Set;}{edit = false;}
    Public Boolean isAdmin {Get; Set;}{isAdmin = False;}
    Public Boolean isRenova {Get; Set;}{isRenova = False;}
    Public Boolean isFin {Get; Set;}{isFin = False;}//MT@Introv_20190514  //Add to determine if the user fin user
    
    Public List<SelectOption> departmentOption {Get; Set;}{departmentOption = new List<SelectOption>();}
    
    Public ASI_MFM_CN_RentalRequestCtrl(apexPages.StandardController stdc){
        
        pageId = ApexPages.currentPage().getParameters().get('id');
        
        List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>([SELECT id FROM PermissionSetAssignment WHERE AssigneeId = : userInfo.getUserId() 
                                                                               AND (PermissionSet.Name Like '%ASI_MFM_CN_StructureCost_AdminUser%'
                                                                                    OR PermissionSet.Name Like '%SI_MFM_CN_StructureCost_ProcurementUser%')
                                                                              ]);
        if(psa.size() > 0)
            isAdmin = True;
            
        //MT@Introv_20190514 start
        //Add to determine if the user fin user
        List<GroupMember> pga = new List<GroupMember>([SELECT id FROM GroupMember WHERE UserOrGroupId = : userInfo.getUserId() 
                                                                               AND groupid in (select id from group where developername like '%ASI_MFM_CN_SC_Admin_Group%' or developername like '%ASI_MFM_CN_SC_Finance_Group%')
                                                                              ]);
        if(pga.size() > 0)
            isFin = True;
        //MT@Introv_20190514 end
        
        if(ApexPages.currentPage().getUrl().toLowercase().contains('asi_mfm_cn_rentalreuqestcreationpage'))
            departmentPicklist();
        
        if(pageId != '' && pageId != Null){
            
            if(!ApexPages.currentPage().getUrl().toLowercase().contains('asi_mfm_cn_rentalreuqestcreationpage'))
                getrentalLine();
            
            rentalRequest = [SELECT id
                             , ASI_MFM_Applicant__c
                             , ASI_MFM_City__c
                             , ASI_MFM_Headcount_Forecast_in_3_years__c
                             , ASI_MFM_Headcount_in_Current_Office__c
                             , ASI_MFM_Leasing_New__c
                             , ASI_MFM_Project_Name_City_Content__c
                             , ASI_MFM_Proposed_New_Space__c
                             , ASI_MFM_Related_Kickoff_Form_ID__c
                             , ASI_MFM_Renovation_New__c
                             , ASI_MFM_Current_Rented_Space__c
                             , recordType.DeveloperName
                             , Name, ASI_MFM_BU__c
                             , ASI_MFM_BU__r.Name
                             , ASI_MFM_Department__c
                             , ASI_MFM_Applicant__r.Name
                             , ASI_MFM_City__r.Name
                             , ASI_MFM_Total_Contract_Amount__c
                             , OwnerId
                             FROM ASI_MFM_Rental_Request__c 
                             WHERE id = : pageId];
            
            if(rentalRequest != Null && rentalRequest.recordType.DeveloperName.contains('ASI_MFM_CN_Renovation'))
                isRenova = True;
                
        }else{
            
        }
    }
    
    Public pageReference backToRentalRequest(){
        
        String prefixkey = Schema.getGlobalDescribe().get('ASI_MFM_Rental_Request__c').getDescribe().getKeyPrefix();
        
        if(pageId != Null && pageId != '')
            return new pageReference('/' + pageId);
        else
            return new pageReference('/' + prefixkey);
    }
    
    Public void editContract(){
        edit = !edit;
    }
    
    //taxcodepisklist
    Public String getTaxCodePiskList(){
        
        String pisklist = '';
        //@ 201904 CR Tax editable add ASI_MFM_VAT_Rate__c to options' id
        for(ASI_MFM_Tax_Code__c obj : [SELECT id, Name, ASI_MFM_VAT_Rate__c  FROM ASI_MFM_Tax_Code__c WHERE RecordType.developerName Like '%_CN_%']){
            pisklist += '<option value="' + obj.id + '" id="'+obj.ASI_MFM_VAT_Rate__c+'">' + obj.Name + '</option>';
        }
        
        Return pisklist;
    }
    
    Public pageReference createRentalApproval(){
        
        if(ApexPages.currentPage().getParameters().get('RecordType') == Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Form')){
            
            String url = '/' + ASI_MFM_Rental_Request__c.sobjecttype.getDescribe().getKeyPrefix() + '/e?';
            url += selectedDepartment != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Department__c + '=' + selectedDepartment : '';
            url += '&RecordType=' + Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Form');
            url += '&nooverride=1&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
            
            PageReference redirect = new PageReference(url);
            redirect.setRedirect(true);
            return redirect;
            
        }
        //MT@Introv 20190528 start
        //handling to redirect page for record type 'renovation request'
        else if(ApexPages.currentPage().getParameters().get('RecordType') == Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Request')){
            
            String url = '/' + ASI_MFM_Rental_Request__c.sobjecttype.getDescribe().getKeyPrefix() + '/e?';
            url += selectedDepartment != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Department__c + '=' + selectedDepartment : '';
            url += '&RecordType=' + Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Request');
            url += '&nooverride=1&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
            
            PageReference redirect = new PageReference(url);
            redirect.setRedirect(true);
            return redirect;
            
        }//MT@Introv 20190528 end
        else if(rentalRequest != Null && rentalRequest.recordType.DeveloperName.contains('ASI_MFM_CN_Rental_Request')){
            queryClass qc = new queryClass();
            
            List<ASI_MFM_Rental_Request__c> rentalApprovalForm = qc.queryApprovalForm(rentalRequest.id); //new List<ASI_MFM_Rental_Request__c>([Select id, ASI_MFM_City__c FROM ASI_MFM_Rental_Request__c WHERE ASI_MFM_Related_Kickoff_Form_ID__c = : rentalRequest.id]);
            
            
            if(rentalApprovalForm.size() > 0){
                
                String url = '/' + rentalApprovalForm[0].id;
                
                if(rentalApprovalForm[0].ASI_MFM_City__c == Null){
                    
                    url = '/' + rentalApprovalForm[0].id + '/e?';
                    url += rentalRequest.ASI_MFM_City__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_City__c + '=' + rentalRequest.ASI_MFM_City__r.Name : '';
                    url += rentalRequest.ASI_MFM_City__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_City__c + '_lkid=' + rentalRequest.ASI_MFM_City__c : '';
                    url += rentalRequest.ASI_MFM_Headcount_Forecast_in_3_years__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Headcount_Forecast_in_3_years__c + '=' + rentalRequest.ASI_MFM_Headcount_Forecast_in_3_years__c : '';
                    url += rentalRequest.ASI_MFM_Headcount_in_Current_Office__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Headcount_in_Current_Office__c + '=' + rentalRequest.ASI_MFM_Headcount_in_Current_Office__c : '';
                    url += rentalRequest.ASI_MFM_Leasing_New__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Leasing__c + '=' + rentalRequest.ASI_MFM_Leasing_New__c : '';
                    url += rentalRequest.ASI_MFM_Project_Name_City_Content__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Project_Name_City_Content__c + '=' + rentalRequest.ASI_MFM_Project_Name_City_Content__c : '';
                    url += rentalRequest.ASI_MFM_Proposed_New_Space__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Proposed_New_Space__c + '=' + rentalRequest.ASI_MFM_Proposed_New_Space__c : '';
                    url += rentalRequest.ASI_MFM_Renovation_New__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Renovation__c + '=' + rentalRequest.ASI_MFM_Renovation_New__c : '';
                    url += rentalRequest.ASI_MFM_Current_Rented_Space__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Current_Rented_Space__c + '=' + rentalRequest.ASI_MFM_Current_Rented_Space__c : '';
                    url += '&cancelURL=%2F' + rentalRequest.id;
                    url += '&saveURL=%2F' + rentalApprovalForm[0].id;
                }
                
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Rental Approval Form Exists. You are not allowed to create more than one Rental Approval Form. To view the approval form, please click <a href="' + url + '" style="font-size:12px;">this</a>'));
                return null;
            }else{
                
                ASI_MFM_Rental_Request__c ra = new ASI_MFM_Rental_Request__c(ASI_MFM_Related_Kickoff_Form_ID__c = rentalRequest.id
                                                                             , ASI_MFM_Department__c = selectedDepartment
                                                                             , ASI_MFM_BU__c = rentalRequest.ASI_MFM_BU__c
                                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval')
                                                                            );
                
                try{
                    
                    Insert ra;
                }catch(dmlException dmle){
                    
                    apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , dmle.getMessage() ));
                    return null;
                }
                
                String url = '/' + ra.id + '/e?';// + ASI_MFM_Rental_Request__c.sobjecttype.getDescribe().getKeyPrefix() + '/e?';
                //url += rentalRequest.ASI_MFM_Applicant__c != Null ? ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Applicant__c + '=' + rentalRequest.ASI_MFM_Applicant__r.name : '';
                //url += rentalRequest.ASI_MFM_Applicant__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Applicant__c + '_lkid=' + rentalRequest.ASI_MFM_Applicant__c : '';
                url += rentalRequest.ASI_MFM_City__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_City__c + '=' + rentalRequest.ASI_MFM_City__r.Name : '';
                url += rentalRequest.ASI_MFM_City__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_City__c + '_lkid=' + rentalRequest.ASI_MFM_City__c : '';
                url += rentalRequest.ASI_MFM_Headcount_Forecast_in_3_years__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Headcount_Forecast_in_3_years__c + '=' + rentalRequest.ASI_MFM_Headcount_Forecast_in_3_years__c : '';
                url += rentalRequest.ASI_MFM_Headcount_in_Current_Office__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Headcount_in_Current_Office__c + '=' + rentalRequest.ASI_MFM_Headcount_in_Current_Office__c : '';
                url += rentalRequest.ASI_MFM_Leasing_New__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Leasing__c + '=' + rentalRequest.ASI_MFM_Leasing_New__c : '';
                url += rentalRequest.ASI_MFM_Project_Name_City_Content__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Project_Name_City_Content__c + '=' + rentalRequest.ASI_MFM_Project_Name_City_Content__c : '';
                url += rentalRequest.ASI_MFM_Proposed_New_Space__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Proposed_New_Space__c + '=' + rentalRequest.ASI_MFM_Proposed_New_Space__c : '';
                //url += '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Related_Kickoff_Form_ID__c + '=' + rentalRequest.Name;
                //url += '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Related_Kickoff_Form_ID__c + '_lkid=' + rentalRequest.id + '&retURL=%2F' + rentalRequest.id;
                url += rentalRequest.ASI_MFM_Renovation_New__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Renovation__c + '=' + rentalRequest.ASI_MFM_Renovation_New__c : '';
                //url += selectedDepartment != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Department__c + '=' + selectedDepartment : '';
                url += rentalRequest.ASI_MFM_Current_Rented_Space__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_Current_Rented_Space__c + '=' + rentalRequest.ASI_MFM_Current_Rented_Space__c : '';
                url += '&cancelURL=%2F' + rentalRequest.id;
                url += '&saveURL=%2F' + ra.id;
                //url += rentalRequest.ASI_MFM_BU__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_BU__c + '=' + rentalRequest.ASI_MFM_BU__r.Name : '';
                //url += rentalRequest.ASI_MFM_BU__c != Null ? '&' + ASI_MFM_CN_RentalRequestSetting__c.getValues('RentalRequestFieldMapping').ASI_MFM_BU__c + '_lkid=' + rentalRequest.ASI_MFM_BU__c : '';
                //url += '&RecordType=' + Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Rental_Approval');
                
                PageReference redirect = new PageReference(url);
                redirect.setRedirect(true);
                return redirect;
            }
        }else{
            return NULL;
        }
    }
    
    Public void departmentPicklist(){
        
        Set<String> deparmentSet = new Set<String>();
        
        if(ApexPages.currentPage().getParameters().get('RecordType') == Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request__cASI_MFM_CN_Renovation_Form')){
            
            for(ASI_CRM_Expense_Control_Form_Line__c ecf : [SELECT id
                                                            , ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c
                                                            FROM ASI_CRM_Expense_Control_Form_Line__c 
                                                            WHERE ASI_MFM_User__c = : userinfo.getUserId() 
                                                            AND RecordType.developerName LIKE 'ASI_MFM_CN_Expense_Control_Form_Allowed_User'
                                                            AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_Only_Renovation_Furniture__c = True
                                                            Order By ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c]){
                                                                
                                                                if(!deparmentSet.contains(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c)){
                                                                    deparmentSet.add(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c);
                                                                    departmentOption.add(new SelectOption(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c, ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c));
                                                                }
                                                            }
            
        }else{
            for(ASI_CRM_Expense_Control_Form_Line__c ecf : [SELECT id
                                                            , ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c
                                                            FROM ASI_CRM_Expense_Control_Form_Line__c 
                                                            WHERE ASI_MFM_User__c = : userinfo.getUserId() 
                                                            AND RecordType.developerName LIKE 'ASI_MFM_CN_Expense_Control_Form_Allowed_User'
                                                            AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_Rental_Request_Expense__c = True
                                                            //(ASI_MFM_Expense_Control_Form__r.ASI_MFM_Only_Renovation_Furniture__c = True
                                                                 //OR ASI_MFM_Expense_Control_Form__r.ASI_MFM_Rental_Request_Expense__c = True
                                                                 //)
                                                            Order By ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c]){
                                                                
                                                                if(!deparmentSet.contains(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c)){
                                                                    deparmentSet.add(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c);
                                                                    departmentOption.add(new SelectOption(ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c, ecf.ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c));
                                                                }
                                                            }
        }
    }
    
    public void getrentalLine(){
        
        totalAmountSum = 0;
        totalCAPEXSum = 0;
        totalOPEXSum = 0;
        
        if(pageId != '' &&  pageId != Null){
            rentalLine = [SELECT id
                          , ASI_MFM_Renovation_Item__c
                          , ASI_MFM_Renovation_Space__c
                          , ASI_MFM_Market_benchmark_RMB__c
                          , ASI_MFM_Market_investigationProposalRMB__c
                          , ASI_MFM_Total_Amount__c
                          , ASI_MFM_CAPEX_Budget__c
                          , ASI_MFM_OPEX_Budget__c
                          , ASI_MFM_Remarks__c
                          FROM ASI_MFM_Rental_Request_Line__c
                          WHERE ASI_MFM_Rental_Request__c = : pageId
                          AND RecordType.developerName Like 'ASI_MFM_CN_Rental_Item'
                         ];
                         
            for(ASI_MFM_Rental_Request_Line__c obj : rentalLine){
                if(obj.ASI_MFM_Total_Amount__c != Null)
                    totalAmountSum += obj.ASI_MFM_Total_Amount__c;
                if(obj.ASI_MFM_CAPEX_Budget__c != Null)
                    totalCAPEXSum += obj.ASI_MFM_CAPEX_Budget__c;
                if(obj.ASI_MFM_OPEX_Budget__c != Null)
                    totalOPEXSum += obj.ASI_MFM_OPEX_Budget__c;
            }
        }
        
        //return rentalLine;
    }
    
    Public void reCalculateTotal(){
        
        totalAmountSum = 0;
        totalCAPEXSum = 0;
        totalOPEXSum = 0;
        
        for(ASI_MFM_Rental_Request_Line__c obj : rentalLine){
            if(obj.ASI_MFM_Total_Amount__c != Null)
                totalAmountSum += obj.ASI_MFM_Total_Amount__c;
            if(obj.ASI_MFM_CAPEX_Budget__c != Null)
                totalCAPEXSum += obj.ASI_MFM_CAPEX_Budget__c;
            if(obj.ASI_MFM_OPEX_Budget__c != Null)
                totalOPEXSum += obj.ASI_MFM_OPEX_Budget__c;
        }
    }
    
    Public void modifyRenovationSection(){
        
        editMode = !editMode;
        reCalculateTotal();
        
        Boolean hasError = false;
        
        if(!editMode){
            
            if(isRenova && totalAmountSum != rentalRequest.ASI_MFM_Total_Contract_Amount__c){
                apexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING , 'Total Amount must be equal to total contract amount.'));
                hasError = True;
                editMode = True;
            }
            
            if(!hasError){
                try{
                    if(rentalLine.size() > 0){
                        
                        update rentalLine;
                    }
                }catch(dmlException dmle){
                    
                }
            }
        }
    }
    
    Public void Cancel(){
        
        editMode = !editMode;
        getrentalLine();
        reCalculateTotal();
    }
    
    Public pageReference Cancel2(){
        
        return new pagereference('/' + pageId);
    }
    
    
    ///Get Data
    @remoteAction
    Global Static List<contractClass> getContractLines(String headerId, String department, String BU, Boolean isRenovation, String recordOwnerId){
        
        List<contractClass> contractList = new List<contractClass>();
        
        String expenseTypePickList = '<option value=""></option>';
        Set<Id> expenseTypeIdSet = new Set<Id>();
        Id UserId = recordOwnerId == Null ? userinfo.getUserId() : id.valueOf(recordOwnerId);
        
        if(!isRenovation){
            for(ASI_CRM_Expense_Control_Form_Line__c obj : [SELECT id, ASI_MFM_Expense_Control_Form__c, ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c, ASI_MFM_Expense_Control_Form__r.Name
                                                            FROM ASI_CRM_Expense_Control_Form_Line__c 
                                                            WHERE ASI_MFM_User__c = : UserId
                                                            AND RecordType.developerName LIKE 'ASI_MFM_CN_Expense_Control_Form_Allowed_User'
                                                            AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c Like : department
                                                            AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_BU__c = : BU
                                                            AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_Rental_Request_Expense__c = TRUE 
                                                            //(ASI_MFM_Expense_Control_Form__r.ASI_MFM_Rental_Request_Expense__c = TRUE
                                                                 //OR ASI_MFM_Expense_Control_Form__r.ASI_MFM_Only_Renovation_Furniture__c = TRUE)
                                                            Order By ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c]){
                                                                
                                                                if(!expenseTypeIdSet.contains(obj.ASI_MFM_Expense_Control_Form__c)){
                                                                    
                                                                    expenseTypeIdSet.add(obj.ASI_MFM_Expense_Control_Form__c);
                                                                    expenseTypePickList += '<option value="' + obj.ASI_MFM_Expense_Control_Form__c + '">' + obj.ASI_MFM_Expense_Control_Form__r.Name + '</option>';
                                                                }
                                                            }
        }else{
            
            for(ASI_CRM_Expense_Control_Form_Line__c obj : [SELECT id, ASI_MFM_Expense_Control_Form__c, ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c, ASI_MFM_Expense_Control_Form__r.Name
                                                            FROM ASI_CRM_Expense_Control_Form_Line__c 
                                                            WHERE ASI_MFM_User__c = : UserId
                                                            AND RecordType.developerName LIKE 'ASI_MFM_CN_Expense_Control_Form_Allowed_User'
                                                            AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_Department__c Like : department
                                                            AND ASI_MFM_Expense_Control_Form__r.ASI_MFM_BU__c = : BU
                                                            AND (ASI_MFM_Expense_Control_Form__r.ASI_MFM_Only_Renovation_Furniture__c = TRUE)
                                                            Order By ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c]){
                                                                
                                                                if(!expenseTypeIdSet.contains(obj.ASI_MFM_Expense_Control_Form__c)){
                                                                    
                                                                    expenseTypeIdSet.add(obj.ASI_MFM_Expense_Control_Form__c);
                                                                    expenseTypePickList += '<option value="' + obj.ASI_MFM_Expense_Control_Form__c + '">' + obj.ASI_MFM_Expense_Control_Form__r.Name + '</option>';
                                                                }
                                                            }
        }
        
        contractClass temp = new contractClass();
        temp.Picklist = expenseTypePickList;
        contractList.add(temp);
        
        
        //Get Line detail
        List<ASI_MFM_Rental_Request_Line__c> PPlist= [SELECT id, ASI_MFM_Tax_Code__c, ASI_MFM_Tax_Code__r.Name, Name,ASI_MFM_Rental_Request_Line__c, ASI_MFM_Contract__c, ASI_MFM_Total_Amount__c, ASI_MFM_ExpenseType__r.Name,ASI_MFM_Amount_Per_Month__c,ASI_MFM_Period_From__c,ASI_MFM_Period_To__c , ASI_MFM_Paid_Amount__c, ASI_MFM_Detail__c,ASI_MFM_CIP_Amount__c, ASI_MFM_ETL__c , ASI_MFM_ExpenseType__c, ASI_MFM_Completion__c, ASI_MFM_Total_Amount_Without_Tax__c FROM ASI_MFM_Rental_Request_Line__c WHERE ASI_MFM_Rental_Request__c = : headerId AND RecordType.developerName Like 'ASI_MFM_CN_Rental_Contract_Line' Order By ASI_MFM_Contract__c ]; //MT@Introv_20190514 add ASI_MFM_Total_Amount_Without_Tax__c
        //Checking if contain detail line
        Set<ID> DetailSet= new Set<ID>();
        for(ASI_MFM_Rental_Request_Line__c obj : PPlist){
            if(obj.ASI_MFM_Detail__c && obj.ASI_MFM_Rental_Request_Line__c != null){
                DetailSet.add(obj.ASI_MFM_Rental_Request_Line__c);
            }
        }
        
        for(ASI_MFM_Rental_Request_Line__c obj : PPlist){
            
            contractClass tmp = new contractClass();
            tmp.PPLine=obj;
            tmp.lineNumber = obj.Name;
            tmp.contract = obj.ASI_MFM_Contract__c != Null ? obj.ASI_MFM_Contract__c : Null;
            tmp.lineId = obj.id;
            tmp.totalAmount = obj.ASI_MFM_Total_Amount__c;
            if(obj.ASI_MFM_ExpenseType__c!=null){
                tmp.expenseType = expenseTypePickList.contains(obj.ASI_MFM_ExpenseType__c) ? expenseTypePickList.replace('value="' + obj.ASI_MFM_ExpenseType__c + '"', 'value="' + obj.ASI_MFM_ExpenseType__c + '" selected') : expenseTypePickList;
                tmp.expenseTypeId = obj.ASI_MFM_ExpenseType__c;
            }
            tmp.taxCodeId = obj.ASI_MFM_Tax_Code__c;
            tmp.taxCodeName = obj.ASI_MFM_Tax_Code__c != Null ? obj.ASI_MFM_Tax_Code__r.Name : '';
            tmp.paidAmount = obj.ASI_MFM_Paid_Amount__c != Null ? obj.ASI_MFM_Paid_Amount__c.setScale(2) : 0;
            tmp.cipAmount = obj.ASI_MFM_CIP_Amount__c != Null ? obj.ASI_MFM_CIP_Amount__c.setScale(2) : 0;
            tmp.ETL = obj.ASI_MFM_ETL__c;
            tmp.completion = obj.ASI_MFM_Completion__c;
            tmp.PeriodFrom = obj.ASI_MFM_Period_From__c != Null ? obj.ASI_MFM_Period_From__c.year() + '-' + obj.ASI_MFM_Period_From__c.month() + '-' + obj.ASI_MFM_Period_From__c.day() : '';
            tmp.PeriodTo = obj.ASI_MFM_Period_To__c != Null ? obj.ASI_MFM_Period_To__c.year() + '-' + obj.ASI_MFM_Period_To__c.month() + '-' + obj.ASI_MFM_Period_To__c.day() : '';
            tmp.isDelete = False;
            tmp.totalAmountWithoutTax = obj.ASI_MFM_Total_Amount_Without_Tax__c; //MT@Introv_20190514 add ASI_MFM_Total_Amount_Without_Tax__c
            
            if(DetailSet.contains(obj.id)){
                tmp.HaveDetailLine=true;
            }
            contractList.add(tmp);
        }
        
        
        
        Return contractList;
    }
    
    
    @remoteAction
    Global Static String SaveDetailLine(List<contractClass> upsertList, List<contractClass> deleteList, String headerId){
        
        String errorMsg = '';
        Boolean hasError = false;
        List<ASI_MFM_Rental_Request_Line__c> deleteLine = new List<ASI_MFM_Rental_Request_Line__c>();
        List<ASI_MFM_Rental_Request_Line__c> upsertLine = new List<ASI_MFM_Rental_Request_Line__c>();
        Map<id, double> mapTotalContractAmount = new Map<Id, Double>();
        set<String> idSet = new Set<String>();
         
         //delete
        if(deleteList.size() > 0){
            
            for(contractClass deleteitem : deleteList){
                if(!idSet.contains(deleteitem.lineId)){
                    if(deleteitem.lineId!=null ){
                        deleteLine.add(new ASI_MFM_Rental_Request_Line__c(id = deleteitem.lineId));
                        idSet.add(deleteitem.lineId);
                    }
                    
                }
            }
        }
        
        
        if(upsertList.size() > 0){
            for(contractClass upsertItem : upsertList){
                if(upsertItem.PeriodFrom!='' && upsertItem.PeriodTo!='' && upsertItem.TotalAmountDetail!=null && upsertItem.AmountPerMonth!=null){
                    if(!idSet.contains(upsertItem.lineId) || upsertItem.lineId == ''){
                        
                        if((upsertItem.PeriodTo != '' && upsertItem.PeriodFrom != '' && date.valueOf(upsertItem.PeriodFrom) > date.valueOf(upsertItem.PeriodTo))){
                            
                            hasError = true;
                            errorMsg += 'Period From cannot be greater than Period To.';
                            
                            return errorMsg;
                        }
                        
                        upsertLine.add(new ASI_MFM_Rental_Request_Line__c(id = (upsertItem.lineId == '' ? Null : upsertItem.lineId),
                                                                          RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line'),
                                                                          ASI_MFM_Rental_Request_Line__c=upsertItem.ParentId,
                                                                          ASI_MFM_Rental_Request__c = headerId,
                                                                          ASI_MFM_Detail__c=true,
                                                                          ASI_MFM_Period_From__c=(upsertItem.PeriodFrom==''? Null:date.valueOf(upsertItem.PeriodFrom)),
                                                                          ASI_MFM_Period_To__c=(upsertItem.PeriodTo==''? Null:date.valueOf(upsertItem.PeriodTo)),
                                                                          ASI_MFM_Total_Amount__c=upsertItem.TotalAmountDetail!=null?upsertItem.TotalAmountDetail:0,
                                                                          ASI_MFM_Amount_Per_Month__c=upsertItem.AmountPerMonth!=null?upsertItem.AmountPerMonth:0
                                                                         ));
                        
                        double amount = upsertItem.TotalAmountDetail!=null?upsertItem.TotalAmountDetail:0;
                        
                        if(mapTotalContractAmount.containsKey(upsertItem.ParentId)){
                            amount = mapTotalContractAmount.get(upsertItem.ParentId) != Null ? amount + mapTotalContractAmount.get(upsertItem.ParentId) : 0;
                        }
                        
                        mapTotalContractAmount.put(upsertItem.ParentId, amount);
                    }
                }else{
                    hasError = true;
                    errorMsg += 'Please input all required fields.';
                }
            }
            
            //20200528-AM@introv - fix rounding issue start
            /*
            for(ASI_MFM_Rental_Request_Line__c obj : [SELECT id, ASI_MFM_Total_Amount__c FROM ASI_MFM_Rental_Request_Line__c WHERE id IN : mapTotalContractAmount.keySet()]){
                if(mapTotalContractAmount.containsKey(obj.id) && obj.ASI_MFM_Total_Amount__c != Null && mapTotalContractAmount.get(obj.id) != obj.ASI_MFM_Total_Amount__c){
                    hasError = true;
                    errorMsg += 'Total Management Fee + Leasing amount must equals to contract amount.';
                    
                    return errorMsg;
                }
            }
			*/
            for(ASI_MFM_Rental_Request_Line__c obj : [SELECT id, ASI_MFM_Total_Amount__c FROM ASI_MFM_Rental_Request_Line__c WHERE id IN : mapTotalContractAmount.keySet()]){
                decimal dLineAmt = obj.ASI_MFM_Total_Amount__c != Null ? obj.ASI_MFM_Total_Amount__c : 0.00;
                decimal dTotalAmt = mapTotalContractAmount.containsKey(obj.id) ? mapTotalContractAmount.get(obj.id) : 0.00;
                dLineAmt = dLineAmt.setScale(2, RoundingMode.HALF_UP);
                dTotalAmt = dTotalAmt.setScale(2, RoundingMode.HALF_UP);
                
                if (mapTotalContractAmount.containsKey(obj.id) && obj.ASI_MFM_Total_Amount__c != Null && dLineAmt != dTotalAmt) {
                    hasError = true;
                    errorMsg += 'Total Management Fee + Leasing amount must be equal to contract amount.';
                    return errorMsg;
                }
            }
            //20200528-AM@introv - fix rounding issue end
        }
        
        if(!hasError){
            
            if(deleteLine.size() > 0){
                try{
                    delete deleteLine;
                }catch(dmlException dmle){
                    return dmle.getMessage();
                }
            }
            
            if(upsertLine.size() > 0){
                try{
                    upsert upsertLine;
                }catch(dmlException dmle){
                    return dmle.getMessage();
                }
            }
        }
        
        return 'Success';
    }
    
    @remoteAction
    Global Static String saveContractLines(List<contractClass> upsertList, List<contractClass> deleteList, String headerId){
        
        String errorMsg = '';
        Boolean hasError = false;
        List<ASI_MFM_Rental_Request_Line__c> deleteLine = new List<ASI_MFM_Rental_Request_Line__c>();
        List<ASI_MFM_Rental_Request_Line__c> upsertLine = new List<ASI_MFM_Rental_Request_Line__c>();
        set<String> idSet = new Set<String>();
        
        //All Expense Type
        Map<id, ASI_CRM_Expense_Control_Form_Line__c> mapet = new Map<id, ASI_CRM_Expense_Control_Form_Line__c>();
        for(ASI_CRM_Expense_Control_Form_Line__c obj : [SELECT id, ASI_MFM_Expense_Control_Form__c, ASI_MFM_Expense_Control_Form__r.ASI_MFM_CIP_Logic__c
                                                        FROM ASI_CRM_Expense_Control_Form_Line__c 
                                                        WHERE ASI_MFM_User__c = : userinfo.getUserId() 
                                                        AND RecordType.developerName LIKE 'ASI_MFM_CN_Expense_Control_Form_Allowed_User'
                                                        ANd (ASI_MFM_Expense_Control_Form__r.ASI_MFM_Rental_Request_Expense__c = TRUE
                                                             OR ASI_MFM_Expense_Control_Form__r.ASI_MFM_Only_Renovation_Furniture__c = TRUE)
                                                        Order By ASI_MFM_Expense_Control_Form__r.ASI_MFM_ExpenseType__c]){
                                                            mapet.put(obj.ASI_MFM_Expense_Control_Form__c, obj);
                                                        }
        
        //delete
        if(deleteList.size() > 0){
            
            
            for(contractClass deleteitem : deleteList){
                if(!idSet.contains(deleteitem.lineId)){
                    if(deleteitem.lineId!=null ){
                        deleteLine.add(new ASI_MFM_Rental_Request_Line__c(id = deleteitem.lineId));
                        idSet.add(deleteitem.lineId);
                    }
                    
                }
            }
        }
        
        //upsert
        if(upsertList.size() > 0){
            
            
            for(contractClass upsertItem : upsertList){
                if(!idSet.contains(upsertItem.lineId) || upsertItem.lineId == ''){
                    if(upsertItem.totalAmount > 0 && upsertItem.contract != '' && upsertItem.expenseType != '' && upsertItem.expenseTypeId!=null && upsertItem.PeriodFrom != '' && upsertItem.PeriodTo != ''){
                       
                        if((upsertItem.PeriodTo != '' && upsertItem.PeriodFrom != '' && date.valueOf(upsertItem.PeriodFrom) > date.valueOf(upsertItem.PeriodTo))){
                            
                            hasError = true;
                            errorMsg += 'Period From cannot be greater than Period To.';
                            
                            return errorMsg;
                        }
                        
                        id expenseType = (upsertItem.expenseTypeId == '' ? Null : upsertItem.expenseTypeId);
                        
                        ASI_MFM_Rental_Request_Line__c tmp = new ASI_MFM_Rental_Request_Line__c(id = (upsertItem.lineId == '' ? Null : upsertItem.lineId)
                                                                                                , ASI_MFM_Contract__c = upsertItem.contract
                                                                                                , ASI_MFM_Total_Amount__c = upsertItem.totalAmount
                                                                                                , ASI_MFM_Completion__c = upsertItem.completion
                                                                                                , ASI_MFM_ExpenseType__c = expenseType//(upsertItem.expenseTypeId == '' ? Null : upsertItem.expenseTypeId)
                                                                                                , ASI_MFM_Tax_Code__c =(upsertItem.taxCodeId == '' ? Null : upsertItem.taxCodeId)
                                                                                                , ASI_MFM_Period_From__c=(upsertItem.PeriodFrom==''? Null:date.valueOf(upsertItem.PeriodFrom))
                                                                                                , ASI_MFM_Period_To__c=(upsertItem.PeriodTo==''? Null:date.valueOf(upsertItem.PeriodTo))
                                                                                                , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Rental_Request_Line__cASI_MFM_CN_Rental_Contract_Line')
                                                                                                , ASI_MFM_Rental_Request__c = headerId
                                                                                                , ASI_MFM_Total_Amount_Without_Tax_Manual__c = upsertItem.totalAmountWithoutTax);//MT@20200319
                        if(mapet.containsKey(expenseType) && upsertItem.lineId == '' )
                            tmp.ASI_MFM_Apply_CIP_Logic__c = mapet.get(expenseType).ASI_MFM_Expense_Control_Form__r.ASI_MFM_CIP_Logic__c;
                            
                        upsertLine.add(tmp);
                    }else{
                        hasError = true;
                        errorMsg += 'Please input all required fields.';
                    }
                }
            }
        }
        
       
        
        if(!hasError){
            if(deleteLine.size() > 0){
                try{
                    
                    delete deleteLine;
                    
                }catch(dmlException dmle){
                    
                    return dmle.getMessage();
                }
            }
            
            if(upsertLine.size() > 0){
                try{
                    
                    upsert upsertLine;
                    
                }catch(dmlException dmle){
                    
                    return dmle.getMessage();
                }
            }
        }else{
            return errorMsg;
        }
        
        Return 'Success';
    }
    
    Global Class contractClass{
        Global ASI_MFM_Rental_Request_Line__c PPLine  {Get; Set;}
        Global String lineNumber {Get; Set;}
        Global String contract {Get; Set;}
        Global String lineId {Get; Set;}
        Global Decimal totalAmount {Get; Set;}
        Global String expenseType {Get; Set;}
        Global String expenseTypeId {Get; Set;}
        Global Decimal paidAmount {Get; Set;}
        Global Decimal cipAmount {Get; Set;}
        Global Boolean ETL {Get; Set;}
        Global Boolean completion {Get; Set;}
        Global Boolean isDelete {Get; Set;}
        Global Boolean HaveDetailLine {Get; Set;}
        Global String Picklist {Get; Set;}
        Global String taxCodeName {Get; Set;}
        Global String taxCodeId {Get; Set;}
        Global Decimal totalAmountWithoutTax {Get; Set;} //MT@Introv_20190514 add ASI_MFM_Total_Amount_Without_Tax__c
        
        
        Global String PeriodFrom {Get; Set;}
        Global String PeriodTo {Get; Set;}
        Global Decimal TotalAmountDetail {Get; Set;}{TotalAmountDetail=0;}
        Global Decimal AmountPerMonth {Get; Set;}{AmountPerMonth=0;}
        Global String ParentId {Get; Set;}
    }
    
    Private without Sharing Class queryClass{
        
        Private List<ASI_MFM_Rental_Request__c> queryApprovalForm(Id requestformid){
            
            Return new List<ASI_MFM_Rental_Request__c>([Select id, ASI_MFM_City__c FROM ASI_MFM_Rental_Request__c WHERE ASI_MFM_Related_Kickoff_Form_ID__c = : requestformid]);
        }
    }
}