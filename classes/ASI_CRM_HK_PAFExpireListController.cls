public with sharing class ASI_CRM_HK_PAFExpireListController {
    //public List<ASI_HK_CRM_Pre_Approval_Form__c> pafWeekList { get; set; }
    //public List<ASI_HK_CRM_Pre_Approval_Form__c> pafMonthList { get; set; }
    public PafList pafWeekList;
    public PafList pafMonthList;
    public class PafList{
        private date today = system.today();
        private date dateOffset;
        private List<id> typeId = new List<id>{Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form'),Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form_Date_Adjustment'),Global_RecordTypeCache.getRTId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form_Read_Only')};
        private String[] status = new String[]{'Confirmed with Customer','FD Approved','FM Approved','MD Final'};
        private integer counter=0;  //keeps track of the offset
        private integer list_size=15; //sets the page size or number of rows
        public integer total_size; //used to show user the total size of the list
        public List<ASI_HK_CRM_Pre_Approval_Form__c> pafRecords {get;set;}
        public pafList(integer n) {
            dateOffset = today.addDays(n);
            updatePafRecords();
        }
        
        public void updatePafRecords() {
            try {
                //Show all the records(for debug)
                //total_size = [select count() from ASI_HK_CRM_Pre_Approval_Form__c WHERE recordTypeid = :typeId];
                //pafRecords = [SELECT Name, ASI_HK_CRM_PAF_Customer__r.Name, ASI_HK_CRM_PAF_Nature_of_Promotion__c, ASI_HK_CRM_Expiry_Date__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE recordTypeid = :typeId ORDER BY Id LIMIT :list_size OFFSET :counter];
                
                //Show only the required records
                total_size = [select count() from ASI_HK_CRM_Pre_Approval_Form__c WHERE ASI_HK_CRM_Expiry_Date__c >= :today AND ASI_HK_CRM_Expiry_Date__c < :dateOffset AND ASI_HK_CRM_PAF_Status__c LIKE :status AND recordTypeid = :typeId];
                pafRecords = [SELECT Name, ASI_HK_CRM_PAF_Customer__r.Name, ASI_HK_CRM_PAF_Nature_of_Promotion__c, ASI_HK_CRM_Expiry_Date__c FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE ASI_HK_CRM_Expiry_Date__c >= :today AND ASI_HK_CRM_Expiry_Date__c < :dateOffset AND ASI_HK_CRM_PAF_Status__c LIKE :status AND recordTypeid = :typeId ORDER BY ASI_HK_CRM_Expiry_Date__c LIMIT :list_size OFFSET :counter];
                                
            } catch (QueryException e) {
                ApexPages.addMessages(e);   
                return;
            }
        }
        public PageReference Beginning() { //user clicked beginning
            counter = 0;
            updatePafRecords();
            return null;
        }
        
        public PageReference Previous() { //user clicked previous button
            counter -= list_size;
            updatePafRecords();
            return null;
        }
        
        public PageReference Next() { //user clicked next button
            counter += list_size;
            updatePafRecords();
            return null;
        }
        
        public PageReference End() { //user clicked end
            integer remainder = math.mod(total_size, list_size);
            if(remainder == 0){
                counter = total_size - list_size;
            } else {
                counter = total_size - remainder;
            }
            
            updatePafRecords();
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
    }
    public pafList getPafWeekList() {
        return pafWeekList;
    }
    public pafList getPafMonthList() {
        return pafMonthList;
    }
    public ASI_CRM_HK_PAFExpireListController()
    {
        pafWeekList = new PafList(7);
        pafMonthList = new PafList(30);
    }
}