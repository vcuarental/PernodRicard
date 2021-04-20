@isTest
private class ASI_KOR_PaymentSettlementTestHelper
{

private Id generateSRProposalByBrand(Id srPaymentSettlementId, Id brandId,String uom){

Id bmHeaderId = null;
Map<String,ASI_KOR_SR_Proposal_By_Brand__c> srProposalByBrandMap = new Map<String,ASI_KOR_SR_Proposal_By_Brand__c>();
if(srProposalByBrandMap.get(brandId+uom) == null){
    ASI_KOR_SR_Proposal_By_Brand__c srProposalByBrand = new ASI_KOR_SR_Proposal_By_Brand__c();
    srProposalByBrand.ASI_KOR_BM_Proposal_By_Brand__c = generateBMProposalByBrand(bmHeaderId,brandId,uom);
    srProposalByBrand.ASI_KOR_Brand__c = brandId;
    srProposalByBrand.ASI_KOR_SR_Proposal_Header__c = srPaymentSettlementId;
    srProposalByBrand.ASI_KOR_UOM__c = uom;
    try{
    insert srProposalByBrand;
    } catch ( DmlException exc) {
     ApexPages.addMessages(exc);
                  return null;
    } 
    srProposalByBrandMap.put(srProposalByBrand.ASI_KOR_Brand__c+uom,srProposalByBrand);
}
return srProposalByBrandMap.get(brandId+uom).id;
}

private Id  generateBMProposalByBrand(Id bmHeaderId, Id brandId, String uom){
Map<String,Id> bmProposalByBrandMap = new Map<String,Id>();
if(bmProposalByBrandMap == null){
List<ASI_KOR_BM_Proposal_By_Brand__c> bmbrands = [select ASI_KOR_Brand__c, ASI_KOR_UOM__c,id from ASI_KOR_BM_Proposal_By_Brand__c
where ASI_KOR_BM_Proposal_Header__c =: bmHeaderId];
for(ASI_KOR_BM_Proposal_By_Brand__c x: bmbrands){
bmProposalByBrandMap.put(x.ASI_KOR_Brand__c+x.ASI_KOR_UOM__c,x.id);
}
}
Id bmProposalByBrandId = bmProposalByBrandMap.get(brandId+uom);
if(bmProposalByBrandId == null){
    ASI_KOR_BM_Proposal_By_Brand__c bmProposalByBrand = new ASI_KOR_BM_Proposal_By_Brand__c();
    bmProposalByBrand.ASI_KOR_RSD_Proposal_By_Brand__c = generateRSDProposalByBrand(bmProposalByBrandId,brandId);
    bmProposalByBrand.ASI_KOR_BM_Proposal_Header__c = bmHeaderId;
    bmProposalByBrand.ASI_KOR_Brand__c = brandId;
    bmProposalByBrand.ASI_KOR_UOM__c = uom;
   // bmProposalByBrand.ASI_KOR_CA_Budget__c = brandBudget.get(brandId);
    try{
    insert bmProposalByBrand;
    } catch ( DmlException exc) {
     ApexPages.addMessages(exc);
                  return null;
    } 
    bmProposalByBrandId = bmProposalByBrand.id;
    bmProposalByBrandMap.put(brandId+uom,bmProposalByBrandId);
    
}
return bmProposalByBrandId;
}

private Id  generateRSDProposalByBrand(Id bmHeaderId, Id brandId){
    
    Id rsdHeader = null;
    
    if(rsdHeader == null){
        ASI_KOR_BM_Proposal_Header__c bmProposalHeader  = [select ASI_KOR_RSD_Proposal_Header__c 
        from ASI_KOR_BM_Proposal_Header__c where id =:bmHeaderId limit 1 ];
        rsdHeader = bmProposalHeader.ASI_KOR_RSD_Proposal_Header__c;    
    }
    
   Map<String,Id> rsdProposalByBrandMap = new Map<String,Id>();
    
    if(rsdProposalByBrandMap == null){

        List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdBrands = [select ASI_KOR_Brand__c, id from ASI_KOR_RSD_Proposal_By_Brand__c
        where ASI_KOR_RSD_Proposal_Header__c =:rsdHeader];
        for(ASI_KOR_RSD_Proposal_By_Brand__c x: rsdBrands){
            rsdProposalByBrandMap.put(x.ASI_KOR_Brand__c,x.id);
        }
    }
    Id rsdProposalByBrandId = rsdProposalByBrandMap.get(brandId);
    if(rsdProposalByBrandId == null){
        ASI_KOR_RSD_Proposal_By_Brand__c rsdProposalByBrand = new ASI_KOR_RSD_Proposal_By_Brand__c();
        rsdProposalByBrand.ASI_KOR_NSD_Proposal_By_Brand__c = generateNSDProposalByBrand(rsdProposalByBrandId,brandId);
        rsdProposalByBrand.ASI_KOR_RSD_Proposal_Header__c = rsdHeader;
        rsdProposalByBrand.ASI_KOR_Brand__c = brandId;
        //rsdProposalByBrand.ASI_KOR_UOM__c = uom;
        try{
        insert rsdProposalByBrand;
        } catch ( DmlException exc) {
         ApexPages.addMessages(exc);
                      return null;
        } 
    rsdProposalByBrandId = rsdProposalByBrand.id;
    rsdProposalByBrandMap.put(brandId,rsdProposalByBrandId );
    }
return rsdProposalByBrandId ;
}
private Id  generateNSDProposalByBrand(Id rsdHeaderId,Id brandId){
    Id nsdHeader = null;
    
    if(nsdHeader == null){
        ASI_KOR_RSD_Proposal_Header__c rsdProposalHeader = [select ASI_KOR_NSD_Proposal_Header__c from
        ASI_KOR_RSD_Proposal_Header__c where id =:rsdHeaderId limit 1 ];
        nsdHeader = rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c;
    }
    
    Map<String,Id> nsdProposalByBrandMap = new Map<String,Id>();

    if(nsdProposalByBrandMap == null){
    
    List<ASI_KOR_NSD_Proposal_By_Brand__c> nsdBrands = [select ASI_KOR_Brand__c, id from ASI_KOR_NSD_Proposal_By_Brand__c
    where ASI_KOR_NSD_Proposal_Header__c =:nsdHeader];
    
    for(ASI_KOR_NSD_Proposal_By_Brand__c x: nsdBrands ){
        nsdProposalByBrandMap.put(x.ASI_KOR_Brand__c,x.id);
        }
    }
    Id nsdProposalByBrandId = nsdProposalByBrandMap.get(brandId);
    if(nsdProposalByBrandId == null){
        ASI_KOR_NSD_Proposal_By_Brand__c nsdProposalByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c ();
        nsdProposalByBrand.ASI_KOR_NSD_Proposal_Header__c = nsdHeader;
        nsdProposalByBrand.ASI_KOR_Brand__c = brandId;
        //nsdProposalByBrand.ASI_KOR_UOM__c = uom;
        try{
        insert nsdProposalByBrand;
        } catch ( DmlException exc) {
         ApexPages.addMessages(exc);
                      return null;
        } 
        nsdProposalByBrandId = nsdProposalByBrand.id;
        nsdProposalByBrandMap.put(brandId,nsdProposalByBrandId);
        
    }
return nsdProposalByBrandId ;
}




}