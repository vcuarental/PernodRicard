public with sharing class LAT_B2B_PIMIntegration {

    public List <LAT_Product__c> getProducts() {
        List <LAT_Product__c> ret = [SELECT Id, LAT_EAN__c, LAT_B2B_Alcohol_Level__c, LAT_B2B_Brand__c, LAT_B2B_Brand_Quality__c, LAT_B2B_Country__c, LAT_B2B_Description__c,
                                        LAT_B2B_Ingredients__c, LAT_B2B_Manufacturer_Details__c, LAT_B2B_Packaging_Details__c, LAT_B2B_Product_History__c, LAT_B2B_Product_Name__c,
                                        LAT_B2B_Quality__c, LAT_B2B_Size_Label__c, LAT_B2B_Size_Value__c, LAT_B2B_Image_URL__c, LAT_B2B_Thumbnail_URL__c, LAT_SKU__c
                                    FROM LAT_Product__c WHERE LAT_IsActive__c = true 
                                    AND RecordType.Name = 'Standard AR' AND LAT_Country__c  = 6 AND LAT_EAN__c != '' ORDER BY LAT_EAN__c];
        return ret;
    }

    public void makePIMCallout (List <Lat_Product__c> products) {
        List<LAT_Product__c> processed = new List<Lat_Product__c>();
        List<LAT_Product__c> toProcess = new List<Lat_Product__c>();
        Map<String, List<Lat_Product__c>> toReturn = new Map<String, List<Lat_Product__c>>();
        if(products.size()> 20){
            for(LAT_Product__c p : products){
                    toProcess.add(p);
                    if(toProcess.size() == 20){
                        makePIMCalloutBatch (toProcess, toReturn, products); 
                        toProcess = new List<Lat_Product__c>();
                    }
            }
            if(toProcess.size() > 0){
                makePIMCalloutBatch (toProcess, toReturn, products);
            }
        } else {
            makePIMCalloutBatch (products, toReturn, products);
        }

        if(toReturn.size()>0){
            for(List<LAT_Product__c> toUpdate : toReturn.values()){
                processed.addAll(toUpdate); 
            }
            update processed;
        }
    }   

    public void makePIMCalloutBatch (List <Lat_Product__c> products, Map<String, List<Lat_Product__c>> toReturn, List <Lat_Product__c> allProducts) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        final String url = 'https://api.pernod-ricard.io/v2/product?locale=es_AR';
        Set<String> eans = new Set<String>();
        for(LAT_Product__c p : products) {
            eans.add(p.LAT_EAN__c);
        } 
        final String productEANs = this.getProductEANList(eans);
        final String pimEndpoint = url + productEANs;
        final Map <String, List<Lat_Product__c>> productsByEAN = this.getProductsByEANMap (allProducts);
        
        System.debug(pimEndpoint);

        request.setEndpoint(pimEndpoint);
        request.setMethod('GET');
        request.setHeader('api_key', 'uqsf7q8fhyuhsxpnea3rqehk');

        HttpResponse response = http.send(request);

        System.debug(response.getStatusCode());
        System.debug(response);

        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map <String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // System.debug(results);
            List<Object> parsedProducts = (List<Object>) results.get('hits');
            
            for (Object p : parsedProducts) {
                Map<String, Object> pp = (Map<String, Object>) p;
                List<Object> gtincodes = (List<Object>)pp.get('gtinCodeList');
                Map<String, Object> gtinCode = (Map<String, Object>) gtincodes.get(0);
                String gtin = gtinCode.get('gtinCode').toString();
                System.debug('%%%% nombre prod : ' + String.valueOf(pp.get('productName')) + 'gtin : ' + gtin );

                // System.debug(gtin);
                // System.debug(productsByEAN);

                if (productsByEAN.containsKey(gtin)) {
                    for(LAT_Product__c latP : productsByEAN.get(gtin)) {
                        Map<String, Object> brand = (Map<String, Object>) pp.get('brand');
                        Map<String, Object> brandQuality = (Map<String, Object>) pp.get('brandQuality');
                        Map<String, Object> packshot = (Map<String, Object>) pp.get('packshot');
                        List<Object> mediaList = (List<Object>) pp.get('mediaList');
                        Map<String, Object> size = (Map<String, Object>) pp.get('size');
                        final String alcoholLevel = String.valueOf(pp.get('alcoholLevel'));
                        System.debug('alcoholLevel: ' + alcoholLevel);
                        final String brandString = (brand != null) ? brand.get('label').toString() : null;
                        System.debug('brandString: ' + brandString);
                        final String brandQualityString = (brandQuality != null) ? brandQuality.get('label').toString() : null;
                        System.debug('brandQualityString: ' + brandQualityString);
                        final String country = pp.get('countryOfOrigin').toString();
                        System.debug('country: ' + country);
                        final String description = String.valueOf(pp.get('description'));
                        System.debug('description: ' + description);
                        final String ingredientList = String.valueOf(pp.get('ingredientList'));
                        System.debug('ingredientList: ' + ingredientList);
                        final String manDetails = String.valueOf(pp.get('manufacturerDetails'));
                        System.debug('manDetails: ' + manDetails);
                        final String packagingDetails = String.valueOf(pp.get('packagingDetails'));
                        System.debug('packagingDetails: ' + packagingDetails);
                        final String productHistory = String.valueOf(pp.get('productHistory'));
                        System.debug('productHistory: ' + productHistory);
                        final String productName = String.valueOf(pp.get('productName'));
                        System.debug('productName: ' + productName);
                        final String quality = String.valueOf(pp.get('quality'));
                        System.debug('quality: ' + quality);
                        final String sizeLabel = (size != null) ? size.get('label').toString() : null;
                        System.debug('sizeLabel: ' + sizeLabel);
                        final String sizeValue = (size != null) ? String.valueOf(size.get('value')) : null;
                        System.debug('sizeValue: ' + sizeValue);
                        String imgUrl = null;
                        String thumbNail = null;
                        if (packshot != null) {
                            Map<String, Object> imgUrls = (Map<String, Object>) packshot.get('urls');
                            imgUrl = (imgUrls != null) ? imgUrls.get('original').toString() : null;
                            System.debug('imgUrl: ' + imgUrl);
                            thumbNail = (imgUrls != null) ? imgUrls.get('thumbnail').toString() : null;
                            System.debug('thumbNail: ' + thumbNail);
                        } else {
                            if (mediaList != null) {
                                if(mediaList.size() > 0){
                                    System.debug('%%%% mediaList : ' + mediaList);
                                    Map<String, Object> imgUrlsItem = (Map<String, Object>) mediaList[0];
                                    Map<String, Object> imgUrls = (Map<String, Object>) imgUrlsItem.get('urls');
                                    if(imgUrls != null){
                                        if(imgUrls.get('original') != null){
                                            imgUrl = imgUrls.get('original').toString();
                                            System.debug('imgUrl: ' + imgUrl);
                                        }
                                        if(imgUrls.get('thumbnail') != null) {
                                            thumbNail = imgUrls.get('thumbnail').toString();
                                            System.debug('thumbNail: ' + thumbNail);
                                        }
                                    }
                                }
                                
                            }
                        }

                        latP.LAT_B2B_Alcohol_Level__c = alcoholLevel;
                        latP.LAT_B2B_Brand__c = brandString;
                        latP.LAT_B2B_Brand_Quality__c = brandQualityString;
                        latP.LAT_B2B_Country__c = country;
                        latP.LAT_B2B_Description__c = description;
                        latP.LAT_B2B_Ingredients__c = ingredientList;
                        latP.LAT_B2B_Manufacturer_Details__c = manDetails;
                        latP.LAT_B2B_Packaging_Details__c = packagingDetails;
                        latP.LAT_B2B_Product_History__c = productHistory;
                        latP.LAT_B2B_Product_Name__c = productName;
                        latP.LAT_B2B_Quality__c = quality;
                        latP.LAT_B2B_Size_Label__c = sizeLabel;
                        latP.LAT_B2B_Size_Value__c = sizeValue;
                        latP.LAT_B2B_Image_URL__c = imgUrl;
                        latP.LAT_B2B_Thumbnail_URL__c = thumbNail;
                    }
                    toReturn.put(gtin ,productsByEAN.get(gtin));
                }
            }
        }
        
    }

    private Map <String, List<Lat_Product__c>> getProductsByEANMap (List <Lat_Product__c> products) {
        Map <String, List<Lat_Product__c>> ret = new Map <String, List<Lat_Product__c>>();
        for (Lat_Product__c p : products) {
            if(ret.get(p.LAT_EAN__c)==null) ret.put(p.LAT_EAN__c, new List<Lat_Product__c>());
            ret.get(p.LAT_EAN__c).add(p);
        }
        return ret;
    }

    private String getProductEANList (Set<String> products) {
        String ret = '&gtinCode=';
        for (String gtin : products) {     
            ret += gtin + ',';
        }
        if (ret.endsWith(',')) {
            ret = ret.removeEnd(',');
        }
        return ret;
    }
}