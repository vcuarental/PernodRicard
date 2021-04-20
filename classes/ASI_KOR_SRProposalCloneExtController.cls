public class ASI_KOR_SRProposalCloneExtController{

public  ASI_KOR_SR_Proposal_Header__c srProposalHeader {get; set;}
public  List<ASI_KOR_SR_Proposal_Detail__c> proposalDetails {get;set;}
public  ASI_KOR_SR_Proposal_Header__c  prevSrProposalHeader {get; set; }
private Map<String,Id> bmProposalByBrandMap = new Map<String,Id>();
private Map<String,Id> srProposalByBrandMap = new Map<String,Id>();

public ASI_KOR_SRProposalCloneExtController(ApexPages.StandardController stdController){
    
    //get the sr header id
    Id srProposalHeaderId = (id) stdController.getRecord().id;
    //
    srProposalHeader = [select id, name,Owner.Name, ownerId,CurrencyIsoCode,ASI_KOR_BM_Proposal_Header__c,ASI_KOR_Delegated_Approver__c,
    ASI_KOR_Month__c,
    ASI_KOR_Status__c,
    ASI_KOR_Year__c from ASI_KOR_SR_Proposal_Header__c
    where
    id =:srProposalHeaderId
    ];
    Date srStartDate = Date.newInstance(Integer.valueOf(srProposalHeader.ASI_KOR_Year__c), Integer.valueOf(srProposalHeader.ASI_KOR_Month__c), 1);
    Date srLastDate = srStartDate.addMonths(-1);
    String month = String.valueOf(srLastDate.month());
    String year = String.valueOf(srLastDate.year());
    prevSrProposalHeader = [select id, name,ASI_KOR_BM_Proposal_Header__c,
    ASI_KOR_Month__c,
    ASI_KOR_Status__c,
    ASI_KOR_Year__c from ASI_KOR_SR_Proposal_Header__c
    where 
    id <> :srProposalHeaderId
    and
    ownerId =: srProposalHeader.ownerId
    order by createdDate DESC limit 1
    ];
    
    Date startDate = Date.newInstance(Integer.valueOf(srProposalHeader.ASI_KOR_Year__c), Integer.valueOf(srProposalHeader.ASI_KOR_Month__c), 1);
    Date endDate = startDate.addMonths(1);
   // Map<Id,Account > venues = new Map<Id,Account>([select id, Name from Account where ownerId =: ownerId]); 
    String ownerBranch = ([select  id,Name, asi_kor_user_branch_code__c,ASI_KOR_User_Branch_Name__c from User where id =: srProposalHeader.ownerId]).asi_kor_user_branch_code__c;
    Set<String> contractSet = new Set<String>();
    Set<String> gradeSet = new Set<String>();
    system.debug('owner branch code: ' + ownerBranch + startDate + '    ' + endDate);
    AggregateResult[] icList = [select ASI_KOR_Contract__c contract, ASI_KOR_Grade__c grade from ASI_KOR_Incentive_Scheme__c 
    where ASI_KOR_BRANCH_CODE__C =:ownerBranch
        and
    ASI_KOR_Effective_Start_Date__c <= :startDate 
    and ASI_KOR_Effective_End_Date__c >= :endDate 
    group by ASI_KOR_Contract__c, ASI_KOR_Grade__c    
    ];
        
    for(AggregateResult ic: icList){
    contractSet.add((String)ic.get('contract'));
    gradeSet.add((String)ic.get('grade'));
    }
    
    Map<Id,Account> venues =  new Map<Id,Account>([select id from Account 
        where 
        ownerId =: srProposalHeader.ownerId 
        and RecordTypeId in (select id from RecordType  where DeveloperName = 'ASI_KOR_Venue' and SobjectType ='Account')
        and ASI_KOR_Contract_Type__c in: contractSet
        and ASI_KOR_Grade__c in: gradeSet]);
    system.debug('venue size' + venues.size());
    proposalDetails = 
    [select id,name,ASI_KOR_Brand__c,
    ASI_KOR_SR_Proposal_By_Brand__c ,
    ASI_KOR_Cap_Unit_Cost_Basic__c ,
    ASI_KOR_Cap_Total_Basic_CA__c,ASI_KOR_Cap_Unit_Cost_CA__c,
    ASI_KOR_Incentive_Scheme__c,ASI_KOR_Last_3_month_Actual_average_UC__c,
    ASI_KOR_Last_3_month_Actual_Average_Volu__c,ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,ASI_KOR_UOM__c,
    ASI_KOR_Business_Rationale__c,
    ASI_KOR_Target_Volume__c,ASI_KOR_Venue__c from ASI_KOR_SR_Proposal_Detail__c
     where  
     ASI_KOR_SR_Proposal_ID__c =:prevSrProposalHeader.id 
     and ASI_KOR_Venue__c in:venues.keySet()
     ]; //and ASI_KOR_Venue__c in : venues.keySet()];
    
    List<ASI_KOR_BM_Proposal_By_Brand__c> bmProposalByBrands= [select id,ASI_KOR_UOM__c,ASI_KOR_Brand__c
    from ASI_KOR_BM_Proposal_By_Brand__c 
    where ASI_KOR_BM_Proposal_Header__c =:srProposalHeader.ASI_KOR_BM_Proposal_Header__c];
    
    for(ASI_KOR_BM_Proposal_By_Brand__c bmProposalByBrand : bmProposalByBrands){
        bmProposalByBrandMap.put(bmProposalByBrand.ASI_KOR_Brand__c+bmProposalByBrand.ASI_KOR_UOM__c+'',bmProposalByBrand.id);
    }
      
}

public PageReference save(){

    try{
        List<ASI_KOR_SR_Proposal_Detail__c> clonedProposalDetails = new List<ASI_KOR_SR_Proposal_Detail__c>();
        
        for(ASI_KOR_SR_Proposal_Detail__c detail: proposalDetails ){
            ASI_KOR_SR_Proposal_Detail__c temp = detail.clone();
            temp.ASI_KOR_SR_Proposal_ID__c = srProposalHeader.id;
            temp.ASI_KOR_SR_Proposal_By_Brand__c = generateSRProposalByBrand(temp.ASI_KOR_Brand__c,temp.ASI_KOR_UOM__c);
            clonedProposalDetails.add(temp);
        }    
        insert clonedProposalDetails ;
    }
     catch ( DmlException exc) {
     ApexPages.addMessages(exc);
                  return null;
    }
    return new PageReference('/'+srProposalHeader.id);
}

private Id generateSRProposalByBrand(Id brandId,String uom){

    Id srProposalByBrandId = srProposalByBrandMap.get(brandId+uom);
    if(srProposalByBrandId  == null){
        ASI_KOR_SR_Proposal_By_Brand__c srProposalByBrand = new ASI_KOR_SR_Proposal_By_Brand__c();
        srProposalByBrand.ASI_KOR_BM_Proposal_By_Brand__c =  bmProposalByBrandMap.get(brandId+uom);
        srProposalByBrand.ASI_KOR_Brand__c = brandId;
        srProposalByBrand.ASI_KOR_SR_Proposal_Header__c = srProposalHeader.id;
        srProposalByBrand.ASI_KOR_UOM__c = uom;
        
        try{
            insert srProposalByBrand ;
        } catch ( DmlException exc) {
            system.debug('XXXX error here:'+exc);
            ApexPages.addMessages(exc);
                      return null;
        } 
        srProposalByBrandId = srProposalByBrand.Id;
        srProposalByBrandMap.put(brandId+uom,srProposalByBrand.Id);
    }
    return srProposalByBrandId;
}

}