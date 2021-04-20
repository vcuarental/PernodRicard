global class LAT_CallOutMockTest implements WebServiceMock{
  public static Integer RESULT_CODE_OK = 200;
  public static Integer RESULT_CODE_ERROR = 400;

  private Integer ResultCode { get; set; }

  global LAT_CallOutMockTest() {
    this.ResultCode = RESULT_CODE_OK;
  }

  global LAT_CallOutMockTest(Integer intResultCode) {    
      this.ResultCode = intResultCode;    
  }

	global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
          
          LAT_GetStockTypes.GetStockResponse_element respElement = null; 
       	  String s = null;
       	  Map<String,LAT_GetStockTypes.GetStockResponse_element> res = null;
          
          respElement = new LAT_GetStockTypes.GetStockResponse_element(); 
       	  s = '';
       	  res = new  Map<String,LAT_GetStockTypes.GetStockResponse_element>();
       		if(this.ResultCode == RESULT_CODE_OK) {
            res.put(s,respElement);
          } else if(this.ResultCode == RESULT_CODE_ERROR) {
            res.put(s, null);
          }
       response.put('response_x', res); 
   }
}