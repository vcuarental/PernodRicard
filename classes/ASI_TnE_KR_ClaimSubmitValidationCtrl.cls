/*********************************************************************************
 * Name:ASI_TnE_KR_ClaimSubmitValidationCtrl 
 * Description: Validate ASI_TnE_ClaimHeader__c on submit
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 * 2018-12-11       Laputa: Hector Tsang    Created
*********************************************************************************/

public with sharing class ASI_TnE_KR_ClaimSubmitValidationCtrl {
  public static final Id rtAnPHeader = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP'); 
  public static final Id rtCashHeader = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_Cash');
  public static final Id rtTnEHeader = Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE');
  private static final Set<String> GnHRecordType = new Set<String>{'ASI_GnH_KR_Offer_Request_Read_Only','ASI_GnH_KR_Receive_Request_Read_Only'};
  private static final String statusFinal = 'Final';
  private static final String statusComplete = 'Complete';
  
  public class applicationException extends Exception {}
  public class GnHInfo {
    public String name {get;set;}
    public Decimal totalAmount {get;set;}{totalAmount = 0;}
    public Decimal totalPax {get;set;}{totalPax = 0;}
    public Integer count {get;set;}{count = 1;}
    public Decimal avgPax {
      get{
        if (this.count == 0)
          return 0;
        return this.totalPax / this.count;
      }
      private set;
    }
    public Decimal averageAmt {
      get {
        if (this.avgPax == 0)
          return 0;
        return (this.totalAmount / this.count) / this.avgPax; 
      }
      private set;
    }
    
    public GnHInfo(String name, Decimal totalAmount, Decimal totalPax, Integer count){
      this.name = name == null ? '' : name;
      this.totalAmount = denullify(totalAmount);
      this.totalPax = denullify(totalPax);
      this.count = denullify(count);
    }
    
    public void add(Decimal addtotalAmount, Decimal addtotalPax){
      this.totalAmount += denullify(addtotalAmount);
      this.totalPax += denullify(addtotalPax);
      this.count++;
    }
  }
  
  public ASI_TnE_KR_ClaimSubmitValidationCtrl(){
    
    }
    
    public PageReference proceed(){
        String id = Apexpages.currentpage().getparameters().get('id');
        if(id != null && id != ''){
          ASI_TnE_ClaimHeader__c claimHeader = [SELECT Id, 
                                ASI_TnE_KR_Is_Custom_Submit__c, 
                                ASI_TnE_KR_LookupTnE__c,
                                RecordtypeId 
                              FROM ASI_TnE_ClaimHeader__c 
                              WHERE Id = :id 
                              LIMIT 1];
            List<String> errorMessages = validateChecking(claimHeader);
            
            //Throw error if errorMessages.size > 0
            if (errorMessages.size() > 0){
              system.debug('Error Message:' + errorMessages);
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, String.join(errorMessages, '<br/>')));
              
              return null;
            }
            
            if(Global_RecordTypeCache.getRt(claimHeader.recordTypeid).developerName.contains('ASI_TnE_KR_TnE') ){
              claimHeader.ASI_TnE_KR_Is_Custom_Submit__c = true;
              if(!Test.isRunningTest())
                  update claimHeader;                         
          }
            
        }
        
        PageReference pageRef = new PageReference('/apex/ASI_SubmitApprovalPage?id=' + id);
        return pageRef;
    }
  
  public List<String> validateChecking(ASI_TnE_ClaimHeader__c claimHeader){
    List<String> errorMessages = new List<String>();
    //Get Information
    Map<String,List<String>> gnhRequestMap = ASI_TnE_KR_ClaimManageAllCtrl.getOtherClaimDetails(claimHeader.Id);
    Map<String, ASI_GnH_Request__c> GNHMap = getGnHRequest();
    Map<String,Set<ASI_GnH_Request_Recipient__c>> requestRecipientMap = ASI_TnE_KR_ClaimManageAllCtrl.getRecipientByRequest();
    Map<String, GnHInfo> GnHFormInfoMap = new Map<String, GnHInfo>();
    Map<string, decimal> map_GNHThreshold = getGNHThreshold();
    Map<string, boolean> map_GNHrelated = getGNHrelated();
    Map<string, string> map_GNHName = getGNHName();
    system.debug(map_GNHName);
    
    List<ASI_TnE_ClaimDetail__c> claimDetailList = (List<ASI_TnE_ClaimDetail__c>)System.JSON.deserialize(ASI_TnE_KR_ClaimManageAllCtrl.getClaimDetails(claimHeader.Id), List<ASI_TnE_ClaimDetail__c>.class);
    List<Decimal> TnEThreshold = ASI_TnE_KR_ClaimManageAllCtrl.getTnEThresholdTolerance();
    
    //Validation: Reject A&P claim before the related T&E (ASI_TnE_KR_LookupTnE__c) is approved
    if (claimHeader.RecordTypeId == rtAnPHeader && claimHeader.ASI_TnE_KR_LookupTnE__c != null){
      ASI_TnE_ClaimHeader__c relatedTnEHeader = [SELECT Id, ASI_TnE_Status__c
                            FROM ASI_TnE_ClaimHeader__c
                            WHERE Id = :claimHeader.ASI_TnE_KR_LookupTnE__c];
      if (relatedTnEHeader.ASI_TnE_Status__c != statusFinal && relatedTnEHeader.ASI_TnE_Status__c != statusComplete){
        errorMessages.add('A&P claim should not be submitted before T&E is approved');
        return errorMessages;
      }
    }
    
    //Check mandatory field
    for (ASI_TnE_ClaimDetail__c claimDetail : claimDetailList){
      //Mandatory for all Record Type
      if (claimDetail.ASI_TnE_Total_Number_Pax__c == null)
        errorMessages.add(claimDetail.Name + ': Please input Pax');
      if (claimDetail.ASI_TnE_Details_Of_Expense__c == null)
        errorMessages.add(claimDetail.Name + ': Details of Expense is empty');
        
      //Mandatory for TnE or Cash
      if (claimHeader.RecordTypeId == rtTnEHeader || claimHeader.RecordTypeId == rtCashHeader){
        if (claimDetail.ASI_TnE_Expense_Category__c == null)
          errorMessages.add(claimDetail.Name + ': Please input Expense Category');
        if (claimDetail.ASI_TnE_Expense_Classification__c == null)
          errorMessages.add(claimDetail.Name + ': Please input Expense Classification');
        //Mandatory for Cash only
        if (claimHeader.RecordTypeId == rtCashHeader){
          if (claimDetail.ASI_TnE_Receipt_Date__c == null)
            errorMessages.add(claimDetail.Name + ': Please input Receipt Date');
          if (claimDetail.ASI_TnE_Currency__c == null)
            errorMessages.add(claimDetail.Name + ': Please input Currency');
          if (claimDetail.ASI_TnE_Receipt_Amount__c == null)
            errorMessages.add(claimDetail.Name + ': Please input Receipt Amount');
        }
      }
      
      // check G&H for T&E card, T&E cash and A&P
      if(map_GNHrelated.containsKey(claimDetail.ASI_TnE_Expense_Classification__c)){
        if(map_GNHrelated.get(claimDetail.ASI_TnE_Expense_Classification__c) && 
          (claimDetail.ASI_GnH_Type__c == null || claimDetail.ASI_TnE_Recipient_Type__c == null)
        ){
          errorMessages.add(claimDetail.Name + ': Please Select G&H Type and Recipent Type');
        }
      }
      
      Decimal totalAmt = claimDetail.ASI_TnE_Receipt_Amount__c != null ? claimDetail.ASI_TnE_Receipt_Amount__c : 0;
      Decimal amountPerPax = (claimDetail.ASI_TnE_Total_Number_Pax__c != null & claimDetail.ASI_TnE_Total_Number_Pax__c > 0) ? claimDetail.ASI_TnE_Receipt_Amount__c / claimDetail.ASI_TnE_Total_Number_Pax__c : 0;
      string GNHThresholdKey = claimDetail.ASI_GnH_Type__c + '_' + claimDetail.ASI_TnE_Recipient_Type__c;
      if(map_GNHThreshold.containsKey(GNHThresholdKey)){
        decimal thresholdAmt = map_GNHThreshold.get(GNHThresholdKey);
        if(amountPerPax > thresholdAmt && claimDetail.ASI_TnE_GnH_Request__c == null){
          errorMessages.add(claimDetail.Name + ': The amount is over the G&H threshold, please fill in the approved G&H Form');
        }
      }
      
      // move validation rule into here
      // ASI_TnE_KR_checkDetailsOfExpense
      if((claimDetail.ASI_TnE_Total_Number_Pax__c>1 || map_GNHName.get(claimDetail.ASI_TnE_Expense_Classification__c) == 'Entertainment for other business partner') &&
        claimDetail.ASI_TnE_Details_of_Expense__c == null
      ){
        errorMessages.add(claimDetail.Name + ': Please enter Details of Expense');
      }
      // ASI_TnE_KR_check_Where
      if((map_GNHName.get(claimDetail.ASI_TnE_Expense_Classification__c) == 'External C&C' || map_GNHName.get(claimDetail.ASI_TnE_Expense_Classification__c) == 'Entertainment for WS & Venue') &&
        claimDetail.ASI_TnE_KR_Where__c == null
      ){
        errorMessages.add(claimDetail.Name + ': Where is mandatory');
      }
      // ASI_TnE_KR_Customer_Validation
      if((map_GNHName.get(claimDetail.ASI_TnE_Expense_Classification__c) == 'External C&C' || map_GNHName.get(claimDetail.ASI_TnE_Expense_Classification__c) == 'Entertainment for WS & Venue') &&
        claimDetail.ASI_TnE_KR_Customer__c == null
      ){
        errorMessages.add(claimDetail.Name + ': Customer is mandatory');
      }
      
            if (claimDetail.ASI_TnE_GnH_Request__c != null){
              Set<ASI_GnH_Request_Recipient__c> recipientSet = requestRecipientMap.get(claimDetail.ASI_TnE_GnH_Request__c);
              
              Decimal tolerance = TnEThreshold[0];
        /* Move out of this IF
              Decimal totalAmt = claimDetail.ASI_TnE_Receipt_Amount__c != null ? claimDetail.ASI_TnE_Receipt_Amount__c : 0;
              Decimal amountPerPax = (claimDetail.ASI_TnE_Total_Number_Pax__c != null & claimDetail.ASI_TnE_Total_Number_Pax__c > 0) ? claimDetail.ASI_TnE_Receipt_Amount__c / claimDetail.ASI_TnE_Total_Number_Pax__c : 0;
              */
        
              ASI_GnH_Request__c selectedGNHRequest = GNHMap.get(claimDetail.ASI_TnE_GnH_Request__r.Name);
              Decimal gnhApprovedAmtTolerance, gnhApprovedAvgTolerance;
              
              if (selectedGNHRequest != null){
                gnhApprovedAmtTolerance = selectedGNHRequest.ASI_GnH_Total_Request_Amount__c * tolerance;
                gnhApprovedAvgTolerance = selectedGNHRequest.ASI_GnH_Amount_per_Recipient__c * tolerance;
              }
              
              
              if (gnhRequestMap.get(claimDetail.ASI_TnE_GnH_Request__c) != null)
                errorMessages.add(claimDetail.Name + ': This GnH form is used in another TnE Claim, Please choose another GnH form to proceed');
              if(claimDetail.ASI_TnE_Receipt_Amount__c > gnhApprovedAmtTolerance)
                errorMessages.add(claimDetail.Name + ': Total Amount exceeded in selected GnH Request');
                if (amountPerPax > gnhApprovedAvgTolerance)
                  errorMessages.add(claimDetail.Name + ': Amount Per Recipient/PAX exceeded in selected GnH Request');
                if(selectedGNHRequest.ASI_GnH_Recipient_Type__c != claimDetail.ASI_TnE_Recipient_Type__c)
                  errorMessages.add(claimDetail.Name + ': Recipient Type does not match with GnH Request');
                if(selectedGNHRequest.ASI_GnH_Type__c != claimDetail.ASI_GnH_Type__c)
                  errorMessages.add(claimDetail.Name + ': GnH Type does not match with GnH Request');
                if (claimDetail.ASI_TnE_Total_Number_Pax__c != recipientSet.size())
                  errorMessages.add(claimDetail.Name + ': Number of recipients should be same as PAX number');
                
                //Check Duplicate Record
                List<String> checkDuplicateRecord = new List<String>();
                if (recipientSet.size() > 0){
                  for (ASI_GnH_Request_Recipient__c recipient : recipientSet){
                    String recordString = recipient.ASI_GnH_Recipient__r.Name + recipient.ASI_GnH_Recipient__r.ASI_GnH_Organization__c + recipient.ASI_GnH_Recipient__r.ASI_GnH_Title__c + recipient.ASI_GnH_Recipient__r.ASI_GnH_Company_Address__c;
                    system.debug('CheckDuplicate: ' + recordString);
                    if (checkDuplicateRecord.contains(recordString))
                      errorMessages.add(claimDetail.Name + ': Duplicated recipient in claim detail - ' + recipient.Name);
                    else 
                      checkDuplicateRecord.add(recordString);
                  }
                }
                
                //Put recipient amount and pax into a map,
                //Key: GnH Form  Value:Receipt Amount, Pax, Number of record
                GnHInfo formInfo = GnHFormInfoMap.get(selectedGNHRequest.Name);
                if (formInfo != null){
                  formInfo.add(claimDetail.ASI_TnE_Receipt_Amount__c, claimDetail.ASI_TnE_Total_Number_Pax__c);
                  GnHFormInfoMap.put(selectedGNHRequest.Name, formInfo);
                } else {
                  GnHFormInfoMap.put(selectedGNHRequest.Name, new GnHInfo(selectedGNHRequest.Name, claimDetail.ASI_TnE_Receipt_Amount__c, claimDetail.ASI_TnE_Total_Number_Pax__c, 1));
                }
            }
    }
    
    if (GnHFormInfoMap.size() > 0){
          for(GnHInfo formInfo : GnHFormInfoMap.values()){
            system.debug('formInfo: ' + formInfo);
            Decimal tolerance = TnEThreshold[0];
            
            ASI_GnH_Request__c selectedGNHRequest = GNHMap.get(formInfo.Name);
            Decimal gnhApprovedAmtTolerance, gnhApprovedAvgTolerance;
            
            system.debug('selectedGNHRequest: ' + selectedGNHRequest);
            
            if (selectedGNHRequest != null){
              gnhApprovedAmtTolerance = selectedGNHRequest.ASI_GnH_Total_Request_Amount__c * tolerance;
              gnhApprovedAvgTolerance = selectedGNHRequest.ASI_GnH_Amount_per_Recipient__c * tolerance;
            
            
              if (formInfo.totalAmount > gnhApprovedAmtTolerance)
                errorMessages.add(formInfo.name + ': Total Receipt Amount of the Claim details are exceeded the approved value in GnH Request');
              else if (formInfo.averageAmt > gnhApprovedAvgTolerance)
                errorMessages.add(formInfo.name + ': Average Receipt Amount of the Claim details are exceeded the approved value in GnH Request');
            } 
          }
        }
        
    return errorMessages;
  }
  
  public static Map<String, ASI_GnH_Request__c> getGnHRequest(){
        List<ASI_GnH_Request__c> gnhRequestList = [SELECT Id, Name, ASI_GnH_Recipient_Type__c, ASI_GnH_Type__c, ASI_GnH_Amount_per_Recipient__c, ASI_GnH_PAX__c, ASI_GnH_Total_Request_Amount__c
                                                   FROM ASI_GnH_Request__c 
                                                   WHERE ASI_GnH_Status__c = 'Approved' 
                                                   AND recordType.DeveloperName IN : GnHRecordType];
        Map<String, ASI_GnH_Request__c> gnhRequestMap = new Map<String, ASI_GnH_Request__c>();
        for (ASI_GnH_Request__c gnhRequest : gnhRequestList){
            gnhRequestMap.put(gnhRequest.Name,gnhRequest);
        }
        
        return gnhRequestMap;
    }
    
    public static Decimal denullify(Decimal d){
      return (d == null ? 0 : d);
    }
    public static Integer denullify(Integer d){
      return (d == null ? 0 : d);
    }
    
  public static Map<string, decimal> getGNHThreshold(){
    Map<string, decimal> map_GNHThreshold = new Map<string, decimal>();
    for(ASI_GnH_Threshold__c t : [
      select 
        ASI_GnH_GnH_Type__c,
        ASI_GnH_Recipient_Type__c,
        ASI_GnH_Threshold_Amount__c 
      from 
        ASI_GnH_Threshold__c 
      where 
        recordType.DeveloperName = 'ASI_GnH_KR_GnH_Offer_Threshold'
        and ASI_GnH_Threshold_Amount__c <> null
    ]){
      string key = t.ASI_GnH_GnH_Type__c + '_' + t.ASI_GnH_Recipient_Type__c;
      if(!map_GNHThreshold.containsKey(key)) map_GNHThreshold.put(key, t.ASI_GnH_Threshold_Amount__c);
    }
    return map_GNHThreshold;
  }
    
  public static Map<string, boolean> getGNHRelated(){
    Map<string, boolean> map_GNHRelated = new Map<string, boolean>();
    for(ASI_JP_TnE_Expense_Classification__c t : [
      SELECT Id, 
        ASI_TnE_GnH__c
        FROM ASI_JP_TnE_Expense_Classification__c 
        WHERE recordType.developerName like 'ASI_TnE_KR%'
    ]){
      string key = t.Id;
      if(!map_GNHRelated.containsKey(key)) map_GNHRelated.put(key, t.ASI_TnE_GnH__c);
    }
    return map_GNHRelated;
  }
    
  public static Map<string, string> getGNHName(){
    Map<string, string> map_GNHName = new Map<string, string>();
    for(ASI_JP_TnE_Expense_Classification__c t : [
      SELECT Id, Name
        FROM ASI_JP_TnE_Expense_Classification__c 
        WHERE recordType.developerName like 'ASI_TnE_KR%'
    ]){
      string key = t.Id;
      if(!map_GNHName.containsKey(key)) map_GNHName.put(key, t.Name);
    }
    return map_GNHName;
  }
}