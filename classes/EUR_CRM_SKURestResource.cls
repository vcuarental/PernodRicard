@RestResource(UrlMapping='/products/*')
global with sharing class EUR_CRM_SKURestResource {

  private static final String RT_MASK = 'EUR_{0}_SKU';
  private static final String CAN_NOT_CREATE_SKU_NO_FOUND_BQS_WITH_EXTERNAL_ID = 'Can not create SKU, no found BQS with External Id: ';

  @HttpPut
  global static void doPut() {
    String skuExtId = getFirstParamFromUri();
    List<EUR_CRM_SKU__c> skus = selectSKUWhereExtId(skuExtId);
    SKUResource skuRes = getSKUResourceFromRequest();

    //If sku not found, create the new one
    if (skus.isEmpty()) {
      String bqsExternalId = getBQSExternalId(skuRes);
      List<EUR_CRM_Size__c> bqss = selectBQSWhereExtId(bqsExternalId);
      if (bqss.isEmpty()) {
        //if no bqs exists
        setResponse(404, CAN_NOT_CREATE_SKU_NO_FOUND_BQS_WITH_EXTERNAL_ID + bqsExternalId);
        return;
      }
      EUR_CRM_SKU__c newSKU = makeSKU(bqss[0].Id, skuRes, skuExtId);
      updateSKUFields(newSKU, skuRes);

      insert newSKU;

      SKUResource newSKUResource = new SKUResource(selectSKUWhereExtId(newSKU.EUR_CRM_External_ID__c)[0]);
      setResponse(200, JSON.serializePretty(newSKUResource));
    } else {
    //if sku was found => update sku
      updateSKUFields(skus[0], skuRes);
      update skus[0];
      List<EUR_CRM_SKU__c> updatedSKU = selectSKUWhereExtId(skuExtId);
      setResponse(200, JSON.serializePretty(new SKUResource(updatedSKU[0])));
    }
  }


  //High level helpers
  private static void updateSKUFields(EUR_CRM_SKU__c sku, SKUResource skuResource) {
    sku.Name = skuResource.TradeItemName;
    sku.EUR_CRM_Article_no__c = skuResource.ExternalID;
    sku.EUR_CRM_SKU_Code__c = skuResource.ExternalID;
    sku.EUR_CRM_EAN_Bottle__c = skuResource.TradeItemGTINBottle;
    sku.EUR_CRM_EAN_Carton__c = skuResource.TradeItemGTINCase;
    if ('Active'.equals(skuResource.Status)) {
      sku.EUR_CRM_Active__c = true;
    } else if ('Inactive'.equals(skuResource.Status)) {
      sku.EUR_CRM_Active__c = false;
    }
    //sku.EUR_CRM_Active__c = String.isBlank(skuResource.Status) ? false : getSKUActive(skuResource.Status);
    sku.EUR_CRM_Unit_Type__c = skuResource.UnitOfMeasure;
    sku.EUR_CRM_Product_Usage__c = skuResource.TradeItemType;
    sku.EUR_CRM_Bottles_per_Case__c = String.isBlank(skuResource.BottlesPerCase) ? null : Decimal.valueOf(skuResource.BottlesPerCase);
    sku.EUR_CRM_Number_of_Bottles__c = String.isBlank(skuResource.BottlesPerCase) ? null : Decimal.valueOf(skuResource.BottlesPerCase);
    sku.EUR_CRM_Cases_per_Pallet__c = String.isBlank(skuResource.CasesPerPallet) ? null : Decimal.valueOf(skuResource.CasesPerPallet);
    sku.EUR_CRM_Cartons_in_Layer__c = String.isBlank(skuResource.CasesPerLayer) ? null : Decimal.valueOf(skuResource.CasesPerLayer);
  }


  //Middle level helpers
  private static SKUResource getSKUResourceFromRequest() {
    return (SKUResource)JSON.deserialize(RestContext.request.requestBody.toString(), SKUResource.class);
  }

  private static String getFirstParamFromUri() {
    return RestContext.request.requestURI.substring(RestContext.request.requestURI.lastIndexOf('/') + 1);
  }

  private static void setResponse(Integer statusCode, String body) {
    RestContext.response.statusCode = statusCode;
    RestContext.response.responseBody = Blob.valueOf(body);
  }


  //Low level helpers
  @TestVisible
  private static String getBQSExternalId(SKUResource sku) {
    //return sku.BrandQualityCode + '_' + Integer.valueOf(sku.BottleSize);
    return sku.BrandQualityCode + '_' + sku.BottleSize;      
  }

  private static String getSKURtDevName(String countryCode) {
    return String.format(RT_MASK, new List<String>{countryCode});
  }

  private static Boolean getSKUActive(String status) {
    //return status.equalsIgnoreCase('Active');
    // return status.equalsIgnoreCase('1');
    return true;      
  }


  //Makers
  private static EUR_CRM_SKU__c makeSKU(Id bqsId, SKUResource skuRes, String skuExtId) {
    String skuRtDevName = getSKURtDevName(skuRes.Affiliate);
    Id rtId = SObjectType.EUR_CRM_SKU__c.getRecordTypeInfosByDeveloperName().get(skuRtDevName).getRecordTypeId();
    return new EUR_CRM_SKU__c(
        RecordTypeId = rtId
    ,   EUR_CRM_Brand_Quality_Size__c = bqsId
    ,   EUR_CRM_External_ID__c = skuExtId
    ,   EUR_CRM_Active__c = true
    );
  }


  //Selectors
  private static List<EUR_CRM_SKU__c> selectSKUWhereExtId(String extId) {
    return [
      SELECT Id
      ,   Name
      ,   EUR_CRM_SKU_Code__c
      ,   EUR_CRM_EAN_Bottle__c
      ,   EUR_CRM_EAN_Carton__c
      ,   EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_External_ID__c
      ,   EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Bottle_Size__c
      ,   EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Bottle_Size_cl__c
      ,   EUR_CRM_Brand_Quality_Size__c
      ,   EUR_CRM_Bottle_Size_Litre__c
      ,   EUR_CRM_Active__c
      ,   EUR_CRM_Unit_Type__c
      ,   EUR_CRM_Bottles_per_Case__c
      ,   EUR_CRM_Cases_per_Pallet__c
      ,   EUR_CRM_Cartons_in_Layer__c
      ,   RecordType.DeveloperName
      ,   EUR_CRM_Product_Usage__c
      ,   EUR_CRM_External_ID__c
      FROM EUR_CRM_SKU__c
      WHERE EUR_CRM_External_ID__c = :extId
    ];
  }

  private static List<EUR_CRM_Size__c> selectBQSWhereExtId(String extId) {
    return [
      SELECT Id
      FROM EUR_CRM_Size__c
      WHERE EUR_CRM_External_ID__c =:extId
    ];
  }


  //Inner class
  public class SKUResource {
    public String Id;
    public String Affiliate;
    public String TradeItemName;
    public String ExternalID;
    public String TradeItemGTINBottle;
    public String TradeItemGTINCase;
    public String BrandQualityCode;
    public String BottleSize;
    public String Status;
    public String UnitOfMeasure;
    public String TradeItemType;
    public String BottlesPerCase;
    public String CasesPerPallet;
    public String CasesPerLayer;

    public SKUResource () {}
    public SKUResource (EUR_CRM_SKU__c sku) {
      this.Id = sku.Id;
      this.Affiliate = getAffiliate(sku.RecordType.DeveloperName);
      this.BrandQualityCode = sku.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_External_ID__c;
      this.BottleSize = this.getValueOrSetEmpty(sku.EUR_CRM_Bottle_Size_Litre__c);
//      this.BottleSize = this.getValueOrSetEmpty(sku.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Bottle_Size_cl__c);
      this.BottlesPerCase = this.getValueOrSetEmpty(sku.EUR_CRM_Bottles_per_Case__c);
      this.CasesPerPallet = this.getValueOrSetEmpty(sku.EUR_CRM_Cases_per_Pallet__c);
      this.CasesPerLayer = this.getValueOrSetEmpty(sku.EUR_CRM_Cartons_in_Layer__c);
      this.TradeItemName = sku.Name;
      this.Status = this.getValueOrSetEmpty(sku.EUR_CRM_Active__c) == 'true' ? 'Active' : 'Inactive';
      this.ExternalID = sku.EUR_CRM_SKU_Code__c;
      this.TradeItemType = sku.EUR_CRM_Product_Usage__c;
      this.TradeItemGTINBottle = sku.EUR_CRM_EAN_Bottle__c;
      this.TradeItemGTINCase = sku.EUR_CRM_EAN_Carton__c;
      this.UnitOfMeasure = sku.EUR_CRM_Unit_Type__c;
    }

    private String getAffiliate(String rtDevName) {
      return rtDevName.substringBetween('EUR_', '_SKU');
    }

    private String getValueOrSetEmpty(Object obj) {
      return obj == null ? '' : String.valueOf(obj);
    }
  }
}