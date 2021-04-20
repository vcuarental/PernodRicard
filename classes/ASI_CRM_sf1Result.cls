global class ASI_CRM_sf1Result {
    public Boolean isSuccess { get; set; }
    public String message { get; set; }
    public String recordID { get; set; }
    
    public ASI_CRM_sf1Result(Exception ex) {
        isSuccess = false;
        message = 'Apex Exception: ' + ex.getStackTraceString() + ' : ' + ex.getMessage();
    }
 
    public ASI_CRM_sf1Result(ID recordID) {
        isSuccess = true;
        message = 'Apex completed succesfully';     
        this.recordID = recordID;   
    }
    
    private ASI_CRM_sf1Result() {}
}