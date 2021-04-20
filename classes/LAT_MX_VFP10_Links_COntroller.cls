public with sharing class LAT_MX_VFP10_Links_COntroller {

  public Boolean isMXN  {get; set;}
  public Boolean isBRL  {get; set;}
  public Boolean isMigratedMXN {get; set;}

	public LAT_MX_VFP10_Links_COntroller() {
		if (UserInfo.getDefaultCurrency() == 'MXN') {
      this.isMXN = true;
    } else {
      this.isMXN = false;
    }
    if (UserInfo.getDefaultCurrency() == 'BRL') {
      this.isBRL = true;
    } else {
      this.isBRL = false;
    }

    if(Utils.wasMigrationDone('12')) { 
      this.isMigratedMXN = true;
      System.debug('%%%%%%%%%%%  isMigratedMXN : '+ isMigratedMXN);
    } else {
      this.isMigratedMXN = false;
      System.debug('%%%%%%%%%%%  isMigratedMXN : '+ isMigratedMXN);
    }

  }
}