global class ASI_CRM_sf1_AddPhoto {
    public ASI_CRM_sf1_AddPhoto(ApexPages.StandardController controller) { }
 
    @RemoteAction
    global static ASI_CRM_sf1Result submitData(sf1Data data) {
        ID recordID;
    
        try {
            System.debug('Data Received');
            System.debug(data);
            if (data == null) {
               // throw new sf1Exception('No data received!');
            } else if ((data.sImage == null) || (data.sImage.length() == 0)) {
               //  throw new sf1Exception('Empty file received!');
            } else {
                // Good data received.
                String b64;
                String dataType;
                Attachment att;
                
                // Get Data
                List<String> docParts = data.sImage.split(',');
                String metadata = docParts[0];
                system.debug('metadata: ' + metadata); 
                b64 = docParts[1];
                system.debug('b64: ' + b64);              
                List<String> metadataParts = metadata.split(';');
                system.debug('metadataParts: ' + metadataParts);  
                dataType = metadataParts[0].split(':')[1]; 
                         
                data.bImage = EncodingUtil.base64Decode(b64);
            
                // Attach file
                att = new Attachment();
                att.Body = data.bImage;
                att.ContentType = data.contentType;
                att.Name = data.name;
                att.ParentId = data.ParentId;
                Insert att;
                recordID = att.id;
            }        
            System.debug('Data Processed');
        } catch (Exception ex) {
            System.debug('Exception ex: ' + ex);
            return new ASI_CRM_sf1Result(ex);
        }
        return new ASI_CRM_sf1Result(recordID); 
    }
    
    global class sf1Data {
        public Blob bImage { get; set; }
 
        global String ParentId { get; set; }
        global String name { get; set; }
        global String sImage { get; set; }
        global String contentType { get; set; }
        global Integer bodyLength { get; set; }
    }
}